# Agentic toolchain — usage & running in isolation

The seven tools below are installed by `./install.sh` (via the `Brewfile`,
`setup/skills.sh`, and `setup/tools.sh`). They compose into one workflow, but
each runs **standalone** — this is the quick reference for using any of them on
its own.

> Most are agent-agnostic and default to your first available harness
> (`claude`, then `codex`). The CLI binaries live in `~/.local/bin`; gnhf/AXI
> CLIs are npm globals. Skills show up as `/slash-commands` in new Claude Code
> sessions.

---

## 1. OpenSuperWhisper — dictation
Menu-bar push-to-talk dictation (Whisper/Parakeet); inserts text into any field.

```sh
open -a OpenSuperWhisper      # launch (lives in the menu bar — no CLI)
```
- Hold your shortcut (e.g. Right ⌥ / Fn), speak, release → text lands at the cursor.
- Model / shortcut / mic are configured from the menu-bar icon.

## 2. AXI — agent-ergonomic CLI design (reference skill)
Principles for building CLIs that agents drive efficiently. Fires only when you're authoring/reviewing a CLI.

```sh
/axi                          # (in Claude Code) load the principles
npx skills use kunchenguid/axi   # invoke on-demand without installing
npx -y gh-axi --help          # reference implementations you can run directly
npx -y chrome-devtools-axi --help
```

## 3. lavish — interactive HTML artifacts
Open agent-generated HTML in the browser; click elements / select text to send feedback back to the agent.

```sh
/lavish <what the artifact should show>   # (in Claude Code)

lavish-axi <file.html>        # standalone: serve + open in browser
lavish-axi poll <file.html>   # long-poll for your feedback (leave it running)
lavish-axi end  <file.html>   # end the session
lavish-axi stop               # shut down the local server
lavish-axi playbook <id>      # guidance: diagram|table|comparison|plan|code|input|slides
```

## 4. no-mistakes — AI validation gate before push
Per-repo gate: push to it, it runs review → test → lint → docs in a throwaway worktree, then opens a clean PR.

```sh
cd <repo>
no-mistakes init              # one-time per repo: set up gate + install /no-mistakes skill
git push no-mistakes <branch> # run the pipeline
no-mistakes                   # ...or the TUI wizard (commit + push + attach)
/no-mistakes <task>           # ...or drive it headlessly from Claude Code

no-mistakes status            # current run        no-mistakes runs    # history
no-mistakes doctor            # health check       no-mistakes eject   # remove the gate
no-mistakes --skip docs,lint  # cheaper run — fewer agent passes = fewer tokens
no-mistakes axi status        # non-interactive TOON view (agent interface)
```
> No token counter — cost lands in your Claude usage (≈4 agent passes per push). Trim with `--skip`.

## 5. gnhf — bounded autonomous loop
"Good night, have fun." Loops your agent toward an objective, one committed change per iteration, until a cap.

```sh
cd <repo>                     # clean working tree required (git init first if needed)
gnhf "your objective"                                # runs on a new gnhf/ branch
gnhf "..." --max-iterations 10 --max-tokens 5000000  # bounded overnight run
gnhf "..." --current-branch --push                   # commit + push on the current branch
gnhf --worktree "task A" &  gnhf --worktree "task B" &   # parallel runs via worktrees
gnhf                          # re-run with no prompt to RESUME the last run
```
- Prints token totals + commit count in its exit summary. `Ctrl+C` to stop; `--mock` for a no-token demo.

## 6. treehouse — reusable worktree pool
Pre-warmed isolated git worktrees so parallel agents never collide; deps/cache survive between uses.

```sh
cd <repo>
treehouse                     # acquire a worktree + drop into a subshell ('exit' returns it)
treehouse get --lease         # non-interactive: reserve one, print its absolute path
treehouse status              # show the pool
treehouse return <path> [--force]   # return to pool (--force discards uncommitted changes)
treehouse prune               # remove stale worktrees      treehouse destroy   # empty the pool
```

## 7. firstmate — multi-agent orchestrator
You're the captain; you talk to one "first mate" that spawns a crew of agents in tmux worktrees and hands you PRs.

```sh
tmux                          # recommended — watch the crew windows live
cd ~/firstmate && claude      # AGENTS.md takes over — this claude is now your first mate
# then just talk:
#   "ahoy! scout task: <investigate / summarize X>"      → read-only, cheap
#   "ahoy! <fix bug / add feature> in project <repo>"    → ship task → PR via no-mistakes
#   "merge it"                                           → explicit approval to merge a PR

bash ~/firstmate/bin/fm-bootstrap.sh   # toolchain self-check (silent = ready)
```
- Projects are cloned under `~/firstmate/projects/`; crewmate tmux windows are named `fm-<id>`.
- Depends on **treehouse + no-mistakes + tmux** (all installed here). Update with `/updatefirstmate`.

> **Expected warning:** launching `claude` inside `~/firstmate` shows "CLAUDE.md is over the 40.0k-char limit (~88k chars)". That file is firstmate's full orchestrator manual (`CLAUDE.md` -> `AGENTS.md`); Claude Code loads it in full despite the warning, so it's cosmetic - nothing to fix, and don't trim it.
