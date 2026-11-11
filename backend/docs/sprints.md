# Sprints

Time-boxed sprints, a backlog, carry-over, burndown and velocity. Always installed; gRPC only (`SprintController`, `BacklogController`). Phase 22. It shows up in a project only when the project's *Sprints* feature is switched on.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `ScopeEvent`

One change to what a sprint holds. ``after_start`` ones (made while it was active) are the

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `sprint` | ForeignKey | → `sprints.Sprint` |
| `task` | ForeignKey | → `tasks.Task` |
| `kind` | Char |  |
| `delta_points` | Decimal |  |
| `delta_tasks` | SmallInteger |  |
| `after_start` | Boolean |  |
| `at` | DateTime |  |

#### `Snapshot`

The sprint at the end of local day ``date`` (taken at the workspace's midnight). A day the

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `sprint` | ForeignKey | → `sprints.Sprint` |
| `date` | Date |  |
| `remaining_points` | Decimal |  |
| `remaining_tasks` | PositiveInteger |  |
| `scope_points` | Decimal |  |
| `scope_tasks` | PositiveInteger |  |
| `backfilled` | Boolean |  |

#### `Sprint`

``planned`` -> ``active`` (Start) -> ``completed`` (Complete), never back. A project has at

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `name` | Char |  |
| `goal` | Char |  |
| `start_date` | Date |  |
| `end_date` | Date |  |
| `state` | Char |  |
| `started_at` | DateTime | nullable |
| `completed_at` | DateTime | nullable |
| `capacity_points` | Decimal | nullable |
| `capacity_sec` | PositiveInteger | nullable |
| `baseline_points` | Decimal |  |
| `baseline_tasks` | PositiveInteger |  |
| `completed_points` | Decimal |  |
| `completed_tasks` | PositiveInteger |  |
| `unfinished_tasks` | PositiveInteger |  |
| `version` | PositiveInteger |  |
| `created_at` | DateTime |  |
| `updated_at` | DateTime |  |
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

A project has a backlog (open top-level tasks in no planned or active sprint) and sprints that go
`planned` -> `active` -> `completed`, never back. Only one sprint per project is active: the
database enforces it with a partial unique index and `start` checks it first (409). Starting fixes
the baseline from the tasks that are still open; tasks added or removed afterwards, and points
edited afterwards, are written as `ScopeEvent` rows and show as steps in the burndown.

Story points are changed only through `SprintController.SetPoints`. The generic task update
refuses `points`, so a change in an active sprint can never skip the scope log.

Completing counts only tasks in a *Done* status category as finished. Other open tasks carry over to
the next sprint or back to the backlog; cancelled tasks stay and count as nothing.

Burndown comes from `Snapshot` rows, one per local day. Run `manage.py sprint_snapshots` (`make tick`
does) at least daily: it writes every closed day not yet recorded and back-fills missed days, with
scope rebuilt exactly from the scope log. Midnight follows the workspace creator's time zone,
falling back to `ACCOUNTS_DEFAULT_TIMEZONE`, then UTC. Writing needs `sprint.manage`; reading needs
`workspace.view`. In TFQL, `sprint = currentSprint()` finds the project's active sprint's tasks.
