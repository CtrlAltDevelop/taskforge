---
name: commit
description: Commit the TaskForge working tree as separate logical commits in the project's emoji Conventional Commits format, after reading every diff; push only when asked. Use when the user says commit, commit changes, or push.
---

# Commit

Rules are in `AGENTS.md` (workflow rule 5); this file is the detail. Style is
copied from `broker_crm_app/docs/GIT_COMMIT_CONVENTIONS.md`.

## Format

```
<emoji> <type>(<scope>): <subject>

<body>

<footer>
```

- Subject: imperative, ≤ 50 chars after the emoji, no trailing period.
- Scope: area touched, optional — `auth`, `tasks`, `app/auth`, `backend`, `deploy`, `docs`.
- Body (optional): wrapped at 72, explains what and why. Mention the phase
  ("Phase 06 — Tasks").
- Footer (optional): `Closes #n`, breaking changes.
- Emoji must match the type.

| Icon | Type | Use for |
|------|------|---------|
| 📦 | `add` | New feature or capability |
| 🛠️ | `fix` | Bug fix |
| 🔃 | `refactor` | Restructuring, no behavior change |
| ⚡ | `perf` | Performance improvement |
| 💫 | `style` | Formatting only |
| 🧪 | `test` | Adding or correcting tests |
| 📄 | `document` | README, docs, comments |
| 🏗️ | `build` | Build system, project version |
| ⚙️ | `ci` | CI/CD config and scripts |
| 🧹 | `chore` | Misc (gitignore, tooling) that is not `upgrade` |
| 🖥️ | `ops` | Infra, deployment, backup |
| ⏪ | `revert` | Reverting a previous commit |
| 🚀 | `release` | Cutting a release |
| 🗑️ | `remove` | Deleting code, files, dead functionality |
| 🔼 | `upgrade` | Bumping a dependency |

Example: `📦 add(app/auth): add sign-in, sessions and account screens`

## Rules that never bend

- **Commit only when the user asks.** Never push unless they ask for that too.
- **One logical change per commit.** Docs, backend and app changes of one phase
  may be separate commits when they stand alone.
- **No attribution lines** — no `Co-Authored-By`, no "Generated with" footer.
- **Read every diff before committing it**, including changes you did not make.
- Never commit secrets, `.env`, tokens, or generated junk (`build/`, `.dart_tool/`).

## Steps

1. **Survey** — `git status --short`, `git diff --stat`, untracked files.
2. **Read** — `git diff -- <paths>` for everything unfamiliar; leave out anything
   that looks accidental and say why.
3. **Verify** — run the `verifier` agent (or at least tests for touched code).
4. **Group** by logical unit; order so each commit builds on the last.
5. **Start clean** — `git reset -q`, then `git add -A -- <explicit paths>`.
6. **Message** — pass through a heredoc so emoji and quotes survive:
   `git commit -F - <<'MSG'`.
7. **Check** — `git log --oneline -<n>` and `git status --short`.

## Report

A table `Commit | What`, then what was left uncommitted and why.
