"""SyncController over a real gRPC server: the contract. Rules are tested on the services."""

from typing import Any

import grpc

from infrastructure.sync.grpc import sync_pb2 as pb
from infrastructure.sync.grpc import sync_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

S = stubs.SyncControllerStub
team = base.team  # the fixture, registered here by name


def _head(grpc_call: GrpcCall, team: dict[str, Any], who: str = "vic") -> str:
    request = pb.SyncHeadRequest(workspace_id=team["ws"])
    return str(grpc_call(S, "Head", request, token=team["tokens"][who]).cursor)


def _since(grpc_call: GrpcCall, team: dict[str, Any], cursor: str, who: str = "vic") -> list[Any]:
    request = pb.SyncSinceRequest(workspace_id=team["ws"], cursor=cursor)
    return list(grpc_call(S, "Since", request, token=team["tokens"][who]))


def test_a_client_catches_up_from_the_head(team: Any, grpc_call: GrpcCall) -> None:
    head = _head(grpc_call, team)
    created = _create(grpc_call, team, title="Fresh")

    entries = _since(grpc_call, team, head)

    assert [(e.type, e.entity_id, e.version) for e in entries] == [("task.created", created.id, 1)]
    assert int(entries[0].cursor) > int(head)
    assert entries[0].project_id == team["project"]


def test_the_head_moves_with_every_change(team: Any, grpc_call: GrpcCall) -> None:
    before = int(_head(grpc_call, team))
    _create(grpc_call, team, title="one")

    assert int(_head(grpc_call, team)) > before


def test_the_actor_is_the_caller_who_changed_it(team: Any, grpc_call: GrpcCall) -> None:
    head = _head(grpc_call, team)
    _create(grpc_call, team, who="max", title="mine")

    [entry] = _since(grpc_call, team, head)

    assert entry.actor == str(team["users"]["max"].pk)


def test_a_bad_cursor_is_invalid_argument_and_an_outsider_is_refused(
    team: Any, grpc_call: GrpcCall
) -> None:
    bad = pb.SyncSinceRequest(workspace_id=team["ws"], cursor="soon")

    assert _refused(grpc_call, S, "Since", bad, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.INVALID_ARGUMENT
    )
    elsewhere = pb.SyncHeadRequest(workspace_id=team["ws"])
    assert _refused(grpc_call, S, "Head", elsewhere, token=team["tokens"]["eve"]).code() is (
        grpc.StatusCode.PERMISSION_DENIED
    )


def test_a_cursor_older_than_the_log_is_one_gap_entry(team: Any, grpc_call: GrpcCall) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.sync import services
    from infrastructure.sync.models import ChangeLog

    _create(grpc_call, team, title="a")
    _create(grpc_call, team, title="b")
    last = ChangeLog.objects.order_by("id").last()
    ChangeLog.objects.update(at=timezone.now() - timedelta(days=20))
    services.trim()

    entries = _since(grpc_call, team, str(last.pk - 1))

    assert [e.type for e in entries] == ["sync.gap"]


def test_a_full_page_ends_with_a_more_entry_that_continues_the_read(
    team: Any, grpc_call: GrpcCall, monkeypatch: Any
) -> None:
    from infrastructure.sync import services

    head = _head(grpc_call, team)
    for n in range(3):
        _create(grpc_call, team, title=str(n))
    real = services.since
    monkeypatch.setattr(
        "infrastructure.sync.grpc.services.services.since",
        lambda user, ws, cursor, limit, overlap: real(user, ws, cursor, 2, overlap),
    )

    first = _since(grpc_call, team, head)
    after = _since(grpc_call, team, first[-1].cursor)

    assert [e.type for e in first] == ["task.created", "task.created", "sync.more"]
    assert [e.type for e in after] == ["task.created"]
