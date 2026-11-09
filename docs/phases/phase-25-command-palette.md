# Phase 25 — Command Palette and Keyboard Shortcuts

**Status:** TODO

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
- [ ] Every primary action in phases 05–24 reachable from palette
- [ ] Cheat sheet is generated from the registry (no hand-maintained list)
- [ ] Rebinding persists and syncs
- [ ] Palette opens < 50 ms and filters as you type

## Tests
Registry uniqueness, availability predicates, fuzzy ranking, conflict detection, shortcut widget tests.

## Depends on
Phases 20 (search) and all feature phases that register actions.
