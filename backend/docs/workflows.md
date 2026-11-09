# Workflows

Per-project statuses grouped into categories, and optional transition rules between them. Always installed. gRPC only (`WorkflowController`, plus `TaskController.Move`), so it has no REST routes and is listed in `INSTALLED_APPS` directly. Phase 07; it replaces the three fixed task statuses of phase 06.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Status`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `project` | ForeignKey | → `projects.Project` |
| `name` | Char |  |
| `color` | Char |  |
| `category` | Char |  |
| `position` | PositiveInteger |  |
| `is_default` | Boolean |  |

#### `Transition`

An allowed move. Only consulted while the workflow restricts transitions.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `project` | ForeignKey | → `projects.Project` |
| `from_status` | ForeignKey | → `workflows.Status` |
| `to_status` | ForeignKey | → `workflows.Status` |
| `required_role` | ForeignKey | → `workspaces.Role`, nullable |
| `require_assignee` | Boolean |  |

#### `Workflow`

One per project. ``version`` is the optimistic lock of a whole-workflow save;

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `project` | OneToOne | unique, → `projects.Project` |
| `restrict_transitions` | Boolean |  |
| `restrict_creation` | Boolean |  |
| `version` | PositiveInteger |  |
<!-- /generated:models -->

## Admin

<!-- generated:admin -->
_This app registers nothing in the admin._
<!-- /generated:admin -->

## Setup

<!-- generated:settings -->
_This app requires no settings of its own._
<!-- /generated:settings -->

## Usage

### Layout

`infrastructure/workflows`: `models.py` (`Workflow`, `Status`, `Transition`), `drafts.py` (the editor's plain values), `validate.py` (the pure rules), `services.py` (everything with a database), `defaults.py` (the starting workflow, shared with the data migration), `signals.py`, `grpc/` (adapter, serializers, `workflows.proto`). `Task.status` (in `infrastructure/tasks`) is a foreign key to `Status`; the check on a move lives in `services.check_move` and is called by `tasks.services.update`.

### The workflow of a project

- **Created on first use** (`ensure`) with three statuses: *To do* (Not started, the default), *In progress* (Active), *Done* (Done). So a project made before this phase, or one nobody has opened, still has one; migrations `tasks/0002`-`0004` create it for every project that already has tasks and point each task at the status its old word meant (three migrations, not one: PostgreSQL refuses to ALTER a table in the transaction that just updated rows holding foreign keys). Concurrent first openers make exactly one (tested on PostgreSQL).
- **Statuses**: a name (1-40 characters, unique per project ignoring case), a colour (`#RRGGBB` or empty, stored upper-case), a **category** and a position. Categories are what reports and boards rely on, so a rename never breaks logic: `not_started`, `active`, `done`, `cancelled` (the last two are *final*). At most 30 statuses.
- **Rules** (`validate.py`, mirrored in the app so the editor answers while typing): at least one *Not started* and one *Done*; exactly one default, which is not final; unique names; known categories; transitions name real, distinct statuses once each. A saved workflow that violates any of them is impossible: an invalid draft is rejected whole.
- **Restrict transitions** (off by default): off means any status may move to any other, and the transition rows are ignored. On means only a move with a `Transition` row is allowed, and then the workflow must also be connected: every status reachable from the default, a *Done* status reachable, and no non-final status that leads nowhere (`STATUS_UNREACHABLE`, `NO_DONE_REACHABLE`, `STATUS_DEAD_END`).
- **Restrict creation** (a second switch, off by default, set per project by whoever may edit the workflow): off means a new task can be created in any status; on means it can only start in the default status and reaches the others by being moved (so the transition rules apply to every step). It is independent of *Restrict transitions*. A refused creation is the same `TRANSITION_NOT_ALLOWED`, with an empty `from` and the reason "New tasks must start in To do.", and burns no task number.
- **Conditions** on a transition: `required_role` (only people holding exactly that role may make the move; if the role is later deleted the condition is dropped with it, which relaxes the rule instead of blocking every move) and `require_assignee` (judged on the assignees *after* the same edit, so assigning and moving in one update works). A condition on the subtasks being done needs phase 08.

