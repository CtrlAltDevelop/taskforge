# Phase 21 — Time Tracking

**Status:** DONE

## Feature
Track time on tasks with a **start/stop timer** and manual entries, plus estimates and timesheets.

## Why it exists
Jira needs paid add-ons for decent time tracking; ClickUp gates it by plan and its timer is flaky across devices. We make it built-in and reliable: the timer lives on the server, not in the app.

## How it works (plain words)
Press ▶ on a task: the server stores a running entry with `started_at`. Because it’s server-side, you can start on your laptop and stop on your phone, and closing the app never loses time. Only one timer per user runs at once (starting another stops the first, with a notice). You can also add a manual entry (date, duration, note) or edit/delete entries. Tasks have an **estimate**; the task shows *logged / estimated*. A timesheet screen shows a week grid by task and day with totals.

## Scope
**In:** timer, manual entries, edit/delete, billable flag, estimate, task totals, weekly timesheet, per-user/per-project totals, idle reminder (“timer running for 8 h”).
**Out:** invoicing, approval flows, payroll export beyond CSV (29).

## Data model
- `TimeEntry(id, workspace, task, user, started_at, ended_at nullable, duration_sec, note, billable, source)`
- `Task.estimate_sec`
- Partial unique index: one open entry per user (`ended_at IS NULL`).

## API surface
- gRPC: `Time.Start(task)`, `Stop`, `Current`, `CreateEntry`, `UpdateEntry`, `DeleteEntry`, `Timesheet(user, week)`
- WS: `timer.changed` to the user’s own room (sync devices).

## Flutter UI
Global timer chip in app bar (visible on all screens), task-detail “Time” section, timesheet grid with inline edit, desktop menu-bar/tray indicator, mobile persistent notification while running.

## Rules and edge cases
- Durations derived from server timestamps; clock skew on client is irrelevant.
- Overlapping manual entries allowed but flagged; editing others’ entries needs `time.edit_others`.
- Entries longer than 24 h flagged for review.
- Feature appears only when enabled in project settings (phase 05).

## Acceptance criteria
- [ ] Start on device A, stop on device B, time correct
- [ ] Only one running timer per user, even under concurrent starts
- [ ] Timesheet totals equal sum of entries
- [ ] Respects the project feature toggle and permissions

## Tests
Concurrency of Start (DB constraint), timezone week boundaries, totals, permission checks.

## Depends on
Phases 05, 06.

## Contract (as built)
New backend app `infrastructure.timetracking` (gRPC package `config.timetracking`, stubs in `app/lib/gen/infrastructure/timetracking/grpc/`). Full description: `backend/docs/timetracking.md`.

| RPC | Request | Answer |
|---|---|---|
| `TimeController.Start` | `workspace_id`, `project_id`, `task_id`, `note` | `TimerStarted{entry, stopped, server_now}`: `stopped` is the caller's timer it replaced |
| `TimeController.Stop` / `Current` | `workspace_id` | `TimerStopped{entry}` / `TimerState{running, entry, server_now}` |
| `TimeController.CreateEntry` | task, `started_at` (ISO with offset), `duration_sec`, `note`, `billable`, `for_user_id` | `Entry` |
| `TimeController.UpdateEntry` | `id`, `fields[]` (what to change), the new values | `Entry` |
| `TimeController.DeleteEntry` | `id` | `{ok}` |
| `TimeController.Entries` / `Summary` | task | everyone's `Entry[]` on it / `TimeSummary{estimate_sec, logged_sec, billable_sec, running}` |
| `TimeController.SetEstimate` | task, `estimate_sec` (0 clears), `expected_version` (0 = whatever is there; else a stale one is refused 409) | `{estimate_sec}` |
| `TimeController.Timesheet` | `week_start`, `timezone` (IANA) or `utc_offset_minutes` (when the device cannot name its zone), `user_id` | `TimesheetAnswer{rows[7 days each], day_totals, total}` |
| `TimeController.Totals` | `project_id`, `start`, `end` | `TotalsAnswer{people[]}` |

Permissions: `time.log` (Owner, Admin, Member) and `time.edit_others` (Owner, Admin) are new registry keys. Live: `timer.changed` on the person's own `user:<id>` room (no content; the app reads again).

Built differently from the plan:
- **Estimate** is `Task.estimate_sec`, set through `SetEstimate` (which calls `tasks.update`), not through the task RPCs.
- **Timesheet** takes a `week_start` date and a time zone (or a UTC offset) rather than a week number, so the app decides what a week is (it uses Monday). The app sends the device's offset on that Monday, so a week that contains a daylight-saving change clips the days after the change by an hour off; naming the zone needs a plugin the app does not have.
- **Archived projects** take no new time (`projects.writable`) but keep and show the old; deleting a task stops its running timers; starting a timer in another workspace stops the first one and tells both workspaces' devices.
- **Feature switch** is enforced on the server (start, log, read), not only hidden in the app.
- **Idle reminder** is an inbox notification (`timer.long`) sent by `inbox_tick` after `TIME_LONG_TIMER_HOURS` (8).
- **App:** a timer chip (floating, on every screen with the sidebar), a Time section in the task detail, a Timesheet screen (week grid, cell dialog to edit, person picker with `time.edit_others`, project totals), and on mobile a persistent ongoing notification (`flutter_local_notifications`) while the timer runs.
- **Timer chip** is a floating chip on every screen that has the sidebar (not in the app bar); login and the debug screen have none.
- **Timesheet "inline edit"** is a dialog opened from a cell (that task's entries for the day: change, delete, add), not editing inside the cell.
- **Not built:** the desktop menu-bar/tray indicator (needs a native tray plugin that could not be verified here).
- **Not verified here:** parallel Start on PostgreSQL (the database rule and the retry loop are tested on SQLite only), a real device (the ongoing notification), and a real browser.
