# Phase 07 — Custom Workflows and Statuses

**Status:** DONE

## Feature
Each project defines its own **statuses** grouped into categories, and optional **transition rules** between them, edited in a visual workflow editor.

## Why it exists
Jira's workflow editor is powerful but fragile (broken workflows block issues; changes need migrations). ClickUp statuses are flexible but have no rules. We give both: simple by default, rules when you want them, and **validation that prevents orphaned tasks**.

## How it works (plain words)
A status has a name, color and a **category**: *Not started*, *Active*, *Done*, *Cancelled*. Reports and boards rely on the category, so you can rename "QA review" freely without breaking logic. By default any status can move to any other. If you turn on **Restrict transitions**, you draw allowed arrows (e.g. Review → Done only). Transitions can require conditions: *assignee set*, *all subtasks done* (once 08 exists), or *only role X*. When you delete a status you must choose where its tasks go — the editor will not let you save otherwise.

## Scope
**In:** statuses CRUD + reorder, categories, default workflow template, restrict-transitions toggle, transition graph editor, conditions (assignee, role), mass-migration of tasks on delete, workflow validation.
**Out:** automation side-effects on transition (24), subtask-condition (needs 08, enabled when available).

## Data model
- `Status(id, project, name, color, category, position, is_default)`
- `Transition(project, from_status, to_status, required_role nullable, require_assignee bool)`
- `Task.status` becomes FK to `Status`.

## API surface
- gRPC: `Workflow.Get/Update` (whole workflow saved atomically), `Workflow.Validate` (dry run), `Tasks.Move(task, to_status)`
- Error `TRANSITION_NOT_ALLOWED{from,to,reason}`.

## Flutter UI
Settings → Workflow: draggable status list on mobile; on desktop/web a node-and-arrow canvas. Validation panel lists problems ("No Done status", "Status X unreachable"). Task status picker shows only allowed targets.

## Rules and edge cases
- At least one status in *Not started* and one in *Done*.
- Exactly one default status for new tasks.
- Workflow save is a single transaction; invalid graph rejected with a list of errors.
- Existing tasks never become invalid: migration step is mandatory.

## Acceptance criteria
- [x] Rename/recolor/reorder doesn't affect any task
- [x] Deleting a status migrates tasks atomically
- [x] Disallowed move rejected on all transports, with reason displayed
- [x] Editor works with touch on mobile

## Tests
Graph validation (unreachable, no terminal), migration on delete, role condition, Flutter editor widget tests.

## Depends on
Phases 04, 06.

## As built (differs from the plan)
- A `Workflow` row per project (`restrict_transitions`, `version`) holds the restrict flag and the optimistic lock of a whole-workflow save; `Status` and `Transition` are as planned. The workflow is created on first use (three default statuses), and migrations `tasks/0002`-`0004` convert every existing task, so nothing changes for anyone.
- `Workflow.Get/Update/Validate` as planned; `Update` takes the whole workflow with `key`s (a saved status's id, or any text for a new one) and a `migrations` list for deleted statuses. `Tasks.Move` is `TaskController.Move`; a status change through `Update` is checked the same way.
- `TRANSITION_NOT_ALLOWED` is gRPC `FAILED_PRECONDITION` with trailers `from`, `to`, `reason` (status ids and a sentence). "All transports" means the service layer: tasks only have gRPC, and any future route must call `tasks.services.update`.
- Rule additions: the default status may not be Done or Cancelled; a restricted workflow must also be connected (every status reachable from the default, a Done reachable, no non-final dead end). The role condition means exactly that role; if the role is deleted the condition is dropped (relaxes, never blocks).
- The status list is the same on every width (touch drag handles; no per-width variant). Wide screens add a read-only node-and-arrow picture of the draft beside it; arrows are edited as chips on each status card, not by drawing on the canvas. The editor mirrors the server's rules locally so problems show while typing; the server stays the authority.
- Creating a task is free in any status by default. A project admin can turn on **Restrict creation** (per project, off by default, part of the workflow save): new tasks then start in the default status only and reach the others by being moved, so the transition rules apply to every step. The default status itself may never be Done or Cancelled.
- Code review found and fixed: the migration is split in three so PostgreSQL can run it on a database that already has tasks; deleting a status that earlier deletions pointed tasks at keeps their place; a delete the server refuses for tasks it did not know of offers a target instead of sticking; a dry run still in flight cannot mark a discarded or just-saved draft; status names are counted in code points like the server.
- A save that conflicts never changes anything silently: the draft is kept and three-way merged with what the other person saved (`workflow_merge.dart`: a field only I changed stays mine, only they changed becomes theirs, both changed becomes theirs; statuses and moves they added are added, ones they deleted stay deleted, one I deleted but they edited is kept; their work is never overwritten). Every decision is listed in a banner, and Save stays off until the person reads it and keeps the draft, or throws the draft away to start from what was saved.
- Not done: the *all subtasks done* condition (needs phase 08), automation side-effects (24).
- Not verified in a real browser or on a device.
