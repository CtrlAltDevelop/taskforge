"""The public API end to end with a ``tf_`` token, token audit entries and SSRF at connect time."""

import json
import socket
from datetime import timedelta
from typing import Any

import pytest
from django.test import Client
from django.utils import timezone

from infrastructure.audit.models import AuditEntry
from infrastructure.automations import safe_http
from infrastructure.developer import outbound, services
from infrastructure.developer.models import ApiToken
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks.models import Task

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


def _issue(team: Any, scopes: list[str], user: Any = None, ws: Any = None) -> services.Issued:
    return services.create_token(user or team.member, ws or team.ws, "ci", scopes)


def _create(team: Any, project: Any, secret: str, ws: Any = None) -> Any:
    ws = ws or team.ws
    return Client().post(
        f"/api/v1/workspaces/{ws.pk}/projects/{project.pk}/tasks",
        data=json.dumps({"title": "From curl"}),
        content_type="application/json",
        HTTP_AUTHORIZATION=f"Bearer {secret}",
    )


def test_a_token_creates_a_task(team: Any, project: Any) -> None:
    issued = _issue(team, ["tasks:write"])
    response = _create(team, project, issued.secret)
    assert response.status_code == 201
    assert response.json()["data"]["title"] == "From curl"
    assert Task.objects.get().title == "From curl"


def test_a_missing_scope_is_403_naming_the_scope(team: Any, project: Any) -> None:
    issued = _issue(team, ["tasks:read"])
    response = _create(team, project, issued.secret)
    assert response.status_code == 403
    assert "tasks:write" in response.content.decode()
    assert Task.objects.count() == 0


def test_a_token_of_another_workspace_is_refused(team: Any, project: Any) -> None:
    issued = _issue(team, ["tasks:write"], user=team.outsider, ws=team.other_ws)
    response = _create(team, project, issued.secret)  # aimed at team.ws
    assert response.status_code in (403, 404)
    assert Task.objects.count() == 0


def test_a_revoked_token_is_401(team: Any, project: Any) -> None:
    issued = _issue(team, ["tasks:write"])
    services.revoke_token(team.member, team.ws, str(issued.token.pk))
    assert _create(team, project, issued.secret).status_code == 401


def test_an_expired_token_is_401(team: Any, project: Any) -> None:
    issued = _issue(team, ["tasks:write"])
    ApiToken.objects.filter(pk=issued.token.pk).update(expires_at=timezone.now() - timedelta(1))
    assert _create(team, project, issued.secret).status_code == 401


def test_a_garbage_token_is_401(team: Any, project: Any) -> None:
    assert _create(team, project, "tf_deadbeef_" + "0" * 48).status_code == 401


def test_token_audit_rows_hold_name_and_prefix_but_never_the_secret(team: Any) -> None:
    issued = _issue(team, ["tasks:read"])
    services.revoke_token(team.member, team.ws, str(issued.token.pk))
    rows = list(AuditEntry.objects.filter(action__in=["token.created", "token.revoked"]))
    assert sorted(r.action for r in rows) == ["token.created", "token.revoked"]
    for row in rows:
        assert row.workspace == team.ws.pk and row.target_id == str(issued.token.pk)
        assert row.actor == str(team.member.pk)
        assert row.changes["name"] == "ci" and row.changes["prefix"] == issued.token.prefix
        dump = json.dumps(row.changes) + row.target_id + row.user_agent
        assert issued.secret not in dump
        assert issued.token.hash not in dump
        assert issued.secret.split("_")[-1] not in dump


# ---- SSRF at connect time (the network is mocked) ----------------------------------------


def _dns(monkeypatch: pytest.MonkeyPatch, *answers: str) -> list[str]:
    """``getaddrinfo`` answering ``answers`` in turn (the last one repeats)."""
    asked: list[str] = []
    queue = list(answers)

    def lookup(host: str, port: int) -> list[Any]:
        asked.append(host)
        address = queue.pop(0) if len(queue) > 1 else queue[0]
        family = socket.AF_INET6 if ":" in address else socket.AF_INET
        return [(family, socket.SOCK_STREAM, 6, "", (address, port))]

    monkeypatch.setattr(safe_http, "_lookup", lookup)
    return asked


