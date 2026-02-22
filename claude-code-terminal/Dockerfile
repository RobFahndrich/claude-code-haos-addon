ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    git \
    curl \
    wget \
    jq \
    ripgrep \
    openssh-client \
    ca-certificates \
    gnupg \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd from official releases
ARG BUILD_ARCH
RUN TTYD_ARCH=$([ "${BUILD_ARCH}" = "aarch64" ] && echo "aarch64" || echo "x86_64") \
    && curl -fsSL -o /usr/bin/ttyd \
       "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${TTYD_ARCH}" \
    && chmod +x /usr/bin/ttyd

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Copy root filesystem overlay
COPY rootfs /

# Make scripts executable
RUN chmod +x /usr/bin/claude-entrypoint.sh \
    && chmod +x /usr/bin/tmux-session.sh \
    && chmod +x /etc/s6-overlay/s6-rc.d/init-claude/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/ttyd/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/ttyd/finish

# Create persistent data directories
RUN mkdir -p /data/.config /data/.cache /data/projects

# Set working directory
WORKDIR /data/projects
