# Deploying TaskForge

A fresh server (Docker with the compose plugin, ports 80/443 open, a DNS record for your domain):

```bash
git clone <repo> && cd taskforge/deploy
cp .env.production.example .env
# edit .env: TASKFORGE_DOMAIN, ACME_EMAIL, DJANGO_SECRET_KEY, DJANGO_FIELD_ENCRYPTION_KEY, POSTGRES_PASSWORD
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser   # the System page needs a staff account
```

Caddy gets a certificate on its own and serves the web app, `/api`, `/admin`, `/ws` and gRPC-Web on
one origin. Every setting is listed, with its default, in `.env.production.example`.

## Upgrade

1. Back up: `deploy/scripts/backup.sh`.
2. Set `TASKFORGE_VERSION` in `.env` to the new tag, then `docker compose -f docker-compose.prod.yml pull && ... up -d`.
3. The `migrate` step runs first; the API, gRPC server and workers start only if it succeeds.

Migrations are written to be backward compatible for one version (add, then remove later), so the
old containers keep working while the new ones start. Roll back by restoring the backup and the
previous tag. Raise `DJANGO_MIN_CLIENT_VERSION` only when a release drops something old apps use.

## Backup and restore

`scripts/backup.sh` writes a `pg_dump` and the file storage (media volume or bucket mirror).
`scripts/restore.sh <dir>` restores it; `scripts/smoke-restore.sh <dir>` proves a dump restores into
a throwaway database and matches the migrations. Keep `DJANGO_FIELD_ENCRYPTION_KEY` with the backup.

## Operations

`GET /api/health/live`, `/api/health/ready` (also `/api/health`), `GET /api/version`;
`GET /metrics` with `Authorization: Bearer $DJANGO_METRICS_TOKEN` (scrape `backend:8010` inside the
network; Caddy never publishes it). Admins see the same under Admin, System in the app.
Releases: `make version V=1.2.0`, commit, tag `v1.2.0`; the Release workflow does the rest. Before tagging, tick the [release checklist](../docs/phases/phase-38-release-deploy.md#release-checklist) (it includes the phase 49 quality gate and the [accessibility sign-off](../docs/accessibility-checklist.md)).
