---
name: agentflow
description: >
  Zach's personal agentic-workflow setup, captured from the Agentic-Workflow repo:
  the terminal stack, Kun Chen's agent toolchain (firstmate, gnhf, treehouse,
  no-mistakes, lavish, axi, OpenSuperWhisper), Neovim, the global agent
  instructions, and the conventions that tie them together. Use when working on,
  extending, reproducing on a new machine, or troubleshooting this setup, any of
  those tools, the Agentic-Workflow repo, or firstmate crew configuration.
---

# agentflow

Zach's reproducible dev + agent setup.
Source of truth: `~/Agentic-Workflow` (https://github.com/zachmarmolejo/Agentic-Workflow).
Everything below is symlinked live from that repo, so to change anything you edit the file in the repo, then `git commit && git push`.

## The golden rule

This setup is reproducible by design.
Configs live in the repo and are symlinked into place by `~/Agentic-Workflow/install.sh`.
Editing a repo file changes the live system immediately (it is symlinked); then commit and push.
A fresh machine is one command: `git clone https://github.com/zachmarmolejo/Agentic-Workflow && cd Agentic-Workflow && ./install.sh`.

## Layout (repo path -> where it links)

- `config/wezterm/wezterm.lua` -> `~/.config/wezterm/` - WezTerm, rose-pine-moon, 80% opacity + blur.
- `config/starship.toml` -> `~/.config/` - Starship prompt.
- `config/nvim/` -> `~/.config/nvim/` - LazyVim, rose-pine-moon, transparent. Cheat sheet: `docs/nvim.md`.
- `config/agents/AGENTS.md` -> `~/.claude/CLAUDE.md`, `~/AGENTS.md`, `~/.codex/AGENTS.md` - one global instruction file for every agent.
- `config/firstmate/crew-dispatch.json` -> seeded into `~/firstmate/config/` - firstmate crew default model.
- `config/skills/agentflow/` -> `~/.claude/skills/agentflow/` - this skill.
- `Brewfile` (brew bundle), `setup/skills.sh` (agent skills), `setup/tools.sh` (CLI tools + firstmate clone).
- `docs/tools.md` - run each tool in isolation. `docs/nvim.md` - nvim cheat sheet.

## The agent toolchain (Kun Chen's ecosystem)

Full standalone usage lives in `~/Agentic-Workflow/docs/tools.md`. Quick map:

- OpenSuperWhisper - push-to-talk dictation (menu bar app).
- AXI - design principles for agent-ergonomic CLIs (`/axi`; reference/build-time skill).
- lavish - open agent-generated HTML for click-to-annotate feedback (`/lavish`, `lavish-axi <file>`).
- no-mistakes - AI gate: `git push no-mistakes` runs review/test/lint/docs then opens a clean PR. ~4 agent passes per push; trim with `--skip`.
- gnhf - bounded autonomous loop: `gnhf "objective" --max-iterations N --max-tokens N`.
- treehouse - reusable isolated worktree pool: `treehouse`, or `treehouse get --lease`.
- firstmate - orchestrator: `cd ~/firstmate && claude`, talk to the first mate, it runs a crew in tmux.

## Conventions

- Never add an agent co-author trailer to commits (no `Co-Authored-By`). Canonical source: the global AGENTS.md.
- Long Markdown: one sentence per line; plain ASCII punctuation, plain `-` not em dash.
- Prefer staying on upstream plus config over carrying code patches.
  Lesson: a local `--model` patch to firstmate went stale in a day when upstream shipped its own; the durable fix was a config file at the tool's own extension point.

## firstmate specifics

- Crew default model lives in `~/firstmate/config/crew-dispatch.json` (gitignored in firstmate, so upstream updates never touch it; seeded from `config/firstmate/crew-dispatch.json`).
  Current default: `claude` / `claude-opus-4-6`, effort medium. Add `rules` for per-task harness/model/effort.
- After editing crew-dispatch, restart the firstmate session so the first mate re-reads it.
- Launching `claude` inside `~/firstmate` warns its CLAUDE.md is over 40k chars; that is expected and it still loads in full.
- Update firstmate with `/updatefirstmate`; it depends on treehouse + no-mistakes + tmux (all installed).

## Common tasks

- New machine: clone the repo, run `./install.sh`.
- Add a brew app: edit `Brewfile`. Add an agent skill: edit `setup/skills.sh`. Add a CLI tool: edit `setup/tools.sh`.
- Change a config: edit it under `~/Agentic-Workflow/` (symlinked live), then commit and push.
