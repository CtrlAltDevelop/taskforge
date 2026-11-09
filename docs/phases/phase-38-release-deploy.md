# Phase 38 — Release and Deployment

## Feature
**One-command self-hosted deployment** and automated **release builds** for web, Android, iOS, and desktop.

## Why it exists
“Free and self-hostable” is only true if a small team can run it in an afternoon and keep it updated. Many open-source trackers fail here.

## How it works (plain words)
A production `docker-compose.yml` (plus Helm chart as a stretch) runs: Django ASGI (Daphne/Uvicorn), gRPC server, Celery worker + beat, Postgres, Redis, Envoy (gRPC-Web), object storage (MinIO or external S3) and a reverse proxy (Caddy) with automatic HTTPS, serving the Flutter web build as static files. `.env.production.example` documents every setting. Migrations run on start via an init container. Backups: a documented `pg_dump` + storage sync script. CI builds tagged releases: Docker images pushed to a registry, Flutter artifacts produced (web bundle, Android APK/AAB, macOS/Windows/Linux installers; iOS via a signing-enabled runner) and attached to a GitHub release with changelog.

## Scope
**In:** production compose, TLS, env docs, health/readiness endpoints, structured logging, Sentry-compatible error reporting hook, backup/restore scripts, upgrade guide with zero-config migrations, CI release pipeline, versioning (SemVer) with API/proto compatibility checks (`buf breaking`), app auto-update check, admin “System” page (version, queue health).
**Out:** managed hosting/SaaS billing, multi-region HA.

## Data model
None new (maybe `SystemInfo` for version/flags).

## API surface
- REST: `GET /api/health`, `/api/ready`, `GET /api/version` (includes minimum supported client version).
- Metrics endpoint (Prometheus format) protected by token.

## Flutter UI
“Server version / client version” in About; blocking screen if the app is older than the server’s minimum; update notices on desktop.

## Rules and edge cases
- Secrets only via env/secret files; startup refuses to boot with default/insecure secret key.
- Zero-downtime-ish upgrade order: migrate → backend → clients; migrations must be backward compatible for one version (expand/contract).
- Rate limits and security headers on by default; CORS locked to configured origins.
- Backup restore is **tested** in CI against a fixture.

## Acceptance criteria
- [ ] Fresh VPS: clone, set 5 env vars, `docker compose up -d` → working HTTPS app
- [ ] Upgrade from previous tag keeps data
- [ ] Restore from backup into a clean instance passes smoke tests
- [ ] Tagged release produces all artifacts automatically

## Tests
Smoke test suite run against the composed stack in CI, migration upgrade test (N → N+1), proto breaking-change gate.

## Depends on
All earlier phases (but infrastructure pieces start in phase 00).
