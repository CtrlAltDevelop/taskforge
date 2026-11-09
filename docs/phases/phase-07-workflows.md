# Phase 07 — Custom Workflows and Statuses

**Status:** TODO

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
- [ ] Rename/recolor/reorder doesn't affect any task
- [ ] Deleting a status migrates tasks atomically
- [ ] Disallowed move rejected on all transports, with reason displayed
- [ ] Editor works with touch on mobile

## Tests
Graph validation (unreachable, no terminal), migration on delete, role condition, Flutter editor widget tests.

## Depends on
Phases 04, 06.
