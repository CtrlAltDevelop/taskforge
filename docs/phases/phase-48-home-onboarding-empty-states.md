# Phase 48 — Home, onboarding and empty states

**Status:** done (see "Not done / deferred" for what is left)

## Feature
A real Home screen ("My work" and a day summary), a first-run flow that gets a new team to a working project in two minutes, and designed empty/error/loading states with illustrations across the app.

## Why it exists
Today `HomeScreen` is a landing list and a new workspace shows blank screens. First impression decides whether a team adopts the tool. ClickUp's Home is useful but crowded and slow; Jira's "Your work" is a bare list. Ours: **open the app and know what to do next.**

## How it works (plain words)
**Home** shows a greeting, then cards: *Today* (due today, overdue, in progress), *Assigned to me* grouped by project with quick status change, *Recent* (items you opened), *Mentions and unread chat* (top 5, link to inbox), *Time this week* mini bar, and *Pinned dashboards*. Cards can be hidden or reordered (personal prefs). **My work** (`/my-work`) is the full list of everything assigned or watched with the standard toolbar from 46. **First run:** after signup the user gets a 3-step flow — name the workspace (existing), pick a **starter** (Software team, Marketing, Bug tracker, Blank — phase 35 templates) and invite teammates (skippable) — and lands in a project with sample tasks marked *Sample* that one click deletes. A **checklist** card on Home ("Create a task, invite someone, try the board, press Cmd+K") ticks itself and disappears when done or dismissed. **Empty states** share one component: small illustration, a title, one sentence, one primary action, optional link to docs; **error states** say what failed in plain words with Retry and "copy details".

## Scope
**In:** Home screen and cards, My work screen, onboarding starter step and sample data, getting-started checklist, illustration set (≈ 12 flat vector scenes in brand colours, light/dark safe, bundled as SVG), a standard `TfEmpty`/`TfError` rollout to every screen that has a list or board (inventory in the phase notes), 404/offline/no-access/maintenance screens, a "What's new" dialog after upgrade.
**Out:** product tours with overlay hotspots; marketing site; email design.

## Data model
- New app `infrastructure/home`: `UserOnboarding(user, workspace, checklist jsonb, dismissed_at, sample_project nullable)`, `RecentItem(user, workspace, task, opened_at)` (tasks only, newest 30 kept) and `DashboardPin(user, workspace, dashboard)`. Home card layout stays a local pref.
- `Task.is_sample` (bool, default false): set by the starter, left out of Home counts and dashboards.

