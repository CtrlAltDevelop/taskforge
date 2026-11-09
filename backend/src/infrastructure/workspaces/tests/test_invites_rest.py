"""Public invitation preview and accept over REST."""

from typing import Any

import pytest
from django.test import Client

from infrastructure.workspaces import invitations, services

from .test_api import _signup


def _post(client: Client, action: str, invite: str, bearer: str = "") -> Any:
    extra = {"HTTP_AUTHORIZATION": f"Bearer {bearer}"} if bearer else {}
    return client.post(
        f"/api/v1/invites/{action}",
        {"token": invite},
        content_type="application/json",
        **extra,
    )


def test_preview_is_public_and_accept_needs_auth(db: None) -> None:
    _, (token, owner) = _signup("zoe")
    workspace = services.create(owner, "Acme", "acme")
    link = invitations.create_link(workspace, owner)

    preview = _post(Client(), "preview", link.token)
    anon_accept = _post(Client(), "accept", link.token)

    assert preview.status_code == 200
    assert preview.json()["data"] == {
        "workspace_name": "Acme",
        "inviter_name": "zoe",
        "email_bound": False,
        "state": "valid",
    }
    assert anon_accept.status_code == 401


def test_accept_joins_and_repeat_is_ok(db: None) -> None:
    _, (_, owner) = _signup("zoe")
    client, (token, _) = _signup("max")
    link = invitations.create_link(services.create(owner, "Acme", "acme"), owner)

    for _ in range(2):
        response = _post(client, "accept", link.token, token)
        assert response.status_code == 200, response.content
        assert response.json()["data"]["slug"] == "acme"


def test_unknown_tokens_all_look_the_same(db: None) -> None:
    bodies = {_post(Client(), "preview", t).content for t in ("nope", "x" * 43, "a-b_c")}

    assert len(bodies) == 1
    assert _post(Client(), "preview", "nope").status_code == 404


def test_token_in_the_path_is_not_a_route(db: None) -> None:
    assert Client().get("/api/v1/invites/nope").status_code in (404, 405)
    assert Client().post("/api/v1/invites/nope/accept").status_code in (404, 405)


def test_expired_accept_is_410(db: None) -> None:
    _, (_, owner) = _signup("zoe")
    client, (token, _) = _signup("max")
    link = invitations.create_link(services.create(owner, "Acme", "acme"), owner)
    invitations.revoke(link.invitation.workspace, str(link.invitation.id))

    response = _post(client, "accept", link.token, token)

    assert response.status_code == 410
    assert response.json()["title"] == "INVITE_REVOKED"


def test_preview_is_rate_limited_per_ip(db: None, settings: Any) -> None:
    settings.API_THROTTLE_INVITE = "2/min"
    codes = [_post(Client(), "preview", "nope").status_code for _ in range(3)]

    assert codes == [404, 404, 429]


@pytest.fixture(autouse=True)
def _media(tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path
