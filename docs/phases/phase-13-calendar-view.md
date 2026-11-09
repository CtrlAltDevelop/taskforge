# Phase 13 — Calendar View

## Feature
A **calendar** (month / week / day) showing tasks by start–due dates, with drag to reschedule.

## Why it exists
Planning by date is natural for many teams. Jira's calendar is a paid add-on in many setups; ClickUp's is fine but weak on mobile. We include it free and make it work on every platform.

## How it works (plain words)
Tasks with a due date appear on that day; tasks with start and due dates span as bars across days. Drag a task to another day to change its due date (keeping the duration if it has both dates). Drag a bar's edge to resize. A sidebar lists **unscheduled** tasks — drag them on the calendar to give them a date. Only the visible date range is requested from the server.

## Scope
**In:** month/week/day modes, range query, drag to move/resize, unscheduled tray, color by status/priority/project, today marker, week-start preference, time zones.
**Out:** external calendar sync (iCal/Google — later), recurring display (28 will plug in).

## Data model
No new tables. `SavedView(kind='calendar')` stores color mode and visible filters. Range query uses indexes on `(project, start_date)` and `(project, due_date)`.

## API surface
- gRPC: `Calendar.ListRange(from, to, view_id) → stream Task(light)`; `Tasks.Update` for date changes.

## Flutter UI
Month grid with overflow "+N more", week/day time-less rows, mobile uses agenda list + month dots. Drag works with mouse and long-press touch. Respects locale first day of week.

## Rules and edge cases
- Dates are **date-only** values without time zone shift (a due date of 5 Nov stays 5 Nov everywhere). A separate optional due *time* uses UTC + user time zone.
- Moving a blocked or dependent task shows a warning if it violates a link (09).
- Range loads are cancelled when user flips months quickly.

## Acceptance criteria
- [ ] Tasks appear on the right days across time zones (test UTC+4:30, UTC−8)
- [ ] Drag/resize updates dates, honoring permissions
- [ ] Unscheduled tray works
- [ ] Works on phone, tablet and desktop layouts

## Tests
Date-only vs datetime handling, range query bounds, multi-day bar layout algorithm, Flutter drag tests.

## Depends on
Phase 11.
