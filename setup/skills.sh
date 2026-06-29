#!/usr/bin/env bash
#
# Install Agent Skills (Kun Chen's AXI ecosystem) globally for Claude Code.
# These land in ~/.claude/skills/ and show up as /slash-commands in new sessions.
#
# Requires: node/npx and the `claude` harness installed.
# Safe to re-run — re-adding a skill just refreshes it.
#
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "skip: npx not found (install Node first)"; exit 0
fi

add_skill() {
  local repo="$1" skill="$2"
  echo "==> skill: $skill ($repo)"
  npx -y skills add "$repo" --global --agent claude-code --skill "$skill" --yes
}

# AXI — design principles for agent-ergonomic CLIs
add_skill kunchenguid/axi axi

# (more get added here as the workflow grows: lavish, no-mistakes, ...)
