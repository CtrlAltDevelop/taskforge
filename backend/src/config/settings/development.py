import os

from config.settings.base import *  # noqa: F403

DEBUG = True
# Plain http://localhost cannot carry a Secure cookie in every browser.
REFRESH_COOKIE_SECURE = False

# A distinct, non-secret key for development databases only (production refuses to start without
# DJANGO_FIELD_ENCRYPTION_KEY). Never reuse it: anything encrypted with it is readable by anyone.
FIELD_ENCRYPTION_KEY = FIELD_ENCRYPTION_KEY or "WKFDTWKLw3-iB-HY-UhDvkeFS-kiuclhvZeTd7VbFQQ="  # noqa: F405

# A fixed, non-secret key for the DPoP server nonce, development only (production refuses to start
# without DJANGO_DPOP_NONCE_SECRET and tests use their own value).
DPOP_NONCE_SECRET = DPOP_NONCE_SECRET or "dev-only-dpop-nonce-secret-not-for-production"  # noqa: F405

# A fixed, non-secret pepper for device fingerprints, development only (production refuses to
# start without DJANGO_DEVICE_FINGERPRINT_PEPPER when collection is on; tests use their own).
DEVICE_FINGERPRINT_PEPPER = (
    DEVICE_FINGERPRINT_PEPPER or "dev-only-device-pepper-not-for-production"  # noqa: F405
)

# No mail server in development: reset codes and other emails print in this process's
# output instead of failing with a connection error.
EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
# 10.0.2.2 is how an Android emulator reaches this machine.
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "10.0.2.2"]

# The in-browser GraphQL editor, on unless this environment says otherwise.
# Re-read here rather than derived from `DEBUG` in `base`, because `base` reads
# its own `DEBUG` -- which is False -- long before the line above raises it.
GRAPHQL_GRAPHIQL = os.getenv("DJANGO_GRAPHQL_GRAPHIQL", "true").lower() == "true"

# --- Debug means everything in memory: no Docker, no Redis, no Postgres, no worker. ------------
# `DJANGO_DEV_EXTERNAL=true` opts back into the environment-driven services (Postgres, Redis, a
# real Celery worker) for someone testing against them; the `DJANGO_*` variables then apply as in
# production. Otherwise they are ignored here, even when `backend/.env` names them.
DEV_EXTERNAL = os.getenv("DJANGO_DEV_EXTERNAL", "false").lower() == "true"

if not DEV_EXTERNAL:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": os.getenv("DJANGO_DEBUG_DB_NAME", str(BASE_DIR / "db.sqlite3")),  # noqa: F405
        }
    }
    CACHES = {"default": {"BACKEND": "django.core.cache.backends.locmem.LocMemCache"}}
    AUTH_CHALLENGE_STORE = "infrastructure.auth.core.challenges.LocMemChallengeStore"
    # Tasks run inline in the caller; no broker, no result backend.
    CELERY_TASK_ALWAYS_EAGER = True
    GOALS_RECOMPUTE_DEBOUNCE_SECONDS = 0  # eager tasks ignore a countdown: recount at once
    CELERY_TASK_EAGER_PROPAGATES = True
    CELERY_BROKER_URL = "memory://"
    CELERY_RESULT_BACKEND = "cache+memory://"
    # The notifications/support brokers stay in-process (the base default) unless
    # DJANGO_NOTIFICATIONS_BROKER / DJANGO_SUPPORT_BROKER name another; `make grpc` names the Redis
    # one so two processes can share live-sync events.
