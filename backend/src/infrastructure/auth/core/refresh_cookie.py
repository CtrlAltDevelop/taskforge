"""Keep the refresh token out of reach of page script on the web.

A browser app that stores its refresh token anywhere script can read (localStorage,
a JS variable) loses it to any cross-site-scripting bug, and the token lives for
weeks. So a web client opts in, per request, with ``X-Refresh-Transport: cookie``:

* responses that would carry a ``refresh_token`` in the JSON body carry it in an
  ``HttpOnly`` cookie instead (the body field is left empty, so the shape is stable);
* a refresh or sign-out sent with no token in its body reads the cookie.

Anything without the header -- mobile, desktop, curl -- is untouched. The header is
also the CSRF defence: a cross-site form or image cannot add a custom header, so a
request that merely makes the browser attach the cookie is never given its token.
"""

import json
from collections.abc import Callable
from typing import Any, Final

from django.conf import settings
from django.http import HttpRequest, HttpResponse

OPT_IN_HEADER: Final = "HTTP_X_REFRESH_TRANSPORT"
AUTH_PREFIX: Final = "/api/v1/auth/"
# Where the cookie is sent: only to the auth endpoints that need it.
COOKIE_PATH: Final = AUTH_PREFIX
LOGOUT_PATH: Final = "/api/v1/auth/password/logout"
# Which body field to fill from the cookie, per endpoint.
BODY_FIELD: Final = {
    "/api/v1/auth/token/refresh": "refresh_token",
    LOGOUT_PATH: "token",
}


def _opted_in(request: HttpRequest) -> bool:
    return request.META.get(OPT_IN_HEADER, "").lower() == "cookie" and request.path.startswith(
        AUTH_PREFIX
    )


def _fill_from_cookie(request: HttpRequest) -> None:
    field = BODY_FIELD.get(request.path)
    cookie = request.COOKIES.get(settings.REFRESH_COOKIE_NAME)
    if request.method != "POST" or field is None or not cookie:
        return
    try:
        body = json.loads(request.body or b"{}")
    except ValueError:
        return
    if isinstance(body, dict) and not body.get(field):
        body[field] = cookie
        # Django reads the body lazily and caches it here; Ninja reads it from the cache.
        request._body = json.dumps(body).encode()


def _credentials_holder(payload: Any) -> dict[str, Any] | None:
    """The dict in a response that holds ``refresh_token``: login/sign-up nest it."""
    data = payload.get("data") if isinstance(payload, dict) else None
    if not isinstance(data, dict):
        return None
    nested = data.get("credentials")
    holder = nested if isinstance(nested, dict) else data
    return holder if holder.get("refresh_token") else None


def _set_cookie(response: HttpResponse, token: str) -> None:
    response.set_cookie(
        settings.REFRESH_COOKIE_NAME,
        token,
        max_age=settings.AUTH_REFRESH_TOKEN_TTL_SECONDS,
        httponly=True,
        secure=settings.REFRESH_COOKIE_SECURE,
        samesite=settings.REFRESH_COOKIE_SAMESITE,
        path=COOKIE_PATH,
    )


def _move_token_to_cookie(response: HttpResponse) -> None:
    if response.status_code != 200 or "json" not in response.get("Content-Type", ""):
        return
    try:
        payload = json.loads(response.content)
    except ValueError:
        return
    holder = _credentials_holder(payload)
    if holder is None:
        return
    _set_cookie(response, str(holder["refresh_token"]))
    holder["refresh_token"] = ""
    response.content = json.dumps(payload).encode()
    if response.has_header("Content-Length"):
        response["Content-Length"] = str(len(response.content))


class RefreshCookieMiddleware:
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        if not _opted_in(request):
            return self.get_response(request)
        _fill_from_cookie(request)
        response = self.get_response(request)
        if request.path == LOGOUT_PATH:
            response.delete_cookie(
                settings.REFRESH_COOKIE_NAME,
                path=COOKIE_PATH,
                samesite=settings.REFRESH_COOKIE_SAMESITE,
            )
        else:
            _move_token_to_cookie(response)
        return response
