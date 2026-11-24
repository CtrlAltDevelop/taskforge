# Changelog

All notable changes to TaskForge are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/). The version lives in the `VERSION` file.

## [1.0.0] - 2026-11-24

First release. TaskForge is a free, self-hostable project and task manager that combines
Jira's workflows, sprints and audit with ClickUp's views, docs and automations, without the
paywalls. One Flutter app runs on web, iOS, Android, macOS, Windows and Linux, backed by
Django (REST), gRPC and WebSocket.

### Added

**Work items**
- Projects with short keys, tasks, custom workflows and statuses, subtasks to any depth,
  typed dependencies with cycle protection, custom fields (text, number, select, date,
  checkbox, URL, user, money), recurring tasks, intake forms and templates.

**Views**
- List, board (Kanban, WIP limits, swimlanes), calendar, workspace calendar and timeline
  (Gantt, critical path), plus saved filters written in the TFQL query language.

**Collaboration**
- Realtime sync and presence, threaded comments with mentions, task chat with change
  messages, chat channels, groups and direct messages, attachments, docs (wiki),
  notifications (inbox, push, email, quiet hours, digests) and global search.

**Planning and tracking**
- Time tracking and timesheets, sprints with burndown, goals (OKRs), workload against
  capacity and dashboards built from saved filters.

**Speed and automation**
- No-code automations with run history and dry-run, a command palette and customizable
  keyboard shortcuts.

**Teams and security**
- Email and password sign-in, workspaces, members and invitations, roles and a permission
  matrix with a "why can't I do this" explainer, two-factor authentication (TOTP) and SSO
  (OIDC, optional SAML), DPoP token binding on every transport, named sessions per device
  and an immutable audit log. Every query is scoped to a workspace.

**Reach and integrations**
- Import from Jira, ClickUp (CSV or API token) and CSV, export to JSON and CSV, offline mode
  with an idempotent outbox, Persian, Pashto and Arabic with right-to-left layout, a public
  REST API with personal and service tokens, outgoing webhooks, and one-command
  self-hosting with Docker.

**Product and design**
- A design system and brand, a new app shell with a phone layout, rebuilt work views, a
  redesigned task screen, Home and first-run onboarding, motion and accessibility passes.

**Site**
- An interactive 3D landing page at <https://ctrlaltdevelop.github.io/taskforge/>, published
  from `main` with GitHub Actions.

### Fixed
- The top bar no longer draws under the iOS status bar and Dynamic Island.
- The Home card grid fits its columns to the width available (a tablet with the sidebar
  open had cards about 230 px wide).
- CI: pinned grpcio-tools and Flutter, a stable Linux golden tolerance, backup and restore
  smoke test, every committed Dart stub is checked, PostgreSQL fixes (`FOR UPDATE` with
  `DISTINCT`, imported-ref entity type width) and steadier scale tests.

### Changed
- CI runs only on pull requests into `main`, with two quick jobs. The full suite starts
  from the Actions tab.
- Dependencies: actions/checkout 7, setup-python 7, download-artifact 8,
  docker/build-push-action 7, docker/setup-buildx-action 4, Django 6.1.3 or newer,
  django-unfold, pytest 9.2, sentry-sdk 2.75, strawberry-graphql-django 0.96,
  flutter_svg 2.5, material_ui 1.11.1 and pasteboard 0.6.2.
- Licensed under AGPL-3.0.

### Known limitations
- Verified so far on web, macOS and the iOS Simulator. Android, Windows and Linux builds,
  real devices, and screen readers still need a person to test them.
- The iOS app is built in a release only when the Apple signing secrets are configured.
- There is no job queue yet (no Celery): run `make tick` every minute and `make purge`
  daily from cron.

[1.0.0]: https://github.com/CtrlAltDevelop/taskforge/releases/tag/v1.0.0
