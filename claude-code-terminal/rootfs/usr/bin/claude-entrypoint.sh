#!/usr/bin/env bash
# ==============================================================================
# Claude Code Terminal - Claude launcher
# Runs inside the tmux session. Sets up env and starts Claude Code.
# ==============================================================================

source /etc/profile.d/claude-env.sh

cd /data/projects || cd /data

# Build Claude arguments
CLAUDE_ARGS=()
if [[ -n "${CLAUDE_MODEL}" && "${CLAUDE_MODEL}" != "default" ]]; then
    CLAUDE_ARGS+=(--model "${CLAUDE_MODEL}")
fi

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║          Claude Code Terminal for HAOS           ║"
echo "  ╠══════════════════════════════════════════════════╣"
echo "  ║  Session: ${SESSION_NAME:-claude}$(printf '%*s' $((30 - ${#SESSION_NAME:-5})) '')║"
echo "  ║  Model:   ${CLAUDE_MODEL:-default}$(printf '%*s' $((30 - ${#CLAUDE_MODEL:-7})) '')║"
echo "  ║  Workdir: /data/projects                        ║"
echo "  ║                                                  ║"
echo "  ║  Close this tab anytime - session persists!      ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

exec claude "${CLAUDE_ARGS[@]}"
