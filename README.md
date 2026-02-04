# Start n8n with Cloudflare HTTPS tunnel

**Only works with npm, locally hosted instance of n8n on Windows or MacOS**

## Why

Telegram requires HTTPS to accept and receive messages to and from bots. This tunneling provides a compliant way to make Telegram (and maybe other similar modules) work in your locally hosted n8n.

## Getting started

### Windows 

#### Install cloudflared
```powershell
winget install Cloudflare.cloudflared
```

#### Install n8n using npm

```powershell
npm i -g n8n@latest
```

#### Start the script using PowerShell or executable file.
n8n instance will be loaded with `cloudflared` WEBHOOK_URL already set and ready to be used as the tunnel. 

Terminal window will be open with n8n logs.

### MacOS

Using a terminal command to start tunneled n8n.

#### 1. Install cloudflared
```sh
brew install cloudflare/cloudflare/cloudflared
```

#### 2. Install n8n (global) npm package
```sh
npm install -g n8n@latest
```

#### 3. Create a script file anywhere you like or copy-paste the file in MacOS folder to any location:
```sh
mkdir -p ~/.local/bin
nano ~/.local/bin/n8n-tunnel.sh
```

##### 3.1 If you entered the 2 commands above, then
Paste the contents of n8n-tunnel.sh

#### 4. Make it executable (provide a correct path if you chose to put it somewhere manually):
```sh
chmod +x ~/.local/bin/n8n-tunnel.sh
```

#### 5. Add alias `n8n-tunnel`
If you use zsh (default on macOS)

```sh
nano ~/.zshrc
```

Add:
```sh
alias n8n-tunnel="$HOME/.local/bin/n8n-tunnel.sh"
```

Reload:
```sh
source ~/.zshrc
```



## Check if it works

- Insert a Telegram Callback Data Trigger in n8n.
- Inside, open the top most dropdown saying "Webhook URLs"
- URL must match the one provided by `cloudflared`.

## Alternative

This script is meant to save time, but it's basically the equivalent of doing the following:

```powershell
> cloudflared tunnel --url http://localhost:5678/
> $env:WEBHOOK_URL="https://your-tunnel.trycloudflare.com"
> n8n
```

---

Vibe coded for your convenience by [Zackyy1](https://github.com/Zackyy1)

## DISCLAIMER

Use at your own risk. Changing WEBHOOK_URL to cloudflare tunnel may give Telegram and other applications enough security to work with local n8n, but it may also break existing features that require a different WEBHOOK_URL. If anything unexpected happens, revert the env variable back to default.