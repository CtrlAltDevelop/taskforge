"""The URL prefixes that answer anyone, signed in or not.

One list, so the layers that demand a credential or a proof of possession on every request (the
global auth layer, a later DPoP check) can exempt public routes cleanly instead of each guessing.
A prefix is added here by the app that publishes the route, never by a blanket pattern.
"""

from typing import Final

# Paths of the Django API (served by `config/public_api.py` and the registry's public routers).
PUBLIC_API_PREFIXES: Final = (
    "/api/public/",  # intake forms: read a form, submit it
    "/api/v1/public/",  # the same routes inside the versioned API
    # Phase 37: the steps of a sign-in that happen before there is a token to send.
    "/api/v1/auth/sso/",  # start (browser redirect), callback, ticket exchange
    "/api/v1/auth/2fa/challenge",  # a second factor for a sign-in already in progress
    "/api/v1/auth/2fa/verify",
)

# Routes of the Flutter web build that render without login chrome or an auth header.
PUBLIC_APP_PREFIXES: Final = (
    "/f/",  # a public intake form
    "/sso/",  # where the identity provider's redirect lands (it carries no token yet)
    "/two-factor",  # the code prompt of a sign-in in progress
)


def is_public_api_path(path: str) -> bool:
    return path.startswith(PUBLIC_API_PREFIXES)
