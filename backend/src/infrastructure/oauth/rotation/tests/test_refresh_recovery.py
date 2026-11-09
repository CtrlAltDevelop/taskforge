"""A refresh whose response was lost can be retried safely, because the client tagged it.

The client sends a secret ``request_id`` with a refresh. If the answer never arrives
it retries the same refresh with the same id; the server recognises its own request
and issues the successor again (killing the copy that was lost). A thief replaying
the spent token does not know the id, so for them nothing changes.
"""

from datetime import timedelta
from typing import Any

from django.test import Client, override_settings
from django.utils import timezone

from infrastructure.oauth.rotation.models import RotatingRefreshToken
from infrastructure.oauth.rotation.tests.test_api import SESSIONS, _login, _refresh

REFRESH = "/api/v1/auth/token/refresh"
RECOVERY = 900


def _refresh_with(client: Client, refresh_token: str, request_id: str) -> Any:
    return client.post(
        REFRESH,
        {"refresh_token": refresh_token, "request_id": request_id},
        content_type="application/json",
    )


def _age_spent_tokens(seconds: int) -> None:
    RotatingRefreshToken.objects.filter(used_at__isnull=False).update(
        used_at=timezone.now() - timedelta(seconds=seconds)
    )


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_a_retry_with_the_same_request_id_recovers_a_lost_response(db: None) -> None:
    client = Client()
    original = _login(client)
    lost = _refresh_with(client, original["refresh_token"], "req-1").json()["data"]
    _age_spent_tokens(60)  # long past the grace window, as a flaky mobile network would be

    retry = _refresh_with(client, original["refresh_token"], "req-1")

    assert retry.status_code == 200, retry.content
    recovered = retry.json()["data"]
    assert recovered["refresh_token"] != lost["refresh_token"]
    # The copy that was lost in transit is dead; the recovered pair is the live one.
    assert _refresh(client, lost["refresh_token"]).status_code == 401
    assert (
        client.get(SESSIONS, HTTP_AUTHORIZATION=f"Bearer {recovered['access_token']}").status_code
        == 200
    )
    assert _refresh(client, recovered["refresh_token"]).status_code == 200


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_a_replay_with_a_different_request_id_is_still_theft(db: None) -> None:
    client = Client()
    original = _login(client)
    _refresh_with(client, original["refresh_token"], "req-1")
    _age_spent_tokens(60)

    thief = _refresh_with(client, original["refresh_token"], "guessed-id")

    assert thief.status_code == 401
    assert thief.json()["title"] == "TOKEN_REUSED"


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_a_replay_with_no_request_id_is_still_theft_after_the_grace_window(db: None) -> None:
    client = Client()
    original = _login(client)
    _refresh_with(client, original["refresh_token"], "req-1")
    _age_spent_tokens(60)

    assert _refresh(client, original["refresh_token"]).status_code == 401


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_recovery_is_refused_once_the_successor_has_been_used(db: None) -> None:
    client = Client()
    original = _login(client)
    first = _refresh_with(client, original["refresh_token"], "req-1").json()["data"]
    assert _refresh(client, first["refresh_token"]).status_code == 200  # the client moved on
    _age_spent_tokens(60)

    replay = _refresh_with(client, original["refresh_token"], "req-1")

    assert replay.status_code == 401
    assert replay.json()["title"] == "TOKEN_REUSED"


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_recovery_expires(db: None) -> None:
    client = Client()
    original = _login(client)
    _refresh_with(client, original["refresh_token"], "req-1")
    _age_spent_tokens(RECOVERY + 60)

    assert _refresh_with(client, original["refresh_token"], "req-1").status_code == 401


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=10, AUTH_REFRESH_RECOVERY_SECONDS=RECOVERY)
def test_a_session_that_ended_cannot_be_recovered(db: None) -> None:
    client = Client()
    original = _login(client)
    first = _refresh_with(client, original["refresh_token"], "req-1").json()["data"]
    client.post(
        "/api/v1/auth/password/logout",
        {"token": first["refresh_token"]},
        content_type="application/json",
    )

    replay = _refresh_with(client, original["refresh_token"], "req-1")

    assert replay.status_code == 401
    assert replay.json()["title"] == "SESSION_ENDED"
