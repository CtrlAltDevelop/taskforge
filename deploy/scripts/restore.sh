#!/usr/bin/env bash
# Restore a backup made by backup.sh into the stack in this directory. DESTROYS the current
# database contents. Stop the app first:  docker compose -f docker-compose.prod.yml stop backend grpc worker beat
#   deploy/scripts/restore.sh backups/<timestamp> [--yes]
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="${1:?usage: restore.sh <backup-dir> [--yes]}"
[ -f "$SRC/db.dump" ] || { echo "no db.dump in $SRC" >&2; exit 1; }
( cd "$SRC" && sha256sum -c SHA256SUMS )
if [ "${2:-}" != "--yes" ]; then
  read -r -p "Replace the database with $SRC/db.dump? Type 'restore' to continue: " answer
  [ "$answer" = "restore" ] || exit 1
fi
COMPOSE=(docker compose -f docker-compose.prod.yml)
set -a; . ./.env; set +a
DB="${POSTGRES_DB:-taskforge}"; USER_="${POSTGRES_USER:-taskforge}"

"${COMPOSE[@]}" up -d postgres
"${COMPOSE[@]}" exec -T postgres sh -c "until pg_isready -U $USER_ -d postgres; do sleep 1; done"
"${COMPOSE[@]}" exec -T postgres psql -U "$USER_" -d postgres -c "DROP DATABASE IF EXISTS \"$DB\" WITH (FORCE)" -c "CREATE DATABASE \"$DB\" OWNER \"$USER_\""
"${COMPOSE[@]}" exec -T postgres pg_restore -U "$USER_" -d "$DB" --no-owner --exit-on-error < "$SRC/db.dump"

if [ -f "$SRC/media.tar.gz" ]; then
  "${COMPOSE[@]}" run --rm --no-deps -T -u root -v "$(cd "$SRC" && pwd):/backup:ro" backend \
    sh -c "tar -xzf /backup/media.tar.gz -C /data/media && chown -R taskforge /data/media"
elif [ -d "$SRC/storage" ]; then
  echo "Storage mirror is in $SRC/storage: copy it back with 'mc mirror $SRC/storage dst/${DJANGO_S3_BUCKET:-bucket}'."
fi
echo "Restored. Start the app:  docker compose -f docker-compose.prod.yml up -d"
