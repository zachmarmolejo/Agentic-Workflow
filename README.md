# Omarchy-Style-MacOS

A reproducible macOS environment inspired by Omarchy's keyboard-driven workflow and cohesive visual style.

The setup combines PaperWM window management, a Rosé Pine Moon terminal and editor, and practical shell tools.
It is built exclusively for macOS.

![Rosé Pine Moon wallpaper](assets/wallpaper.png)

## Included

| Area | Tools | Configuration |
| --- | --- | --- |
| Window management | Hammerspoon and PaperWM | Horizontally scrolling tiling, four Spaces, pointer focus, and searchable keybindings |
| Terminal | WezTerm and Hack Nerd Font | Rosé Pine Moon, 80% opacity, macOS blur, integrated title bar, and themed tabs |
| Multiplexer | tmux | Mouse support, 50,000-line history, pane shortcuts, and a Catppuccin Mocha status bar |
| Prompt | Starship | Compact directory, Git state, command duration, and status prompt |
| Editor | Neovim and LazyVim | Rosé Pine Moon, transparent editing buffers, LSP, completion, project search, and Treesitter |
| Shell | bat, eza, and fzf | Readable file output, directory listings, fuzzy file search, aliases, and colored manual pages |
| Optional artwork | Original wallpaper | A bundled 2560x1440 Rosé Pine Moon image that the installer never copies or applies |

All applications and command-line packages are declared in [`Brewfile`](Brewfile).

## Install

```bash
git clone https://github.com/zachmarmolejo/Omarchy-Style-MacOS.git
cd Omarchy-Style-MacOS
./install.sh
```

The installer supports macOS only.
It is safe to rerun and backs up files or symlinks it replaces as `<path>.bak.<timestamp>`.

After installation:

1. Grant Hammerspoon access in **System Settings > Privacy & Security > Accessibility**.
2. Log out and back in if **Displays have separate Spaces** was previously disabled.
3. Open a new WezTerm window, or run `source ~/.zshrc` in the current shell.

## Installer Behavior

`install.sh` performs the following work:

1. Installs Homebrew when necessary and applies the `Brewfile`.
2. Symlinks the repository's terminal, prompt, tmux, Neovim, and Hammerspoon configurations into the home directory.
3. Installs PaperWM at the commit pinned in `setup/hammerspoon.sh`.
4. Configures Spaces and trackpad settings for PaperWM, restarts affected macOS services, and launches Hammerspoon.
5. Restores the LazyVim plugins pinned in `config/nvim/lazy-lock.json` and verifies the dashboard and theme.
6. Maintains a marked readability block in `~/.zshrc` and initializes Starship without duplicating an existing setup.

The installer does not copy, apply, or otherwise modify desktop wallpapers.

The managed configuration targets are:

| Repository path | Installed path |
| --- | --- |
| `config/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `config/starship.toml` | `~/.config/starship.toml` |
| `config/tmux/tmux.conf` | `~/.tmux.conf` |
| `config/nvim/` | `~/.config/nvim/` |
| `config/hammerspoon/init.lua` | `~/.hammerspoon/init.lua` |
| `config/hammerspoon/paperwm_recovery.lua` | `~/.hammerspoon/paperwm_recovery.lua` |

## Documentation

- [Window management](docs/window-management.md): required macOS settings, PaperWM behavior, keybindings, and maintenance.
- [Neovim cheat sheet](docs/nvim.md): LazyVim modes, navigation, editing, search, and project shortcuts.
- [Optional wallpaper assets](assets/README.md): editable source, raster image, and artwork provenance.

## Repository Layout

```text
.
├── assets/                  # Optional wallpaper source and raster image
├── config/
│   ├── hammerspoon/         # PaperWM integration and state recovery
│   ├── nvim/                # LazyVim configuration and plugin lockfile
│   ├── tmux/                # tmux behavior and theme
│   ├── starship.toml        # Shell prompt
│   └── wezterm/             # Terminal appearance and behavior
├── docs/                    # Focused user guides
├── setup/                   # PaperWM and Neovim installers
├── shell/                   # Managed Zsh readability block
├── tests/                   # Installer and PaperWM regression tests
├── Brewfile                 # Homebrew dependencies
└── install.sh               # macOS bootstrap entry point
```

## Testing

Run the complete validation suite on macOS:

```bash
tests/run.sh
```

The suite checks shell and Lua syntax, ShellCheck, JSON and TOML parsing, Homebrew declarations, Starship, tmux, isolated installer behavior, and PaperWM recovery behavior.
GitHub Actions runs the same suite for every pull request and for pushes to `main`.
Accessibility permissions, Spaces behavior, gestures, and multi-display movement still require a manual Hammerspoon smoke test.

## Credits

- Terminal styling adapted from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix).
- Color palette from [Rosé Pine](https://rosepinetheme.com/).
- Window management powered by [PaperWM.spoon](https://github.com/mogenson/PaperWM.spoon).
