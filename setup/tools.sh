#!/usr/bin/env bash
#
# Install standalone CLI binaries (Kun Chen's agentic toolchain) via their
# official installers. Binaries land in ~/.local/bin (already on PATH).
# Safe to re-run.
#
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# --- readability tools (bat, eza, fzf) ---
# bat: syntax-highlighted cat replacement
# eza: modern ls replacement with colors and git status
# fzf: fuzzy finder (Ctrl+T files, Ctrl+R history)
install_readability_tools() {
  local arch os
  arch="$(uname -m)"
  os="$(uname -s)"

  # normalize arch
  case "$arch" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="aarch64" ;;
  esac

  # --- bat ---
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    echo "    bat already installed"
  else
    local bat_ver
    bat_ver="$(curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+')"
    echo "==> bat v${bat_ver}"
    local tmp
    tmp="$(mktemp -d)"
    case "$os" in
      Darwin) brew install bat ;;
      Linux)
        curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${bat_ver}/bat-v${bat_ver}-${arch}-unknown-linux-gnu.tar.gz" -o "$tmp/bat.tar.gz"
        tar xzf "$tmp/bat.tar.gz" -C "$tmp"
        cp "$tmp/bat-v${bat_ver}-${arch}-unknown-linux-gnu/bat" "$HOME/.local/bin/bat"
        chmod +x "$HOME/.local/bin/bat"
        ;;
    esac
    rm -rf "$tmp"
  fi

  # --- eza ---
  if command -v eza >/dev/null 2>&1; then
    echo "    eza already installed"
  else
    local eza_ver
    eza_ver="$(curl -sL https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+')"
    echo "==> eza v${eza_ver}"
    local tmp
    tmp="$(mktemp -d)"
    case "$os" in
      Darwin) brew install eza ;;
      Linux)
        curl -fsSL "https://github.com/eza-community/eza/releases/download/v${eza_ver}/eza_${arch}-unknown-linux-gnu.tar.gz" -o "$tmp/eza.tar.gz"
        tar xzf "$tmp/eza.tar.gz" -C "$tmp"
        cp "$tmp/eza" "$HOME/.local/bin/eza"
        chmod +x "$HOME/.local/bin/eza"
        ;;
    esac
    rm -rf "$tmp"
  fi

  # --- fzf ---
  if command -v fzf >/dev/null 2>&1; then
    echo "    fzf already installed"
  else
    echo "==> fzf"
    if [ ! -d "$HOME/.fzf" ]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi
    yes | "$HOME/.fzf/install" --no-update-rc --bin >/dev/null 2>&1 || true
    # ensure fzf is on PATH
    if [ -f "$HOME/.fzf/bin/fzf" ] && [ ! -f "$HOME/.local/bin/fzf" ]; then
      ln -s "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
    fi
  fi
}

install_readability_tools

# --- firstmate: clone-based orchestrator (talk to one agent, ship with a crew) ---
# No install — you run your agent inside the clone: `cd ~/firstmate && claude`.
if [ -d "$HOME/firstmate/.git" ]; then
  echo "==> firstmate already cloned at ~/firstmate"
else
  echo "==> firstmate (cloning to ~/firstmate)"
  git clone https://github.com/kunchenguid/firstmate "$HOME/firstmate"
fi

# Seed firstmate's local crew-dispatch profile (which model/effort crewmates spawn
# with). It's gitignored in firstmate, so upstream updates never touch it. Only
# seed when absent, so local edits are never clobbered.
if [ -d "$HOME/firstmate" ] && [ ! -f "$HOME/firstmate/config/crew-dispatch.json" ] \
   && [ -f "$TOOLS_DIR/firstmate/crew-dispatch.json" ]; then
  mkdir -p "$HOME/firstmate/config"
  cp "$TOOLS_DIR/firstmate/crew-dispatch.json" "$HOME/firstmate/config/crew-dispatch.json"
  echo "    seeded firstmate config/crew-dispatch.json (crew default: claude/opus-4.6)"
fi
