# Phase 21 — Time Tracking

**Status:** TODO

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
