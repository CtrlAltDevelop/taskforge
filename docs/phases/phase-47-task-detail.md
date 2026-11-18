# Phase 47 — Task detail redesign

**Status:** DONE

## Feature
A redesigned task screen. **Layout (decided by the owner, replacing the first sketch):** clicking a task from any view opens it as a separate centred, wide **modal** (a full page on phones; a resizable side peek is an option in the header menu). The **left** side is the task: header (`PROJ-123`, breadcrumb, prev/next, copy link, watch, template, delete, open-as menu, close), a big editable title, the description, the Details grid (every field click-to-edit) and the tabs Subtasks, Links, Attachments, Docs, Time, Fields with counts. The **right** side is the whole chat/activity feed (bubbles grouped by person and day, system events, reactions, replies, pinned messages, load earlier, full activity record) with the composer pinned at the bottom. Neither side scrolls the other away. Under 900 px it is one column (fields, then conversation in one scroll) with the composer pinned.

## Why it exists
`task_detail.dart` (743 lines) is a long stack of sections. ClickUp's task modal is the benchmark for speed (everything editable inline, activity beside the work) but drowns you in sections; Jira's issue view is clean but the field area is rigid and the page jumps while loading. Ours: **the two things you do most — change fields, read/write conversation — never need scrolling past each other.**

## How it works (plain words)
Three **presentations** of one screen: *Peek* (right side sheet over the list, default on wide screens, keeps list context and `j/k` navigation), *Modal* (centred, wide, from board/calendar), *Page* (own route, deep links, phones). Layout: header row with breadcrumb `PROJ-123`, copy-link, watch, "…" menu, prev/next, close. Left column: big editable title, description (rich text), then tabs **Subtasks · Links · Attachments · Docs · Time · Fields** with counts. Right column: **Details** (status pill with transitions, assignees, priority, dates with Repeat chip, estimate, tags, custom fields) in a labelled two-column grid, every value click-to-edit with optimistic save and the conflict dialog from 06. Below or beside: the **Activity** feed with chat and system messages (42) and the composer pinned at the bottom. On phones one column with a sticky bottom composer and the Details collapsed into an expandable card under the title.

## Scope
**In:** the three presentations, new layout, inline editing for every field, keyboard (`Esc` close, `[`/`]` prev/next, `Cmd+Enter` send, `s` status, `a` assign), sticky composer, tab counts, share link, loading skeleton, not-found/no-access states, unsaved description draft indicator.
**Out:** new task capabilities; real-time editing of the description by several people (23-style collab); changes to chat or comment backends.

## Data model
- None.

## API surface
- None; the screen composes existing `Tasks`, `Comments`, `Chat`, `Links`, `Attachments`, `Time`, `Activity` calls.

## Flutter UI
- Split `task_detail.dart` into `TaskHeader`, `TaskTitle`, `TaskDescription`, `TaskTabs`, `DetailsPanel`, `ActivityPanel`, `TaskComposer` (< 300 lines each), `TaskPresentation` (peek/modal/page switch).
- Reuse `FieldInput`, `status_picker`, subtasks and links panels, restyled.
- States: skeleton with the same two-column geometry; field saving spinner; conflict dialog; archived/deleted banner; "Restricted task" for hidden links.
- Peek width resizable (remembers), collapses to full page under 900 px.

## Rules and edge cases
- Opening a task from a notification, search, a link or the board lands in the right presentation without a double animation.
- Switching task with prev/next never loses an unsaved description (autosave draft, prompt on failure).
- Required fields and workflow transition conditions surface inline at the field, not as a late dialog.
- Permission-denied fields render read-only, not hidden, with a tooltip reason.
- Offline: edits queue with the pending mark from 30; the composer shows queued state.
- 500 comments and 200 subtasks stay smooth (virtualized activity, collapsed subtasks).

