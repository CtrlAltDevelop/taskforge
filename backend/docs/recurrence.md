# Recurring tasks

Tasks that repeat on a schedule or after completion.

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `Occurrence`

Task ``task`` is instance number ``index`` of ``series``, for the day ``occurs_on``. A

| Field | Type | Notes |
| --- | --- | --- |
| `id` | BigAuto | primary key |
| `task` | OneToOne | unique, → `tasks.Task` |
| `series` | ForeignKey | → `recurrence.RecurrenceSeries` |
| `index` | Integer |  |
| `occurs_on` | Date |  |

#### `RecurrenceSeries`

The rule, and what each new instance is made from.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `project` | ForeignKey | → `projects.Project` |
| `template_task` | ForeignKey | → `tasks.Task`, nullable |
| `template` | JSON |  |
| `rrule` | Char |  |
| `mode` | Char |  |
| `timezone` | Char |  |
| `starts_on` | Date |  |
| `at_time` | Time |  |
| `lead_days` | PositiveSmallInteger |  |
| `ends_on` | Date | nullable |
| `skip_weekends` | Boolean |  |
| `paused` | Boolean |  |
| `pause_reason` | Char |  |
| `next_due_on` | Date | nullable |
| `next_run_at` | DateTime | nullable |
| `last_index` | Integer |  |
| `created_by` | ForeignKey | → `accounts.User` |
| `version` | PositiveInteger |  |
| `created_at` | DateTime | not editable |
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

- **Shape**: a `RecurrenceSeries` (the rule, a snapshot `template`, the next date and moment) and an `Occurrence` per task that belongs to it (`index`, `occurs_on`). The task the rule was set on is instance 0, on its due date (today without one). There is no `Task.series`: the side table avoids a circular dependency.
- **Rules**: an RRULE (`FREQ` DAILY/WEEKLY/MONTHLY/YEARLY, `INTERVAL`, `BYDAY` with an optional nth, `BYMONTHDAY`, `BYMONTH`, `BYSETPOS`, `COUNT` or `UNTIL`); anything else is refused. `COUNT` is a number of instances. A day past a short month's end ("the 31st") lands on the last day, so Feb 29 becomes the 28th in other years. `Preview` gives the sentence ("Every 2 weeks on Mon, Thu") and the next dates with the same arithmetic the clock uses.
- **Schedule mode**: `manage.py recurrence_tick` (`make tick`, every minute; no Celery yet) makes each instance `lead_days` before its date at `at_time` in the series' time zone, so daylight-saving changes keep the wall clock. Running it twice, or from two machines, makes each instance once (row lock, unique `(series, index)` and `(series, day)`).
- **Catch-up**: after downtime only the most recent `RECURRENCE_MAX_CATCHUP` (1) missed instances are made; the skipped days still count towards `COUNT`.
- **After completion**: the next instance is made when the newest one reaches a done status (a `task_activity` receiver; the tick repairs a missed hook), `INTERVAL` days/weeks/months after that day, and never while one is open. `skip_weekends` drops weekend dates (after-completion: moves them to Monday).
- **Instances** copy title, description, priority, assignees (one who can no longer open the project is dropped), field values, due time and the start/due gap, and the subtasks as an open checklist. They are made as the series' owner (whoever last set or resumed it) and audited as the system.
- **Edits**: "this task only" is an ordinary task edit. `UpdateFuture` takes the task as the new template and carries title, description, priority and people to later open instances. Deleting the template task never stops the series; `Clear` does (instances stay).
- **Pausing**: `Pause` pauses and resumes (dates missed meanwhile are skipped). A series that cannot make an instance (owner lost access, a required field has no value, archived project) is paused with `pause_reason`.
- **Permissions**: `Set`, `Clear`, `Pause` and `UpdateFuture` need `task.update` on the task's project; `Get`, `Preview` and `Upcoming` need to see it. `Upcoming` lists ghost dates only for projects the caller can open.
- **Concurrency**: the series row is locked while it changes or generates; two edits at once are last-write-wins (`version` is bumped for readers, not checked). The lock is a no-op on SQLite, so the two-machine race rests on the lock plus the unique constraints and was not run on PostgreSQL.
- **Numbers**: `index` is a running counter and skipped catch-up days still count, so it can have gaps. Re-setting a rule on a later instance keeps the series' original start.
