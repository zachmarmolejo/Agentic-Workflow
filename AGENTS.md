# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## Cross-platform install

`install.sh` detects the OS via `uname -s` and branches:
- **Darwin**: Homebrew + Brewfile (unchanged).
- **Linux**: `setup/packages-linux.sh` handles apt/dnf/pacman.
  Neovim >= 0.10 is required for LazyVim; the script falls back to the official tarball when the distro package is too old.
  Starship uses the official installer script.
  Hack Nerd Font is fetched into `~/.local/share/fonts`.
  WezTerm is skipped in headless/container environments.
  OpenSuperWhisper is macOS-only and skipped on Linux.

Do NOT run `./install.sh` on the owner's live Mac from a worktree - it rewrites home-directory symlinks.
Verify the mac path by review only; test the Linux path via Docker containers.

## WezTerm translucency + blur (Linux)

WezTerm's own blur options are macOS-only (`macos_window_background_blur`) and KDE-only (`kde_window_background_blur`), so on X11/XFCE the blur is done by a compositor:
- `config/wezterm/wezterm.lua` sets `window_background_opacity = 0.85` in the `is_linux` branch.
- `config/picom/picom.conf` (picom, `dual_kawase`) blurs the desktop behind the translucent terminal. `install.sh` symlinks it, autostarts picom, and disables xfwm4's built-in compositor on XFCE (the two conflict).

The xfwm4 server-side titlebar is left as the stock desktop theme (it shows up black). Theming it rose-pine at the WM level, or removing it via `window_decorations = "NONE"`, were both tried and reverted - the owner prefers the default bar. NOTE: `convert` on the owner's Kali box is shadowed by a payload tool - call `magick` (or `/usr/bin/convert`) directly if you ever need ImageMagick here.