## Acceptance criteria
- [ ] Peek, modal and page presentations from list, board, calendar, search, inbox and deep link
- [ ] Every field editable inline with optimistic save, rollback and the conflict dialog
- [ ] Activity feed and composer visible together on desktop without scrolling the fields away
- [ ] Phone layout one column with sticky composer; sweep clean at 360 px in en/fa/ar
- [ ] Prev/next and keyboard shortcuts registered in the action registry
- [ ] Skeleton geometry matches the loaded layout (no layout jump, checked by a golden diff)
- [ ] `task_detail.dart` replaced; all pieces < 300 lines; lint allow-list empty here
- [ ] Phase 06–10, 17, 18, 21, 42 task-screen tests pass

## Tests
Widget tests per presentation and per field type; permission read-only; conflict flow; offline pending; goldens (peek, modal, phone) in light/dark/fa; integration: open from board → edit status → comment → next task.

## Depends on
44, 45, 46; 06–10, 17, 18, 21, 42.

## Built differently / deferred
- **Presentations.** Modal is the default from list, board, calendar and timeline; below 600 px a page; the side peek is inline beside the view (needs 900 px, else it becomes a modal) and its width is remembered. The choice is remembered per device (`taskPresentationProvider`). `TaskOpenScope`/`openTask` are unchanged for callers; `TaskPresenter` (`detail/task_presenter.dart`) owns the route. A deep link, notification, search hit or inbox item opens the right presentation immediately with no animation; opening another task while one is up swaps it in place.
- **Pieces** (`app/lib/features/tasks/presentation/detail/`): `TaskHeader`, `TaskTitle`, `TaskDescription`, `TaskTabs`, `DetailsPanel`, `TaskComposer`, `TaskPresentation`, `TaskScreen`, `TaskFrame`, `TaskSkeleton`, and `activity/` (`ActivityPanel`, `MessageBubble`, feed items). Each under 300 lines. `task_detail.dart` is gone and off the lint allow-list; `comments_section.dart` keeps only shared helpers.
- **Keys.** `s` (status) and `a` (assign to me) now have default keys; new actions `task.close` (Esc), `task.prev` (`[`), `task.next` (`]`), `task.send` (Cmd/Ctrl+Enter). `[` also toggles the sidebar: the two actions share the key through `AppAction.sharesKeyWith` and only one is available at a time (a task open means previous). `bracketright` was added to the key names the app and backend accept. The shortcut host also works while the task window is on top. `s` still opens the status dialog, not the inline menu.
- **Description** stays Markdown source in a text box (no rich editor). Drafts are kept per task, saved when leaving the box or closing, and marked "Unsaved draft" with Save if saving failed.
- **Previous/next** follow the project's task order, not the filtered view.
- **Composer.** The box itself is still the older `CommentComposer` (Material look) in a token panel; migrating it, `ReactionsBar`/`BodyView` and the task-fields inputs, links, attachments, time and docs panels to `Tf*` is left for phase 49. `TfMenu` now consumes the outside click so a menu click does not hit the window backdrop.
- **Custom fields** live in the Fields tab (flagged `!` when a required one is empty), not in the Details grid. Attachments, Time, Links and Fields are tabs, so tests open the tab first (`test/features/tasks/detail_tabs.dart`).
- **Existing tests touched** (finders only): the status picker checks `ValueButton` instead of a dropdown; tests of links, attachments, time and custom fields open their tab first; the custom-field test scrolls to a field and closes the window before opening a second task; the palette test closes with the `close-detail` key.
- **Tests.** `test/features/tasks/task_modal_test.dart`: modal geometry, phone page, field saves, read-only viewer, Esc and `]`, the board to status to comment to next-task flow, overflow at 360/768/1280 px. The existing conflict, offline-pending and required-field tests cover those paths. The task detail goldens (en, fa) were regenerated; **new modal and phone goldens in light/dark/fa, a skeleton-geometry golden diff, and per-field-type widget tests beyond priority/assignee/due are not written**.
- **Not done:** release-build frame measurements; peek and phone goldens in fa; native-speaker review of the new fa/ar/ps strings.
