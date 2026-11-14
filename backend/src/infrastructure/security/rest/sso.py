"""Single sign-on over HTTP: the browser redirects, and the ticket exchange.

``GET /{slug}/start`` sends the browser to the identity provider (the workspace's URL name is
the provider key). ``GET /callback`` is where the provider sends it back; it ends in a redirect
to the app carrying a one-time ``ticket``. ``POST /exchange`` trades the ticket and the app's
PKCE verifier for the same credentials a password login returns. None of them takes a bearer
token (see ``infrastructure.common.public_routes``).
"""

from django.conf import settings
from django.http import HttpRequest, HttpResponse, HttpResponseRedirect
from ninja import Router, Schema

from infrastructure.auth.core.rest.schemas import LoginOut, MessageOut, login_out
from infrastructure.security import sso

router = Router()


class AppRedirect(HttpResponseRedirect):
    """A redirect that may also target the app's native scheme (``taskforge://``)."""

    allowed_schemes = ["http", "https", settings.SSO_NATIVE_RETURN_URL.split(":", 1)[0]]


class ExchangeIn(Schema):
    ticket: str
    code_verifier: str


def _cookie(response: HttpResponse, request: HttpRequest, value: str, max_age: int) -> None:
    response.set_cookie(
        sso.BINDING_COOKIE,
        value,
        max_age=max_age,
        httponly=True,
        secure=request.is_secure(),
        samesite="Lax",  # the provider's redirect is a top-level GET
        path="/api/v1/auth/sso/",
    )


@router.get(
    "/callback",
    auth=None,
    response={302: None, 400: MessageOut},
    summary="Where the identity provider sends the browser back",
)
def callback(request: HttpRequest) -> HttpResponse:
    params = {key: request.GET.get(key, "") for key in ("state", "code", "error")}
    target = sso.complete(request, params, request.COOKIES.get(sso.BINDING_COOKIE, ""))
    response = AppRedirect(target)
    _cookie(response, request, "", 0)
    return response


@router.post(
    "/exchange",
    auth=None,
    response={200: LoginOut, 400: MessageOut, 403: MessageOut, 410: MessageOut},
    summary="Trade a sign-in ticket for credentials",
)
def exchange(request: HttpRequest, payload: ExchangeIn) -> LoginOut:
    return login_out(sso.exchange(request, payload.ticket, payload.code_verifier))


@router.get(
    "/{slug}/start",
    auth=None,
    response={302: None, 400: MessageOut, 404: MessageOut, 503: MessageOut},
    summary="Start signing in through a workspace's identity provider",
)
def start(request: HttpRequest, slug: str, return_to: str, code_challenge: str) -> HttpResponse:
    started = sso.begin(request, slug, return_to, code_challenge)
    response = HttpResponseRedirect(started.authorization_url)
    _cookie(response, request, started.binding, started.expires_in)
    return response
