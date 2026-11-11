"""Uploading and reading a file over HTTP, as the app does it."""

from datetime import timedelta
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.test import Client
from django.utils import timezone

from infrastructure.attachments.models import UploadSession
from infrastructure.attachments.tests.conftest import real_png
from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import services as workspaces

PASSWORD = "corr3ct-horse-battery"


class Caller:
    def __init__(self, name: str) -> None:
        self.client = Client()
        response = self.client.post(
            "/api/v1/auth/password/signup",
            {"identifier": name, "password": PASSWORD, "email": f"{name}@example.com"},
            content_type="application/json",
        )
        assert response.status_code == 200, response.content
        self.token = response.json()["data"]["credentials"]["access_token"]
        self.user = get_user_model().objects.get(username=name)

    def call(self, method: str, path: str, body: Any = None, **extra: Any) -> Any:
        headers = {"HTTP_AUTHORIZATION": f"Bearer {self.token}"}
        send = getattr(self.client, method)
        if isinstance(body, bytes):
            return send(path, body, content_type="application/octet-stream", **headers, **extra)
        if body is not None:
            return send(path, body, content_type="application/json", **headers, **extra)
        return send(path, **headers, **extra)


@pytest.fixture
def world(db: None) -> dict[str, Any]:
    zoe, max_ = Caller("zoe"), Caller("max")
    workspace = workspaces.create(zoe.user, "Acme", "acme")
    project = projects.create(zoe.user, workspace, "Web", "WEB").project
    task = tasks.create(zoe.user, workspace, str(project.pk), "Fix login")
    return {"zoe": zoe, "max": max_, "ws": workspace, "project": project, "task": task}


def _open(who: Caller, world: dict[str, Any], name: str, size: int, **more: Any) -> Any:
    return who.call(
        "post",
        "/api/v1/uploads",
        {
            "workspace_id": str(world["ws"].pk),
            "project_id": str(world["project"].pk),
            "task_id": str(world["task"].pk),
            "filename": name,
            "size": size,
            **more,
        },
    )


def _send(who: Caller, world: dict[str, Any], name: str, data: bytes) -> dict[str, Any]:
    opened = _open(who, world, name, len(data))
    assert opened.status_code == 200, opened.content
    session = opened.json()["data"]
    size = session["chunk_size"]
    for n in range(session["chunk_count"]):
        part = data[n * size : (n + 1) * size]
        put = who.call("put", f"/api/v1/uploads/{session['id']}/chunk/{n}", part)
        assert put.status_code == 200, put.content
    done = who.call("post", f"/api/v1/uploads/{session['id']}/complete")
    assert done.status_code == 200, done.content
    return done.json()["data"]


def test_a_file_goes_up_in_chunks_and_comes_back_through_a_signed_link(
    world: dict[str, Any],
) -> None:
    zoe = world["zoe"]
    data = b"the quick brown fox jumps over the lazy dog\n" * 3

    attachment = _send(zoe, world, "fox.txt", data)
    link = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]
    fetched = Client().get(link["url"])  # no credential: the token is the credential

    assert attachment["mime"] == "text/plain" and attachment["size"] == len(data)
    assert fetched.status_code == 200 and b"".join(fetched.streaming_content) == data
    assert fetched["Content-Disposition"].startswith("inline")
    assert fetched["X-Content-Type-Options"] == "nosniff"


