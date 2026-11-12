# Phase 28 — Recurring Tasks

**Status:** DONE (PostgreSQL not run, no database here: see *Built*)

## Feature
Tasks that **repeat on a schedule** (daily, weekly, monthly, custom, or after completion).

## Why it exists
Routine work (reports, maintenance, reviews) shouldn’t be re-created by hand. Incumbents either lack it or generate confusing duplicates.

## How it works (plain words)
On a task you set a **repeat rule**: e.g. “every weekday”, “first Monday of the month”, or “3 days after I complete it”. Two modes: **Schedule** (new instance created on the calendar rhythm regardless of completion) and **After completion** (next instance created when this one is done). A clock (`manage.py recurrence_tick`, run by `make tick`; Celery replaces it later) creates due instances ahead of time (never more than one open instance in “after completion” mode). Each new instance copies title, description, assignees, fields and subtasks (checklist reset) and links back to the series. You can edit “this task only” or “all future”.

## Scope
**In:** rule editor (RRULE-compatible), two modes, instance generation, series view, edit this/future, pause/stop series, calendar integration (shows next occurrences as ghost items).
**Out:** per-instance different assignees rotation, exceptions calendar beyond skip/skip-weekends.

## Data model
- `RecurrenceSeries(id, workspace, project, template_task (nullable), template JSON snapshot, rrule, mode, timezone, starts_on, at_time, lead_days, ends_on, skip_weekends, paused, pause_reason, next_due_on, next_run_at, last_index, created_by, version)`
- `Occurrence(task 1:1, series, index, occurs_on)`, unique `(series, index)` and `(series, occurs_on)`. A side table replaces `Task.series` / `Task.series_index` (no circular dependency between the apps).

## API surface
- gRPC `RecurrenceController`: `Get(task)`, `Set(task, rule, mode, timezone, at_time, lead_days, skip_weekends)`, `Clear`, `Pause(paused)`, `UpdateFuture` ("edit this" is an ordinary task edit), `Preview(rule, count) → summary + dates`, `Upcoming(range) → ghost dates` for the calendar. Changes need `task.update`; reads need to see the task.
- Clock: `manage.py recurrence_tick` (in `make tick`), idempotent; `RECURRENCE_MAX_CATCHUP` (default 1).

## Flutter UI
“Repeat” chip on task, rule editor with human-readable summary (“Every 2 weeks on Mon, Thu”) and next-5-dates preview, series badge, calendar ghosts.

## Rules and edge cases
- Use `dateutil.rrule` + time zone of series; DST changes keep local wall-clock time.
- Month-end handling: “31st” on shorter months clamps to last day.
- Generation idempotent via unique `(series, series_index)`; worker down for days catches up but caps at 1 missed instance to avoid floods (configurable).
- Deleting the template task asks: stop the series or keep it running. The series keeps a snapshot of the template, so it never needs "promote next instance".
- A series that cannot make an instance (owner lost access, a required field has no value, archived project) is paused with `pause_reason`; a missing assignee is dropped, not fatal.
- `COUNT` is a number of instances (the first task is instance 0). `index` is a running counter: dates skipped by the catch-up cap still count, so numbers can have gaps; the app shows the number of tasks made, not the index.
- Re-setting a rule on a later instance replaces the series' rule and template but keeps its original start, so `INTERVAL` phase follows the first task.
- Concurrent changes of a series: the row is locked and the last write wins (`version` is bumped for readers, not checked).

## Acceptance criteria
- [x] Weekly, monthly-nth-weekday and after-completion rules generate correct dates (fixtures including DST and Feb 29)
- [x] Double-running the job creates no duplicates
- [x] Edit-this vs edit-future behaves as stated
- [x] Preview matches what is actually generated

## Tests
RRULE fixtures, DST, idempotency, catch-up cap, series edit scopes.

## Depends on
Phases 06, 08, 13.

## Built
- **Backend** (`recurrence` app): `rules.py` (RRULE parse/render/dates/describe, month-end clamp), `schedule.py` (shared arithmetic of the clock, preview and ghosts), `template.py` (snapshot, instance with open checklist), `clock.py` (row-locked generation, catch-up cap, after-completion hook + safety net, pause on failure), `services.py`, gRPC `RecurrenceController`, audit tracking (`recurrence.*`, instances recorded as the system), RBAC matrix entries, `backend/docs/recurrence.md`.
- **App**: Repeat chip, series badge, task count and paused notice in task detail; editor with the sentence and next five dates from the server's `Preview`; stop / pause / "use this task for future ones"; stop-or-keep prompt when deleting a template; calendar ghosts (grid, month dots, agenda).
- **Tests**: backend recurrence suite (rules, clock, DST through the clock, Feb 29, preview parity for five schedule rules and after-completion, double run, catch-up cap, edit this/future, cross-workspace, per-viewer ghosts, failure branches, gRPC); Flutter domain, UI and calendar-ghost tests.
- **Time zones**: the editor offers 13 common zones (the server accepts any IANA name); the app has no device-zone plugin.
- **Not verified**: PostgreSQL (the row lock is a no-op on SQLite, so the two-machine race is argued from the lock and the unique constraints, not run); a real browser or device.
