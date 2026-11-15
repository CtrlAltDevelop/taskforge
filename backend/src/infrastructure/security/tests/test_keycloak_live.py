"""A real sign-in against the dev Keycloak realm (``deploy/keycloak/taskforge-realm.json``).

Skipped unless ``TASKFORGE_LIVE_KEYCLOAK`` names the realm, so the normal suite stays offline:

    docker compose -f deploy/docker-compose.yml --profile sso up -d keycloak
    TASKFORGE_LIVE_KEYCLOAK=http://localhost:8082/realms/taskforge pytest -k keycloak_live

The browser is played by httpx: follow the redirect to Keycloak, post the login form, then hand the
provider's redirect back to the server exactly as a browser would (with the binding cookie).
"""

import html
import os
import re
from typing import Any
from urllib.parse import parse_qs, urlparse

import httpx
import pytest
from django.contrib.auth import get_user_model
from django.test import RequestFactory

from infrastructure.security import oidc, sso
from infrastructure.security.models import IdentityProvider
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace, WorkspaceMember

ISSUER = os.getenv("TASKFORGE_LIVE_KEYCLOAK", "")
pytestmark = pytest.mark.skipif(not ISSUER, reason="TASKFORGE_LIVE_KEYCLOAK is not set")

VERIFIER = "k" * 64
CALLBACK_BASE = "http://localhost:8010"
FORM_ACTION = re.compile(r'<form[^>]*id="kc-form-login"[^>]*action="([^"]+)"')


@pytest.fixture(autouse=True)
def _dev_settings(settings: Any) -> None:
    settings.DEBUG = True  # plain http to localhost is only accepted while DEBUG is on
    settings.SSO_CALLBACK_BASE_URL = CALLBACK_BASE


@pytest.fixture
def provider(db: None) -> IdentityProvider:
    owner = get_user_model().objects.create_user(
        username="o", email="o@acme.test", password="x-1A-y"
    )
    workspace = Workspace.objects.create(name="Acme", slug="acme-kc", created_by=owner)
    WorkspaceMember.objects.create(
        workspace=workspace, user=owner, role=access.builtin_role("Owner")
    )
    row = IdentityProvider.objects.create(
        workspace=workspace,
        issuer=ISSUER,
        client_id="taskforge",
        allowed_domains=["taskforge.test"],
    )
    row.set_client_secret("taskforge-dev-only")
    row.save()
    return row


def _request() -> Any:
    request = RequestFactory().get("/")
    request.META["REMOTE_ADDR"] = "127.0.0.1"
    return request


def _sign_in_at_keycloak(authorization_url: str, password: str) -> dict[str, str]:
    """Log in on Keycloak's page; return the query Keycloak redirects back with."""
    with httpx.Client(follow_redirects=False, timeout=20) as browser:
        page = browser.get(authorization_url)
        for _ in range(3):
            if page.status_code not in (301, 302, 303):
                break
            page = browser.get(page.headers["location"])
        action = FORM_ACTION.search(page.text)
        assert action, "Keycloak did not show its login form"
        # Keycloak marks its cookies Secure; over plain http the jar would not send them back.
        cookie = "; ".join(f"{name}={value}" for name, value in browser.cookies.items())
        reply = browser.post(
            html.unescape(action.group(1)),
            headers={"Cookie": cookie},
            data={"username": "dev@taskforge.test", "password": password},
        )
    if reply.status_code != 302:
        return {"error": "login_failed"}
    location = reply.headers["location"]
    assert location.startswith(f"{CALLBACK_BASE}{sso.CALLBACK_PATH}")
    return {key: values[0] for key, values in parse_qs(urlparse(location).query).items()}


def test_a_real_keycloak_login_ends_in_a_ticket_that_exchanges_for_credentials(
    provider: IdentityProvider,
) -> None:
    challenge = oidc.pkce_challenge(VERIFIER)
    started = sso.begin(_request(), "acme-kc", settings_native_return(), challenge)

    returned = _sign_in_at_keycloak(started.authorization_url, "dev-only-password")
    target = sso.complete(_request(), returned, started.binding)

    assert "ticket=" in target and sso.ERROR_PARAM not in target
    ticket = parse_qs(urlparse(target).query)["ticket"][0]
    result = sso.exchange(_request(), ticket, VERIFIER)
    assert result.credentials is not None
    user = get_user_model().objects.get(email="dev@taskforge.test")
    assert WorkspaceMember.objects.filter(workspace=provider.workspace, user=user).exists()
    with pytest.raises(Exception):  # noqa: B017  # a ticket is single use
        sso.exchange(_request(), ticket, VERIFIER)


def test_a_wrong_keycloak_password_never_reaches_the_server(provider: IdentityProvider) -> None:
    started = sso.begin(
        _request(), "acme-kc", settings_native_return(), oidc.pkce_challenge(VERIFIER)
    )
    returned = _sign_in_at_keycloak(started.authorization_url, "wrong-password")
    assert "code" not in returned


def settings_native_return() -> str:
    from django.conf import settings

    return settings.SSO_NATIVE_RETURN_URL
