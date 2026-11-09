import os

from config.settings.base import *  # noqa: F403

DEBUG = True
# Plain http://localhost cannot carry a Secure cookie in every browser.
REFRESH_COOKIE_SECURE = False

# No mail server in development: reset codes and other emails print in this process's
# output instead of failing with a connection error.
EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
# 10.0.2.2 is how an Android emulator reaches this machine.
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "10.0.2.2"]

# The in-browser GraphQL editor, on unless this environment says otherwise.
# Re-read here rather than derived from `DEBUG` in `base`, because `base` reads
# its own `DEBUG` -- which is False -- long before the line above raises it.
GRAPHQL_GRAPHIQL = os.getenv("DJANGO_GRAPHQL_GRAPHIQL", "true").lower() == "true"
