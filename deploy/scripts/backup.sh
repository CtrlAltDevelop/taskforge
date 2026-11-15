#!/usr/bin/env bash
# Back up a running stack: a PostgreSQL dump plus the file storage (the `media` volume, or the
# S3/MinIO bucket). Run from anywhere; writes ./backups/<timestamp>/ next to this repo's deploy/.
#   deploy/scripts/backup.sh [output-dir]
# Keep the DJANGO_FIELD_ENCRYPTION_KEY and DJANGO_SECRET_KEY from .env with the backup (separately
# from it): without the encryption key, stored TOTP and SSO secrets cannot be read after a restore.
set -euo pipefail
cd "$(dirname "$0")/.."
COMPOSE=(docker compose -f docker-compose.prod.yml)
OUT="${1:-backups}/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT"
set -a; . ./.env; set +a

echo "Dumping PostgreSQL ..."
"${COMPOSE[@]}" exec -T postgres pg_dump -U "${POSTGRES_USER:-taskforge}" -Fc "${POSTGRES_DB:-taskforge}" > "$OUT/db.dump"

if [ -n "${DJANGO_S3_BUCKET:-}" ] && [ -n "${DJANGO_S3_ENDPOINT_URL:-}" ]; then
  echo "Mirroring bucket ${DJANGO_S3_BUCKET} ..."
  NETWORK_ARGS=()
  [[ "$DJANGO_S3_ENDPOINT_URL" == http://minio:* ]] && NETWORK_ARGS=(--network "$("${COMPOSE[@]}" ps -q postgres | xargs docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')")
  docker run --rm "${NETWORK_ARGS[@]}" -v "$(cd "$OUT" && pwd):/backup" --entrypoint sh minio/mc -c \
    "mc alias set src '$DJANGO_S3_ENDPOINT_URL' '${DJANGO_S3_ACCESS_KEY:-}' '${DJANGO_S3_SECRET_KEY:-}' >/dev/null \
     && mc mirror --overwrite src/'$DJANGO_S3_BUCKET' /backup/storage"
else
  echo "Archiving the media volume ..."
  "${COMPOSE[@]}" run --rm --no-deps -T -v "$(cd "$OUT" && pwd):/backup" backend \
    tar -czf /backup/media.tar.gz -C /data/media .
fi
( cd "$OUT" && sha256sum db.dump > SHA256SUMS )
echo "Backup written to $OUT"
