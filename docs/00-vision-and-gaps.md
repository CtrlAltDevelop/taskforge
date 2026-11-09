# 00 — Vision and Gap Analysis

## Vision

One tool that is as **structured** as Jira and as **flexible** as ClickUp, without
the price walls, the clutter, or the lag. Free to self-host. Every core feature is
available to everyone.

## Weaknesses of Jira and ClickUp, and our answer

| # | Weakness (Jira / ClickUp / similar) | Our answer | Phase |
|---|-------------------------------------|-----------|-------|
| 1 | Paywalls on basics (automations, time tracking, dashboards, guests, audit) | Everything free; self-hosted, no seat limits | all |
| 2 | Slow UI, long loads on big projects (both) | Paginated gRPC streaming, local cache, optimistic updates | 06, 16, 30 |
| 3 | Too many clicks; Jira admin screens are maze-like | Command palette + keyboard shortcuts everywhere | 25 |
| 4 | Jira workflow/permission config is complex and fragile | Visual workflow editor with validation, safe defaults | 07, 04 |
| 5 | ClickUp has too many features/toggles, overwhelming | Opinionated defaults, features switched on per project | 05 |
| 6 | Bugs: lost edits, stale boards, notification spam | Realtime sync, version-checked writes, notification digests | 16, 19 |
| 7 | Weak/no offline mode | Local-first cache + queued mutations | 30 |
| 8 | Notification overload, no control | Per-event channels, quiet hours, digest | 19 |
| 9 | JQL is powerful but hard; ClickUp filters are weak | Visual filter builder that compiles to a text query | 14 |
| 10 | Vendor lock-in, painful export | Import from Jira/ClickUp/CSV, full export | 29 |
| 11 | Mobile apps are weaker than web | Single Flutter codebase, same features everywhere | 00 |
| 12 | Subtasks/dependencies shallow or cluttered | Unlimited-depth tree + typed dependencies with cycle check | 08, 09 |
| 13 | Time tracking is bolt-on or paid | Built-in timer + manual entries + reports | 21 |
| 14 | Agile in Jira is heavy; ClickUp sprints are shallow | Lean sprints: backlog, burndown, carry-over | 22 |
| 15 | Poor RTL / localization | i18n + RTL (Persian, Arabic, Pashto) from the start | 31 |
| 16 | Opaque permissions ("why can't I see this?") | Role matrix + "why" explainer on denied access | 04 |
| 17 | No audit trail on free tiers | Immutable audit log, free | 27 |
| 18 | Automations limited by run count | Unlimited rule runs, with run history | 24 |

## Non-goals (for now)

- Billing/subscriptions. This is free software.
- AI features. Possible later; not part of the core roadmap.
- Built-in chat app and whiteboards (comments + docs cover collaboration first).

## Success criteria

- Board with 5,000 tasks scrolls at 60 fps and opens in < 1.5 s on mid-range hardware.
- A user can go from empty install to first task in under 60 seconds.
- An edit made on one device appears on another in < 500 ms (online).
- Any action reachable by keyboard.
