#!/usr/bin/env bash
#
# Bootstrap a machine into this setup:
#   1. installs packages (Homebrew on macOS, native package manager on Linux)
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
OS="$(uname -s)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$1"; }

# --- 1. Packages --------------------------------------------------------------
case "$OS" in
  Darwin)
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
    ;;
  Linux)
    info "Installing Linux packages..."
    PKG_RC=0
    bash "$REPO_DIR/setup/packages-linux.sh" || PKG_RC=$?
    if [ "$PKG_RC" -eq 0 ]; then
      ok "packages ready"
    elif [ "$PKG_RC" -eq 3 ]; then
      warn "packages skipped (no supported package manager) - continuing with symlinks and shell setup"
    else
      exit "$PKG_RC"
    fi
    ;;
  *)
    echo "Unsupported OS: $OS (only macOS and Linux are supported)." >&2
    exit 1
    ;;
esac

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
link_file "$REPO_DIR/config/tmux/tmux.conf"      "$HOME/.tmux.conf"
link_file "$REPO_DIR/config/nvim"                "$HOME/.config/nvim"

# Global agent instructions - one file shared by Claude Code, Codex, and AGENTS.md
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/AGENTS.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.claude/CLAUDE.md"
link_file "$REPO_DIR/config/agents/AGENTS.md"    "$HOME/.codex/AGENTS.md"

# agentflow skill - captures this whole setup; loads on demand in Claude Code
link_file "$REPO_DIR/config/skills/agentflow"    "$HOME/.claude/skills/agentflow"

# picom - X11 compositor that blurs the desktop behind translucent WezTerm.
# Only meaningful on Linux (macOS/Windows blur themselves via WezTerm).
if [ "$OS" = "Linux" ]; then
  link_file "$REPO_DIR/config/picom/picom.conf" "$HOME/.config/picom/picom.conf"

  if command -v picom >/dev/null 2>&1; then
    # autostart picom on login (picom finds ~/.config/picom/picom.conf by default)
    mkdir -p "$HOME/.config/autostart"
    cat > "$HOME/.config/autostart/picom.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=picom
Comment=Compositor providing background blur for WezTerm
Exec=picom
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF
    ok "picom autostart configured"

    # xfwm4's built-in compositor fights picom - turn it off on XFCE
    if command -v xfconf-query >/dev/null 2>&1 && [ "${XDG_CURRENT_DESKTOP:-}" = "XFCE" ]; then
      xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null \
        && ok "disabled xfwm4 built-in compositor (picom takes over)" \
        || warn "could not disable xfwm4 compositing - do it in Settings > Window Manager Tweaks > Compositor"
    fi
  else
    warn "picom not installed - WezTerm background blur unavailable (run setup/packages-linux.sh)"
  fi
fi

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

if [ "$OS" = "Linux" ]; then
  LOGIN_SHELL="$(getent passwd "$(whoami)" 2>/dev/null | cut -d: -f7 || true)"
  if [ -n "$LOGIN_SHELL" ] && [ "$LOGIN_SHELL" != "$(command -v zsh 2>/dev/null || true)" ]; then
    warn "your login shell is $LOGIN_SHELL, not zsh"
    warn "run: chsh -s \$(which zsh)"
  fi
fi

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
if [ "$OS" = "Darwin" ]; then
  info "Done. Open a new WezTerm window (or run: source ~/.zshrc)."
else
  info "Done. Open a new terminal (or run: source ~/.zshrc)."
fi