### Saving

`Workflow.Update(project, expected_version, restrict_transitions, restrict_creation, statuses[], transitions[], migrations[])` saves the **whole workflow in one transaction**. `statuses` is in display order (that order is `position`); `key` is a saved status's id, or any text the client invents for a new one, and `transitions` and `migrations` refer to statuses by `key`. The project row and the workflow row are locked, so two saves serialise.

- **Permission**: `project.update` (a project's creator holds it for their own project). Reading (`Get`) needs only `workspace.view` and a visible project. An archived project refuses a save (`PROJECT_ARCHIVED`).
- **Optimistic lock**: a stale `expected_version` is `ABORTED` / `VERSION_CONFLICT`. The version bumps on every save.
- **Invalid draft**: `INVALID_ARGUMENT` / `WORKFLOW_INVALID`. The trailer `x-error-errors-bin` is a JSON list of `{code, message, status_key}` (every problem, not the first), and nothing changed. Besides `validate.py` the database adds `STATUS_NEEDS_MIGRATION` and `TRANSITION_ROLE_UNKNOWN`.
- **Names may swap or be reused** in one save: every existing name is first set to a temporary one, then the final names are written, because names are unique per project.
- **Deleting a status moves its tasks.** A status that still has tasks (trashed ones included) must be given a target in `migrations` (a status that stays or a new one, never itself), otherwise `STATUS_NEEDS_MIGRATION`. The tasks move in the same transaction, read and written in batches of 500 (the project row stays locked meanwhile, so a very large status delays other writes to that project); each counts as an edit of the status field (`version` and `field_versions["status"]` bump), so a client holding the old version is told it changed. No task is ever left without a status (the foreign key is `PROTECT`). Rename, recolour and reorder never touch a task.
- `Workflow.Validate` is a dry run of `Update` with the same input: it answers `problems[]` (empty means it would save) and saves nothing. It needs `project.update` too.
- After a save `signals.workflow_changed(sender=Workflow, project_id, workspace_id, version)` is sent through `transaction.on_commit`; phase 16 turns it into a WebSocket event.

### Moving a task

A status change is `Update` with `status` (the id of a status of the task's own project; any other id is a 400) or the thin `TaskController.Move(project, id, expected_version, status)`. Both call `check_move`:

- the same status is never a move; without restriction every move is allowed; creating a task is not a move: it is free in any status unless the project turned on *Restrict creation* (then only the default status, see above);
- otherwise a refusal is `FAILED_PRECONDITION` / `TRANSITION_NOT_ALLOWED` with trailers `x-error-from-bin`, `x-error-to-bin` (status ids) and `x-error-reason-bin`, e.g. "To do → Done is not allowed.", "… needs an assignee first.", "… is only for the Admin role.". The task is unchanged.
- the rule is on the **service**, so it holds on every transport that exists for tasks (gRPC `Update` and `Move`). Tasks have no REST routes; any future one must call the same service.

### gRPC contract (`config.workflows`)

All requests carry `workspace_id` and `project_id`.

`Workflow{project_id, restrict_transitions, restrict_creation, version, statuses[StatusResponse{id, name, color, category, position, is_default, task_count}], transitions[TransitionResponse{from_status, to_status, required_role_id, require_assignee}]}`; `task_count` counts every task in the status, which is how many a delete would move. `Update` and `Validate` take `statuses[StatusInput{key, name, color, category, is_default}]`, `transitions[TransitionInput{from_key, to_key, required_role_id, require_assignee}]` and `migrations[MigrationInput{from_key, to_key}]`.

Errors as in [projects](projects.md), plus `WORKFLOW_INVALID` and `TRANSITION_NOT_ALLOWED` above.
