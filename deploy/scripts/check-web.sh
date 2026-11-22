#!/bin/sh
# Static check of deploy/web/Caddyfile: the SPA fallback (so /invite/<token> opens the app) and
# the app-link files. Also runs `caddy validate` when Docker is up. Used by `make prod-config`.
set -eu
f="$(dirname "$0")/../web/Caddyfile"
for needle in 'try_files {path} /index.html' '/.well-known/assetlinks.json' '/.well-known/apple-app-site-association' '"/":"/invite/*"'; do
  grep -qF -- "$needle" "$f" || { echo "Caddyfile is missing: $needle" >&2; exit 1; }
done
if docker info >/dev/null 2>&1; then
  docker run --rm -e TASKFORGE_DOMAIN=localhost -e ACME_EMAIL=a@example.com \
    -v "$(cd "$(dirname "$f")" && pwd)/Caddyfile:/etc/caddy/Caddyfile:ro" \
    caddy:2-alpine caddy validate --config /etc/caddy/Caddyfile >/dev/null
else
  echo "docker not running: skipped caddy validate" >&2
fi
