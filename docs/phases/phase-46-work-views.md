# Phase 46 — Work views: List, Board, Calendar, Timeline

**Status:** DONE

## Feature
Rebuild the project page — view tabs, toolbar, list table, board cards, calendar and timeline chrome — on the design system so working in a project feels like a finished product.

## Why it exists
This is where people spend 80 % of their time and it is the most MVP-looking part: a `SegmentedButton` for switching views, a stack of unrelated toolbars (each view has its own), plain rows, bare board cards. ClickUp's strength is its view tabs bar and group headers; Jira's is the dense, sortable issue table and polished board cards. ClickUp's weakness is a toolbar that wraps into noise; Jira's is configuration sprawl. Ours: **one toolbar grammar for every view.**

## How it works (plain words)
The project header shows the project avatar, name, favourite star, members stack and a "Share/Settings" menu. Under it a **view tab bar**: List, Board, Calendar, Timeline, Sprints, Dashboards (per project feature toggles), with "+ View" to add a saved view as its own tab (saved layouts from 11/14). Under the tabs, one **toolbar** shared by all views: Search in view · Filter chip (opens the builder, shows active count and a clear ×) · Group · Sort · Fields/Columns · view-specific control (board: swimlanes; calendar: Month/Week/Day + Today; timeline: zoom) · "+ Task" primary. Active filters show as removable chips below. The **list** gets 36 px compact rows (Comfortable 44), sticky header, hover row actions, status as a coloured pill, priority icon, assignee avatars, due date coloured when overdue, group headers with count and collapse, a bulk bar that floats at the bottom. **Board** cards: id in mono, title (2 lines), tags row, avatars, due chip, subtask ring; column headers with count/WIP and "+"; smooth drag with a drop line. **Calendar/Timeline** use the same chips and colours; bars use the status-category palette.

## Scope
**In:** project header, view tabs (incl. saved-view tabs), shared toolbar and filter chips, list table restyle with density, board cards and columns, calendar and timeline chrome, bulk bar, inline quick-add row, loading/empty/error states for each view, phone variants (cards list, horizontally snapped board columns, agenda).
**Out:** new view types, behaviour changes to filters/grouping/offline logic (reuse providers), task detail (47).

## Data model
- None new. Saved view tabs use phase 11/14 `savedviews` (add `pinned_as_tab bool` and `tab_order int` if absent — migration + test).

## API surface
- `SavedViews`: `Update` gains `pinned_as_tab`, `tab_order` only if the fields are added. Otherwise none.

## Flutter UI
- Replace `task_section.dart` view switch and the per-view toolbars (`list_toolbar`, `board_toolbar`, `calendar_toolbar`, `timeline_toolbar`) with `ProjectHeader`, `ViewTabs`, `ViewToolbar` (slots for view-specific controls), `FilterChips`.
- `task_table.dart` (724 lines) split into header, row, cells, group header, bulk bar (each < 300 lines).
- States: skeleton rows matching real row height; empty per view ("No tasks match these filters — Clear filters" vs "No tasks yet — Add your first task"); error with retry; offline banner (existing).
- Hover/focus/selected row states; keyboard (`j/k`, `Enter`, `x` select, `e` edit) as in 11/25.

## Rules and edge cases
- Switching tabs keeps filters, search and sort that apply to both views; view-only settings stay per view.
- 5,000-row list and 1,000-card board stay at 60 fps (profile, record in the phase notes); skeletons never shift layout when data arrives.
- Column widths and visible fields persist per view as today; reset action in the Fields menu.
- Long titles truncate with tooltip; RTL columns mirror; numerals follow the user's digit setting.
- Overdue colour needs an icon too (not colour alone).
- Tab bar scrolls horizontally on narrow widths; the active tab stays visible.

