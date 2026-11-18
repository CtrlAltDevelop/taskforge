# Phase 48 — Home, onboarding and empty states

**Status:** TODO

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
- `UserOnboarding(user, workspace, checklist jsonb, dismissed_at, sample_project nullable)` in `accounts` or `shortcuts` (pick during the phase). Home card layout stays a local pref.

## API surface
- gRPC `Home`: `Summary(workspace)` → today/overdue/in-progress counts and top items, recent, time this week (single call, workspace- and permission-scoped, cached 30 s per viewer).
- gRPC `Onboarding`: `Get`, `CompleteStep(step)`, `Dismiss`, `DeleteSamples`.

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
- [ ] Home renders all cards with data, loading, empty, error and offline states
- [ ] My work lists assigned and watched tasks with the shared toolbar
- [ ] New user: sign up → starter → lands in a populated project; samples removable in one click
- [ ] Checklist ticks from real actions and can be dismissed for good
- [ ] Every list/board/dashboard/doc/chat/inbox screen uses `TfEmpty`/`TfError`; inventory shows none left hand-rolled
- [ ] 404, no-access, offline and maintenance screens designed
- [ ] `Home.Summary` permission-scoped (private project test) and under 150 ms p95 on a 50k-task workspace seed
- [ ] Goldens for Home (phone, desktop), onboarding steps, three empty states — light/dark/fa

## Tests
Backend pytest-django: scoping, cache keying per viewer, checklist transitions, sample deletion. Flutter: card states, onboarding flow, empty-state inventory test (greps for forbidden ad-hoc empty widgets), goldens.

## Depends on
44, 45, 46, 47; 35 (templates), 26 (dashboards), 19, 21, 43.
