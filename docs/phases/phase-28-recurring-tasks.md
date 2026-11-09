# Phase 28 — Recurring Tasks

**Status:** TODO

## Feature
Tasks that **repeat on a schedule** (daily, weekly, monthly, custom, or after completion).

## Why it exists
Routine work (reports, maintenance, reviews) shouldn’t be re-created by hand. Incumbents either lack it or generate confusing duplicates.

## How it works (plain words)
On a task you set a **repeat rule**: e.g. “every weekday”, “first Monday of the month”, or “3 days after I complete it”. Two modes: **Schedule** (new instance created on the calendar rhythm regardless of completion) and **After completion** (next instance created when this one is done). A Celery beat job creates due instances ahead of time (never more than one open instance in “after completion” mode). Each new instance copies title, description, assignees, fields and subtasks (checklist reset) and links back to the series. You can edit “this task only” or “all future”.

## Scope
**In:** rule editor (RRULE-compatible), two modes, instance generation, series view, edit this/future, pause/stop series, calendar integration (shows next occurrences as ghost items).
**Out:** per-instance different assignees rotation, exceptions calendar beyond skip/skip-weekends.

## Data model
- `RecurrenceSeries(id, template_task, rrule text, mode, timezone, next_run_at, ends_at, paused, created_by)`
- `Task.series` FK, `Task.series_index`.

## API surface
- gRPC: `Recurrence.Set(task, rule)`, `Clear`, `Pause`, `UpdateSeries(scope: this|future)`, `Preview(rule, count) → dates[]`
- Celery beat: `generate_recurring_instances` every few minutes, idempotent.

## Flutter UI
“Repeat” chip on task, rule editor with human-readable summary (“Every 2 weeks on Mon, Thu”) and next-5-dates preview, series badge, calendar ghosts.

## Rules and edge cases
- Use `dateutil.rrule` + time zone of series; DST changes keep local wall-clock time.
- Month-end handling: “31st” on shorter months clamps to last day.
- Generation idempotent via unique `(series, series_index)`; worker down for days catches up but caps at 1 missed instance to avoid floods (configurable).
- Deleting the template task asks: stop series or promote next instance.

## Acceptance criteria
- [ ] Weekly, monthly-nth-weekday and after-completion rules generate correct dates (fixtures including DST and Feb 29)
- [ ] Double-running the job creates no duplicates
- [ ] Edit-this vs edit-future behaves as stated
- [ ] Preview matches what is actually generated

## Tests
RRULE fixtures, DST, idempotency, catch-up cap, series edit scopes.

## Depends on
Phases 06, 08, 13.