## API surface
- gRPC `Home` (`home.proto`): `Summary(workspace_id, today, utc_offset_minutes)` → today/overdue/in-progress counts and top 5 items, recent, top-5 mentions and unread counts (inbox, chat), time this week per day, pinned dashboards (single call, workspace- and permission-scoped, cached 30 s per viewer and day). `MyWork(workspace_id, relation, include_done, filter_ast, today, cursor, limit)` lists assigned or watched tasks across visible projects (a workspace-level RPC, because `Tasks.List` is per project; the toolbar's TFQL filter applies). `RecordRecent(task_id)` and `PinDashboard(dashboard_id, pinned)` feed Recent and Pinned.
- gRPC `Onboarding`: `Get`, `CompleteStep(step)` (`create_task`, `invite_member`, `try_board`, `open_palette`; the first two also tick from the real action), `Dismiss`, `ApplyStarter(starter, name, key)` (`software-team`, `marketing`, `bug-tracker`, `blank`; needs `project.create`), `DeleteSamples` (to the trash, project stays).

## Flutter UI
- `features/home/` (screen, cards, `my_work_screen`), `features/onboarding/` extended (starter picker, sample project, checklist card).
- States: each card has its own skeleton, empty and error state so one slow call never blanks Home; offline shows last cached summary with a stale mark (30).
- Phone: single column, cards collapse to headers; tablet two columns; desktop three.

## Rules and edge cases
- Home numbers count only what the viewer can see (scoped like dashboards, 26); a test proves a private project never leaks into counts.
- Sample tasks are flagged, excluded from reports and dashboards by default, and deletable in one action; deleting leaves the project.
- The checklist never reappears after dismiss or completion; new workspace for the same user starts a new checklist.
- Illustrations carry no text (translation) and have meaningful semantic labels; reduced-motion users get static images.
- Greeting uses the user's locale, calendar and name; no stale "good morning" after local midnight.

## Acceptance criteria
- [x] Home renders all cards with data, loading, empty, error and offline states
- [x] My work lists assigned and watched tasks with the shared toolbar
- [x] New user: sign up → starter → lands in a populated project; samples removable in one click
- [x] Checklist ticks from real actions and can be dismissed for good
- [x] Every list/board/dashboard/doc/chat/inbox screen uses `TfEmpty`/`TfError`; inventory shows none left hand-rolled
- [x] 404, no-access, offline and maintenance screens designed
- [x] `Home.Summary` permission-scoped (private project test) and under 150 ms p95 on a 50k-task workspace seed
- [x] Goldens for Home (phone, desktop), onboarding steps, three empty states — light/dark/fa

## Tests
Backend pytest-django: scoping, cache keying per viewer, checklist transitions, sample deletion. Flutter: card states, onboarding flow, empty-state inventory test (greps for forbidden ad-hoc empty widgets), goldens.

## Depends on
44, 45, 46, 47; 35 (templates), 26 (dashboards), 19, 21, 43.

## Notes

### Shared UI (built, Flutter)
- `TfIllustration(kind, {semanticLabel, height})` in `core/ui/tf/tf_illustration.dart`: 15 flat scenes (`TfIllustrationKind`: tasks, board, calendar, timeline, docs, chat, inbox, search, goals, time, noAccess, offline, notFound, maintenance, generic), no text, bundled as SVG files in `app/assets/illustrations/` and drawn with `flutter_svg` (a dependency added for this). The files use placeholder colours that are mapped to the theme's at draw time, so they are right in light, dark and high contrast. Nothing animates, so reduced motion needs no branch; the semantic label defaults to a translated description of the scene.
- `TfEmpty` takes `illustration`, `title`, `message`, `actionLabel`/`onAction`, `docsLabel`/`onDocs`, `compact` (inside a list or card), `actionKey`; `icon` still works.
- `TfError` takes `message` (plain words), `title`, `details` (copied by "Copy details"), `onRetry`, `retryKey`, `compact`.
- Full pages (`features/system/presentation/status_screens.dart`): `NotFoundScreen` (router `errorBuilder`), `NoAccessScreen`, `NoConnectionScreen`, `MaintenanceScreen`; `UpdateRequiredScreen` uses the same `StatusPage`.

### Empty/error inventory
Migrated to `TfEmpty` / `TfError` (none hand-rolled; `test/core/ui/empty_state_inventory_test.dart` fails on a new one):
work views (list, board, calendar, timeline: `WorkEmpty`, `WorkError`, board column, calendar tray and agenda, timeline list), task trash, task links, inbox, chat (space list, conversation, placeholder), audit and activity, docs (page tree, doc page, revisions), dashboards (list, widget card and body, drill-down, editor preview), goals (list, detail), forms (list, submissions, builder, public form), templates, members (list, pending, invite link), roles, fields, workflows, automations (list, runs), sprints (backlog and sprint panes, burndown, velocity), timesheet, workload (grid, capacity, time off, holidays), developer (tokens, webhooks, deliveries), projects (project, settings, archived, private), imports (history), SSO setup, system info, workspace settings and the home workspace-load failure, search overlay, repeat section.
Banners over data that is already on screen (calendar, timeline) stay `TfBanner`. The inventory test has no exemptions: the repeat editor's preview error, the goal history list in its dialog and the import problems note are compact `TfError`s.

### Home, My work and first run (built, Flutter)
- `features/home/`: `HomeScreen` (greeting in the person's locale, calendar and digits; it follows `homeClockProvider`, which moves on at 05:00, 12:00, 17:00 and local midnight, and the summary is read again for the new day), cards `Today`, `Assigned to me` (grouped by project, status menu on each row through the task client), `Recent`, `Mentions and unread chat`, `Time this week`, `Pinned dashboards`, and the getting-started checklist. Layout: 1 / 2 / 3 columns on phone / tablet / desktop. Cards hide, show and reorder from "Customize" or a card's menu (a local pref, `home.cards.v1`).
- Each card has its own skeleton, empty state and compact `TfError` with Retry. The five cards fed by `Home.Summary` fail together (one call) but never take the greeting, the Assigned card (its own `MyWork` call), the checklist or the rest of the screen down. Offline, `ReadCache` keeps the last summary and My work page; cards show "Offline: showing the saved copy from ..." (`home-stale-<card>`).
- `/my-work` (`MyWorkScreen`): relation switch (assigned and watching / assigned / watching), include done, and the shared filter bar on its own session-only scope (`myWorkFilterScope`, workspace-wide like the all-projects calendar but not shared with it); paged by cursor ("Load more"). Sidebar entry `my-work` in the main group; on a phone it is the first row of More (the bottom bar stays Home, Inbox, Chat).
- First run: workspace name (existing) -> `/welcome/starter` (software team, marketing, bug tracker, blank, each with a picture) -> `/welcome/invite` (the existing invite dialog, skippable) -> the new project. Sample tasks carry a `Sample` badge (table, phone list, board, task detail) and a banner offers "Delete sample tasks" (one `DeleteSamples` call). Checklist steps `try_board` (board opened) and `open_palette` (palette opened) are sent once per workspace by the app; `create_task` and `invite_member` tick server-side. `Home.RecordRecent` is sent when a task's detail opens.
- "What's new": shown once per version after an upgrade (last seen version kept locally, never on first install, whatever the version). The version is read from the app's own version source (`clientVersion`, set by the release build); the notes are `releaseNotes` in `whats_new.dart` (strings in the ARB files): rewrite that list at each release.
- Status pages are wired: `NoAccessScreen` when the project catalog refuses the person, `NoConnectionScreen` when the workspace list cannot be reached at start, `MaintenanceScreen` when that call fails with gRPC UNAVAILABLE carrying "maintenance" (the server sends it while `DJANGO_MAINTENANCE_MODE=true`: REST answers 503 `{"maintenance": true}`, gRPC UNAVAILABLE `maintenance: ...`; health, version, metrics and the admin stay up).
- Home's old settings tiles are gone: every account page is in the avatar menu and the phone More sheet.

### Not done / deferred
- The My work filter is not saved across sessions (by choice: the toolbar choices are).
- The Home card frame and the starter cards have no `/debug/gallery` entry (they need providers the gallery sweep does not have).
- Maintenance is recognised on the workspace bootstrap and in the auth forms; other REST calls that can also see a 503 maintenance body (logo upload, version check) still report an ordinary failure.
