import os

from django.core.exceptions import ImproperlyConfigured

from config.settings.base import *  # noqa: F403
from config.settings.base import logging_config
from infrastructure.system.reporting import init_error_reporting
from infrastructure.system.version import server_version

_WEAK_KEY_MARKERS = ("unsafe", "change-me", "changeme", "django-insecure", "secret", "example")


def _check_secret_key(key: str) -> None:
    """Refuse to boot on a default, placeholder or short key: it signs every token."""
    lowered = key.lower()
    if (
        len(key) < 50
        or len(set(key)) < 10
        or any(marker in lowered for marker in _WEAK_KEY_MARKERS)
    ):
        raise ImproperlyConfigured(
            "DJANGO_SECRET_KEY is missing, a placeholder or too short (need 50+ random "
            'characters): python -c "import secrets; print(secrets.token_urlsafe(64))"'
        )


_check_secret_key(SECRET_KEY)  # noqa: F405

if not ALLOWED_HOSTS:  # noqa: F405
    raise ImproperlyConfigured("DJANGO_ALLOWED_HOSTS must be set in production")

if INBOX_UNSUBSCRIBE_URL.startswith("http://localhost"):  # noqa: F405
    raise ImproperlyConfigured(
        "DJANGO_INBOX_UNSUBSCRIBE_URL must be set in production (the link in notification emails)"
    )

if not FIELD_ENCRYPTION_KEY:  # noqa: F405
    raise ImproperlyConfigured(
        "DJANGO_FIELD_ENCRYPTION_KEY must be set in production (a Fernet key: "
        'python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")'
    )

if not PUBLIC_ORIGIN.startswith("https://"):  # noqa: F405
    raise ImproperlyConfigured(
        "DJANGO_PUBLIC_ORIGIN must be set to the https:// address the app is served at"
    )
if "*" in CORS_ALLOWED_ORIGINS or "*" in ALLOWED_HOSTS:  # noqa: F405
    raise ImproperlyConfigured("CORS origins and allowed hosts must be listed, never '*'")

# The DPoP server nonce is on by default here and keyed by a secret of its own, never shared with
# development or tests.
DPOP_NONCE_SECRET = os.getenv("DJANGO_DPOP_NONCE_SECRET", "")  # noqa: F405
if len(DPOP_NONCE_SECRET) < 32:
    raise ImproperlyConfigured(
        "DJANGO_DPOP_NONCE_SECRET must be set in production (32+ random characters): "
        'python -c "import secrets; print(secrets.token_urlsafe(48))"'
    )
DPOP_NONCE_ENABLED = os.getenv("DJANGO_DPOP_NONCE_ENABLED", "true").lower() == "true"

# Caddy terminates TLS and says so; probes and the metrics scrape reach Django over plain HTTP
# inside the Docker network, so they are exempt from the HTTPS redirect.
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SECURE_REDIRECT_EXEMPT = [r"^api/health", r"^api/version$", r"^metrics$"]

SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_REFERRER_POLICY = "same-origin"
SECURE_SSL_REDIRECT = os.getenv("DJANGO_SECURE_SSL_REDIRECT", "true").lower() == "true"
SECURE_HSTS_SECONDS = int(os.getenv("DJANGO_SECURE_HSTS_SECONDS", "31536000"))
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = os.getenv("DJANGO_SECURE_HSTS_PRELOAD", "true").lower() == "true"
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
X_FRAME_OPTIONS = "DENY"


# --- Services, all from the environment. Missing required values fail at startup. ---------------
def _required(name: str) -> str:
    value = os.getenv(name, "")
    if not value:
        raise ImproperlyConfigured(f"{name} must be set in production")
    return value


