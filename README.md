# Omarchy-Style-MacOS

My tailored macOS development and agentic-workflow setup, in code.
A fresh Mac is one command away from feeling like home.

It covers an Omarchy-inspired PaperWM window manager, the terminal stack (WezTerm + Starship, `rose-pine-moon` theme), and a seven-tool agentic toolchain.

Built exclusively for **macOS**.

## Quick start

```bash
git clone https://github.com/zachmarmolejo/Omarchy-Style-MacOS.git
cd Omarchy-Style-MacOS
./install.sh
```

Then open a new WezTerm window (or `source ~/.zshrc`).

`install.sh` is safe to re-run — it's idempotent and backs up any file or symlink it would overwrite to `<file>.bak.<timestamp>`.
Homebrew, npm tools, no-mistakes, and treehouse use their current upstream releases; PaperWM is pinned to a tested commit.

## What's inside

| Area | Tool | What it gives you |
|------|------|-------------------|
| Window management | [Hammerspoon](https://www.hammerspoon.org/) + [PaperWM](https://github.com/mogenson/PaperWM.spoon) | Horizontally scrolling tiling, four managed Spaces, hover focus, and searchable keybindings |
| Terminal | [WezTerm](https://wezfurlong.org/wezterm/) | `rose-pine-moon` theme, Hack Nerd Font, 80% opacity + macOS background blur, rose-tinted tab bar that hides on a single tab |
| Multiplexer | [tmux](https://github.com/tmux/tmux) | Catppuccin Mocha status bar, 50k scrollback, mouse support, right-click paste, intuitive pane splits |
| Prompt | [Starship](https://starship.rs/) | bold blue dir · gray git branch · yellow command-duration · purple `❯` |
| Font | Hack Nerd Font | glyphs/icons the prompt relies on |
| Editor | [Neovim](https://neovim.io/) + [LazyVim](https://lazyvim.org/) | rose-pine-moon (transparent to match), LSP · completion · telescope · treesitter |
| Readability | [bat](https://github.com/sharkdp/bat) | syntax-highlighted `cat` with line numbers, colored man pages |
| Readability | [eza](https://github.com/eza-community/eza) | modern `ls` with colors, git status, directory-first sorting |
| Readability | [fzf](https://github.com/junegunn/fzf) | fuzzy finder — Ctrl+T files, Ctrl+R history, Catppuccin themed |

See [docs/window-management.md](docs/window-management.md) for PaperWM behavior and keybindings.

## What `install.sh` does

1. Installs Homebrew and everything in `Brewfile`, including WezTerm, Hammerspoon, Neovim, Node, tmux, bat, eza, fzf, and OpenSuperWhisper.
2. Symlinks the configs into place (so edits in this repo are live):
   - `config/wezterm/wezterm.lua` -> `~/.config/wezterm/wezterm.lua`
   - `config/starship.toml` -> `~/.config/starship.toml`
   - `config/tmux/tmux.conf` -> `~/.tmux.conf`
   - `config/nvim/` -> `~/.config/nvim/` (LazyVim)
   - `config/hammerspoon/init.lua` -> `~/.hammerspoon/init.lua` (PaperWM)
   - `config/agents/AGENTS.md` -> `~/.claude/CLAUDE.md`, `~/AGENTS.md`, `~/.codex/AGENTS.md`
   - `config/skills/agentflow/` -> `~/.claude/skills/agentflow/` (the `/agentflow` skill)
3. Installs PaperWM and configures macOS Spaces, trackpad gestures, and the Hammerspoon keybinding chooser.
4. Maintains a marked readability block in `~/.zshrc` and ensures Starship is initialized without duplicating an existing setup.
5. Installs the agent skills and CLI toolchain.

## Agentic toolchain

Beyond the terminal, this repo installs Kun Chen's agentic toolchain — seven
tools that compose into one workflow but each run standalone. Installed via the
`Brewfile`, `setup/skills.sh` (Claude Code skills), and `setup/tools.sh`
(CLI binaries + the firstmate clone).

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

## Global agent instructions

One file, every agent. `config/agents/AGENTS.md` holds my global agent rules and
is symlinked to all three targets so they never drift:

- `~/.claude/CLAUDE.md` — Claude Code (loaded into every session)
- `~/AGENTS.md` — the cross-agent [AGENTS.md](https://agents.md) standard
- `~/.codex/AGENTS.md` — Codex

Edit `config/agents/AGENTS.md` once and every agent picks it up. It can point to
optional on-demand companions: `~/OPINIONS.md` (viewpoints) and `~/VOICE.md`
(writing voice).

## Neovim cheat sheet

LazyVim, leader = `<Space>`. Neovim is **modal** — that's the part that trips
people up. Press `<Space>` and pause anytime to get the which-key menu.

**→ Also at [docs/nvim.md](docs/nvim.md)** — open from inside nvim with `:e ~/Omarchy-Style-MacOS/docs/nvim.md`.

**Modes**

| Key | Mode |
|-----|------|
| `i` / `a` | insert — type text |
| `<Esc>` | back to **normal** mode (stop editing) |
| `v` | visual — select |
| `:` | command line |

**Get out / around**

| Key | Action |
|-----|--------|
| `<Space>h` | back to the dashboard (custom keymap) |
| `<Space>` then wait | which-key menu — shows everything |
| `:w` · `:q` · `:wq` | save · quit window · save+quit |
| `<Space>qq` | quit all |

**Buffers (open files)**

| Key | Action |
|-----|--------|
| `<Space>,` | list / switch buffers |
| `<Space>bb` | switch to previous buffer |
| `<Space>bd` | close current buffer |
| `<Space>bD` | close buffer + window |

**Windows / splits**

| Key | Action |
|-----|--------|
| `<Space>-` · `<Space>\|` | split below · split right |
| `<C-h/j/k/l>` | move between splits |
| `<Space>wd` | close current split |
| `<C-w>o` | unsplit — close all *other* splits |

**Copy & paste (yank)** - yanks sync to the macOS clipboard, so `y` = `Cmd+C`; "cut" is just delete (`dd`/`dw`/`x`) then `p`.

| Key | Action |
|-----|--------|
| `yy` / `Y` | copy the current line |
| `yw` · `y$` | copy a word · to end of line |
| `v`/`V`/`<C-v>`, then `y` | select (char/line/block), then copy |
| `p` / `P` | paste after / before the cursor |

**Search in a file**

| Key | Action |
|-----|--------|
| `/text` then `<Enter>` | search forward to the first match |
| `?text` then `<Enter>` | search backward |
| `n` / `N` | jump to next / previous match |
| `*` / `#` | search the word under the cursor (forward / back) |
| `<Esc>` or `:noh` | clear the match highlight |

**Files & search**

| Key | Action |
|-----|--------|
| `<Space>ff` | find files |
| `<Space>/` | grep in project |
| `<Space>e` | file explorer |
| `<Space>fn` | new file |

## Structure

```
.
├── install.sh              # one-command bootstrap
├── Brewfile                # declarative dependency list (brew bundle, macOS)
├── AGENTS.md               # project agent memory (CLAUDE.md symlinks to it)
├── config/
│   ├── wezterm/
│   │   └── wezterm.lua     # terminal appearance + behavior
│   ├── hammerspoon/
│   │   └── init.lua        # PaperWM window management + keybindings
│   ├── tmux/
│   │   └── tmux.conf      # tmux: Catppuccin Mocha, mouse, scrollback, keybinds
│   ├── nvim/               # LazyVim config (rose-pine-moon, transparent)
│   ├── agents/
│   │   └── AGENTS.md       # global agent instructions (Claude/Codex/AGENTS.md)
│   ├── firstmate/
│   │   └── crew-dispatch.json  # firstmate crew default model
│   ├── skills/
│   │   └── agentflow/      # this whole setup, as a Claude Code skill
│   └── starship.toml       # prompt
├── shell/
│   └── zshrc.snippet       # lines install.sh adds to ~/.zshrc
├── setup/
│   ├── hammerspoon.sh      # installs the pinned PaperWM release
│   ├── skills.sh           # installs agent skills (axi [reference], lavish)
│   └── tools.sh            # installs CLI binaries (no-mistakes, treehouse, gnhf, AXI CLIs) + clones firstmate
├── docs/
│   ├── nvim.md             # Neovim cheat sheet
│   ├── tools.md            # how to run each agentic tool in isolation
│   └── window-management.md # PaperWM behavior and keybindings
└── assets/                 # wallpaper / screenshots
```

## Roadmap

- [x] Terminal stack (WezTerm + Starship, rose-pine-moon)
- [x] PaperWM scrolling window management through Hammerspoon
- [x] tmux config (Catppuccin Mocha, mouse, scrollback, pane keybinds)
- [x] Readability tools (bat, eza, fzf)
- [x] Agentic toolchain (OpenSuperWhisper · AXI · lavish · no-mistakes · gnhf · treehouse · firstmate)
- [ ] Desktop wallpaper (lakeside pagoda at sunset — see `assets/`)
- [x] Neovim (LazyVim, rose-pine-moon)
- [x] Reproducible macOS bootstrap with Homebrew
- [ ] Security-lab tooling (wrap recon/scan CLIs as AXI tools)

## Credits

- Terminal style adapted from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix)
- Color scheme: [Rosé Pine (Moon)](https://rosepinetheme.com/)
