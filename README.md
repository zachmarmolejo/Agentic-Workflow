# Agentic-Workflow

My tailored development + agentic-workflow setup, in code — so a fresh Mac is one
command away from feeling like home.

This starts with the terminal stack (WezTerm + Starship, `rose-pine-moon` theme)
and will grow to cover the rest of my workflow over time.

## Quick start

```bash
git clone https://github.com/zachmarmolejo/Agentic-Workflow.git
cd Agentic-Workflow
./install.sh
```

Then open a new WezTerm window (or `source ~/.zshrc`).

`install.sh` is safe to re-run — it's idempotent and backs up any file it would
overwrite to `<file>.bak.<timestamp>`.

## What's inside

| Area | Tool | What it gives you |
|------|------|-------------------|
| Terminal | [WezTerm](https://wezfurlong.org/wezterm/) | `rose-pine-moon` theme, Hack Nerd Font, 80% opacity + macOS background blur, rose-tinted tab bar that hides on a single tab |
| Prompt | [Starship](https://starship.rs/) | blue dir · gray git branch · yellow command-duration · purple `❯` |
| Font | Hack Nerd Font | glyphs/icons the prompt relies on |

## What `install.sh` does

1. Installs Homebrew if missing, then installs everything in `Brewfile`.
2. Symlinks the configs into place (so edits in this repo are live):
   - `config/wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua`
   - `config/starship.toml` → `~/.config/starship.toml`
3. Appends the Starship init line to `~/.zshrc` (only if not already there).

## Structure

```
.
├── install.sh              # one-command bootstrap
├── Brewfile                # declarative dependency list (brew bundle)
├── config/
│   ├── wezterm/
│   │   └── wezterm.lua     # terminal appearance + behavior
│   └── starship.toml       # prompt
├── shell/
│   └── zshrc.snippet       # lines install.sh adds to ~/.zshrc
└── assets/                 # wallpaper / screenshots
```

## Roadmap

Things to fold in next:

- [ ] Desktop wallpaper (lakeside pagoda at sunset — see `assets/`)
- [ ] Claude Code / agent configuration
- [ ] Neovim
- [ ] Security-lab tooling

## Credits

- Terminal style adapted from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix)
- Color scheme: [Rosé Pine (Moon)](https://rosepinetheme.com/)
