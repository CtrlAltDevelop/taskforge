# 02 — Roadmap

One feature per phase. Do them in order; each lists its dependencies.
Groups are just for reading — a phase is still exactly one feature.

## Status

- **Phase 00** — implemented on `develop`; verified on web (real browser) and native Dart. Not yet verified: Android, iOS, Windows, Linux runs, CI on GitHub, fresh-clone boot.
- **Phase 01** — implemented on `develop`: backend policy + refresh grace window + Postgres, Flutter sign-in/up, sessions, gRPC `Me`. Passwords are hashed with Argon2 (PBKDF2 hashes upgrade on login). Verified: backend suite (SQLite and Postgres), Flutter tests, a live end-to-end run, and the web UI in a real browser. Not yet verified: CI on GitHub (incl. the new Postgres job), the new UI on macOS/Android/iOS.
- **Phase 02** — implemented on `develop`: workspaces backend (`WorkspaceController`, logo upload, scoping helpers, `purge_workspaces`) and Flutter onboarding/switcher/settings. Create, switch, invite and role flows run in a real browser against real Envoy. Not run on a device. WS non-member close deferred to phase 16 (the socket helper exists).
- **Phase 03** — implemented on `develop`: members and invitations backend (`MemberController`, `InvitationController`, REST invite preview/accept) and Flutter Members screen, invite dialog and `/invite/:token` deep link. Invite emails go out from a post-commit signal on an in-process worker (durable job queue comes with a later phase). Deep link checked in a real browser (web) and on macOS; not run on Android, iOS, Windows or Linux. Not done: Windows/Linux scheme registration, HTTPS app links; web `/invite/*` SPA fallback is for phase 38.
- **Phase 04** — implemented on `develop`: permission registry, `can()`/`require()` on every workspace-scoped endpoint, custom roles (`RoleController`, `PermissionController`, `MemberController.SetRole`), deny reasons on gRPC and REST, and the Flutter Roles matrix, role picker and `PermissionGate`. Invitations can carry a role. Checked in a real browser against real Envoy (denial reason headers readable on web, role edit conflict). Not run on a device. The socket error-frame helper exists; the realtime channel itself arrives in phase 16.
- **Phase 05** — implemented on `develop`: projects backend (`ProjectController`, keys locked once tasks exist, open/private visibility through the single `visible_to` query path, archive/restore, favorites, feature toggles, safe task counter `number_task`, a project creator can manage their own project) and Flutter project sidebar, create dialog, settings with members, archived list and admin private list. Backend suite on SQLite and Postgres, Flutter tests; not run in a real browser or on a device. Phase 06 must number tasks via `number_task` and read only through `visible_to`.
- **Phase 06** — implemented on `develop`: tasks backend (`TaskController`: create/get/update/delete/restore and a server-streamed, cursor-paged `List`; display ids `KEY-N` from the project counter; field-level optimistic locking so different fields merge and the same field answers `ABORTED` with the current value; soft delete plus a trash list; fractional-index positions; `task.*` permissions) and Flutter quick-add, streamed list with skeleton/empty/error states, detail side panel or page, assignee chips (project members only), date pickers, priority icons, conflict dialog, optimistic edits with rollback, a Trash screen with Restore, and a marked-up-text description editor that round-trips the shared rich-text document. Full backend suite (SQLite; tasks and projects also on Postgres: 50 parallel creates, 10,000-task first page) and Flutter tests pass; not run in a real browser or on a device (Docker stopped responding when I tried). The description is a text box, not a WYSIWYG editor; that can come with Docs.
- Toolchain: the app needs Flutter 3.47.9 (Dart 3.13.7+); older SDKs fail `flutter pub get`. On Windows, `make` assumes macOS paths, so run the proto and test steps by hand.
- **Phase 07** — implemented on `develop`: per-project workflows (`WorkflowController` Get/Update/Validate, `TaskController.Move`): statuses with name, colour, category and order, one default, optional restricted transitions with role and assignee conditions, atomic whole-workflow save that rejects an invalid graph with the full list of problems (a conflicting save is merged with the other person's changes and every decision is shown before anything is saved), an optional per-project *Restrict creation* rule (new tasks start in the default status only; off by default), deleting a status moves its tasks in the same transaction, `TRANSITION_NOT_ALLOWED` with the reason; `Task.status` is now a project status (migration converts every existing task). Flutter: Project settings → Workflow editor (touch drag-to-reorder, category/colour/default, per-status move chips with conditions, delete-with-migration dialog, validation panel, node-and-arrow picture on wide screens) and a status picker that offers only allowed targets. Not run in a real browser or on a device; the *all subtasks done* condition waits for phase 08.
- **Phase 08** — implemented on `develop`: subtasks to any depth (parent link, materialized path and tree key, cycle and depth checks, subtree re-parent in one query, progress that rolls up in the same transaction, delete as `subtree` or `promote`, restore of a deleted batch, tree-order paging with `include_subtasks`, `Move` that takes open subtasks along, and the workflow condition "all subtasks done" in the editor). Flutter: indented tree with chevrons, progress rings, inline add, "Move under…", press-and-drag to nest on wide screens, breadcrumb and subtask checklist in the detail, delete-mode and complete-all prompts. 5,000-task tree tested on the server and in the app. The tasks, workflows and projects suites (including the race and migration tests) pass on PostgreSQL; not run in a real browser or on a device.
- **Phase 09** — implemented on `develop`: typed task links (`LinkController`: blocks / blocked by, relates, duplicates), seen from both ends, with loop protection that names the path, a blocked lock and a completion guard that a project manager can override (recorded). Hidden far ends show as "Restricted task". Blocked tasks name their blockers, the picker searches every project you can open, link changes are announced for phase 16, and the loop race is tested in parallel on PostgreSQL. Not done: a board badge (phase 12). Not run in a real browser or on a device.
- **Phase 10** — implemented on `develop`: per-project custom fields of nine types (`FieldController`; archive and restore within 30 days, option remap, required and default values, per-field edit conflicts, index-backed value filters) and Flutter Fields settings, `FieldInput`, task detail section and a required-values dialog on quick-add. Backend suites on SQLite and PostgreSQL (index plans, parallel edit race) and Flutter tests pass; not run in a real browser or on a device. Real list columns wait for phase 11, board group-by for 12, filtering UI for 14.
- **Phase 11** — implemented on `develop`: the list is a virtualized table (sort, group with server counts, resize, show/hide columns, inline edit, keyboard operation, phone cards) over `Tasks.List` with `sort`/`group_by`, a streaming `BulkUpdate` with per-task results, and personal/shared layouts in the new `savedviews` app. Backend and Flutter suites pass on SQLite; PostgreSQL, device frame rate and a real browser were not checked.
- **Phase 12** — implemented on `develop`: the Kanban board (`BoardController` `Get`/`ListColumn`/`Move`; columns by status, priority, assignee or a select field; lazy columns of 30 cards; fractional ranks changed one card at a time with server-side respacing; drag, Move-to menu, WIP limits, swimlanes, card fields, per-column quick-add) and a List | Board switch in the app. Backend and Flutter suites pass on SQLite; PostgreSQL, device frame rate and a real browser were not checked.
- **Phase 13** — implemented on `develop`: the calendar (`CalendarController` `ListRange`/`ListUnscheduled`; date-only tasks by their start–due days; month, week and day, phone agenda; drag to move, drag an edge to resize, unscheduled tray, colour by status or priority, week-start choice; personal `calendar` layouts) and a List | Board | Calendar switch. Backend and Flutter suites pass on SQLite; PostgreSQL, a real browser/device and the optional due time were not done.
- **Next:** phase 14 (Saved filters and query language).
- Phases 14–40 — planned.

## A. Foundation
- [00 Foundation: monorepo, dev env, CI, hello-world on every transport](phases/phase-00-foundation.md)

## B. Identity and tenancy
- [01 Authentication](phases/phase-01-authentication.md)
- [02 Workspaces](phases/phase-02-workspaces.md)
- [03 Members and invitations](phases/phase-03-members-invitations.md)
- [04 Roles and permissions](phases/phase-04-roles-permissions.md)

## C. Core work items
- [05 Projects](phases/phase-05-projects.md)
- [06 Tasks](phases/phase-06-tasks.md)
- [07 Custom workflows and statuses](phases/phase-07-workflows.md)
- [08 Subtasks](phases/phase-08-subtasks.md)
- [09 Task dependencies](phases/phase-09-dependencies.md)
- [10 Custom fields](phases/phase-10-custom-fields.md)

## D. Views
- [11 List view](phases/phase-11-list-view.md)
- [12 Board (Kanban) view](phases/phase-12-board-view.md)
- [13 Calendar view](phases/phase-13-calendar-view.md)
- [14 Saved filters and query language](phases/phase-14-filters-query.md)
- [15 Timeline (Gantt) view](phases/phase-15-timeline-view.md)

## E. Collaboration
- [16 Realtime sync](phases/phase-16-realtime-sync.md)
- [17 Comments and mentions](phases/phase-17-comments-mentions.md)
- [18 Attachments](phases/phase-18-attachments.md)
- [19 Notifications](phases/phase-19-notifications.md)
- [20 Global search](phases/phase-20-search.md)

## F. Planning and tracking
- [21 Time tracking](phases/phase-21-time-tracking.md)
- [22 Sprints](phases/phase-22-sprints.md)
- [23 Docs (wiki)](phases/phase-23-docs.md)
- [24 Automations](phases/phase-24-automations.md)

## G. Speed and insight
- [25 Command palette and shortcuts](phases/phase-25-command-palette.md)
- [26 Dashboards and reports](phases/phase-26-dashboards.md)
- [27 Audit log](phases/phase-27-audit-log.md)
- [28 Recurring tasks](phases/phase-28-recurring-tasks.md)

## H. Reach and trust
- [29 Import and export](phases/phase-29-import-export.md)
- [30 Offline mode](phases/phase-30-offline.md)
- [31 Localization and RTL](phases/phase-31-i18n-rtl.md)
- [32 Webhooks and API tokens](phases/phase-32-webhooks-api-tokens.md)
- [33 Intake forms](phases/phase-33-intake-forms.md)
- [34 Goals (OKRs)](phases/phase-34-goals.md)
- [35 Templates](phases/phase-35-templates.md)
- [36 Workload and capacity](phases/phase-36-workload.md)
- [37 Two-factor auth and SSO](phases/phase-37-2fa-sso.md)
- [38 Release and deployment](phases/phase-38-release-deploy.md)
- [39 DPoP token binding](phases/phase-39-dpop-token-binding.md)
- [40 Device info and named sessions](phases/phase-40-device-info-sessions.md)

## Milestones

| Milestone | Phases | You can… |
|-----------|--------|----------|
| M1 "Usable" | 00–06, 11 | Sign in, make a workspace/project, manage tasks in a list |
| M2 "Jira-class" | 07–10, 12, 14, 16, 22 | Workflows, boards, queries, sprints, live sync |
| M3 "ClickUp-class" | 13, 15, 17–21, 23–26 | All views, docs, automations, dashboards |
| M4 "Switch over" | 27–38 | Import from Jira/ClickUp, offline, deploy for a team |
