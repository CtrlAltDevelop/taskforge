# Phase 09 — Task Dependencies

**Status:** DONE

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

## As built
- `LinkController` (`Add`, `Remove`, `ListForTask`, `SearchTasks`) beside `TaskController`; links are changed with `task.update` and read with `workspace.view`, no new permission key. Kinds are seen from the asked-about task: `blocks`, `blocked_by`, `relates`, `duplicates`, `duplicated_by`. `SearchTasks` finds live tasks (title or `KEY-N`) in every project the caller can open, for the picker.
- A hidden far end reads back as `restricted` and shows as "Restricted task" in the links, in a `LINK_CYCLE` path, in the `TASK_BLOCKED` blocker list and in `Task.blocked_by`. Adding a link needs both ends open to the caller and neither project archived.
- A blocking link takes the workspace lock before the loop check, so two opposite links added together cannot both be stored (a parallel test on PostgreSQL fails without the lock). A soft-deleted task blocks nothing and is skipped by the loop check; its links stay until purge.
- Completing a blocked task is `FAILED_PRECONDITION TASK_BLOCKED`; `x-error-can_override-bin` says whether this caller may go ahead, and the app offers "Complete anyway" exactly then (also when completing with subtasks). `override_blocked` on `Update` / `Move` works for whoever holds `project.update` for the project (creator rule included) and is recorded in `BlockOverride` with the real blocker ids.
- `Task.is_blocked` and `Task.blocked_by` (`WEB-4 (In progress)`) are set on every task the service returns, the trash list included; the lock's tooltip in list rows and in the detail names the blockers.
- Adding or removing a link announces `linked` / `unlinked` for both tasks through `task_changed` (phase 16 turns it into a WebSocket event).
- `close_duplicate` moves the duplicate to the project's Cancelled status, or Done when it has none.
- The app opens a link to a task of another project as `/projects/<id>?task=<id>`; the task opens beside the list on wide screens and as a page on narrow ones.
- Not done: a board badge (no board until phase 12).
- Run on PostgreSQL (tasks, workflows, projects and workspaces suites, including the parallel opposite-links race); not run in a real browser or on a device.