def _no_socket(monkeypatch: pytest.MonkeyPatch) -> list[Any]:
    dialled: list[Any] = []

    def refuse(*args: Any, **kwargs: Any) -> Any:
        dialled.append(args)
        raise AssertionError("a connection was attempted")

    monkeypatch.setattr(socket, "create_connection", refuse)
    return dialled


@pytest.mark.parametrize(
    "address", ["127.0.0.1", "169.254.169.254", "10.0.0.8", "::ffff:127.0.0.1", "::1", "fe80::1"]
)
def test_a_name_resolving_privately_is_refused_before_any_connection(
    monkeypatch: pytest.MonkeyPatch, address: str
) -> None:
    _dns(monkeypatch, address)
    dialled = _no_socket(monkeypatch)
    with pytest.raises(outbound.UnsafeUrl):
        outbound.post("http://hooks.example.com/x", b"{}", {})
    assert dialled == []


def test_one_private_answer_among_public_ones_refuses_the_name(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def lookup(host: str, port: int) -> list[Any]:
        return [
            (socket.AF_INET, socket.SOCK_STREAM, 6, "", (a, port))
            for a in ("93.184.216.34", "169.254.169.254")
        ]

    monkeypatch.setattr(safe_http, "_lookup", lookup)
    with pytest.raises(outbound.UnsafeUrl):
        outbound._resolve("http://hooks.example.com/x")


def test_dns_rebinding_the_second_answer_is_never_used(monkeypatch: pytest.MonkeyPatch) -> None:
    asked = _dns(monkeypatch, "93.184.216.34", "127.0.0.1")
    target = outbound._resolve("http://rebind.example.com/x")
    assert target.ip == "93.184.216.34"  # pinned: the connection goes to the vetted address
    dialled: list[Any] = []

    def fake_connection(address: Any, timeout: float) -> Any:
        dialled.append(address)
        raise OSError("stop here")

    monkeypatch.setattr(socket, "create_connection", fake_connection)
    with pytest.raises(outbound.UnsafeUrl):
        outbound.post("http://rebind.example.com/x", b"{}", {})
    assert asked == ["rebind.example.com", "rebind.example.com"]
    # the second resolve (127.0.0.1) was refused outright; no connection was made to it
    assert all(a[0] != "127.0.0.1" for a in dialled)


def test_the_address_is_vetted_again_at_the_moment_of_connecting(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    dialled = _no_socket(monkeypatch)
    bad = safe_http.Target("http", "x.example.com", 80, "/", "127.0.0.1")
    connection = outbound._Pinned(bad, deadline=1e12)
    with pytest.raises(outbound.UnsafeUrl):
        connection.connect()
    assert dialled == []


def test_a_redirect_is_an_answer_and_is_not_followed(monkeypatch: pytest.MonkeyPatch) -> None:
    _dns(monkeypatch, "93.184.216.34")
    requests: list[str] = []

    class FakeResponse:
        status = 302

        def read(self, n: int) -> bytes:
            return b""

    class FakeConnection:
        sock = None

        def __init__(self, target: Any, deadline: float) -> None:
            self.target = target

        def request(self, method: str, path: str, body: bytes, headers: dict[str, str]) -> None:
            requests.append(f"{self.target.ip}{path}")

        def getresponse(self) -> FakeResponse:
            return FakeResponse()

        def close(self) -> None:
            return None

    monkeypatch.setattr(outbound, "_Pinned", FakeConnection)
    answer = outbound.post("http://hooks.example.com/start", b"{}", {})
    assert answer.status == 302
    assert requests == ["93.184.216.34/start"]  # one request only; the Location was ignored


def test_urls_naming_private_hosts_never_reach_dns(monkeypatch: pytest.MonkeyPatch) -> None:
    asked = _dns(monkeypatch, "93.184.216.34")
    for url in ("http://[::ffff:127.0.0.1]/x", "http://169.254.169.254/latest/meta-data"):
        with pytest.raises(outbound.UnsafeUrl):
            outbound.check_url(url)
    assert asked == []
