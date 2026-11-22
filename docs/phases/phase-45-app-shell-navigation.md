# Phase 45 — App shell and navigation

**Status:** DONE

## Feature
A new application frame: a workspace sidebar with spaces and projects, a top bar with breadcrumbs, search and quick actions, and a phone layout built around a bottom bar and a "More" sheet.

## Why it exists
Today the frame is a project list sidebar plus a six-icon `NavigationRail` (inbox, dashboards, goals, docs, chat, folder) that hides everything else (calendar, workload, timesheet, forms, templates, import, audit…) behind routes you must already know. Jira's left nav is dense but confusing and changes per project type; ClickUp's sidebar is a long, noisy tree. We want one predictable frame: **where am I, what is here, what can I do next** always visible.

## How it works (plain words)
**Wide screens:** a 264 px sidebar (collapsible to a 56 px icon strip, remembers the choice, `[` toggles). Top: workspace switcher with logo. Then fixed entries — Home, Inbox (badge), My work, Chat (badge), Search. Then **Favourites**, then **Projects** grouped by folder/space with the project avatar and colour, drag to reorder, "+" to create. Below, collapsed by default: **Workspace** (Dashboards, Goals, Docs, Calendar, Workload, Timesheet, Forms, Templates) and **Admin** (Members, Roles, Import/Export, Audit, Developer, Settings) shown only if permitted. The bottom has the running-timer chip, help and the avatar menu. The **top bar** shows breadcrumbs (Workspace › Project › View), the global search/command field (Ctrl/Cmd+K), a "+ Create" menu (Task, Doc, Project, Channel…), live/offline indicator, and notifications. **Tablets:** the strip form by default, sidebar as an overlay. **Phones:** bottom bar with Home, My work, Inbox, Chat, **More**; More opens a sheet with everything else; project switcher is a searchable sheet from the title.

## Scope
**In:** sidebar (expanded/strip/overlay), top bar, breadcrumbs, create menu, projects tree with favourites and reorder, recent items, phone bottom bar and More sheet, nav state restore, keyboard navigation (`g` then letter go-to shortcuts, `[` sidebar), route-level page transitions, deep-link safe active-item highlight.
**Out:** the content of any page (46–48); a new server-side folder concept beyond what projects already have (if grouping needs one it becomes its own phase — here group by favourites/recent/alphabetical and the existing project look colour).

## Data model
- Reuse `Project.favorite` and project look. New per-user nav prefs in `local_prefs` (collapsed state, section open/closed, order). If synced order is wanted across devices, add `NavPref(user, workspace, key, value jsonb)` in `shortcuts` app — decide in this phase, default local only.

## API surface
- None required. Optional `NavPref` Get/Set only if synced order is chosen.

## Flutter UI
- `features/shell/` replaces `projects/presentation/app_shell.dart` and `project_sidebar.dart`: `AppFrame`, `Sidebar`, `SidebarSection`, `SidebarItem`, `TopBar`, `Breadcrumbs`, `CreateMenu`, `MoreSheet`, `ProjectSwitcher`.
- States: sidebar skeleton while projects load; empty ("Create your first project"); offline dot; badge overflow (99+).
- Sidebar items: hover reveal "…" menu (favourite, rename, settings, archive); active item has accent bar and tinted fill; section headers collapsible with remembered state.
- Platform: macOS/Windows/Linux get a draggable title area; web respects browser back/forward and tab titles (`Project · TaskForge`).

## Rules and edge cases
- Items needing a permission are absent, not disabled (use `PermissionGate`); the frame never flashes an item then removes it — wait for the permission snapshot.
- Very long project names truncate with tooltip; 500 projects stay smooth (virtualized list).
- Breadcrumb segments are links; on narrow widths collapse the middle to "…".
- Keyboard: full sidebar traversal with arrows, `Enter` opens, `F2` rename project; focus ring visible.
- RTL: sidebar on the right, chevrons mirror.
- Switching workspace keeps the current page type where it exists (Dashboards → Dashboards).
- Unsaved edits prompt before navigating away (existing guards still fire).

## Acceptance criteria
- [x] Every route in `app_router.dart` is reachable from the sidebar, More sheet or create/search — none only by URL
- [x] Sidebar expanded, strip and overlay work at widths 360, 768, 1280, 1920; choice persists
- [x] Favourites, reorder, recent items, create menu work and are covered by tests
- [x] Breadcrumbs correct on every route family (project, task, doc, goal, chat space, settings)
- [x] Permitted-only items; no flicker on load
- [x] Go-to shortcuts and `[` registered in the action registry (cheat sheet updated)
- [x] en/fa/ar sweep clean; goldens for sidebar (expanded/strip), top bar, phone More sheet in light and dark
- [x] Old shell files deleted; lint allow-list for these screens is empty

## Tests
Widget tests per width; permission-gating; reorder persistence; breadcrumb mapping table test over all routes; keyboard traversal; integration test: sign in → create project → open task → back via breadcrumbs.

## Depends on
44; 05 (projects), 19 (inbox badge), 20/25 (search and palette), 04 (permissions).

## Built differently / deferred
- The frame is part of each page route (`framedPage`), not a nested `ShellRoute`: a nested navigator made `Navigator.of(pageContext).pop()` in dialogs pop the page.
- Nav prefs stay local (`nav.v1`); no `NavPref` server table.
- Breadcrumbs name the project, task, doc, goal, chat space and form once they are loaded (`currentCrumbs`); a name still loading, or not visible, keeps the generic word. A doc inside a project is looked up in the workspace tree only, so it keeps the generic word. A direct message has no name and keeps it too.
- "My work" is in the sidebar and in the phone's More sheet (the bar holds Home, Inbox and Chat).
- The sign-in → create project → open task → breadcrumbs flow is `integration_test/breadcrumbs_flow_test.dart` (runs with `make integration`).
- The draggable desktop title area does not apply: the app uses the operating system's own title bar, which already drags. It becomes work only if a custom title bar is added (macOS `fullSizeContentView`, Windows/Linux runner changes).
- Not done: go-to keys for System.
- Tablets: the strip carries the workspace avatar (switcher) and the settings gear; the full sidebar is the overlay.
