# Time tracking

A server-side timer, manual entries, estimates and weekly timesheets. Always installed; gRPC only (`TimeController`). Phase 21. It shows up in a project only when the project's *Time tracking* feature is switched on (off keeps the data and hides it).

## Routes

<!-- generated:routes -->
_This app publishes no routes of its own._
<!-- /generated:routes -->

## Models

<!-- generated:models -->
#### `TimeEntry`

Time ``user`` spent on ``task``. ``ended_at`` is empty while the timer runs; ``duration_sec``

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | primary key, not editable |
| `workspace` | ForeignKey | → `workspaces.Workspace` |
| `task` | ForeignKey | → `tasks.Task` |
| `user` | ForeignKey | → `accounts.User` |
| `started_at` | DateTime |  |
| `ended_at` | DateTime | nullable |
| `duration_sec` | PositiveInteger |  |
| `note` | Char |  |
| `billable` | Boolean |  |
| `source` | Char |  |
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

### The timer

`Start(task)` stores a running `TimeEntry` (no `ended_at`) with the server's clock; `Stop` closes it. Elapsed time is always the server's now minus `started_at`, so a wrong device clock changes nothing and closing the app loses nothing; start on a laptop, stop on a phone. A person has **one** running entry across every workspace, enforced by a partial unique index (`ended_at IS NULL`, per user): starting another stops the first in the same transaction and returns it as `stopped` so the app can say so, and two devices starting at once cannot both win (the loser retries, up to three times). `Current(workspace)` is the caller's timer in that workspace. After every change the owner's other devices get a `timer.changed` event in their own `user:<id>` room (no content: they read again).

### Entries

`CreateEntry` logs time that already happened (a second to 7 days; not in the future beyond 5 minutes of slack); `UpdateEntry` changes `started_at`, `duration_sec`, `note`, `billable` (a running entry takes only the note and billable flag); `DeleteEntry`. Archived projects take no new time. A task that is deleted stops its running timers. Your own entries need `time.log`; somebody else's need `time.edit_others` (Owner and Admin), as does logging for another member (`for_user_id`). Entries are flagged on read: `overlap` (another entry of the same person covers part of the time), `long` (over 24 h, for review), `running`. Everyone who can see a task sees all entries on it (`Entries`); `Summary` gives its estimate, logged total (a running timer counts up to now) and billable total.

### Estimates

`Task.estimate_sec` (null = none). `SetEstimate` needs `task.update` and goes through `tasks.update` (version bump, conflict check, live event); 0 clears.

### Timesheet and totals

`Timesheet(week_start, timezone | utc_offset_minutes, user_id)`: seconds per task per local day for seven days from `week_start` (the app uses Monday), entries clipped at local midnights (so an entry across midnight splits, and DST days are 23 or 25 hours long). Other people's sheets need `time.edit_others`. Tasks of projects with the feature off, archived or private-and-hidden projects are left out. `Totals(project, start, end)`: per person, by entries that *started* in `[start, end)`; without `time.edit_others` only the caller's own line. Both are computed from entries on read, so they cannot disagree with them.

### Idle reminder

`manage.py inbox_tick` (every minute from cron, `make tick`) tells the owner once, through the inbox (`timer.long`, push on by default), when a timer has run for `TIME_LONG_TIMER_HOURS` (8) hours.

### Settings

`DJANGO_TIME_LONG_TIMER_HOURS` (8; 0 turns the reminder off).

### Permissions

`workspace.view` to read; `time.log` (Owner, Admin, Member) to start, stop and log; `time.edit_others` (Owner, Admin). A viewer can see time but not log it.
