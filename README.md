# Agentic-Workflow

My tailored development + agentic-workflow setup, in code — so a fresh Mac is one
command away from feeling like home.

It covers the terminal stack (WezTerm + Starship, `rose-pine-moon` theme) and a
seven-tool agentic toolchain, and will grow to cover the rest of my workflow.

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

## Agentic toolchain

Beyond the terminal, this repo installs Kun Chen's agentic toolchain — seven
tools that compose into one workflow but each run standalone. Installed via the
`Brewfile`, `setup/skills.sh` (Claude Code skills), and `setup/tools.sh` (CLI
binaries + the firstmate clone).

| # | Tool | What it does | Run it |
|---|------|--------------|--------|
| 1 | OpenSuperWhisper | Push-to-talk dictation in any text field | menu bar |
| 2 | [AXI](https://axi.md) | Principles for agent-ergonomic CLIs (reference skill) | `/axi` |
| 3 | lavish | Open agent HTML artifacts for click-to-annotate feedback | `/lavish` · `lavish-axi` |
| 4 | no-mistakes | AI gate: push → review/test/lint/docs → clean PR | `git push no-mistakes` |
| 5 | gnhf | Bounded autonomous loop (one committed change per iteration) | `gnhf "objective"` |
| 6 | treehouse | Reusable isolated git worktree pool for parallel agents | `treehouse` |
| 7 | firstmate | Talk to one agent; it runs a crew in tmux and hands you PRs | `cd ~/firstmate && claude` |

**→ [docs/tools.md](docs/tools.md) — how to run each tool in isolation.**

> **Note — `axi` is a reference / build-time skill, not a daily driver.** It
> teaches the agent the AXI principles for building agent-ergonomic CLIs and
> only fires when you're *authoring or reviewing a CLI* (e.g. wrapping a
> security tool for agent use). Kept on purpose: near-zero cost (one lazy-loaded
> `SKILL.md`) and the foundation the other AXI tools (`lavish`, `no-mistakes`,
> `gh-axi`) build on.

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
├── setup/
│   ├── skills.sh           # installs agent skills (axi [reference], lavish)
│   └── tools.sh            # installs CLI binaries (no-mistakes, treehouse, gnhf, AXI CLIs) + clones firstmate
├── docs/
│   └── tools.md            # how to run each agentic tool in isolation
└── assets/                 # wallpaper / screenshots
```

## Roadmap

- [x] Terminal stack (WezTerm + Starship, rose-pine-moon)
- [x] Agentic toolchain (OpenSuperWhisper · AXI · lavish · no-mistakes · gnhf · treehouse · firstmate)
- [ ] Desktop wallpaper (lakeside pagoda at sunset — see `assets/`)
- [ ] Neovim
- [ ] Security-lab tooling (wrap recon/scan CLIs as AXI tools)

## Credits

- Terminal style adapted from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix)
- Color scheme: [Rosé Pine (Moon)](https://rosepinetheme.com/)
