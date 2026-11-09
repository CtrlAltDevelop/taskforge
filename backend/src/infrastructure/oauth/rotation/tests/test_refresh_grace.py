"""A refresh that races its own successor is a hiccup; a replay long after is theft.

Two requests on one device can find the access token expired at the same moment
and both refresh with the same token. Treating the loser as theft ends the
session and logs the user out for no reason, so a token spent a moment ago is
answered with a retryable 409 instead -- and the session stays alive.
"""

from datetime import timedelta
from typing import Any

from django.test import Client, override_settings
from django.utils import timezone

from infrastructure.oauth.rotation.models import RotatingRefreshToken
from infrastructure.oauth.rotation.tests.test_api import SESSIONS, _login, _refresh

GRACE = 10


def _age_spent_tokens(seconds: int) -> None:
    RotatingRefreshToken.objects.filter(used_at__isnull=False).update(
        used_at=timezone.now() - timedelta(seconds=seconds)
    )


def _sessions(client: Client, access_token: str) -> Any:
    return client.get(SESSIONS, HTTP_AUTHORIZATION=f"Bearer {access_token}")


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=GRACE)
def test_a_token_spent_a_moment_ago_gets_a_retryable_conflict(db: None) -> None:
    client = Client()
    original = _login(client)
    _refresh(client, original["refresh_token"])

    response = _refresh(client, original["refresh_token"])

    assert response.status_code == 409, response.content
    assert response.json()["title"] == "REFRESH_RACE"


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=GRACE)
def test_a_race_does_not_end_the_session(db: None) -> None:
    client = Client()
    original = _login(client)
    winner = _refresh(client, original["refresh_token"]).json()["data"]
    _refresh(client, original["refresh_token"])  # the loser of the race

    retry = _refresh(client, winner["refresh_token"])

    assert retry.status_code == 200, retry.content
    assert _sessions(client, retry.json()["data"]["access_token"]).status_code == 200


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=GRACE)
def test_a_replay_after_the_grace_window_is_theft_and_ends_the_session(db: None) -> None:
    client = Client()
    original = _login(client)
    winner = _refresh(client, original["refresh_token"]).json()["data"]
    _age_spent_tokens(GRACE + 1)

    replay = _refresh(client, original["refresh_token"])

    assert replay.status_code == 401, replay.content
    assert replay.json()["title"] == "TOKEN_REUSED"
    assert _refresh(client, winner["refresh_token"]).status_code == 401


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=0)
def test_with_no_grace_window_any_replay_is_theft(db: None) -> None:
    client = Client()
    original = _login(client)
    _refresh(client, original["refresh_token"])

    replay = _refresh(client, original["refresh_token"])

    assert replay.status_code == 401
    assert replay.json()["title"] == "TOKEN_REUSED"


@override_settings(AUTH_REFRESH_REUSE_GRACE_SECONDS=GRACE)
def test_a_spent_token_of_an_ended_session_is_refused_not_told_to_retry(db: None) -> None:
    """Inside the grace window, a revoked session must not read as a harmless race."""
    client = Client()
    original = _login(client)
    winner = _refresh(client, original["refresh_token"]).json()["data"]
    client.post(
        "/api/v1/auth/password/logout",
        {"token": winner["refresh_token"]},
        content_type="application/json",
    )

    replay = _refresh(client, original["refresh_token"])

    assert replay.status_code == 401, replay.content
    assert replay.json()["title"] == "SESSION_ENDED"
