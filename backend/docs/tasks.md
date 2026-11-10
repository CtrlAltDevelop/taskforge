# Tasks

Tasks inside a project: title, rich description, status, priority, dates and assignees, with soft delete, field-level optimistic locking and a server-streamed list. Always installed. gRPC only (`TaskController`), so it has no REST routes and is listed in `INSTALLED_APPS` directly. Phase 06; the WebSocket event bridge is phase 16.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `BlockOverride`

The record an override leaves: who completed a blocked task anyway, and the open blockers.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | ForeignKey | → `tasks.Task` |
| `actor` | ForeignKey | → `accounts.User` |
| `blockers` | Text |  |
| `created_at` | DateTime |  |

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
| `due_time` | Time | nullable |
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

#### `TaskLink`

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `from_task` | ForeignKey | → `tasks.Task` |
| `to_task` | ForeignKey | → `tasks.Task` |
| `type` | Char |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `created_at` | DateTime |  |

#### `WorkingCalendarSetting`

Which weekdays a workspace works (0 Monday ... 6 Sunday) and its holidays (ISO dates). No

| Field | Type | Notes |
| --- | --- | --- |
| `workspace` | OneToOne | primary key, → `workspaces.Workspace` |
| `days` | JSON |  |
| `holidays` | JSON |  |
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

### Links

`links.py`, over gRPC as `LinkController` (`Add`, `Remove`, `ListForTask`, `SearchTasks`; `task.update` to change, workspace membership to read and to search). A link is stored once (`TaskLink`, `from_task` → `to_task`) and read from both ends as a `kind`: `blocks` / `blocked_by`, `relates`, `duplicates` / `duplicated_by`. `relates` is stored in id order, so it has no mirror image.

- A task cannot link to itself or repeat a link (`LINK_EXISTS`); a chain of `blocks` may not loop (`LINK_CYCLE`, `x-error-path-bin` names the loop, iterative walk, one query per hop).
- Both ends must be tasks the caller can open (else 404). A far end the caller cannot open reads back as `restricted` with no id, title or status, and as "Restricted task" in a cycle path or blocker list.
- A blocking link takes the workspace lock before the loop check (two opposite links added at once cannot both be stored); the loop check skips soft-deleted tasks.
- A task with an open blocker (alive, not done or cancelled) is `is_blocked` (`Task.blocked_by` names the blockers as the caller may see them) and cannot move into a Done status (`TASK_BLOCKED`, `x-error-blockers-bin`, `x-error-can_override-bin`). `override_blocked` on `Update` / `Move` lets someone who holds `project.update` for the project (or created it) do it anyway; each use is stored as a `BlockOverride` with the real blocker ids. Subtasks moved along with a parent are checked the same way.
- `close_duplicate` on a `duplicates` link moves the duplicate to the project's Cancelled status, or Done if it has none.
- Adding or removing a link announces `linked` / `unlinked` for both tasks (`task_changed`, for phase 16).
- A soft-deleted task keeps its links but stops blocking and is hidden from `ListForTask`; a purge removes them.

### The streamed list

`List(workspace_id, project_id, status, assignee_id, cursor, page_size)` returns `stream Task` in board order (`position`, then `number`). The server reads keyset pages (default 100, at most 500) and yields them one by one, so the first messages arrive after one indexed query and memory stays flat for any project size. `cursor` resumes after a task (opaque; malformed is `INVALID_ARGUMENT`). Each page costs a constant number of queries (assignees are prefetched in one). Measured by `tests/test_scale.py` (10,000 tasks) on SQLite and PostgreSQL.

### Sorting, grouping and counts

`List` also takes `sort[]` (`key`, `desc`; at most 3 keys) and `group_by`. Keys: `title`, `status` (workflow order), `priority` (urgent first), `start_date`, `due_date`, `created_at`, `updated_at`, `field:<id>` (any field type but multi-select; typed columns, nulls last). `group_by`: `status`, `priority`, `assignee` (first assignee) or `field:<id>` of a select field. Groups come one after another; each task then carries `group_key` (set on list reads only; `""` is the group with no value). The order ends with `number`, so paging is stable; a cursor is only valid for the sort it was made with. A custom field archived after a layout chose it is dropped from the sort and grouping instead of failing the list. Code: `listing.py`.

`GroupCounts(workspace_id, project_id, group_by, status, assignee_id, include_subtasks)` returns `{group_key, count}` per group in list order over the same filters, so headers are right before the stream ends.

### Bulk update

`BulkUpdate(workspace_id, project_id, ids[], status, priority, set_assignees + assignee_ids, or delete + delete_mode)` takes 1–500 ids and **streams** one `BulkResult{id, ok, task | error}` per task, in the order done. The call as a whole is checked first (permission, archived project, shape of the change) and a mistake refuses everything; after that each task is its own transaction, so a blocked task or a forbidden transition fails alone. An edit changes the task as it is now (a concurrent edit is retried) rather than answering a conflict. Deleting goes top-down: a parent chosen with all its live subtasks is deleted as one `subtree` batch (restoring it brings them back) and the subtasks are reported as deleted with it. Code: `bulk.py`.

### The board

`BoardController` (`board.py`, `grpc/board_services.py`; phase 12) shows the project's **top-level** live tasks as cards (a parent's card carries its subtask progress; subtasks are not cards). Columns come from `group_by` (`status`, `priority`, `assignee`, or `field:<select field id>`), optionally split into rows by `swimlane` (`assignee`).

