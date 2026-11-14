# Phase 36 — Workload and Capacity

**Status:** DONE

## Feature
A **workload view** showing how much work each person has per day/week versus their capacity, with drag-to-rebalance.

## Why it exists
Overloaded teammates are discovered too late. ClickUp Workload is paywalled and Jira needs add-ons. Managers need one screen to see and fix overload.

## How it works (plain words)
Each member has a **capacity** (e.g. 6 h/day, working days Sun–Thu, with time off). Each task has an estimate (phase 21) spread across its start–due range over working days (e.g. 12 h over 4 days = 3 h/day). The workload grid sums per person per day; a cell turns amber/red when load passes 100% of capacity. Drag a task bar from one person’s row to another to reassign, or move it in time; totals update immediately. Unestimated tasks are listed separately so they don’t hide (“8 tasks without estimates”).

## Scope
**In:** capacity settings per member, working-day calendar + holidays, time-off entries, workload grid (day/week/month), over/under allocation colors, reassign via drag, filter by project/team, unestimated list.
**Out:** automatic leveling/optimization, cost/budget, skills matching.

## Data model
- `MemberCapacity(workspace, user, hours_per_day, working_days[])`
- `TimeOff(user, start, end, kind, note)`; `Holiday(workspace, date, name)`
- Workload computed on demand (SQL + service), cached briefly.

## API surface
- gRPC: `Capacity.Get/Set`, `TimeOff.*`, `Holidays.*`, `Workload.Get(range, filters) → per-user day buckets`, reassignment via existing `Tasks.Update`.

## Flutter UI
Grid of people × days with stacked load bars, hover tooltip listing contributing tasks, drag/drop reassign (mouse/touch), range zoom, legend and clear empty/“set capacity” states.

## Rules and edge cases
- Spread algorithm skips non-working days, holidays and time off; if no working day in range, load lands on due date with a warning.
- Multiple assignees split an estimate equally unless per-assignee estimates set.
- Only users with `workload.view` see others’ numbers (privacy toggle).
- Same algorithm is reused by timeline cascade (15) — single shared service.

## Acceptance criteria
- [x] Hand-computed fixture matches grid for multi-day, multi-assignee tasks
- [x] Holidays/time off reduce capacity correctly
- [x] Drag reassign updates both people’s totals instantly and persists
- [x] Unestimated list accurate

## Tests
Allocation algorithm (edge dates, DST, zero-length), capacity math, permission to view, Flutter grid widget tests.

## Depends on
Phases 15, 21.
