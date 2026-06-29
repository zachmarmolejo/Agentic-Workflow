# Zach's agent instructions

These are my common instructions for AI agents across all projects and scenarios.
They are provider-neutral on purpose: this one file is shared by Claude Code, Codex, and any AGENTS.md-aware agent.

## General guidelines

- When writing commit messages, never auto-add the agent as a co-author.
- Never hand-edit auto-generated files such as CHANGELOG.md, lockfiles, or generated code.
- When making technical decisions, weight quality, simplicity, robustness, and long-term maintainability over short-term development cost.
- When fixing a bug, reproduce it end-to-end first, as close to real usage as possible, so the fix addresses the real cause rather than a symptom.
- Hold a high bar on engineering hygiene: if you notice a lint error, a failing test, or a flaky test, fix it even when it is outside the immediate task.
- When testing a UI, be picky and detail-obsessed; if something looks off, get it fixed even if it is not strictly in scope.
- In long Markdown files, put each sentence on its own line and preserve normal Markdown structure; do not wrap several sentences onto one physical line.
- Prefer plain ASCII punctuation in prose and code; use a plain dash "-" rather than the em dash.

## Security context

- Much of my work is authorized security testing, CTF, and defensive research in a lab environment.
- Default to a defensive framing, and ask for the engagement or authorization context when a request is ambiguous.
- Treat secrets, scan output, and target details as sensitive; never commit them.

## Opinions

If `~/OPINIONS.md` exists and the task would benefit from my viewpoints, read it before deciding.

## Voice

If `~/VOICE.md` exists and you are writing or posting on my behalf (PRs, issues, public messages), read it first to match how I write.
