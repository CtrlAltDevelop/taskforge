# Tasks

Tasks inside a project: title, rich description, status, priority, dates and assignees, with soft delete, field-level optimistic locking and a server-streamed list. Always installed. gRPC only (`TaskController`), so it has no REST routes and is listed in `INSTALLED_APPS` directly. Phase 06; the WebSocket event bridge is phase 16.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Task`

``version`` is the whole-row counter; ``field_versions`` maps each field to the version

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `number` | PositiveInteger |  |
| `title` | Char |  |
| `description` | JSON |  |
| `status` | ForeignKey | → `workflows.Status` |
| `priority` | Char |  |
| `start_date` | Date | nullable |
| `due_date` | Date | nullable |
| `created_by` | ForeignKey | → `accounts.User` |
| `version` | PositiveInteger |  |
| `field_versions` | JSON |  |
| `position` | Char |  |
| `parent` | ForeignKey | → `tasks.Task`, nullable |
| `depth` | PositiveSmallInteger |  |
| `path` | Char |  |
| `tree_key` | Char |  |
| `progress_done` | PositiveInteger |  |
| `progress_total` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
| `deleted_at` | DateTime | nullable |

#### `TaskAssignee`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `user` | ForeignKey | → `accounts.User` |
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

`infrastructure/tasks`: `models.py`, `fields.py` (validation), `rank.py` (fractional-index positions), `services.py` (every rule), `signals.py`, `grpc/` (adapter, serializers, `tasks.proto`). The `task.*` permission keys live in the single workspaces registry; their grants migration is `workspaces/migrations/0010_task_permissions.py`.

### Permissions

`Get` and `List` need only `workspace.view`; `Create` `task.create`; `Update` `task.update`; `Delete`, `Restore` and `ListTrash` `task.delete`. Owner, Admin and Member hold all three; Viewer none. Every call runs `access.require`, then loads the project through `projects.services.load` (`visible_to`), then the task inside that project, so a private project, a foreign project and a task id from another project are all `NOT_FOUND`. Writes to an archived project are `PROJECT_ARCHIVED`.

### Rules

- **Display id** `KEY-N`: `N` comes from `projects.services.next_task_number` inside the creating transaction (the project row lock). Numbers are never reused, including after delete. Unique per `(project, number)`; 50 parallel creates are tested on PostgreSQL (`make test-postgres`).
- **Title** 1-500 characters. **Status** is one of the project's workflow statuses ([workflows](workflows.md)), sent as the status id (`status_name` and `status_category` come back with it); a new task starts in the default status unless `Create` names another (a project can turn that off with *Restrict creation*: then only the default status is accepted). A status change must be allowed by the workflow (`TRANSITION_NOT_ALLOWED`); `Move` is `Update` of the status alone. **Priority** `urgent | high | normal | low | none`. **Dates** `YYYY-MM-DD` or empty; `due_date` may not precede `start_date` (checked against the stored other date on update).
- **Description** is the rich-text JSON document sent as a string: `{"type": "doc", "content": [...]}` with block nodes `paragraph heading bullet_list ordered_list list_item checklist checklist_item code_block blockquote horizontal_rule` and inline nodes `text hard_break link`, at most 8 levels deep and 200 KB. `""` clears it. The format is shared with Docs later.
- **Assignees** (multiple): each must be an active workspace member and, for a private project, one of its members; otherwise `INVALID_ARGUMENT`. The same user in any letter case counts once.
- **Update by field mask**: `TaskUpdateRequest` carries only the fields to change (proto3 `optional`, so `""` is a real value that clears a date) plus `expected_version`; `set_assignees` plus `assignee_ids` replaces the assignee set. The task keeps `field_versions` (field -> version that last changed it). A field conflicts only if it changed after `expected_version`; different fields merge. A conflict is `ABORTED` / `VERSION_CONFLICT` with trailers `x-error-field-bin`, `x-error-current-bin` (the current value; assignees as sorted comma-joined ids; description as JSON) and `x-error-version-bin`. The row is locked `select_for_update` for the check and write, and `version` bumps once per update. `expected_version` must be between 1 and the task's current version, otherwise `INVALID_ARGUMENT`: a made-up huge version would pass every field check and silently defeat the lock.
- **Soft delete**: `Delete` sets `deleted_at` (bumps `version`); trashed tasks are invisible to Get, List and Update; `Restore` clears it. `ListTrash(workspace_id, project_id)` returns the project's deleted tasks, newest deletion first (at most 200), so a task can be found again after the Undo moment has passed. All three need `task.delete`; Delete and Restore also refuse an archived project, ListTrash does not.
- **Position** is a rank string (`rank.py`): appends count in fixed width (6 characters, however many tasks) and `rank.between(a, b)` returns a string strictly between two neighbours, for cheap reordering later. Lowercase letters only, so the order is the same under any database collation.
- **Realtime hook**: `signals.task_changed(sender=Task, task_id, project_id, workspace_id, version, action)` is sent through `transaction.on_commit` (`created updated deleted restored`; never on rollback). Phase 16 turns it into `task.created|updated|deleted`; no socket code exists yet.

### Subtasks

A task can have one parent task of the **same project**; a subtask can have subtasks of its own, to any depth up to a hard cap of 24 levels (the app stops offering more at 8). There is no cross-project parent, and no moving a subtree to another project (tasks cannot change project in this phase).

- **Shape**: every task stores `parent`, `depth` (0 at the top), `path` (the ids of all its ancestors and itself, each followed by `/`, so a subtree is one `path__startswith` query) and `tree_key` (the `position` of each ancestor and itself, each followed by `0`). `tree_key` is what orders the list: a parent sorts right before its own subtasks, and the `0` separator sorts before every rank letter in any database collation (a `/` would not: collations that ignore punctuation order `a/b` after `ab`). A task's `position` is a rank among its siblings only.
- **Create** with `parent_id` (a live task of the project, else a 400). **`SetParent(id, expected_version, parent_id)`** makes a task a subtask of another (or top-level with `""`), together with everything under it: one `UPDATE` rewrites `path`, `tree_key` and `depth` of the whole subtree (deleted descendants too, so a later restore finds them in place). It needs `task.update`, conflicts like any field (`field: "parent"`), is refused in an archived project, and never allows a **cycle** (a task under itself or one of its own subtasks, `INVALID_ARGUMENT`) or a subtree that would pass the depth cap. Putting a task under its current parent is a no-op.
- **Progress**: `progress_total` is the number of live descendants (any depth) and `progress_done` how many of them are in a *done*-category status (a cancelled one counts in the total, not as done). It is recounted for every ancestor in the same transaction as each change that can alter it: create, a status change, delete, restore, re-parent (the old and the new ancestors), and a move with subtasks. Every task write already holds the project row lock, so two writers never count the same subtree at once (tested on PostgreSQL with parallel children finishing at once).
- **Listing**: `List(include_subtasks)` returns only top-level tasks unless `include_subtasks`, then every task in tree order, in keyset pages of `(tree_key, number)`. `ListChildren(id)` returns the direct subtasks in order.
- **Delete**: a task with live subtasks must say what happens to them, else `INVALID_ARGUMENT` / `HAS_SUBTASKS` with `x-error-count-bin` (how many): `mode=subtree` deletes them with it, all stamped with the same `deleted_at`; `mode=promote` first moves each direct child (with its subtree) up to the deleted task's own parent. A task without subtasks ignores the mode.
- **Restore** brings back the task and the descendants that were deleted in the same batch (same `deleted_at`); ones deleted separately earlier stay in the trash. A task whose parent is still deleted comes back as a top-level task.
- **Complete with subtasks**: `Move(include_subtasks)` also moves every open live subtask to the same status in one transaction (one already done is left alone when the target is a done status). Each must be allowed to make that move under the workflow, or nothing at all is moved.
- **Workflow condition** "all subtasks done" (`Transition.require_subtasks_done`, see [workflows](workflows.md)): the move is refused with `TRANSITION_NOT_ALLOWED` and "needs all subtasks done first (N still open)" while any live subtask is not done or cancelled; deleted subtasks do not count. It is satisfied by `Move(include_subtasks)`, which finishes them in the same step.
- **Signal**: `task_changed` also announces `reparented` (and a `deleted` for every task of a deleted subtree); no WebSocket code exists yet (phase 16).

### The streamed list

`List(workspace_id, project_id, status, assignee_id, cursor, page_size)` returns `stream Task` in board order (`position`, then `number`). The server reads keyset pages (default 100, at most 500) and yields them one by one, so the first messages arrive after one indexed query and memory stays flat for any project size. `cursor` resumes after a task (opaque; malformed is `INVALID_ARGUMENT`). Each page costs a constant number of queries (assignees are prefetched in one). Measured by `tests/test_scale.py` (10,000 tasks) on SQLite and PostgreSQL.

### gRPC contract (`config.tasks`)

All requests carry `workspace_id` and `project_id`. Responses are `Task` (`List` streams them).

`TaskTrash{tasks[]}` is the `ListTrash` reply.

`Task{id, workspace_id, project_id, number, display_id, title, description, status, status_name, status_category, priority, parent_id, depth, progress_done, progress_total, start_date, due_date, assignee_ids[], created_by, version, position, created_at, updated_at, deleted_at}` (dates and timestamps are ISO strings, `""` when unset).

Errors as in [projects](projects.md): `PERMISSION_DENIED` (with reason trailers), `NOT_FOUND`, `INVALID_ARGUMENT`, `ALREADY_EXISTS` `PROJECT_ARCHIVED`, `ABORTED` `VERSION_CONFLICT`. A refusal raised inside the `List` stream ends it with the same status.
