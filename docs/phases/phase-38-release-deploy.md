# Phase 38 — Release and Deployment

**Status:** DONE — see the roadmap entry for what was verified and what could not be run here

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
- [x] Fresh VPS: clone, set 5 env vars, `docker compose up -d` → working HTTPS app (run locally on Docker with Caddy's local CA; a public-CA certificate needs a public domain and was not run)
- [ ] Upgrade from previous tag keeps data (the CI `upgrade` job does it once a tag exists; none does yet)
- [x] Restore from backup into a clean instance passes smoke tests (`backup.sh`, `smoke-restore.sh` and `restore.sh` run; CI runs the backup and smoke restore)
- [ ] Tagged release produces all artifacts automatically (workflow written and linted with actionlint; it needs GitHub and signing keys to run)

## Tests
Smoke test suite run against the composed stack in CI, migration upgrade test (N → N+1), proto breaking-change gate.

## Depends on
All earlier phases (but infrastructure pieces start in phase 00).

## Faults found by running the stack

Running the real images (not just the tests) exposed these; all are fixed:

- `python manage.py ...` failed in the container (`manage.py` was not in the working directory): the Dockerfile links it.
- The compose stack booted with no `DJANGO_AUTH_METHODS` and the other switches TaskForge needs, which only `backend/.env` set in development: they are now `ENV` defaults in the image (override in `.env`), including the Redis challenge store.
- `Prefetch[Any]` in an annotation failed on Python 3.13 (the image) though not on 3.14 (the dev machine).
- Two audit migrations (`0002_immutable`, `0003_retention`) failed on PostgreSQL: `schema_editor.execute` reads `%` as a placeholder. The test suite skips migrations, so only a real migrate showed it.
- The gRPC server did not start (see phase 39), and `smoke-restore.sh` lacked the DPoP nonce secret.
- The web image used a Flutter image older than the SDK range; it now clones Flutter at a pinned tag. The scripts were not executable in git. CI's compose check lacked `DJANGO_DPOP_NONCE_SECRET`.
