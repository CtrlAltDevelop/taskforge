# 01 — Architecture

## The three transports and why each exists

The brief: **Django Ninja + gRPC + WebSocket**. Each does a distinct job so they
never overlap.

| Transport | Job | Used for |
|-----------|-----|----------|
| **Django Ninja (REST/JSON)** | Request/response where HTTP tooling matters | Login/refresh, file upload/download, webhooks in/out, public API with API tokens, health, OpenAPI docs, OAuth/SSO callbacks |
| **gRPC (protobuf)** | Typed, fast, streaming app data | Task/project queries, bulk edits, server-streamed lists, import/export streams |
| **WebSocket (Django Channels)** | Push from server to clients | "Something changed" events, presence, typing, live notifications |

Rule of thumb: *client asks → gRPC (or REST if it is a file/public/auth call);
server tells → WebSocket.*

## Diagram

```
 Flutter app (web / mobile / desktop)
   │  REST+JSON ──────────────► Django Ninja  ──┐
   │  gRPC (native) ──────────► gRPC server   ──┼──► Services layer ──► PostgreSQL
   │  gRPC-Web (browser) ─► Envoy ─► gRPC srv ──┤                  └──► Redis (cache, channel layer)
   │  WebSocket ──────────────► Channels (ASGI)─┘                  └──► Celery workers (jobs)
```

## Key decisions

### 1. One services layer, three thin adapters
All business rules live in `backend/<app>/services.py` (plain Python, takes an
`actor`, a `workspace`, and validated input). Ninja views, gRPC servicers and
WebSocket consumers only: authenticate → call a service → serialize. This
guarantees the same permission check applies no matter the transport.

### 2. gRPC in the browser
Browsers cannot speak native gRPC (no HTTP/2 trailers control). Flutter web uses
**gRPC-Web**, so an **Envoy** proxy (in docker-compose) translates gRPC-Web ⇄ gRPC.
Mobile/desktop use native gRPC directly. Dart's `grpc` package supports both
transports behind one client API, so feature code is identical.
Streaming caveat: gRPC-Web supports **server streaming** but not client/bidi
streaming. We only use server streaming; anything bidirectional goes to WebSocket.

### 3. gRPC server runs beside Django
`grpcio` aio server started by `manage.py run_grpc` (calls `django.setup()` so it
shares models/ORM). Uses sync services wrapped with `sync_to_async` (thread-sensitive)
until ORM async coverage is enough. Auth via interceptor reading
`authorization: Bearer <jwt>` metadata.

### 4. Proto is the contract
`proto/*.proto` is the single source of truth. `make proto` generates Python stubs
into `backend/` and Dart stubs into `app/lib/gen/`. CI fails if generated code is
stale. Use `buf` for lint + breaking-change detection.

### 5. Multi-tenancy
Every business table has `workspace_id`. A manager `for_workspace(ws)` is the only
way services query. Membership check happens in the adapter before the service runs.
Cross-tenant tests are mandatory in each phase.

### 6. Concurrency and sync
Every mutable row has an integer `version`. Updates send `expected_version`;
mismatch returns `ABORTED` (gRPC) / `409` (REST) with the current row so the client
can merge. This removes the "lost edit" bugs of the incumbents.

### 7. Realtime event shape
```
{ "type": "task.updated", "workspace": "<id>", "project": "<id>",
  "entity_id": "<id>", "version": 12, "actor": "<user id>", "ts": "..." }
```
Small events, no big payloads. Client compares `version` with its cache and
refetches via gRPC only when it is behind. Group names: `ws:<workspace>`,
`proj:<project>`, `user:<id>`. Events are published **after commit**
(`transaction.on_commit`).

### 8. Auth
Short-lived JWT access token (15 min) + rotating refresh token (stored hashed).
Same access token works on REST (header), gRPC (metadata) and WebSocket (first
message or subprotocol — never in the URL query string, to keep it out of logs).

### 9. Flutter app structure
Feature-first folders, Riverpod for state, freezed models (immutable),
go_router with auth guards, Drift (SQLite; WASM on web) as local cache for
offline phase. Adaptive layout: one widget tree with breakpoints
(phone < 600, tablet < 1024, desktop ≥ 1024).

```
app/lib/
  core/        # theme, router, grpc client, ws client, errors
  gen/         # generated protobuf
  features/<feature>/{data,domain,presentation}
```

### 10. Backend structure
```
backend/
  config/            # settings, asgi, urls
  accounts/ workspaces/ projects/ tasks/ ...   # one Django app per domain
    models.py services.py api.py (ninja) grpc.py consumers.py tests/
```

## Tooling summary

Python 3.12, Django 5, django-ninja, grpcio + grpcio-tools, channels +
channels-redis, daphne/uvicorn, Celery + Redis, PostgreSQL 16, pytest-django,
ruff, mypy. Flutter stable, Riverpod, freezed, go_router, grpc, drift, buf,
Envoy, Docker Compose, GitHub Actions.

## Security baseline (every phase)

Validate input at the adapter; check permission in the service; scope by
workspace; no secrets in repo; rate-limit auth endpoints; never log tokens.
