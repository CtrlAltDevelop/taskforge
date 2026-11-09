# AGENTS.md — TaskForge

Canonical instructions for any AI agent or human working in this repo.
`CLAUDE.md`, `GEMINI.md` etc. are pointers only; new rules go **here**.

## What this is

TaskForge is a free, self-hostable project/task manager that combines the best of
**Jira** (workflows, sprints, query language, audit) and **ClickUp** (many views,
docs, automations, goals) and fixes their known weaknesses: slowness, paywalls,
bugs, clutter, weak offline support, weak keyboard flow.

## Stack (fixed decisions — see docs/01-architecture.md)

| Layer | Choice |
|-------|--------|
| Client | Flutter (one codebase: web, Android/iOS, macOS/Windows/Linux) |
| REST backend | Django + **Django Ninja** (auth, uploads, webhooks, public API) |
| Typed data API | **gRPC** (grpcio) — app data, streaming, bulk ops; gRPC-Web for Flutter web |
| Realtime | **WebSocket** (Django Channels) — live events, presence |
| DB / cache / jobs | PostgreSQL, Redis, Celery |

## Repo layout (target)

```
taskforge/
  AGENTS.md  README.md
  docs/                 # all planning docs (this is Phase-0 output)
    00-vision-and-gaps.md
    01-architecture.md
    02-roadmap.md
    03-phase-template.md
    phases/phase-NN-<feature>.md   # ONE feature per phase
  backend/              # Django project (created in phase 00)
  app/                  # Flutter project (created in phase 00)
  proto/                # .proto files, single source of truth for gRPC
  deploy/               # docker compose, CI
```

## Workflow rules

1. Work **one phase at a time**, in roadmap order. Read the phase doc fully first.
2. A phase = exactly one user-visible feature. Do not smuggle in a second feature;
   write a new phase doc instead.
3. TDD: tests first, 80%+ coverage on new code. Backend: pytest-django.
   Flutter: unit + widget tests; integration test for the main flow.
4. A phase is done only when every item in its **Acceptance criteria** passes and
   the docs are updated if behaviour differed from the plan.
5. Commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci).
6. Contracts first: change `proto/` or the Ninja schema, regenerate clients, then code.
7. Every query is workspace-scoped. Never trust a client-supplied workspace id
   without checking membership. (Multi-tenancy bugs are the #1 risk.)
8. Immutable state on the Flutter side (freezed + Riverpod). No mutation of models.

## Backend skeleton: reuse `django-ninja-starter`

The backend starts from the user's own `/Users/m.zarif/GitHub/django-ninja-starter`
(generate with `django-ninja-starter backend`), not from an empty Django project.
It already ships Ninja, gRPC via `django-socio-grpc`, a WebSocket/ASGI setup,
env-based settings, JWT auth (password/email-code/magic-link, TOTP and other
second factors, Google/Apple/Microsoft/GitHub OIDC), a notifications app with a
socket, an Unfold admin, CI, and a response-envelope convention. Per phase:
00 adopts it; 01 enables its `accounts` + `auth_password` + token mode instead of
rewriting auth; 19 builds on its `notifications` app; 37 enables its
`auth_twofactor` and `oauth_*` apps. Read its `docs/` before writing any
backend code, and keep apps that TaskForge does not need (shop, wallet, club,
cms, support) switched off. Gap to verify in phase 00: the starter has no
Celery/Channels group layer by default — check how its socket publishes before
phase 16.

## Agents and skills (`.agents/`, symlinked from `.claude/`)

| Name | Kind | Use for |
|------|------|---------|
| `start-phase` | skill | Implement a phase test-first from its doc |
| `commit` | skill | Logical Conventional Commits, push only when asked |
| `code-reviewer` | agent | Read-only diff review (tenant isolation first) |
| `verifier` | agent | Run lint, types, migrations, proto drift, tests |
| `test-writer` | agent | Write pytest-django / Flutter tests |
| `proto-regen` | agent | Regenerate and check gRPC stubs |
| `phase-auditor` | agent | Audit code against a phase's acceptance criteria |
| `docs-sync` | agent | Keep docs true after changes |

Ported and generalized from `broker_crm_app/.agents` (code-reviewer, flutter-verifier,
test-writer, docs-sync, api-regen, commit). Not ported: its feature/page auditors
and refactorer (they encode Broker CRM's theme-token and `AppLayout` rules),
`clickup-task`, and `text-to-lottie`.

## Commands

Filled in by phase 00 (`make dev`, `make test`, `make proto`). Until then: none.
