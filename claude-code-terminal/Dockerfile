ARG BUILD_FROM
FROM ${BUILD_FROM}

# Environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Install system dependencies (Alpine)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    nodejs \
    npm \
    openssh-client \
    libstdc++ \
    ncurses \
    tmux \
    coreutils \
    findutils \
    grep \
    sed \
    ca-certificates \
    openssl \
    ripgrep

# Install ttyd static binary
ARG BUILD_ARCH
RUN case "${BUILD_ARCH}" in \
        amd64) TTYD_ARCH="x86_64" ;; \
        aarch64) TTYD_ARCH="aarch64" ;; \
        *) TTYD_ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" -o /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Configure tmux
RUN echo 'set-option -g history-limit 50000' > /root/.tmux.conf && \
    echo 'set-option -g mouse on' >> /root/.tmux.conf && \
    echo 'set-option -g default-terminal "screen-256color"' >> /root/.tmux.conf && \
    echo 'set-option -g status on' >> /root/.tmux.conf && \
    echo 'set-option -g status-position bottom' >> /root/.tmux.conf && \
    echo 'set-option -g status-style "bg=#1a1b26,fg=#a9b1d6"' >> /root/.tmux.conf && \
    echo 'set-option -g status-left " #[fg=#7aa2f7,bold]Claude Code #[fg=#565f89]| "' >> /root/.tmux.conf && \
    echo 'set-option -g status-right "#[fg=#565f89]Session: #[fg=#9ece6a]#{session_name} "' >> /root/.tmux.conf && \
    echo 'set-option -g allow-rename off' >> /root/.tmux.conf && \
    echo 'set-option -sg escape-time 10' >> /root/.tmux.conf

# Configure bash
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'export LANG=C.UTF-8' >> /root/.bashrc && \
    echo 'alias c="claude"' >> /root/.bashrc && \
    echo 'alias cc="claude --continue"' >> /root/.bashrc

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:7681/ || exit 1

# Clear entrypoint from base image, use CMD for everything
ENTRYPOINT []
CMD ["/bin/bash", "-c", "\
  export TERM=xterm-256color && \
  export LANG=C.UTF-8 && \
  \
  # Create persistent directories \n\
  PERSIST_DIR=/data/claude-persist && \
  mkdir -p $PERSIST_DIR/config $PERSIST_DIR/cache /data/projects && \
  \
  # Read add-on options \n\
  API_KEY=$(jq -r '.anthropic_api_key // \"\"' /data/options.json) && \
  MODEL=$(jq -r '.model // \"sonnet\"' /data/options.json) && \
  YOLO_MODE=$(jq -r '.yolo_mode // false' /data/options.json) && \
  TMUX_HISTORY=$(jq -r '.tmux_history_limit // 50000' /data/options.json) && \
  SESSION_NAME=$(jq -r '.session_name // \"claude\"' /data/options.json) && \
  \
  # Set API key \n\
  if [ -n \"$API_KEY\" ] && [ \"$API_KEY\" != \"\" ]; then \
    export ANTHROPIC_API_KEY=\"$API_KEY\"; \
    echo \"[INFO] Anthropic API key configured\"; \
  else \
    echo \"[WARN] No Anthropic API key set - Claude will prompt for auth\"; \
  fi && \
  \
  # Symlink Claude config to persistent storage \n\
  if [ ! -L /root/.claude ]; then rm -rf /root/.claude; ln -s $PERSIST_DIR /root/.claude; fi && \
  if [ ! -L /root/.config/claude-code ]; then mkdir -p /root/.config; rm -rf /root/.config/claude-code; ln -s $PERSIST_DIR/config /root/.config/claude-code; fi && \
  \
  # Update tmux scrollback from options \n\
  sed -i \"s/history-limit.*/history-limit $TMUX_HISTORY/\" /root/.tmux.conf && \
  \
  # Configure YOLO mode \n\
  if [ \"$YOLO_MODE\" = \"true\" ]; then \
    echo '[INFO] YOLO mode enabled'; \
    mkdir -p $PERSIST_DIR && \
    echo '{\"permissions\":{\"allow\":[\"Bash(*)\",\"Read(*)\",\"Write(*)\",\"Edit(*)\",\"Glob(*)\",\"Grep(*)\"],\"deny\":[]}}' > $PERSIST_DIR/settings.json; \
  fi && \
  \
  # Configure HA MCP if supervisor token available \n\
  if [ -n \"$SUPERVISOR_TOKEN\" ]; then \
    echo '[INFO] Configuring Home Assistant MCP server...'; \
    claude mcp remove homeassistant -s user 2>/dev/null || true; \
    claude mcp add-json homeassistant '{\"type\":\"http\",\"url\":\"http://supervisor/core/api/mcp\",\"headers\":{\"Authorization\":\"Bearer '\"$SUPERVISOR_TOKEN\"'\"}}' -s user 2>/dev/null && \
    echo '[INFO] HA MCP configured'; \
  fi && \
  \
  # Build model args \n\
  CLAUDE_ARGS=\"\" && \
  if [ \"$MODEL\" != \"default\" ] && [ -n \"$MODEL\" ]; then \
    CLAUDE_ARGS=\"--model $MODEL\"; \
  fi && \
  \
  echo '' && \
  echo '  Claude Code Terminal for Home Assistant' && \
  echo '  Session: '\"$SESSION_NAME\"' | Model: '\"$MODEL\" && \
  echo '  Close this tab anytime - session persists!' && \
  echo '' && \
  \
  cd /data/projects && \
  exec ttyd --port 7681 --writable --ping-interval 30 --max-clients 5 --reconnect 10 \
    -t fontSize=14 \
    -t fontFamily=Monaco,Consolas,monospace \
    -t scrollback=20000 \
    -t 'theme=background=#1e1e2e,foreground=#cdd6f4,cursor=#f5e0dc' \
    tmux new-session -A -s \"$SESSION_NAME\" \
"]