## Acceptance criteria
- [x] One toolbar component used by all four views; no view has its own search/filter UI
- [x] Active filters shown as chips with counts, clearable individually and all at once
- [x] List, board, calendar, timeline render with design-system components only (lint allow-list empty for these folders)
- [x] Compact and Comfortable density both pass overflow sweep at 360/768/1280
- [x] Saved views can be pinned as tabs, reordered and removed
- [x] Frame-time check on 5,000 rows / 1,000 cards recorded (debug-VM proxy: frame cost independent of task count; the release 16 ms budget is not measured, see below)
- [x] Goldens: list, board, calendar, timeline, phone list, phone board — light/dark, en and fa
- [x] Existing behaviour tests for phases 11–15 still pass unchanged

## Tests
Reuse existing view tests; add toolbar slot test, tab persistence, chips, density goldens, performance smoke (`flutter test --profile`-style timing helper), saved-view tab migration test.

## Depends on
44, 45; 11–15, 22 (sprints tab).

## Built differently / deferred
- **Material controls kept.** The list rows' selection checkbox and the sprint toggle still use Material `Checkbox`/`FilterChip`; the phone cards use `TfCheckbox`. The lint (hex colours, `BorderRadius.circular`, `Icons.*`) is clean for every phase-46 file and they are off the allow-list.
- **`TaskOpenScope`** is installed by `TaskSection`; every view opens a task through `openTask(context, task)`, the one door phase 47 changes.
- **`task_section.dart` split** (1,307 lines) into `task_section.dart` (the page), `task_list.dart` with part files `task_list_phone.dart`, `task_list_drag.dart` and `task_list_ops.dart`, plus `task_tile.dart` (phone card) and `quick_add.dart`; all under 300 lines. `TaskTile` is a card of tokens (status stripe, id in mono, `TfStatusPill`, `DueText`) instead of a `ListTile`.
- **States.** `work/work_states.dart`: `WorkSkeleton` (rows at the density's row height, cards at `phoneCardHeight`), `BoardSkeleton`, `WorkEmpty` (filters or search hide everything: "No tasks match these filters" + Clear filters; none: "No tasks yet" + Add your first task), `WorkError` (a danger `TfBanner` with Retry). The calendar and timeline show their errors as a `TfBanner` too. An empty, unfiltered board keeps its columns (they hold the add fields) instead of the empty state; the calendar and timeline have no empty state (an empty month is a month). The offline banner is the existing one (`OfflineBanner`), shown above the tabs; a test covers it on the project page.
- **Chips are not controls on a card.** `TfInteractive` is opaque even without a tap handler, so the status pill, due chip and field chips on a card are wrapped in `IgnorePointer` and a tap on them opens the card.
- **Timeline canvas.** The painter (`timeline_painter.dart`, the PNG export) keeps taking a Material `ColorScheme` (it already derives from the tokens); the chrome around it (header, list rows, error banner) is on the tokens.
- **Performance, measured.** A widget test runs the debug VM with no GPU, so it cannot prove 60 fps. `test/features/tasks/work_perf_test.dart` checks that the cost of a scrolled frame does not depend on the number of tasks, and records numbers (debug VM, one Mac, median of 40 scrolled frames, build + layout): list 200 rows 38 ms vs 5,000 rows 31 ms; board 50 cards 21 ms vs 1,000 cards 16 ms. The "no frame over 16 ms in a release build" budget has **not** been measured: it needs a profile-mode run on a device.
- **Overflow sweep.** `work_sweep_test.dart` opens the four views at 360, 768 and 1280 px in both densities with long titles, four assignees, a blocked task and a done task; no overflow.
- **Goldens.** `test/i18n/work_goldens_test.dart`: list, board, calendar, timeline (1280 px), phone list and phone board, light and dark, en and fa (24 images, `test/i18n/goldens/work_*`). Regenerated for the restyle: the phone `task_list`/`board` goldens of `rtl_goldens_test` and the frame goldens of `test/features/shell` (the project page is in them).
- **Backend.** `savedviews/tests/test_migrations.py` migrates `0002_pinned_view_tabs` back and forth over an existing layout (it keeps `pinned_as_tab=False`, `tab_order=0`).
- **Existing tests changed** for the new look (no behaviour change): the Jalali dim colour, the saved-filter menu item type, and the cards' priority label.
