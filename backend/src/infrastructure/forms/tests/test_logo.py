"""A form's logo can be uploaded instead of linked; the public page then shows the upload."""

import json
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import Client

from infrastructure.forms import services
from infrastructure.forms.models import Form
from infrastructure.projects import services as project_services
from infrastructure.workspaces import services as workspace_services

PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 32
PASSWORD = "corr3ct-horse-battery"
FIELDS = [{"id": "t", "kind": "title", "label": "Title"}]


@pytest.fixture(autouse=True)
def _media(tmp_path: Any, settings: Any) -> None:
    settings.MEDIA_ROOT = tmp_path


class World:
    def __init__(self) -> None:
        self.client = Client()
        reply = self.client.post(
            "/api/v1/auth/password/signup",
            {"identifier": "zoe", "password": PASSWORD, "email": "zoe@example.com"},
            content_type="application/json",
        )
        self.token = reply.json()["data"]["credentials"]["access_token"]
        self.user = get_user_model().objects.get(username="zoe")
        self.ws = workspace_services.create(self.user, "Acme", "acme")
        project = project_services.create(self.user, self.ws, "Web", "WEB").project
        self.form: Form = services.create(
            self.user, self.ws, str(project.pk), "Bug", fields=FIELDS
        ).form

    def upload(self, data: bytes = PNG, name: str = "logo.png", **extra: Any) -> Any:
        return self.client.post(
            f"/api/v1/forms/{self.form.pk}/logo",
            {
                "file": SimpleUploadedFile(name, data, content_type="image/png"),
                "expected_version": str(self.form.version),
                **extra,
            },
            HTTP_AUTHORIZATION=f"Bearer {self.token}",
            HTTP_X_WORKSPACE=str(self.ws.pk),
        )

    def public(self) -> dict[str, Any]:
        self.form.refresh_from_db()
        return json.loads(Client().get(f"/api/v1/public/forms/{self.form.token}").content)["data"]


@pytest.fixture
def world(db: None) -> World:
    return World()


def test_an_uploaded_logo_is_what_the_public_page_shows(world: World) -> None:
    response = world.upload()

    assert response.status_code == 200, response.content
    body = response.json()["data"]
    assert body["logo_url"].endswith(".png") and body["version"] == world.form.version + 1
    assert world.public()["logo_url"] == body["logo_url"]


def test_a_program_renamed_to_png_is_refused(world: World) -> None:
    response = world.upload(b"MZ\x90\x00" + b"0" * 64)

    assert response.status_code == 400
    world.form.refresh_from_db()
    assert not world.form.logo


def test_a_logo_over_two_megabytes_is_refused(world: World) -> None:
    assert world.upload(PNG + b"0" * (2 * 1024 * 1024)).status_code == 400


def test_a_stale_version_is_a_conflict(world: World) -> None:
    assert world.upload(expected_version="99").status_code == 409


def test_someone_without_form_manage_cannot_upload(world: World) -> None:
    from infrastructure.workspaces.tests.conftest import add_member  # noqa: F401

    other = get_user_model().objects.create_user("eve", "eve@example.com", PASSWORD)
    from infrastructure.workspaces import invitations

    invitations.accept(invitations.create_link(world.ws, world.user).token, other)
    login = Client().post(
        "/api/v1/auth/password/login",
        {"identifier": "eve", "password": PASSWORD},
        content_type="application/json",
    )
    token = login.json()["data"]["credentials"]["access_token"]

    response = world.client.post(
        f"/api/v1/forms/{world.form.pk}/logo",
        {
            "file": SimpleUploadedFile("l.png", PNG, content_type="image/png"),
            "expected_version": str(world.form.version),
        },
        HTTP_AUTHORIZATION=f"Bearer {token}",
        HTTP_X_WORKSPACE=str(world.ws.pk),
    )

    assert response.status_code == 403


def test_linking_a_web_address_replaces_the_upload_and_deletes_the_file(world: World) -> None:
    world.upload()
    world.form.refresh_from_db()
    stored = world.form.logo.path

    services.update(
        world.user, world.ws, str(world.form.pk), world.form.version,
        logo_url="https://example.com/logo.png",
    )  # fmt: skip

    world.form.refresh_from_db()
    assert not world.form.logo
    assert world.public()["logo_url"] == "https://example.com/logo.png"
    from pathlib import Path

    assert not Path(stored).exists()


def test_clearing_the_logo_removes_the_upload(world: World) -> None:
    world.upload()
    world.form.refresh_from_db()

    services.update(world.user, world.ws, str(world.form.pk), world.form.version, logo_url="")

    assert world.public()["logo_url"] == ""


def test_an_uploaded_logo_replaces_a_linked_one(world: World) -> None:
    services.update(
        world.user, world.ws, str(world.form.pk), world.form.version,
        logo_url="https://example.com/logo.png",
    )  # fmt: skip
    world.form.refresh_from_db()

    world.upload()

    assert world.public()["logo_url"].endswith(".png")
    assert "example.com" not in world.public()["logo_url"]
