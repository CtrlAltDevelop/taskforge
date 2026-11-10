"""ViewController over a real gRPC server: the contract, status codes, titles and trailers.
The rules are tested on the services."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as projects
from infrastructure.savedviews.grpc import savedviews_pb2 as pb
from infrastructure.savedviews.grpc import savedviews_pb2_grpc as stubs
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

V = stubs.ViewControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic", "eve")  # owner, member, viewer, outsider
LAYOUT = pb.Layout(
    columns=["status", "due_date"],
    widths=[pb.LayoutWidth(column="title", width=300)],
    sort=[pb.LayoutSort(key="due_date", desc=True)],
    group_by="status",
)


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    workspace_services.create(users["eve"], "Other", "other")
    add_member(workspace, users["max"], "Member")
    add_member(workspace, users["vic"], "Viewer")
    project = projects.create(users["zoe"], workspace, "Web", "WEB").project
    return {"ws": str(workspace.id), "project": str(project.pk), "tokens": tokens}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _save(call: GrpcCall, team: dict[str, Any], who: str = "max", **fields: Any) -> Any:
    request = pb.ViewSaveRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        **{"name": "Mine", "layout": LAYOUT, **fields},
    )
    return call(V, "Save", request, token=team["tokens"][who])


def _list(call: GrpcCall, team: dict[str, Any], who: str = "max") -> Any:
    request = pb.ViewListRequest(workspace_id=team["ws"], project_id=team["project"])
    return call(V, "List", request, token=team["tokens"][who])


def test_save_and_list_round_trip_the_whole_layout(team: Any, grpc_call: GrpcCall) -> None:
    saved = _save(grpc_call, team)

    [got] = _list(grpc_call, team).views

    assert got.id == saved.id and (got.name, got.kind, got.version) == ("Mine", "list", 1)
    assert not got.is_shared and got.owner_id != ""
    assert list(got.layout.columns) == ["status", "due_date"]
    assert [(w.column, w.width) for w in got.layout.widths] == [("title", 300)]
    assert [(s.key, s.desc) for s in got.layout.sort] == [("due_date", True)]
    assert got.layout.group_by == "status"


def test_a_board_layout_round_trips_over_the_wire(team: Any, grpc_call: GrpcCall) -> None:
    board = pb.BoardLayout(
        group_by="priority",
        swimlane="assignee",
        card_fields=["due_date"],
        limits=[pb.BoardLimit(column="high", limit=3)],
    )

    saved = _save(grpc_call, team, kind="board", board=board)
    request = pb.ViewListRequest(workspace_id=team["ws"], project_id=team["project"], kind="board")
    [got] = grpc_call(V, "List", request, token=team["tokens"]["max"]).views

    assert got.id == saved.id and got.kind == "board"
    assert (got.board.group_by, got.board.swimlane) == ("priority", "assignee")
    assert list(got.board.card_fields) == ["due_date"]
    assert [(x.column, x.limit) for x in got.board.limits] == [("high", 3)]


def test_a_second_save_needs_the_version_and_a_stale_one_aborts(
    team: Any, grpc_call: GrpcCall
) -> None:
    saved = _save(grpc_call, team)

    again = _save(grpc_call, team, id=saved.id, expected_version=1, name="Renamed")
    stale = _refused(
        grpc_call,
        V,
        "Save",
        pb.ViewSaveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            id=saved.id,
            expected_version=1,
            name="Late",
            layout=LAYOUT,
        ),
        token=team["tokens"]["max"],
    )

    assert (again.name, again.version) == ("Renamed", 2)
    assert stale.code() == grpc.StatusCode.ABORTED
    assert dict(stale.trailing_metadata())["x-error-version-bin"] == b"2"


def test_sharing_needs_the_manage_permission(team: Any, grpc_call: GrpcCall) -> None:
    denied = _refused(
        grpc_call,
        V,
        "Save",
        pb.ViewSaveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            name="team",
            layout=LAYOUT,
            shared=True,
        ),
        token=team["tokens"]["max"],
    )
    shared = _save(grpc_call, team, who="zoe", name="team", shared=True)

    assert denied.code() == grpc.StatusCode.PERMISSION_DENIED
    assert shared.is_shared and shared.owner_id == ""
    assert [v.name for v in _list(grpc_call, team, "vic").views] == ["team"]


def test_a_layout_that_means_nothing_is_invalid_argument_with_its_title(
    team: Any, grpc_call: GrpcCall
) -> None:
    refused = _refused(
        grpc_call,
        V,
        "Save",
        pb.ViewSaveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            name="bad",
            layout=pb.Layout(columns=["nope"]),
        ),
        token=team["tokens"]["max"],
    )

    assert refused.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert "VIEW_INVALID" in refused.details()


def test_delete_and_the_stranger(team: Any, grpc_call: GrpcCall) -> None:
    saved = _save(grpc_call, team)
    request = pb.ViewDeleteRequest(workspace_id=team["ws"], project_id=team["project"], id=saved.id)

    other = _refused(grpc_call, V, "Delete", request, token=team["tokens"]["vic"])
    stranger = _refused(
        grpc_call,
        V,
        "List",
        pb.ViewListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["eve"],
    )
    grpc_call(V, "Delete", request, token=team["tokens"]["max"])

    assert other.code() == grpc.StatusCode.NOT_FOUND
    assert stranger.code() in (grpc.StatusCode.NOT_FOUND, grpc.StatusCode.PERMISSION_DENIED)
    assert list(_list(grpc_call, team).views) == []
