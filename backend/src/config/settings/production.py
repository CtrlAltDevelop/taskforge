import os

from django.core.exceptions import ImproperlyConfigured

from config.settings.base import *  # noqa: F403

if SECRET_KEY == "unsafe-development-key":  # noqa: F405
    raise ImproperlyConfigured("DJANGO_SECRET_KEY must be set in production")

if not ALLOWED_HOSTS:  # noqa: F405
    raise ImproperlyConfigured("DJANGO_ALLOWED_HOSTS must be set in production")

if INBOX_UNSUBSCRIBE_URL.startswith("http://localhost"):  # noqa: F405
    raise ImproperlyConfigured(
        "DJANGO_INBOX_UNSUBSCRIBE_URL must be set in production (the link in notification emails)"
    )

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
