#!/usr/bin/env bash
#
# Bootstrap a machine into this setup:
#   1. installs packages with Homebrew
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

# --- 1. Packages --------------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  echo "Omarchy-Style-MacOS requires macOS." >&2
  exit 1
fi

if [ -n "${OMARCHY_BREW_BIN:-}" ]; then
  BREW_BIN="$OMARCHY_BREW_BIN"
else
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Prefer the native Homebrew installation for this Mac's architecture.
  if [ "$(uname -m)" = "arm64" ] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  BREW_BIN="$(command -v brew)"
fi

info "Installing packages from Brewfile..."
"$BREW_BIN" bundle --file="$REPO_DIR/Brewfile"
ok "packages ready"

# --- 2. Symlink config files --------------------------------------------------
link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    if [ "$(/usr/bin/stat -f '%Y' "$dest")" = "$src" ]; then
      ok "already linked $dest"
      return
    fi
    mv "$dest" "$dest.bak.$TS"
    warn "backed up $dest -> $dest.bak.$TS"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.bak.$TS"
    warn "backed up $dest -> $dest.bak.$TS"
  fi
  ln -s "$src" "$dest"
  ok "linked $dest"
}

info "Linking dotfiles..."
link_file "$REPO_DIR/config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
link_file "$REPO_DIR/config/starship.toml"       "$HOME/.config/starship.toml"
link_file "$REPO_DIR/config/tmux/tmux.conf"      "$HOME/.tmux.conf"
link_file "$REPO_DIR/config/nvim"                "$HOME/.config/nvim"

link_file "$REPO_DIR/config/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"
link_file "$REPO_DIR/config/hammerspoon/paperwm_recovery.lua" "$HOME/.hammerspoon/paperwm_recovery.lua"

info "Installing PaperWM..."
bash "$REPO_DIR/setup/hammerspoon.sh"
ok "PaperWM ready"

defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.spaces spans-displays -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 0
# Reserve Command+Option+Space for Hammerspoon instead of Finder's search window.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '{ enabled = 0; }'
killall cfprefsd 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
ok "Mission Control configured for PaperWM"
warn "grant Hammerspoon access in Privacy & Security > Accessibility on first launch"
killall Hammerspoon 2>/dev/null || true
open -a Hammerspoon

info "Installing desktop wallpaper..."
bash "$REPO_DIR/setup/wallpaper.sh"
ok "wallpaper ready"

# Global agent instructions - one file shared by Claude Code, Codex, and AGENTS.md
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/AGENTS.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.claude/CLAUDE.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.codex/AGENTS.md"

# agentflow skill - captures this whole setup; loads on demand in Claude Code
link_file "$REPO_DIR/config/skills/agentflow"    "$HOME/.claude/skills/agentflow"

# --- 3. Neovim / LazyVim ------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  bash "$REPO_DIR/setup/nvim.sh"
else
  warn "nvim not found - skipping LazyVim bootstrap"
fi

# --- 4. Shell init ------------------------------------------------------------
info "Wiring shell prompt..."
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
ZSHRC_TMP="$(mktemp "${TMPDIR:-/tmp}/omarchy-zshrc.XXXXXX")"
IN_MANAGED_BLOCK=false
FOUND_MANAGED_BLOCK=false

write_shell_block() {
  printf '# >>> Omarchy-Style-MacOS >>>\n'
  cat "$REPO_DIR/shell/zshrc.snippet"
  printf '# <<< Omarchy-Style-MacOS <<<\n'
}

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    '# >>> Agentic-Workflow >>>'|'# >>> Omarchy-Style-MacOS >>>')
      if [ "$FOUND_MANAGED_BLOCK" = false ]; then
        write_shell_block >> "$ZSHRC_TMP"
        FOUND_MANAGED_BLOCK=true
      fi
      IN_MANAGED_BLOCK=true
      ;;
    '# <<< Agentic-Workflow <<<'|'# <<< Omarchy-Style-MacOS <<<')
      IN_MANAGED_BLOCK=false
      ;;
    *)
      if [ "$IN_MANAGED_BLOCK" = false ]; then
        printf '%s\n' "$line" >> "$ZSHRC_TMP"
      fi
      ;;
  esac
done < "$ZSHRC"

if [ "$FOUND_MANAGED_BLOCK" = false ]; then
  if [ -s "$ZSHRC_TMP" ]; then
    printf '\n' >> "$ZSHRC_TMP"
  fi
  write_shell_block >> "$ZSHRC_TMP"
fi
if ! grep -Eq '^[[:space:]]*([^#[:space:]][^#]*&&[[:space:]]*)?eval[[:space:]]+.*starship init zsh' "$ZSHRC_TMP"; then
  # This command must run when Zsh loads the file.
  # shellcheck disable=SC2016
  printf '\n# Starship prompt\neval "$(starship init zsh)"\n' >> "$ZSHRC_TMP"
fi

if cmp -s "$ZSHRC" "$ZSHRC_TMP"; then
  ok "shell setup already present in ~/.zshrc"
else
  cp "$ZSHRC" "$ZSHRC.bak.$TS"
  cat "$ZSHRC_TMP" > "$ZSHRC"
  warn "backed up $ZSHRC -> $ZSHRC.bak.$TS"
  ok "updated shell setup in ~/.zshrc"
fi
rm "$ZSHRC_TMP"

# --- 5. Agent skills ----------------------------------------------------------
if command -v npx >/dev/null 2>&1; then
  info "Installing agent skills..."
  bash "$REPO_DIR/setup/skills.sh"
  ok "agent skills installed"
else
  warn "npx not found - skipping agent skills (install Node, then run setup/skills.sh)"
fi

# --- 6. CLI tools (curl-installed binaries) -----------------------------------
info "Installing CLI tools..."
bash "$REPO_DIR/setup/tools.sh"
ok "CLI tools installed"

echo
info "Done. Open a new WezTerm window (or run: source ~/.zshrc)."
