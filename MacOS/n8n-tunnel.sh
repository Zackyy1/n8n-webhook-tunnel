#!/bin/bash
set -e

# Ensure this script runs in its own process group
if [[ $$ -ne $(ps -o pgid= $$ | tr -d ' ') ]]; then
  exec setsid "$0" "$@"
fi

PGID=$(ps -o pgid= $$ | tr -d ' ')

FIFO="$(mktemp -u)"
mkfifo "$FIFO"

cleanup() {
  echo
  echo "Shutting down (killing process group $PGID)..."
  kill -TERM -"$PGID" 2>/dev/null || true
  rm -f "$FIFO"
  exit 0
}

trap cleanup INT TERM EXIT

echo "Starting Cloudflare tunnel..."

cloudflared tunnel --url http://localhost:5678 2> "$FIFO" &
CLOUDFLARED_PID=$!

WEBHOOK_URL=""

# --- Wait for tunnel URL ---
while IFS= read -r line; do
  echo "$line"

  if [[ "$line" =~ https://[a-zA-Z0-9-]+\.trycloudflare\.com ]]; then
    WEBHOOK_URL="${BASH_REMATCH[0]}"
    export WEBHOOK_URL
    export N8N_WEBHOOK_URL="$WEBHOOK_URL"
    export N8N_EDITOR_BASE_URL="$WEBHOOK_URL"
    echo "WEBHOOK_URL set to $WEBHOOK_URL"
    break
  fi
done < "$FIFO"

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "Failed to detect Cloudflare tunnel URL" >&2
  cleanup
fi

# Ensure no old n8n survives
pkill -f n8n || true

export N8N_HOST=localhost
export N8N_PORT=5678
export N8N_PROTOCOL=http

echo "Starting n8n..."

n8n &
N8N_PID=$!

# --- Wait for n8n readiness ---
echo "Waiting for n8n to be ready..."
for _ in {1..45}; do
  if curl -fs http://localhost:5678 >/dev/null 2>&1; then
    open http://localhost:5678
    echo "n8n is ready. Tunnel active."
    break
  fi
  sleep 1
done

# --- Block terminal on n8n ---
wait "$N8N_PID"
