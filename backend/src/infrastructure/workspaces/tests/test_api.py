"""Logo upload over REST."""

from typing import Any

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import Client

from infrastructure.workspaces import services
from infrastructure.workspaces.models import Workspace

PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 32
PASSWORD = "corr3ct-horse-battery"


def _signup(username: str) -> tuple[Client, Any]:
    client = Client()
    response = client.post(
        "/api/v1/auth/password/signup",
        {"identifier": username, "password": PASSWORD, "email": f"{username}@example.com"},
        content_type="application/json",
    )
    assert response.status_code == 200, response.content
    token = response.json()["data"]["credentials"]["access_token"]
    from django.contrib.auth import get_user_model

    return client, (token, get_user_model().objects.get(username=username))


@pytest.fixture(autouse=True)
def _media(tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path


def _upload(client: Client, token: str, workspace_id: Any, data: bytes = PNG) -> Any:
    return client.post(
        f"/api/v1/workspaces/{workspace_id}/logo",
        {"file": SimpleUploadedFile("logo.png", data, content_type="image/png")},
        HTTP_AUTHORIZATION=f"Bearer {token}",
    )


def test_owner_uploads_a_logo(db: None) -> None:
    client, (token, user) = _signup("zoe")
    workspace = services.create(user, "Acme", "acme")

    response = _upload(client, token, workspace.id)

    assert response.status_code == 200, response.content
    body = response.json()["data"]
    assert body["logo"].endswith(".png") and body["version"] == 2


def test_upload_requires_a_credential(db: None) -> None:
    _, (_, user) = _signup("zoe")
    workspace = services.create(user, "Acme", "acme")

    response = Client().post(f"/api/v1/workspaces/{workspace.id}/logo")

    assert response.status_code == 401


def test_outsider_gets_403_same_as_a_missing_workspace(db: None) -> None:
    _, (_, zoe) = _signup("zoe")
    client, (token, _) = _signup("max")
    workspace = services.create(zoe, "Acme", "acme")

    real = _upload(client, token, workspace.id)
    fake = _upload(client, token, "00000000-0000-0000-0000-000000000000")

    assert real.status_code == fake.status_code == 403
    assert Workspace.objects.get(pk=workspace.pk).logo.name == ""


def test_non_image_is_rejected(db: None) -> None:
    client, (token, user) = _signup("zoe")
    workspace = services.create(user, "Acme", "acme")

    response = _upload(client, token, workspace.id, b"<html></html>")

    assert response.status_code == 400


def test_oversized_upload_is_rejected_before_reading(db: None) -> None:
    client, (token, user) = _signup("zoe")
    workspace = services.create(user, "Acme", "acme")
    big = PNG + b"0" * services.LOGO_MAX_BYTES

    response = _upload(client, token, workspace.id, big)

    assert response.status_code == 400
    assert Workspace.objects.get(pk=workspace.pk).logo.name == ""
