#!/usr/bin/env bash
#
# Install packages on Linux using the native package manager.
# Called by install.sh - not meant to be run directly.
#
# Supported families: apt (Debian/Ubuntu), dnf (Fedora/RHEL), pacman (Arch).
# Unsupported distros get a manual-install message instead of a crash.
#
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$1"; }

# --- sudo helper: use sudo only when not root --------------------------------
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    warn "not root and sudo not found - package installs may fail"
  fi
fi

# --- detect package manager ---------------------------------------------------
PKG=""
if command -v apt-get >/dev/null 2>&1; then
  PKG="apt"
elif command -v dnf >/dev/null 2>&1; then
  PKG="dnf"
elif command -v pacman >/dev/null 2>&1; then
  PKG="pacman"
fi

if [ -z "$PKG" ]; then
  warn "no supported package manager found (need apt-get, dnf, or pacman)"
  warn "install these packages manually: zsh neovim (>= 0.10) curl git fontconfig"
  exit 3
fi

pkg_install() {
  case "$PKG" in
    apt)    $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
  esac
}

# --- core packages ------------------------------------------------------------
info "Installing core packages via $PKG..."

case "$PKG" in
  apt)    $SUDO apt-get update -y; pkg_install zsh curl git unzip fontconfig gnupg ;;
  dnf)    pkg_install zsh curl git unzip fontconfig ;;
  pacman) $SUDO pacman -Syu --noconfirm; pkg_install zsh curl git unzip fontconfig ;;
esac
ok "core packages"

# --- neovim (>= 0.10 required for LazyVim) -----------------------------------
install_neovim_from_tarball() {
  info "Installing neovim from official tarball (distro package too old for LazyVim)..."
  local nvim_url="https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz"
  local arch
  arch="$(uname -m)"
  if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    nvim_url="https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-arm64.tar.gz"
  fi
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$nvim_url" | tar xz -C "$tmp"
  $SUDO rm -rf /opt/nvim
  $SUDO mv "$tmp"/nvim-linux-* /opt/nvim
  rm -rf "$tmp"
  $SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  hash -r
  ok "neovim $(/opt/nvim/bin/nvim --version | head -1)"
}

neovim_is_new_enough() {
  local ver
  ver="$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)" || return 1
  local major minor
  major="${ver%%.*}"
  minor="${ver#*.}"
  [ "$major" -gt 0 ] || [ "$minor" -ge 10 ]
}

info "Installing neovim..."
case "$PKG" in
  apt|dnf)
    pkg_install neovim || true
    if ! neovim_is_new_enough; then
      install_neovim_from_tarball
    else
      ok "neovim $(nvim --version | head -1)"
    fi
    ;;
  pacman)
    pkg_install neovim
    ok "neovim $(nvim --version | head -1)"
    ;;
esac

# --- starship (official installer) --------------------------------------------
info "Installing starship..."
if command -v starship >/dev/null 2>&1; then
  ok "starship already installed"
else
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  ok "starship installed"
fi

# --- wezterm ------------------------------------------------------------------
install_wezterm() {
  info "Installing wezterm..."
  if command -v wezterm >/dev/null 2>&1; then
    ok "wezterm already installed"
    return 0
  fi
  case "$PKG" in
    apt)
      curl -fsSL https://apt.fury.io/wez/gpg.key | $SUDO gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg || return 1
      echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
        | $SUDO tee /etc/apt/sources.list.d/wezterm.list >/dev/null || return 1
      $SUDO apt-get update -y || return 1
      pkg_install wezterm || return 1
      ;;
    dnf)
      $SUDO dnf copr enable -y wezfurlong/wezterm-nightly || return 1
      pkg_install wezterm || return 1
      ;;
    pacman)
      pkg_install wezterm || return 1
      ;;
  esac
  ok "wezterm"
}

# wezterm needs a display server; skip gracefully in headless/container environments
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] || { [ -n "${XDG_SESSION_TYPE:-}" ] && [ "${XDG_SESSION_TYPE:-}" != "tty" ]; }; then
  install_wezterm || warn "wezterm install failed - install manually from https://wezfurlong.org/wezterm/install/linux.html"
else
  warn "no display detected (headless/container) - skipping wezterm"
fi

# --- Hack Nerd Font -----------------------------------------------------------
info "Installing Hack Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/Hack*.ttf >/dev/null 2>&1; then
  ok "Hack Nerd Font already installed"
else
  mkdir -p "$FONT_DIR"
  FONT_TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" \
    -o "$FONT_TMP/Hack.zip"
  unzip -qo "$FONT_TMP/Hack.zip" -d "$FONT_DIR"
  rm -rf "$FONT_TMP"
  fc-cache -f "$FONT_DIR"
  ok "Hack Nerd Font installed"
fi

# --- opensuperwhisper (macOS-only) --------------------------------------------
warn "OpenSuperWhisper is macOS-only - skipped on Linux"
warn "for Linux speech-to-text, see: https://github.com/Vaibhavs10/insanely-fast-whisper"
