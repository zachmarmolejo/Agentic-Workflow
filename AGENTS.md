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
