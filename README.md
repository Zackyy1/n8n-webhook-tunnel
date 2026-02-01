# Start n8n with Telegram-ready Cloudflare HTTPS tunnel

**Only works with npm, locally hosted instance of n8n on Windows**

## Install cloudflared
`winget install Cloudflare.cloudflared`

## Why

Telegram requires HTTPS to accept and receive messages to and from bots. This tunneling provides a compliant way to make Telegram (and maybe other similar modules) work in your locally hosted n8n.

## Getting started

Start the script using PowerShell or executable file.
n8n instance will be loaded with `cloudflared` WEBHOOK_URL already set and ready to be used as the tunnel. 

Terminal window will be open with n8n logs.

## Check if it works

- Insert a Telegram Callback Data Trigger in n8n.
- Inside, open the top most dropdown saying "Webhook URLs"
- URL must match the one provided by `cloudflared`.

## Alternative

This script is meant to save time, but it's basically the equivalent of doing the following:

```
> cloudflared tunnel --url http://localhost:5678/
> $env:WEBHOOK_URL="https://your-tunnel.trycloudflare.com"
> n8n
```

---

Vibe coded for your convenience by [Zackyy1](https://github.com/Zackyy1)