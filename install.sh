#!/usr/bin/env bash
#
# Bootstrap a machine into this setup:
#   1. installs Homebrew (if missing) + the packages in Brewfile
#   2. symlinks the configs in this repo into ~/.config (backing up anything there)
#   3. wires the shell prompt into ~/.zshrc
#
# Safe to re-run — it's idempotent and backs up files it would overwrite.
#
#   ./install.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$1"; }

# --- 1. Homebrew + packages ---------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# make brew available in this shell (Apple Silicon, then Intel)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -x /usr/local/bin/brew ]    && eval "$(/usr/local/bin/brew shellenv)"

info "Installing packages from Brewfile..."
brew bundle --file="$REPO_DIR/Brewfile"
ok "packages ready"

# --- 2. Symlink config files --------------------------------------------------
link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"                       # replace an old symlink
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.bak.$TS"       # back up a real file
    warn "backed up $dest -> $dest.bak.$TS"
  fi
  ln -s "$src" "$dest"
  ok "linked $dest"
}

info "Linking dotfiles..."
link_file "$REPO_DIR/config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link_file "$REPO_DIR/config/starship.toml"       "$HOME/.config/starship.toml"
link_file "$REPO_DIR/config/nvim"                "$HOME/.config/nvim"

# Global agent instructions — one file shared by Claude Code, Codex, and AGENTS.md
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/AGENTS.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.claude/CLAUDE.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.codex/AGENTS.md"

# --- 3. Shell init ------------------------------------------------------------
info "Wiring shell prompt..."
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if grep -q 'starship init zsh' "$ZSHRC"; then
  ok "starship init already present in ~/.zshrc"
else
  {
    printf '\n# >>> Agentic-Workflow >>>\n'
    cat "$REPO_DIR/shell/zshrc.snippet"
    printf '# <<< Agentic-Workflow <<<\n'
  } >> "$ZSHRC"
  ok "added starship init to ~/.zshrc"
fi

# --- 4. Agent skills ----------------------------------------------------------
if command -v npx >/dev/null 2>&1; then
  info "Installing agent skills..."
  bash "$REPO_DIR/setup/skills.sh"
  ok "agent skills installed"
else
  warn "npx not found — skipping agent skills (install Node, then run setup/skills.sh)"
fi

# --- 5. CLI tools (curl-installed binaries) -----------------------------------
info "Installing CLI tools..."
bash "$REPO_DIR/setup/tools.sh"
ok "CLI tools installed"

echo
info "Done. Open a new WezTerm window (or run: source ~/.zshrc)."
