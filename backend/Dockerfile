# One image for every backend role (ASGI API, gRPC, Celery worker, beat, migrate): the command
# differs, the code does not. Build from the repository root so VERSION is in the context:
#   docker build -f backend/Dockerfile --build-arg COMMIT=$(git rev-parse HEAD) -t taskforge-backend .
FROM python:3.13-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 \
    DJANGO_SETTINGS_MODULE=config.settings.production
WORKDIR /app

# Dependencies first, so a code-only change reuses this layer.
COPY backend/pyproject.toml backend/README.md ./
RUN mkdir -p src && pip install --upgrade pip \
 && python - <<'PY' > /tmp/requirements.txt
import tomllib
data = tomllib.load(open("pyproject.toml", "rb"))["project"]
extras = data["optional-dependencies"]
deps = list(data["dependencies"])
for name in ("oauth", "redis", "s3", "totp", "asgi", "media", "sentry"):
    deps += extras[name]
print("\n".join(deps))
PY
RUN pip install -r /tmp/requirements.txt

COPY backend/manage.py ./
COPY backend/src ./src
# Commands run from /app/src (where `config` lives): `python manage.py ...` must work there too.
RUN ln -s /app/manage.py /app/src/manage.py
COPY VERSION ./VERSION
RUN pip install --no-deps -e . \
 && useradd --system --uid 10001 --home /app taskforge \
 && mkdir -p /app/staticfiles /data/media \
 && chown -R taskforge /app/staticfiles /data/media
COPY deploy/scripts/healthcheck.py /usr/local/bin/tf-healthcheck

ARG COMMIT=""
# What TaskForge needs switched on (the same set as backend/Makefile ALL_APPS); override in .env.
ENV DJANGO_AUTH_METHODS=password DJANGO_AUTH_SECOND_FACTORS=totp,recovery \
    DJANGO_AUTH_TOKEN_MODE=rotation DJANGO_OAUTH_MODE=rotation \
    DJANGO_NOTIFICATIONS_ENABLED=true \
    DJANGO_AUTH_CHALLENGE_STORE=infrastructure.auth.core.challenges.RedisChallengeStore \
    DJANGO_NOTIFICATIONS_BROKER=apps.notifications.broadcast.RedisBroker
ENV DJANGO_BUILD_COMMIT=${COMMIT} DJANGO_MEDIA_ROOT=/data/media
USER taskforge
WORKDIR /app/src
EXPOSE 8010 50051
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
  CMD ["python", "/usr/local/bin/tf-healthcheck"]
CMD ["python", "-m", "uvicorn", "config.asgi:application", "--host", "0.0.0.0", "--port", "8010", \
     "--proxy-headers", "--forwarded-allow-ips", "*"]
