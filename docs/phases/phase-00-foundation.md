# Phase 00 — Foundation

## Feature
A working skeleton: Flutter app and Django backend that talk over **REST, gRPC and WebSocket** with one "ping" each, running locally with one command.

## Why it exists
Jira and ClickUp suffer from inconsistent platforms (web is strong, mobile is weaker). If the three transports and all four Flutter targets work on day 1, every later phase just adds features instead of fighting plumbing.

## How it works (plain words)
You run `make dev`. Docker starts Postgres, Redis, Envoy. Django serves REST + WebSocket (ASGI) and a separate process serves gRPC. The Flutter app has one debug screen with three buttons: **REST ping**, **gRPC ping**, **WS ping**. Each shows the server reply. If all three are green on web, Android emulator and desktop, the foundation is done.

## Scope
**First step — adopt the skeleton:** generate `backend/` from the user's `django-ninja-starter` (see `AGENTS.md`) rather than `django-admin startproject`. It already provides Ninja, `django-socio-grpc`, ASGI/WebSocket, settings, CI and JWT auth, which shrinks phases 01, 19 and 37. Check what it lacks (Channels group layer, Celery) and add only that.
**In:** repo layout, `backend/` + `app/` + `proto/` + `deploy/`, docker-compose, Envoy gRPC-Web config, `buf` + codegen (`make proto`), lint/format/test tooling, GitHub Actions CI, health endpoint, env-based settings.
**Out:** users, any business model, real UI design.

## Data model
None (only Django's default migrations).

## API surface
- REST: `GET /api/health` → `{status:"ok"}`
- gRPC: `taskforge.v1.Health/Ping(PingRequest{message}) → PingReply{message, server_time}`
- WS: `ws://host/ws/ping/` echoes `{type:"pong"}` for `{type:"ping"}`

## Flutter UI
One `DebugScreen` with 3 buttons + result tiles. Base theme (light/dark), go_router, Riverpod set up. Platforms enabled: web, android, ios, macos, windows, linux.

## Rules and edge cases
- Web must use gRPC-Web through Envoy (see architecture §2); native uses plain gRPC.
- CORS configured for dev origins only.
- Secrets only via env (`.env.example` committed, `.env` ignored).
- Generated code is committed or generated in CI — pick one and enforce with a CI check.

## Acceptance criteria
- [ ] `make dev` boots the full stack from a clean clone
- [ ] Three pings succeed from Flutter web, one mobile target, one desktop target
- [ ] `make proto` regenerates Python + Dart stubs; CI fails on drift
- [ ] `make test` runs backend (pytest) and app (flutter test) suites
- [ ] CI green: ruff, mypy, pytest, flutter analyze, flutter test, buf lint
- [ ] `AGENTS.md` "Commands" section filled in

## Tests
Backend: health endpoint, gRPC Ping via in-process channel, WS consumer. Flutter: widget test for DebugScreen with fake clients.

## Depends on
Nothing.
