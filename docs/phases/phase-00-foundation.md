# Phase 00 — Foundation

**Status:** DONE

## Feature
A working skeleton: Flutter app and Django backend that talk over **REST, gRPC and WebSocket** with one "ping" each, running locally with one command.

## Why it exists
Jira and ClickUp suffer from inconsistent platforms (web is strong, mobile is weaker). If the three transports and all four Flutter targets work on day 1, every later phase just adds features instead of fighting plumbing.

## How it works (plain words)
You run `make dev` (Docker: Postgres, Redis, Envoy), then `make serve` (REST + WebSocket, ASGI) and `make grpc` (gRPC) in two terminals, and `make web`. The Flutter app has one debug screen with three buttons: **REST ping**, **gRPC ping**, **WS ping**. Each shows the server reply. If all three are green on web, Android emulator and desktop, the foundation is done.

## Scope
**First step — adopt the skeleton:** generate `backend/` from the user's `django-ninja-starter` (see `AGENTS.md`) rather than `django-admin startproject`. It already provides Ninja, `django-socio-grpc`, ASGI/WebSocket, settings, CI and JWT auth, which shrinks phases 01, 19 and 37. It has no Celery and uses plain ASGI sockets (not Channels) — see the architecture reality check; add only what a phase needs.
**In:** repo layout, `backend/` + `app/` + `deploy/` (protos live beside their services in `backend/src/**/grpc/`), docker-compose, Envoy gRPC-Web config, `buf lint` + codegen (`make proto` = `manage.py protos` + `protoc` for Dart), lint/format/test tooling, GitHub Actions CI, health endpoint, env-based settings.
**Out:** users, any business model, real UI design.

## Data model
None (only Django's default migrations).

## API surface
- REST: `GET /api/v1/health/live` (and `/ready`) → starter envelope `{data:{status:"ok"}, isSuccess:true, …}`
- gRPC: `config.common.HealthController/Liveness(Empty) → Health{status, is_ready, checks}` (from the starter; no custom Ping RPC needed)
- WS: `ws://host:8010/ws/ping/` answers `{type:"pong"}` to `{type:"ping"}` (errors as `{type:"error"}` frames)

## Flutter UI
One `DebugScreen` with 3 buttons + result tiles. Base theme (light/dark) and Riverpod set up. (go_router is added in phase 01 when auth needs routing.) Platforms enabled: web, android, ios, macos, windows, linux.

## Rules and edge cases
- Web must use gRPC-Web through Envoy (see architecture §2); native uses plain gRPC.
- CORS configured for dev origins only.
- Secrets only via env (`.env.example` committed, `.env` ignored).
- Generated code is committed or generated in CI — pick one and enforce with a CI check.

## Acceptance criteria
- [ ] `make dev` + `make serve` + `make grpc` boot the full stack from a clean clone (documented in AGENTS.md)
- [ ] Three pings succeed from Flutter web, one mobile target, one desktop target (web ✅ verified in a real browser; native Dart ✅; macOS/Android builds pending — see roadmap status)
- [ ] `make proto` regenerates Python + Dart stubs; CI fails on drift
- [ ] `make test` runs backend (pytest) and app (flutter test) suites
- [ ] CI green: ruff, mypy, pytest, flutter analyze, flutter test, buf lint
- [ ] `AGENTS.md` "Commands" section filled in

## Tests
Backend: health endpoint, gRPC Ping via in-process channel, WS consumer. Flutter: widget test for DebugScreen with fake clients.

## Notes from implementation
- Postgres runs in compose, but the backend defaults to SQLite until a phase needs it (add `psycopg`, set `DJANGO_DB_*`, run migrations on Postgres before phase 02).
- macOS needs the `com.apple.security.network.client` entitlement; Android needs `INTERNET` (release) and cleartext in debug only. Both are set.
- `x-workspace` is already an allowed CORS header for phase 02.

## Depends on
Nothing.
