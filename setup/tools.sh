#!/usr/bin/env bash
#
# Install standalone CLI binaries (Kun Chen's agentic toolchain) via their
# official installers. Binaries land in ~/.local/bin (already on PATH).
# Safe to re-run.
#
set -euo pipefail

echo "==> no-mistakes (AI validation gate: push -> review/test/lint/docs -> clean PR)"
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh

echo "==> treehouse (reusable pre-warmed git worktree pool for parallel agents)"
curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh

# --- npm-global tools ---
if command -v npm >/dev/null 2>&1; then
  echo "==> gnhf (good night, have fun — bounded autonomous overnight loop)"
  npm install -g gnhf
fi
