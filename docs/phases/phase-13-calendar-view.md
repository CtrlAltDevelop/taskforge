# Phase 13 — Calendar View

**Status:** DONE

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
- [x] Tasks appear on the right days across time zones (test UTC+4:30, UTC−8)
- [x] Drag/resize updates dates, honoring permissions
- [x] Unscheduled tray works
- [x] Works on phone, tablet and desktop layouts

## Tests
Date-only vs datetime handling, range query bounds, multi-day bar layout algorithm, Flutter drag tests.

## Depends on
Phase 11.

## As built
- **API**: `CalendarController` in the tasks app — `ListRange(range_start, range_end, include_done)` (server stream, at most 62 days, subtasks included) and `ListUnscheduled` (the tray, cursor-paged). There is no `view_id`: layouts are personal `SavedView`s of kind `calendar` (mode, colour by status/priority, week start, hide done). Dates change through the existing `Tasks.Update`. New indexes on `(project, start_date)` and `(project, due_date)`. Details in `backend/docs/tasks.md` ("The calendar").
- **Dates** are date-only end to end (a `YYYY-MM-DD` string on the wire, a UTC-midnight `Day` in the app); the date logic (range, bar layout, move, resize) is plain Dart in `calendar_math.dart`, unit tested including daylight-saving days and far zones. A due *time* is not built: tasks have no time field. Colouring by project is not offered (a calendar shows one project).
- **Flutter**: List | Board | Calendar switch. Month grid (bars across days, "+N more", today marker), week (every task) and day (a list); on a phone an agenda — a month of dots and the tasks of the chosen day. Drag a bar to move it (it keeps its length), drag an end handle to resize, drag a task from the tray onto a day (long press instead of a plain drag below 900 px, so touch still scrolls). Every task also has a date-picker button (`Reschedule…` / `Schedule…`) for keyboard and phone. A refused change puts the bar (or tray task) back with the reason. Moving a blocked task shows a note naming its blockers (it does not compare dates). The week starts on the viewer's locale unless chosen. A read for a range that was flipped past is ignored.
- Not done / not verified: the optional due time; a link-aware warning (only the plain note above); the stream of a flipped-past range is not cancelled on the server; a range with more than 5,000 tasks is cut silently; right-to-left layouts; PostgreSQL and a real browser/device were not run.
