#!/usr/bin/env bash
# ==============================================================================
# Claude Code Terminal - tmux session manager
# Attaches to existing session or creates a new one.
# Called by ttyd on every browser connection.
# ==============================================================================

source /etc/profile.d/claude-env.sh

SESSION="${SESSION_NAME:-claude}"
TMUX_CONF="/data/.tmux.conf"

# Ensure tmux socket directory exists
mkdir -p /tmp/tmux
chmod 700 /tmp/tmux

# Check if tmux session already exists
if tmux -f "${TMUX_CONF}" has-session -t "${SESSION}" 2>/dev/null; then
    # Session exists - reattach (this is the persistence magic)
    exec tmux -f "${TMUX_CONF}" attach-session -t "${SESSION}"
else
    # No session - create a new one running Claude Code
    exec tmux -f "${TMUX_CONF}" new-session -s "${SESSION}" /usr/bin/claude-entrypoint.sh
fi
