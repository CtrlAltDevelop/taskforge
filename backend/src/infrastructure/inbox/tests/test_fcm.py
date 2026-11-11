"""The FCM provider against a fake HTTP server."""

import json
from pathlib import Path
from typing import Any

import httpx
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

from infrastructure.inbox import push


class Device:
    token = "device-token"
    platform = "android"
    pk = 1


@pytest.fixture
def credentials(settings: Any, tmp_path: Path) -> None:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    pem = key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode()
    path = tmp_path / "account.json"
    path.write_text(
        json.dumps({"client_email": "svc@proj.iam.gserviceaccount.com", "private_key": pem})
    )
    settings.INBOX_FCM_CREDENTIALS_FILE = str(path)
    settings.INBOX_FCM_PROJECT_ID = "taskforge-test"


def client(answer: int = 200, text: str = "{}") -> tuple[httpx.Client, list[httpx.Request]]:
    seen: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        if request.url.host == "oauth2.googleapis.com":
            return httpx.Response(200, json={"access_token": "ya29.token", "expires_in": 3600})
        return httpx.Response(answer, text=text)

    return httpx.Client(transport=httpx.MockTransport(handler)), seen


def test_a_push_is_posted_with_a_bearer_token_from_the_service_account(credentials: None) -> None:
    http, seen = client()

    push.FcmPush(http).send(Device(), "Title", "Body", {"task_id": "t"})

    token_call, send_call = seen
    assert b"jwt-bearer" in token_call.content
    assert send_call.url.path == "/v1/projects/taskforge-test/messages:send"
    assert send_call.headers["Authorization"] == "Bearer ya29.token"
    message = json.loads(send_call.content)["message"]
    assert message["token"] == "device-token" and message["notification"]["title"] == "Title"
    assert message["data"] == {"task_id": "t"}


def test_the_access_token_is_reused(credentials: None) -> None:
    http, seen = client()
    provider = push.FcmPush(http)

    provider.send(Device(), "a", "b", {})
    provider.send(Device(), "c", "d", {})

    assert [r.url.host for r in seen].count("oauth2.googleapis.com") == 1


@pytest.mark.parametrize(
    ("status", "text"), [(404, ""), (410, ""), (400, '{"error":"UNREGISTERED"}')]
)
def test_a_token_the_service_does_not_know_is_reported_dead(
    credentials: None, status: int, text: str
) -> None:
    http, _ = client(status, text)

    with pytest.raises(push.DeadToken):
        push.FcmPush(http).send(Device(), "a", "b", {})


def test_any_other_failure_is_an_error_to_retry(credentials: None) -> None:
    http, _ = client(500)

    with pytest.raises(httpx.HTTPStatusError):
        push.FcmPush(http).send(Device(), "a", "b", {})


def test_the_provider_is_one_per_process(monkeypatch: pytest.MonkeyPatch, settings: Any) -> None:
    from infrastructure.inbox import delivery

    monkeypatch.setattr(delivery, "_provider", None)
    settings.INBOX_PUSH_PROVIDER = "infrastructure.inbox.push.LoggingPush"

    assert delivery.push_provider() is delivery.push_provider()


def test_missing_credentials_say_so(settings: Any) -> None:
    settings.INBOX_FCM_CREDENTIALS_FILE = ""
    http, _ = client()

    with pytest.raises(RuntimeError, match="INBOX_FCM"):
        push.FcmPush(http).send(Device(), "a", "b", {})
