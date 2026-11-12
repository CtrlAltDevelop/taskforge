# Phase 25 — Command Palette and Keyboard Shortcuts

**Status:** DONE

## Feature
A **command palette** (`Cmd/Ctrl+K`) to run any action or jump anywhere, plus a consistent set of customizable keyboard shortcuts.

## Why it exists
Jira is click-heavy and admin pages are a maze; ClickUp has shortcuts but few and undiscoverable. Power users want to never touch the mouse.

## How it works (plain words)
Every action in the app (create task, change status, go to project, start timer, switch workspace, toggle theme…) is registered once in a central **action registry** with a title, keywords, optional shortcut, and an “is available now?” check based on context (e.g. “Assign to me” only when a task is selected). The palette fuzzy-searches the registry; typing `>` shows actions only, `#` projects, `@` people, a task id jumps to it. Shortcuts call the same registry entries, so UI buttons, menus, palette and keys never drift apart. A `?` key opens the cheat sheet. Users can rebind keys.

## Scope
**In:** action registry, palette UI with fuzzy search and recents, context-aware availability, global and per-view shortcuts, cheat sheet, rebinding with conflict detection, mobile “quick actions” sheet.
**Out:** macros, user scripts.

## Data model
- `UserShortcut(user, action_id, keys)` (synced across devices); registry itself is client code.

## API surface
- gRPC: `Shortcuts.Get/Set`. Palette search for projects/people/tasks reuses `Search.Query` (phase 20).

## Flutter UI
Overlay dialog with input and result list (keyboard-driven), `Shortcuts`/`Actions` widgets wrapping the app, shortcut hints shown beside menu items and tooltips. On mobile: a floating “quick actions” button instead of keys.

## Rules and edge cases
- Shortcuts disabled while typing in text fields (except modifier combos).
- Platform-aware modifiers (Cmd on macOS, Ctrl elsewhere); web must not clash with browser keys (avoid `Ctrl+T/W/N`).
- Registry entries must declare a11y labels.
- Rebinding two actions to one key is rejected.

## Acceptance criteria
- [x] Every primary action in phases 05–24 reachable from palette — every page and project area, plus new task, change status, assign to me, start/stop timer (the last three need `?task=` on the route)
- [x] Cheat sheet is generated from the registry (no hand-maintained list)
- [x] Rebinding persists and syncs live: a change sends `shortcuts.changed` to the person's `user:` room and other open devices read their bindings again (also on a sync gap)
- [x] Palette opens < 50 ms and filters as you type — it is on screen in the first frame (no awaits), and ranking the whole registry for six keystrokes is asserted under 50 ms in a test

## Tests
Registry uniqueness, availability predicates, fuzzy ranking, conflict detection, shortcut widget tests.

## Depends on
Phases 20 (search) and all feature phases that register actions.

## Built
- Backend: new `shortcuts` app (`UserShortcut`, `ShortcutController.Get/Set`). Personal, not per workspace. Chords are validated and normalised (`mod+shift+k`; browser keys refused); a chord two of a person's actions share is `SHORTCUT_CONFLICT` and names the other action; `reset` drops the override.
- App: `core/actions` (action, registry with uniqueness/label/default-clash checks, chord, fuzzy ranking) and `features/shortcuts` (built-in actions, palette, cheat sheet with rebinding, key host, phone quick-actions sheet). `Ctrl/Cmd+K` is now the palette (it used to open search; `/` still opens search). `?` opens the cheat sheet. Palette: `>` actions, `#` projects, `@` people, anything else actions plus a search (a task id jumps).
- Registered: palette, search, cheat sheet, every top-level page and every page of the current project (offered only inside a project), and in `task_level_actions.dart` New task (`Alt+N`), Change status, Assign to me, Start timer (`Alt+S`), Stop timer (`Alt+Shift+S`); each checks permission, archived state and the time-tracking feature, and a refusal shows as a snackbar.
- Live: `ShortcutService` announces through `publish.to_user` (personal, no workspace, no change-log row, cursor 0); the app's sync coordinator re-reads bindings on `shortcuts.changed`.
- A phone shows a quick-actions button beside the timer chip instead of keys.
- **Audit fixes**:
  - *More registered actions* (`more_actions.dart`): switch workspace (only with two or more), toggle dark mode (new `themeModeProvider`, wired in `app.dart`, saved on the device), create project, doc, dashboard and sprint (the last three ask for a name), invite a member, sign out, Import and export (`data.manage`), Offline and storage. Each has a label, a permission or availability check and a test.
  - *Per-view scope*: `AppAction.views` limits an action to some views of a project page (`ActionContext.view` reads `?view=`). Added `Alt+1..4` view switches and `task.rename` (`F2`, list only), which replaces the hard-coded F2 of the task table: the table now asks the bindings for the rename key and listens to `renameRequestProvider`, so rebinding it works.
  - *The open task and view are in the route*: `TaskSection` keeps `?task=` and `?view=` in the URL when a task is opened or closed or the view is switched (wide screens), and follows a route that changes under it. Before, a task opened from the list or board left the URL bare, so Change status, Assign to me and the timer actions were not offered.
  - *Use default* is refused while another action holds the default keys (client check, and the server refuses a `reset` that carries `keys` = the default chord held by another override; the server does not know defaults, so the client sends it).
  - *Hints*: the sidebar (search, inbox, timesheet, dashboards, docs), the quick-add field, the timer's stop button and the row rename button read the keys from the bindings, so a rebinding changes them.
  - *Browser-reserved chords*: one list (`reserved_chords.json`) read by the server; a Dart test checks `browserReserved` equals it. Added `mod+l/r/shift+r/p/s/d` and `alt+left/right`.
  - *Recents* are kept on the device (`LocalPrefs`, the secure storage; a device without it forgets).
  - Tests: palette task-id jump, `>` mode, QuickActionsSheet, the rebind dialog's failure paths, and each item above.
- **Known limits**: the server still accepts a chord that is another action's *default* (only the client knows defaults; it refuses it); view-scoped actions exist for the four views and rename only; the phone's task detail is a pushed page, so task actions there are not in the route; recents are per device, not per account.
