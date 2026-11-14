#!/usr/bin/env bash
# Prove a backup restores: load db.dump into a throwaway PostgreSQL, run the app's own checks
# against it (migrations all applied, the ORM reads the data) and print the row counts.
# Touches nothing of the running stack. CI runs it against a fixture dump.
#   deploy/scripts/smoke-restore.sh backups/<timestamp>   (needs docker and the backend image)
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="$(cd "${1:?usage: smoke-restore.sh <backup-dir>}" && pwd)"
IMAGE="${TASKFORGE_BACKEND_IMAGE:-ghcr.io/taskforge/backend}:${TASKFORGE_VERSION:-latest}"
NET="tf-smoke-$$"; PG="tf-smoke-pg-$$"
cleanup() { docker rm -f "$PG" >/dev/null 2>&1 || true; docker network rm "$NET" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker network create "$NET" >/dev/null
docker run -d --name "$PG" --network "$NET" -e POSTGRES_PASSWORD=smoke -e POSTGRES_DB=taskforge -e POSTGRES_USER=taskforge postgres:16-alpine >/dev/null
for _ in $(seq 1 60); do docker exec "$PG" pg_isready -U taskforge >/dev/null 2>&1 && break; sleep 1; done
docker exec -i "$PG" pg_restore -U taskforge -d taskforge --no-owner --exit-on-error < "$SRC/db.dump"

# The restored schema must match this version's migrations (no unapplied ones) and be readable.
docker run --rm --network "$NET" \
  -e DJANGO_SETTINGS_MODULE=config.settings.production \
  -e DJANGO_SECRET_KEY="smoke-$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 60)" \
  -e DJANGO_FIELD_ENCRYPTION_KEY=WKFDTWKLw3-iB-HY-UhDvkeFS-kiuclhvZeTd7VbFQQ= \
  -e DJANGO_PUBLIC_ORIGIN=https://smoke.example.test -e DJANGO_ALLOWED_HOSTS=smoke.example.test \
  -e DJANGO_INBOX_UNSUBSCRIBE_URL=https://smoke.example.test/u?token={token} \
  -e DJANGO_DB_NAME=taskforge -e DJANGO_DB_USER=taskforge -e DJANGO_DB_PASSWORD=smoke -e DJANGO_DB_HOST="$PG" \
  -e DJANGO_REDIS_URL=redis://127.0.0.1:6379/0 -e DJANGO_SKIP_PREFLIGHT=true \
  "$IMAGE" sh -c '
    python manage.py migrate --check &&
    python manage.py shell -c "
from django.contrib.auth import get_user_model
from infrastructure.workspaces.models import Workspace
print(\"users:\", get_user_model().objects.count(), \"workspaces:\", Workspace.objects.count())"'
echo "Restore smoke test passed."
