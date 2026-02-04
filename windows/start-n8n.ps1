$ErrorActionPreference = "Stop"

Write-Host "Launching cloudflared..." -ForegroundColor Cyan

# --- Start cloudflared ---
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cloudflared"
$psi.Arguments = "tunnel --url http://localhost:5678"
$psi.UseShellExecute = $false
$psi.RedirectStandardError = $true
$psi.RedirectStandardOutput = $true
$psi.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi
$process.Start() | Out-Null

Write-Host "cloudflared PID:" $process.Id

# --- Detect tunnel URL (from STDERR) ---
$webhookUrl = $null
while (-not $process.HasExited) {
    $line = $process.StandardError.ReadLine()
    if ($line -and $line -match 'https://[a-zA-Z0-9\-]+\.trycloudflare\.com') {
        $webhookUrl = $matches[0]
        break
    }
}

if (-not $webhookUrl) {
    throw "Cloudflare tunnel URL not detected."
}

$env:WEBHOOK_URL = $webhookUrl
Write-Host "WEBHOOK_URL set to $webhookUrl" -ForegroundColor Green

# --- Force predictable n8n binding ---
$env:N8N_HOST = "localhost"
$env:N8N_PORT = "5678"
$env:N8N_PROTOCOL = "http"

# --- Start n8n (npm global shim-safe) ---
Write-Host "Starting n8n..."

$n8nPath = (Get-Command n8n.cmd -ErrorAction Stop).Source
Start-Process -FilePath $n8nPath -NoNewWindow

# --- Wait until n8n responds ---
Write-Host "Waiting for n8n to be ready..."

$timeout = 30
$ready = $false

for ($i = 0; $i -lt $timeout; $i++) {
    try {
        Invoke-WebRequest "http://localhost:5678" -UseBasicParsing -TimeoutSec 2 | Out-Null
        $ready = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}

if (-not $ready) {
    throw "n8n did not become ready within $timeout seconds."
}

# --- Open browser ---
Start-Process "http://localhost:5678"

Write-Host "n8n is ready. Tunnel active."
Write-Host "Press Ctrl+C to stop."

# Keep tunnel alive
Wait-Process -Id $process.Id