def test_progress_can_be_read_back_to_resume(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    opened = _open(zoe, world, "a.bin", 40).json()["data"]
    zoe.call("put", f"/api/v1/uploads/{opened['id']}/chunk/1", b"x" * 16)

    status = zoe.call("get", f"/api/v1/uploads/{opened['id']}").json()["data"]

    assert status["received"] == [1] and status["chunk_count"] == 3


def test_an_incomplete_upload_says_what_is_missing(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    opened = _open(zoe, world, "a.bin", 40).json()["data"]

    done = zoe.call("post", f"/api/v1/uploads/{opened['id']}/complete")

    assert done.status_code == 409
    assert done.json()["title"] == "UPLOAD_INCOMPLETE"
    assert done.json()["data"] == {"missing": "0,1,2"}


def test_a_chunk_longer_than_it_should_be_is_refused(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    opened = _open(zoe, world, "a.bin", 40).json()["data"]

    put = zoe.call("put", f"/api/v1/uploads/{opened['id']}/chunk/0", b"x" * 5000)

    assert put.status_code == 413


def test_cancelling_removes_the_upload(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    opened = _open(zoe, world, "a.bin", 40).json()["data"]

    assert zoe.call("delete", f"/api/v1/uploads/{opened['id']}").status_code == 200
    assert zoe.call("get", f"/api/v1/uploads/{opened['id']}").status_code == 404
    assert not UploadSession.objects.exists()


def test_a_stranger_gets_403_and_cannot_touch_anothers_upload(world: dict[str, Any]) -> None:
    zoe, max_ = world["zoe"], world["max"]

    assert _open(max_, world, "a.txt", 5).status_code == 403
    opened = _open(zoe, world, "a.bin", 40).json()["data"]
    assert max_.call("get", f"/api/v1/uploads/{opened['id']}").status_code == 404


def test_every_upload_call_needs_a_credential(world: dict[str, Any]) -> None:
    anonymous = Client()

    assert anonymous.post("/api/v1/uploads", {}, content_type="application/json").status_code == 401
    assert anonymous.get("/api/v1/uploads/x").status_code in (401, 422)
    assert anonymous.get(f"/api/v1/files/{world['task'].pk}/link").status_code == 401


def test_a_link_stops_working_after_it_expires_and_a_stranger_never_gets_one(
    world: dict[str, Any], settings: Any
) -> None:
    zoe, max_ = world["zoe"], world["max"]
    attachment = _send(zoe, world, "plans.txt", b"secret plans\n")

    assert max_.call("get", f"/api/v1/files/{attachment['id']}/link").status_code == 403
    assert max_.call("get", f"/api/v1/files/{attachment['id']}").status_code == 403
    url = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]["url"]
    settings.ATTACHMENT_LINK_TTL_SECONDS = -1

    late = Client().get(url)

    assert late.status_code == 403 and late.json()["title"] == "LINK_EXPIRED"


def test_a_link_cannot_be_used_for_another_file(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    first = _send(zoe, world, "a.txt", b"one\n")
    second = _send(zoe, world, "b.txt", b"two\n")
    url = zoe.call("get", f"/api/v1/files/{first['id']}/link").json()["data"]["url"]

    swapped = Client().get(url.replace(first["id"], second["id"]))

    assert swapped.status_code == 403


def test_the_plain_download_redirects_to_a_signed_link(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    attachment = _send(zoe, world, "a.txt", b"one\n")

    response = zoe.call("get", f"/api/v1/files/{attachment['id']}")

    assert response.status_code == 302 and "/raw?token=" in response["Location"]


def test_risky_content_is_always_a_download(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    attachment = _send(zoe, world, "page.html", b"<html><script>alert(1)</script></html>")
    url = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]["url"]

    served = Client().get(url)

    assert served["Content-Disposition"].startswith("attachment")
    assert "sandbox" in served["Content-Security-Policy"]


def test_pictures_have_a_thumbnail_link(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    attachment = _send(zoe, world, "a.png", real_png())

    thumb = zoe.call("get", f"/api/v1/files/{attachment['id']}/link?thumb=true").json()["data"]
    served = Client().get(thumb["url"])

    assert attachment["has_thumb"] and served["Content-Type"] == "image/jpeg"
    assert (
        zoe.call(
            "get", f"/api/v1/files/{_send(zoe, world, 'b.txt', b'x')['id']}/link?thumb=true"
        ).status_code
        == 404
    )


@pytest.mark.parametrize(
    ("header", "status", "length", "content_range"),
    [
        ("bytes=0-3", 206, 4, "bytes 0-3/10"),
        ("bytes=6-", 206, 4, "bytes 6-9/10"),
        ("bytes=-3", 206, 3, "bytes 7-9/10"),
        ("bytes=4-400", 206, 6, "bytes 4-9/10"),
        ("bytes=50-60", 416, None, "bytes */10"),
        ("bytes=-0", 416, None, "bytes */10"),
    ],
)
def test_ranges_are_honoured_so_video_can_seek(
    world: dict[str, Any], header: str, status: int, length: int | None, content_range: str
) -> None:
    zoe = world["zoe"]
    attachment = _send(zoe, world, "a.txt", b"0123456789")
    url = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]["url"]

    served = Client().get(url, HTTP_RANGE=header)

    assert served.status_code == status and served["Content-Range"] == content_range
    if length is not None:
        assert len(b"".join(served.streaming_content)) == length


def test_a_session_that_expired_is_gone(world: dict[str, Any]) -> None:
    zoe = world["zoe"]
    opened = _open(zoe, world, "a.bin", 40).json()["data"]
    UploadSession.objects.update(expires_at=timezone.now() - timedelta(hours=1))

    gone = zoe.call("put", f"/api/v1/uploads/{opened['id']}/chunk/0", b"x" * 16)

    assert gone.status_code == 404 and gone.json()["title"] == "UPLOAD_EXPIRED"


@pytest.mark.parametrize("header", ["bytes=0-1,3-4", "items=0-1", "bytes=abc", "garbage"])
def test_a_range_we_do_not_serve_is_ignored_and_the_whole_file_goes_out(
    world: dict[str, Any], header: str
) -> None:
    zoe = world["zoe"]
    attachment = _send(zoe, world, "a.txt", b"0123456789")
    url = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]["url"]

    served = Client().get(url, HTTP_RANGE=header)

    assert served.status_code == 200 and b"".join(served.streaming_content) == b"0123456789"


def test_the_token_is_not_leaked_through_the_referrer_and_a_pdf_is_not_sandboxed(
    world: dict[str, Any], settings: Any
) -> None:
    import io

    from PIL import Image

    settings.ATTACHMENT_MAX_BYTES = 1024 * 1024
    zoe = world["zoe"]
    pdf = io.BytesIO()
    Image.new("RGB", (100, 100), "white").save(pdf, "PDF")
    attachment = _send(zoe, world, "a.pdf", pdf.getvalue())
    url = zoe.call("get", f"/api/v1/files/{attachment['id']}/link").json()["data"]["url"]

    served = Client().get(url)

    assert served["Referrer-Policy"] == "no-referrer"
    assert "sandbox" not in served["Content-Security-Policy"]
    assert served["Content-Disposition"].startswith("inline")
