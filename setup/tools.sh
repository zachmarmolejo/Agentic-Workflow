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

  echo "==> AXI reference CLIs (gh-axi, chrome-devtools-axi, lavish-axi, tasks-axi) + discovery hooks"
  npm install -g gh-axi chrome-devtools-axi lavish-axi tasks-axi
  for t in gh-axi chrome-devtools-axi lavish-axi tasks-axi; do "$t" setup hooks || true; done
fi

# --- firstmate: clone-based orchestrator (talk to one agent, ship with a crew) ---
# No install — you run your agent inside the clone: `cd ~/firstmate && claude`.
if [ -d "$HOME/firstmate/.git" ]; then
  echo "==> firstmate already cloned at ~/firstmate"
else
  echo "==> firstmate (cloning to ~/firstmate)"
  git clone https://github.com/kunchenguid/firstmate "$HOME/firstmate"
fi
