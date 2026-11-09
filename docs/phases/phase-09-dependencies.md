# Phase 09 — Task Dependencies

**Status:** TODO

## Feature
Link tasks with typed relations — **blocks / blocked by**, **relates to**, **duplicates** — with cycle protection and a "blocked" indicator.

## Why it exists
Jira links exist but don't schedule or warn well; ClickUp dependencies are paywalled on lower plans and easy to turn into loops. Here they are free, safe, and visible everywhere.

## How it works (plain words)
From a task, add a link: choose type and the other task. *Blocks* means the other task cannot be finished until this one is done. A blocked task shows a lock badge and cannot move to a *Done* category until its blockers are done (warning, with an override for admins). The link is stored once and displayed from both sides ("blocks X" / "blocked by Y"). A *duplicates* link can optionally close the duplicate.

## Scope
**In:** link types, add/remove, both-side display, blocked badge, completion guard, cycle check for blocking chains, cross-project links within the workspace.
**Out:** automatic date shifting and the visual arrows (phase 15 timeline uses these links).

## Data model
- `TaskLink(id, workspace, from_task, to_task, type)`; unique `(from, to, type)`; `relates` stored with ordered pair to avoid mirrored duplicates.
- `Task.is_blocked` derived (computed in query or cached column updated by service).

## API surface
- gRPC: `Links.Add`, `Remove`, `ListForTask`
- Error `LINK_CYCLE{path}` lists the loop.

## Flutter UI
"Links" section in task detail grouped by type, task picker with search, red lock badge in lists/boards, tooltip "Blocked by WEB-4 (In progress)". Warning dialog on completing a blocked task.

## Rules and edge cases
- Cannot link a task to itself; cannot create a blocking cycle (A→B→C→A) — detected with graph walk.
- Cross-project links respect permissions: user must be able to see both ends, otherwise the far end shows as "Restricted task".
- Deleting a task removes its links (soft-deleted tasks keep them until purge).

## Acceptance criteria
- [ ] All types add/remove and show on both sides
- [ ] Cycle rejected with readable path
- [ ] Blocked guard works, admin override recorded
- [ ] Restricted far-end never leaks title

## Tests
Cycle detection (long chains), permission leakage test, duplicate-close behavior, derived `is_blocked` updates when blocker completes.

## Depends on
Phases 06, 07.