- `Get(workspace_id, project_id, group_by, swimlane, page_size)` answers the whole board: lanes (one with key `""` without swimlanes), each with its columns, every column's `count` and its first `page_size` cards (default 30) plus a `cursor`. Columns: all statuses / all priorities / the options of the select field then `No value` / the people that hold a card then `Unassigned`. People are named by the client.
- `ListColumn(..., column, lane, cursor, page_size)` pages one column (cell) further, in rank order.
- `Move(id, expected_version, group_by, column, before_id, after_id, include_subtasks, override_blocked)` drops a card. A different column changes the task's field through `update` / `move` (so the workflow, blockers and `task.update` apply and a refusal changes nothing; `expected_version` is checked then); a drop inside the card's own column only changes its place and never conflicts. The card gets a rank right after `after_id` and right before `before_id` (one side is enough; neither: last); neighbours that no longer sort in that order fall back to "right after `after_id`", a neighbour of another project is `NOT_FOUND`.
- **Ranks**: only the dropped task changes (`tree.reposition` rewrites its subtree's `tree_key` prefix so the list's tree order follows). Two drops into one gap get different ranks (a taken rank is nudged), and when a rank grows past `board.REBALANCE_AT` characters the server respaces the project's top-level ranks in the same transaction (`tree.rebalance`, no versions change). Clients never compute global order.
- Permissions: `Get`/`ListColumn` need workspace membership, `Move` `task.update` on a project that is not archived.

### The calendar

`CalendarController` (`calendar.py`, `grpc/calendar_services.py`; phase 13). Dates are date-only: a range is two calendar days compared as days, never shifted by a zone.

- `ListRange(workspace_id, project_id, range_start, range_end, include_done)` streams the live tasks (subtasks too) that fall on any day from `range_start` to `range_end` inclusive (`YYYY-MM-DD`, at most 62 days apart, else `INVALID_ARGUMENT`): a task with both dates covers every day between them, with one date it sits on that day. In task-number order, in chunks of 500 that each follow the last number seen: never capped, and a task edited meanwhile is never listed twice. Each task also carries `blockers_due` (the latest due date among its open blockers) and `blocks_due` (the earliest due date among the open tasks it blocks), counting only projects the caller can open, so a client can tell whether a new date would break a link. Indexes `(project, start_date)` and `(project, due_date)`.
- `ListWorkspaceRange(workspace_id, range_start, range_end, include_done, project_ids[])` is the same across every non-archived project the caller can open (phase 13b); `project_ids` only narrows that set, in task-id order.
- `ListUnscheduled(workspace_id, project_id, cursor, page_size)` pages the open tasks with no dates (the tray) by number.
- Both need workspace membership. A date is changed with `TaskController.Update` (`start_date`, `due_date`, `due_time`), which refuses a start after the due date.
- **Due time**: `Task.due_time` is an optional `HH:MM` in UTC on the due date (empty clears it; it needs a due date and is cleared with it). It never moves the date; clients show it on the viewer's clock.

### The timeline

`TimelineController` (`timeline.py`, `schedule.py`, `grpc/timeline_services.py`; phase 15). Same date rules as the calendar. `schedule.py` is pure Python (no database): a task is a bar (both dates), a milestone (exactly one date) or unscheduled; a blocking link means the dependent starts after the blocker finishes.

- `Get(workspace_id, project_id, range_start, range_end, include_done, filter_ast, today)` streams chunks of tasks (as the calendar's `ListRange`, but up to 1,100 days apart) each with the blocking links that touch them as `(from_id, to_id)`; a link is sent once, and links to tasks the caller cannot open or that are deleted are left out.
- `CriticalPath(workspace_id, project_id)` names the longest chain of linked, open, dated tasks by working days (milestones weigh 0; a longer chain wins a tie, then the smaller id), first blocker first; empty when no two tasks are linked. Cycles in bad data are ignored.
- `PreviewShift(.., task_id, start_date, due_date)` says which dependents would move if the task took those dates (the task's new start and/or due; at least one): through any chain, each dependent that would start on or before its blockers' finish goes to the first working day after, keeping its length in working days (a milestone moves its one date). Unscheduled, finished, deleted, archived-project and hidden-project dependents are left alone. Nothing is saved. At most 2,000 tasks are reached.
- `ApplyShift(.., expected_version, affected_ids[])` needs `task.update`. In one transaction it locks the projects involved in a fixed order, works the cascade out again, refuses (`ABORTED`, `VERSION_CONFLICT`) when it is not exactly `affected_ids` (the preview), then updates the task and every dependent as ordinary edits (versions, events after commit, per-project permissions all apply). Any failure rolls everything back.
- `GetWorkingDays` / `SetWorkingDays` (`workspace.update`): the workspace's working weekdays (0 Monday .. 6 Sunday; none chosen means every day) and up to 400 holidays, in `WorkingCalendarSetting`. The cascade and the critical path use them.
- The person's zoom, grouping, hide-done and critical-path choices are a personal `timeline` `SavedView` (see savedviews).

### gRPC contract (`config.tasks`)

All requests carry `workspace_id` and `project_id`. Responses are `Task` (`List` streams them).

`TaskTrash{tasks[]}` is the `ListTrash` reply.

`Task{id, workspace_id, project_id, number, display_id, title, description, status, status_name, status_category, priority, parent_id, depth, progress_done, progress_total, start_date, due_date, assignee_ids[], created_by, version, position, created_at, updated_at, deleted_at}` (dates and timestamps are ISO strings, `""` when unset).

Errors as in [projects](projects.md): `PERMISSION_DENIED` (with reason trailers), `NOT_FOUND`, `INVALID_ARGUMENT`, `ALREADY_EXISTS` `PROJECT_ARCHIVED`, `ABORTED` `VERSION_CONFLICT`. A refusal raised inside the `List` stream ends it with the same status.

### Custom field values

`Task.fields` lists the task's custom field values and `Create` / `Update` take `field_values`; the rules, the wire forms and the per-field conflict key (`field_versions["field:<id>"]`) are in [custom fields](customfields.md).
