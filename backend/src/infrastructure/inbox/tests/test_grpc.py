"""The inbox controllers over a real gRPC server: the contract. Rules are tested on the services."""

import json
from datetime import timedelta
from typing import Any

import grpc
from django.utils import timezone

from infrastructure.inbox.grpc import inbox_pb2 as pb
from infrastructure.inbox.grpc import inbox_pb2_grpc as stubs
from infrastructure.inbox.models import PushDevice
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

team = base.team  # the fixture, registered here by name
INBOX, W, P, D = (
    stubs.InboxControllerStub,
    stubs.WatcherControllerStub,
    stubs.PrefControllerStub,
    stubs.DeviceControllerStub,
)


def _assign(call: GrpcCall, team: dict[str, Any], who: str = "max") -> Any:
    return _create(call, team, who="zoe", title="T", assignee_ids=[str(team["users"][who].pk)])


def _list(call: GrpcCall, team: dict[str, Any], who: str = "max", **kw: Any) -> Any:
    request = pb.InboxListRequest(workspace_id=team["ws"], **kw)
    return call(INBOX, "List", request, token=team["tokens"][who])


def test_an_assignment_reaches_the_inbox_over_the_wire(team: Any, grpc_call: GrpcCall) -> None:
    task = _assign(grpc_call, team)

    page = _list(grpc_call, team)

    [got] = page.notifications
    assert (got.type, got.task_id, got.actor_id) == (
        "task.assigned",
        task.id,
        str(team["users"]["zoe"].pk),
    )
    assert json.loads(got.payload)["key"] == "WEB-1" and got.count == 1
    assert got.read_at == "" and got.created_at and got.actor_name
    assert page.unread_count == 1 and page.cursor == ""


def test_read_snooze_archive_and_count(team: Any, grpc_call: GrpcCall) -> None:
    _assign(grpc_call, team)
    [got] = _list(grpc_call, team).notifications
    token = team["tokens"]["max"]

    def count() -> int:
        request = pb.UnreadCountRequest(workspace_id=team["ws"])
        return int(grpc_call(INBOX, "UnreadCount", request, token=token).count)

    assert count() == 1
    read = grpc_call(
        INBOX,
        "MarkRead",
        pb.MarkReadRequest(workspace_id=team["ws"], ids=[got.id], read=True),
        token=token,
    )
    assert read.count == 0 and count() == 0
    later = (timezone.now() + timedelta(hours=3)).isoformat()
    snoozed = grpc_call(
        INBOX,
        "Snooze",
        pb.SnoozeRequest(workspace_id=team["ws"], id=got.id, until=later),
        token=token,
    )
    assert snoozed.snoozed_until
    assert list(_list(grpc_call, team).notifications) == []
    assert len(_list(grpc_call, team, filter="snoozed").notifications) == 1
    grpc_call(
        INBOX,
        "Archive",
        pb.ArchiveRequest(workspace_id=team["ws"], ids=[got.id], archived=True),
        token=token,
    )
    assert len(_list(grpc_call, team, filter="archived").notifications) == 1
    assert (
        grpc_call(INBOX, "UnreadCount", pb.UnreadCountRequest(), token=token).count == 0
    )  # all workspaces


def test_a_stranger_is_refused_and_a_bad_request_is_invalid(team: Any, grpc_call: GrpcCall) -> None:
    refused = _refused(
        grpc_call,
        INBOX,
        "List",
        pb.InboxListRequest(workspace_id=team["ws"]),
        token=team["tokens"]["eve"],
    )
    bad = _refused(
        grpc_call,
        INBOX,
        "List",
        pb.InboxListRequest(workspace_id=team["ws"], filter="everything"),
        token=team["tokens"]["max"],
    )

    assert refused.code() is grpc.StatusCode.PERMISSION_DENIED
    assert bad.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_watching_round_trips(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, who="zoe", title="T")
    request = {"workspace_id": team["ws"], "project_id": team["project"], "task_id": task.id}
    token = team["tokens"]["max"]

    before = grpc_call(W, "Get", pb.WatchGetRequest(**request), token=token)
    on = grpc_call(W, "Add", pb.WatchAddRequest(**request), token=token)
    off = grpc_call(W, "Remove", pb.WatchRemoveRequest(**request), token=token)

    assert (before.watching, on.watching, off.watching) == (False, True, False)
    assert (before.watcher_count, on.watcher_count, off.watcher_count) == (1, 2, 1)


def test_preferences_and_settings_round_trip(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]

    got = grpc_call(P, "Get", pb.PrefsGetRequest(), token=token)
    assert [r.event_type for r in got.prefs][0] == "task.assigned" and got.settings.digest_hour == 8
    changed = grpc_call(
        P,
        "Set",
        pb.PrefSetRequest(event_type="comment.added", inbox=False, push=True, email_mode="digest"),
        token=token,
    )
    row = {r.event_type: r for r in changed.prefs}["comment.added"]
    assert (row.inbox, row.push, row.email_mode) == (False, True, "digest")
    set_ = grpc_call(
        P,
        "SetSettings",
        pb.SettingsSetRequest(
            timezone="Asia/Tehran", quiet_start="22:00", quiet_end="07:00", digest_hour=9
        ),
        token=token,
    )
    assert (set_.settings.timezone, set_.settings.quiet_start, set_.settings.digest_hour) == (
        "Asia/Tehran",
        "22:00",
        9,
    )
    bad = _refused(
        grpc_call,
        P,
        "SetSettings",
        pb.SettingsSetRequest(timezone="Nope", digest_hour=8),
        token=token,
    )
    assert bad.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_devices_register_and_unregister(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]

    assert grpc_call(
        D, "Register", pb.DeviceRegisterRequest(platform="android", token="t-1"), token=token
    ).registered
    assert PushDevice.objects.filter(token="t-1").exists()
    assert not grpc_call(
        D, "Unregister", pb.DeviceUnregisterRequest(token="t-1"), token=token
    ).registered
    assert not PushDevice.objects.exists()
