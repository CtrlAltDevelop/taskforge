"""TaskController over a real gRPC server. Rules are tested on the services; this checks the
contract: field names, status codes, titles, the stream, the payload."""

import json
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as projects
from infrastructure.tasks.grpc import tasks_pb2 as pb
from infrastructure.tasks.grpc import tasks_pb2_grpc as stubs
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

T = stubs.TaskControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic", "eve")  # owner, member, viewer, outsider
DOC = json.dumps({"type": "doc", "content": [{"type": "paragraph"}]})


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    workspace_services.create(users["eve"], "Other", "other")
    add_member(workspace, users["max"], "Member")
    add_member(workspace, users["vic"], "Viewer")
    project = projects.create(users["zoe"], workspace, "Web", "WEB").project
    return {"ws": str(workspace.id), "project": str(project.pk), "tokens": tokens, "users": users}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _create(call: GrpcCall, team: dict[str, Any], who: str = "max", **fields: Any) -> Any:
    request = pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], **{"title": "Fix", **fields}
    )
    return call(T, "Create", request, token=team["tokens"][who])


def test_create_and_get_round_trip_with_the_full_payload(team: Any, grpc_call: GrpcCall) -> None:
    assignee = str(team["users"]["max"].pk)
    created = _create(
        grpc_call,
        team,
        description=DOC,
        priority="high",
        start_date="2026-03-01",
        due_date="2026-03-05",
        assignee_ids=[assignee],
    )

    got = grpc_call(
        T,
        "Get",
        pb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=created.id),
        token=team["tokens"]["vic"],
    )

    assert got == created
    assert (got.display_id, got.number, got.version, got.status) == ("WEB-1", 1, 1, "todo")
    assert got.priority == "high" and got.due_date == "2026-03-05"
    assert list(got.assignee_ids) == [assignee]
    assert json.loads(got.description) == json.loads(DOC)
    assert got.deleted_at == "" and got.position and got.created_by == assignee


def test_update_sends_only_the_fields_in_the_mask(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, priority="low", due_date="2026-03-05")
    request = pb.TaskUpdateRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        id=created.id,
        expected_version=1,
        title="New",
        due_date="",  # present and empty: clears the date
    )

    updated = grpc_call(T, "Update", request, token=team["tokens"]["max"])

    assert (updated.title, updated.priority, updated.due_date, updated.version) == (
        "New",
        "low",
        "",
        2,
    )


def test_update_can_replace_and_clear_assignees(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, assignee_ids=[str(team["users"]["max"].pk)])
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}

    cleared = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, set_assignees=True),
        token=team["tokens"]["max"],
    )
    untouched = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=2, title="Again"),
        token=team["tokens"]["max"],
    )

    assert list(cleared.assignee_ids) == [] and list(untouched.assignee_ids) == []


def test_same_field_conflict_is_aborted_with_the_current_value(
    team: Any, grpc_call: GrpcCall
) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}
    grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, title="Theirs"),
        token=team["tokens"]["zoe"],
    )

    merged = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, priority="urgent"),
        token=team["tokens"]["max"],
    )
    refusal = _refused(
        grpc_call,
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, title="Mine"),
        token=team["tokens"]["max"],
    )

    assert merged.title == "Theirs" and merged.priority == "urgent"
    assert refusal.code() == grpc.StatusCode.ABORTED
    assert refusal.details().startswith("VERSION_CONFLICT")
    trailers = {k: v for k, v in refusal.trailing_metadata()}
    assert trailers["x-error-field-bin"] == b"title"
    assert trailers["x-error-current-bin"] == b"Theirs"


def test_delete_and_restore(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}

    gone = grpc_call(T, "Delete", pb.TaskDeleteRequest(**base), token=team["tokens"]["max"])
    missing = _refused(grpc_call, T, "Get", pb.TaskGetRequest(**base), token=team["tokens"]["max"])
    back = grpc_call(T, "Restore", pb.TaskRestoreRequest(**base), token=team["tokens"]["max"])

    assert gone.deleted_at != "" and back.deleted_at == "" and back.version == 3
    assert missing.code() == grpc.StatusCode.NOT_FOUND


def test_list_streams_every_task_in_order_across_pages(team: Any, grpc_call: GrpcCall) -> None:
    for i in range(7):
        _create(grpc_call, team, title=f"t{i}")

    streamed = grpc_call(
        T,
        "List",
        pb.TaskListRequest(workspace_id=team["ws"], project_id=team["project"], page_size=3),
        token=team["tokens"]["vic"],
    )
    done = grpc_call(
        T,
        "List",
        pb.TaskListRequest(workspace_id=team["ws"], project_id=team["project"], status="done"),
        token=team["tokens"]["vic"],
    )

    assert [t.title for t in streamed] == [f"t{i}" for i in range(7)]
    assert [t.number for t in streamed] == list(range(1, 8))
    assert done == []


def test_refusals_map_to_the_usual_statuses(team: Any, grpc_call: GrpcCall) -> None:
    request = pb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title="x")
    viewer = _refused(grpc_call, T, "Create", request, token=team["tokens"]["vic"])
    stranger = _refused(grpc_call, T, "Create", request, token=team["tokens"]["eve"])
    anonymous = _refused(grpc_call, T, "Create", request)
    invalid = _refused(
        grpc_call,
        T,
        "Create",
        pb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title=" "),
        token=team["tokens"]["max"],
    )
    stream = _refused(
        grpc_call,
        T,
        "List",
        pb.TaskListRequest(workspace_id=team["ws"], project_id="nope"),
        token=team["tokens"]["vic"],
    )

    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED
    assert dict(viewer.trailing_metadata())["x-error-permission-bin"] == b"task.create"
    assert stranger.code() == grpc.StatusCode.PERMISSION_DENIED
    assert anonymous.code() == grpc.StatusCode.UNAUTHENTICATED
    assert invalid.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert stream.code() == grpc.StatusCode.NOT_FOUND


def test_list_trash_returns_deleted_tasks_and_needs_the_delete_permission(
    team: Any, grpc_call: GrpcCall
) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"]}
    grpc_call(T, "Delete", pb.TaskDeleteRequest(**base, id=created.id), token=team["tokens"]["max"])

    trash = grpc_call(T, "ListTrash", pb.TaskListTrashRequest(**base), token=team["tokens"]["max"])
    refused = _refused(
        grpc_call, T, "ListTrash", pb.TaskListTrashRequest(**base), token=team["tokens"]["vic"]
    )

    assert [t.id for t in trash.tasks] == [created.id]
    assert trash.tasks[0].deleted_at != ""
    assert refused.code() == grpc.StatusCode.PERMISSION_DENIED
