# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## macOS install

`install.sh` supports macOS only and installs dependencies through Homebrew and the `Brewfile`.
It symlinks the repository configs into the owner's home directory, installs PaperWM, changes macOS settings, and launches Hammerspoon.

Do NOT run `./install.sh` on the owner's live Mac from a worktree - it rewrites home-directory symlinks.
Validate installer changes with syntax checks and focused command stubs rather than executing the full installer from a worktree.

Run the complete local validation suite with `tests/run.sh`.
GitHub Actions runs the same suite on a macOS runner.
Real Accessibility, Spaces, gestures, and multi-display behavior still require a manual Hammerspoon smoke test.

## WezTerm translucency and blur

`config/wezterm/wezterm.lua` uses WezTerm's native macOS background blur with 80% opacity.
