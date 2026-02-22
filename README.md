# Claude Code Terminal - Home Assistant Add-on

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) directly in your Home Assistant dashboard with persistent terminal sessions.

## Features

- **Persistent tmux sessions** - Navigate away and come back, your conversation is still there
- **Auto-reconnect** - WebSocket reconnects automatically if the connection drops
- **HA Ingress** - Access via the sidebar, no port forwarding needed
- **Configurable** - Choose model (Sonnet/Opus/Haiku), enable YOLO mode, adjust scrollback
- **Persistent auth** - API key and Claude config survive container restarts

## Installation

1. In Home Assistant, go to **Settings > Add-ons > Add-on Store**
2. Click the **...** menu (top right) > **Repositories**
3. Add this repository URL:
   ```
   https://github.com/robertfahndrich/claude-code-haos-addon
   ```
4. Find **Claude Code Terminal** in the store and click **Install**
5. Go to the **Configuration** tab and enter your Anthropic API key
6. Start the add-on
7. Click **Open Web UI** or find "Claude Code" in your sidebar

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `anthropic_api_key` | *(required)* | Your Anthropic API key |
| `model` | `sonnet` | Claude model: `sonnet`, `opus`, or `haiku` |
| `yolo_mode` | `false` | Auto-approve all tool use |
| `tmux_history_limit` | `50000` | Lines of scrollback history |
| `session_name` | `claude` | tmux session name |

## How It Works

```
Browser tab → HA Ingress → ttyd (web terminal) → tmux session → Claude Code
```

- **ttyd** serves a web terminal over WebSocket with auto-reconnect
- **tmux** keeps the session alive even when you're not looking at it
- **s6-overlay** manages service lifecycle (init → ttyd)
- **/data** volume persists auth and config across restarts

## Architecture

- Base image: `hassio-addons/debian-base` (s6-overlay included)
- Node.js 20 LTS for Claude Code
- tmux for session persistence
- ttyd for web terminal serving
- s6-rc services: `init-claude` (oneshot setup) → `ttyd` (longrun server)

## Supported Architectures

- `amd64` (Intel/AMD)
- `aarch64` (ARM64, e.g., Raspberry Pi 4/5)
