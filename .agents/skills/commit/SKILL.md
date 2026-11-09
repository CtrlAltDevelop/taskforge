---
name: commit
description: Commit the TaskForge working tree as separate logical commits in the project's Conventional Commits format, after reading every diff; push only when asked. Use when the user says commit, commit changes, or push.
---

# Commit

Rules are in `AGENTS.md` (workflow rule 5). Format: `<type>: <description>` with
types `feat fix refactor docs test chore perf ci`; optional body wrapped at 72
explaining what and why. Subject imperative, ≤ 50 chars, no trailing period.
Mention the phase in the body when relevant ("Phase 06 — Tasks").

## Rules that never bend

- **Commit only when the user asks.** Never push unless they ask for that too.
- **One logical change per commit.** Docs, backend and app changes of one phase
  may be separate commits when they stand alone.
- **Read every diff before committing it**, including changes you did not make.
- Never commit secrets, `.env`, tokens, or generated junk (`build/`, `.dart_tool/`).

## Steps

1. **Survey** — `git status --short`, `git diff --stat`, untracked files.
2. **Read** — `git diff -- <paths>` for everything unfamiliar; leave out anything
   that looks accidental and say why.
3. **Verify** — run the `verifier` agent (or at least tests for touched code).
4. **Group** by logical unit; order so each commit builds on the last.
5. **Start clean** — `git reset -q`, then `git add -A -- <explicit paths>`.
6. **Message** — pass through a heredoc: `git commit -F - <<'MSG'`.
7. **Check** — `git log --oneline -<n>` and `git status --short`.

## Report

A table `Commit | What`, then what was left uncommitted and why.
