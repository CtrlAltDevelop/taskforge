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

## Commands

Filled in by phase 00 (`make dev`, `make test`, `make proto`). Until then: none.