EMAIL_BACKEND = os.getenv("DJANGO_EMAIL_BACKEND", "django.core.mail.backends.smtp.EmailBackend")
EMAIL_HOST = os.getenv("DJANGO_EMAIL_HOST", "localhost")
EMAIL_PORT = int(os.getenv("DJANGO_EMAIL_PORT", "587"))
EMAIL_HOST_USER = os.getenv("DJANGO_EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.getenv("DJANGO_EMAIL_HOST_PASSWORD", "")
EMAIL_USE_TLS = os.getenv("DJANGO_EMAIL_USE_TLS", "true").lower() == "true"
DEFAULT_FROM_EMAIL = os.getenv("DJANGO_DEFAULT_FROM_EMAIL", "TaskForge <no-reply@localhost>")

LOGGING = logging_config(  # noqa: F405
    fmt=os.getenv("DJANGO_LOG_FORMAT", "json").lower(), level=LOG_LEVEL  # noqa: F405
)

REDIS_URL = _required("DJANGO_REDIS_URL")  # e.g. redis://redis:6379/0

DATABASES = {
    "default": {
        "ENGINE": os.getenv("DJANGO_DB_ENGINE", "django.db.backends.postgresql"),
        "NAME": _required("DJANGO_DB_NAME"),
        "USER": _required("DJANGO_DB_USER"),
        "PASSWORD": _required("DJANGO_DB_PASSWORD"),
        "HOST": _required("DJANGO_DB_HOST"),
        "PORT": os.getenv("DJANGO_DB_PORT", "5432"),
        "CONN_MAX_AGE": int(os.getenv("DJANGO_DB_CONN_MAX_AGE", "60")),
    }
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": os.getenv("DJANGO_CACHE_URL", REDIS_URL),
        "KEY_PREFIX": os.getenv("DJANGO_CACHE_KEY_PREFIX", "taskforge"),
        "OPTIONS": {"CLIENT_CLASS": "django_redis.client.DefaultClient"},
    }
}

CELERY_BROKER_URL = os.getenv("DJANGO_CELERY_BROKER_URL", "") or REDIS_URL
CELERY_RESULT_BACKEND = os.getenv("DJANGO_CELERY_RESULT_BACKEND", "") or REDIS_URL

AUTH_REDIS_URL = os.getenv("DJANGO_AUTH_REDIS_URL", REDIS_URL)
AUTH_CHALLENGE_STORE = "infrastructure.auth.core.challenges.RedisChallengeStore"
NOTIFICATIONS_REDIS_URL = os.getenv("DJANGO_NOTIFICATIONS_REDIS_URL", REDIS_URL)
SUPPORT_REDIS_URL = os.getenv("DJANGO_SUPPORT_REDIS_URL", REDIS_URL)
NOTIFICATIONS_BROKER = "apps.notifications.broadcast.RedisBroker"
SUPPORT_BROKER = "apps.support.broadcast.RedisBroker"

# Object storage (S3, MinIO, ...) when a bucket is named; local files under MEDIA_ROOT otherwise.
if os.getenv("DJANGO_S3_BUCKET"):
    STORAGES = {
        "default": {
            "BACKEND": "storages.backends.s3.S3Storage",
            "OPTIONS": {
                "bucket_name": os.environ["DJANGO_S3_BUCKET"],
                "endpoint_url": os.getenv("DJANGO_S3_ENDPOINT_URL") or None,
                "region_name": os.getenv("DJANGO_S3_REGION") or None,
                "access_key": os.getenv("DJANGO_S3_ACCESS_KEY") or None,
                "secret_key": os.getenv("DJANGO_S3_SECRET_KEY") or None,
                "addressing_style": os.getenv("DJANGO_S3_ADDRESSING_STYLE", "path"),
            },
        },
        "staticfiles": {"BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage"},
    }

init_error_reporting(
    SENTRY_DSN,  # noqa: F405
    environment=SENTRY_ENVIRONMENT,  # noqa: F405
    release=server_version(),
    traces_sample_rate=SENTRY_TRACES_SAMPLE_RATE,  # noqa: F405
)
