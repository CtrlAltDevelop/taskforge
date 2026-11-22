# Demo data guide

A full demo dataset that lets you open every part of the app and see it filled in.

```bash
cd backend && python manage.py seed_demo --reset      # needs DEBUG on (development settings)
```

- Safe to re-run: `--reset` removes only the demo users (`owner`, `admin`, …, `demo`), the
  workspaces they created and the `sa-…` service-account user, then rebuilds. Other accounts and
  workspaces are untouched. Without `--reset` it does nothing if the demo is already there.
- Run `make migrate` first (pending migrations make the seed fail on missing tables).
- Everything goes through the apps' own service functions, so audit entries, live events, inbox
  items and automation runs are real. Webhooks never call out (their history is written directly).
- Code: `backend/src/infrastructure/common/demo/` — modules `core`, `collab`, `planning`, `extras`
  in that order, each with `seed(ctx)`. Tests: `pytest src/infrastructure/common/demo`.

**Sign in** with `<name>@example.com` and password `demo-password-123`.

| Login | Person | Role in "Acme Studio" | Good for |
|-------|--------|----------------------|----------|
| `owner` | Maya Torres | Owner | Almost everything; start here |
| `admin` | Daniel Kim | Admin | Members, roles, workload, goals |
| `member` | Priya Nair | Member | Unread DM, inbox, "my work" |
| `dev` | Lukas Brandt | Member | Running timer, part-time capacity, over-allocation, own shortcuts |
| `designer` | نگار رضایی | Member | Persian (RTL) comments and docs, attachments |
| `viewer` | Chloe Martin | Viewer | Read-only UI; has TOTP two-factor on |
| `guest` | خالد الحسن | Support (custom role) | Arabic content, narrow permissions |
| `demo` | Demo User | — | Old one-user demo; first-run onboarding |

Workspaces: **Acme Studio** (everything below) and **Side Project** (second workspace, 2FA
required with a 14-day grace period, the dev's invitation).

## Where to look

| App area | Sign in as | What you will see |
|----------|-----------|-------------------|
| Projects list | owner | Website (WEB), Mobile app (MOB), Bug tracker (BUG), Marketing (MKT), Leadership (PRV, **private**), Old site (OLD, **archived**), Billing (BIL, created by the Jira import) |
| List / board / calendar / other views | owner | About 77 tasks with subtasks (depth 3), blocks / relates / duplicates links, one of every custom-field type, Persian task titles, 3 tasks in the trash |
| Saved filters and views | owner | 15 filters (some workspace-wide), 20+ views, some pinned as tabs |
| Members, roles, invitations | owner or admin | Seven members, a custom "Support" role, 2 pending invitations (one link) |
| Comments, threads, reactions | owner | Threads, reactions, mentions; Persian from designer, Arabic from guest; viewer sees them read-only |
| Attachments | owner or designer | Images with thumbnails, a log, a CSV, a PDF; files on comments |
| Docs | owner | Handbook with nested pages, project docs, version history, doc↔task links, a Persian page, **Salary bands** (restricted: `member` must not see it) |
| Chat | owner, member | Channels per project, `design`, `random`, a private "Leads" group, DMs, threads, reactions, an `@channel`, an edited and a removed message, mutes; member's unread DM shows in owner |
| Inbox, watchers, preferences | owner, member | ~260 notifications in read / unread / snoozed / archived states, watchers on tasks, per-person channel preferences |
| Sprints | owner | Sprint 12 (completed), Sprint 13 (active, with burndown), Sprint 14 (planned) in Website |
| Time tracking | owner (timer: dev) | About 50 entries, estimates, a timer already running for `dev` |
| Workload, capacity, time off | owner or admin | `dev` is part-time and over-allocated; time off entries |
| Recurring tasks | owner | Recurring definitions with due instances |
| Goals | owner (private goal), admin | Launch the new checkout, Raise conversion by 10%, Fix the crash backlog, Hire two engineers — every key-result kind, check-ins |
| Dashboards | owner, admin, dev | Company health, Web project board, Project overview, My work — every widget type |
| Automations | owner | 7 rules with runs (a comment written, a status refused, …), plus dry-run |
| Forms | owner (public side: no login) | Report a bug, Content request, Website feedback, with submissions |
| Templates | owner | Campaign kit, Product squad, Customer onboarding, Checkout epic |
| Import / export | owner | Finished Jira import, finished CSV import with a bad row, one waiting for mapping, one failed, a finished project export |
| Developer settings | owner | API tokens, one service account ("Release bot"), webhooks Slack relay (delivered), Billing sync (retrying), Old Zapier zap (inactive, gave up) |
| Account: sessions, devices | owner | Several signed-in sessions with device details, trusted devices (one revoked) |
| Account: two-factor | viewer | TOTP enabled; the secret and recovery codes are in the seed context only (`ctx.extra["totp"]`), re-seed to get a known state |
| Shortcuts, recents, saved searches | owner, dev | Overrides (`alt+n`, `alt+i`, `alt+c`), recent tasks, searches including Persian |
| Home / onboarding | demo | First-run checklist with one step done |
| Audit log | owner or admin | Entries from all of the above |

## Notes

- Dates are relative to the day you seed, so burndown, "due soon" and overdue states look right
  right after a run; re-seed after a few weeks.
- Run `make tick` once to let notifications, sprint snapshots and due reminders catch up.
- Search results and full-text need the index: `make migrate` runs `reindex` for you.
