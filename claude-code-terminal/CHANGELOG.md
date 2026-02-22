# Changelog

## 1.0.0 (2026-02-22)

### Initial Release

- Claude Code running in persistent tmux sessions via ttyd
- Auto-reconnect on WebSocket disconnection (10s interval)
- WebSocket keepalive pings (30s interval) to prevent proxy timeout
- Configurable model selection (Sonnet, Opus, Haiku)
- YOLO mode for auto-approving tool use
- Configurable tmux scrollback buffer (default 50,000 lines)
- s6-overlay service management with proper init/run separation
- HA ingress integration (sidebar access, no port forwarding)
- Persistent auth and config across container restarts via /data volume
- Access to HA config, share, media, and SSL directories
