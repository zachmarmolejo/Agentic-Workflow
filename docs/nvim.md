# Neovim cheat sheet

For the LazyVim setup in this repo (`config/nvim/`, rose-pine-moon). Leader = `<Space>`.

Neovim is **modal** — that's the part that trips people up. Press `<Space>` and
pause anytime to get the which-key menu, which lists every shortcut.

> Open this file from inside nvim with `:e ~/Agentic-Workflow/docs/nvim.md`.

## Modes

| Key | Mode |
|-----|------|
| `i` / `a` | insert — type text |
| `<Esc>` | back to **normal** mode (stop editing) |
| `v` | visual — select |
| `:` | command line |

## Get out / around

| Key | Action |
|-----|--------|
| `<Space>h` | back to the dashboard (custom keymap) |
| `<Space>` then wait | which-key menu — shows everything |
| `:w` · `:q` · `:wq` | save · quit window · save+quit |
| `<Space>qq` | quit all |

## Buffers (open files)

| Key | Action |
|-----|--------|
| `<Space>,` | list / switch buffers |
| `<Space>bb` | switch to previous buffer |
| `<Space>bd` | close current buffer |
| `<Space>bD` | close buffer + window |

## Windows / splits

| Key | Action |
|-----|--------|
| `<Space>-` · `<Space>\|` | split below · split right |
| `<C-h/j/k/l>` | move between splits |
| `<Space>wd` | close current split |
| `<C-w>o` | unsplit — close all *other* splits |

## Search in a file

| Key | Action |
|-----|--------|
| `/text` then `<Enter>` | search forward to the first match |
| `?text` then `<Enter>` | search backward |
| `n` / `N` | jump to next / previous match |
| `*` / `#` | search the word under the cursor (forward / back) |
| `<Esc>` or `:noh` | clear the match highlight |

## Files & search

| Key | Action |
|-----|--------|
| `<Space>ff` | find files |
| `<Space>/` | grep in project |
| `<Space>e` | file explorer |
| `<Space>fn` | new file |

---

Config lives in `config/nvim/` — keymaps in `lua/config/keymaps.lua`, theme in
`lua/plugins/colorscheme.lua`.
