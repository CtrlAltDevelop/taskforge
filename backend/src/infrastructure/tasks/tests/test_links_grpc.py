"""LinkController over a real gRPC server. Rules are tested on the services; this checks the
contract: field names, status codes, titles, trailers, what a restricted far end shows."""

from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as projects
from infrastructure.tasks import services as task_services
from infrastructure.tasks.grpc import tasks_pb2 as pb
from infrastructure.tasks.grpc import tasks_pb2_grpc as stubs
from infrastructure.workflows.models import Status
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

L = stubs.LinkControllerStub
T = stubs.TaskControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic")  # owner, member, viewer


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    add_member(workspace, users["max"], "Member")
    add_member(workspace, users["vic"], "Viewer")
    project = projects.create(users["zoe"], workspace, "Web", "WEB").project
    secret = projects.create(users["max"], workspace, "Secret", "SEC", visibility="private").project
    tasks = [
        task_services.create(users["zoe"], workspace, str(project.pk), f"T{n}") for n in range(3)
    ]
    hidden = task_services.create(users["max"], workspace, str(secret.pk), "Layoffs plan")
    return {
        "ws": str(workspace.id),
        "project": str(project.pk),
        "tokens": tokens,
        "tasks": [str(t.pk) for t in tasks],
        "hidden": str(hidden.pk),
        "done": str(Status.objects.get(project=project, name="Done").pk),
    }


def _add(call: GrpcCall, team: dict[str, Any], a: str, b: str, kind: str, who: str = "max") -> Any:
    request = pb.LinkAddRequest(workspace_id=team["ws"], task_id=a, other_task_id=b, kind=kind)
    return call(L, "Add", request, token=team["tokens"][who])


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def test_add_returns_the_links_of_the_task_with_the_full_payload(
    team: Any, grpc_call: GrpcCall
) -> None:
    a, b, _ = team["tasks"]

    added = _add(grpc_call, team, a, b, "blocks")
    seen_from_b = grpc_call(
        L,
        "ListForTask",
        pb.LinkListForTaskRequest(workspace_id=team["ws"], task_id=b),
        token=team["tokens"]["vic"],
    )

    assert [(x.kind, x.other_display_id, x.other_title) for x in added.links] == [
        ("blocks", "WEB-2", "T1")
    ]
    assert [(x.kind, x.other_display_id, x.restricted) for x in seen_from_b.links] == [
        ("blocked_by", "WEB-1", False)
    ]
    assert seen_from_b.links[0].other_status_category == "not_started"


def test_a_loop_is_already_exists_with_the_path_in_a_trailer(
    team: Any, grpc_call: GrpcCall
) -> None:
    a, b, c = team["tasks"]
    _add(grpc_call, team, a, b, "blocks")
    _add(grpc_call, team, b, c, "blocks")

    refusal = _refused(grpc_call, L, "Add", _request(team, c, a, "blocks"), token=_t(team, "max"))

    assert refusal.code() is grpc.StatusCode.ALREADY_EXISTS
    assert refusal.details().startswith("LINK_CYCLE:")
    assert (
        dict(refusal.trailing_metadata())["x-error-path-bin"]
        == "WEB-3 → WEB-1 → WEB-2 → WEB-3".encode()
    )


def _t(team: dict[str, Any], who: str) -> str:
    return team["tokens"][who]


def _request(team: dict[str, Any], a: str, b: str, kind: str) -> Any:
    return pb.LinkAddRequest(workspace_id=team["ws"], task_id=a, other_task_id=b, kind=kind)


def test_a_viewer_can_list_but_not_add(team: Any, grpc_call: GrpcCall) -> None:
    a, b, _ = team["tasks"]

    refusal = _refused(grpc_call, L, "Add", _request(team, a, b, "relates"), token=_t(team, "vic"))

    assert refusal.code() is grpc.StatusCode.PERMISSION_DENIED


def test_a_hidden_far_end_reads_back_restricted_without_a_title(
    team: Any, grpc_call: GrpcCall
) -> None:
    a = team["tasks"][0]
    _add(grpc_call, team, a, team["hidden"], "blocks", who="max")

    seen = grpc_call(
        L,
        "ListForTask",
        pb.LinkListForTaskRequest(workspace_id=team["ws"], task_id=a),
        token=_t(team, "vic"),
    )

    link = seen.links[0]
    assert link.restricted and link.kind == "blocks"
    assert (link.other_id, link.other_title, link.other_display_id) == ("", "", "")
    assert b"Layoffs" not in seen.SerializeToString() and b"SEC" not in seen.SerializeToString()


def test_remove_deletes_the_link_and_returns_the_rest(team: Any, grpc_call: GrpcCall) -> None:
    a, b, c = team["tasks"]
    first = _add(grpc_call, team, a, b, "blocks").links[0]
    _add(grpc_call, team, a, c, "relates")

    left = grpc_call(
        L,
        "Remove",
        pb.LinkRemoveRequest(workspace_id=team["ws"], task_id=a, id=first.id),
        token=_t(team, "max"),
    )

    assert [x.kind for x in left.links] == ["relates"]


def test_completing_a_blocked_task_is_a_failed_precondition_that_an_owner_can_override(
    team: Any, grpc_call: GrpcCall
) -> None:
    a, b, _ = team["tasks"]
    _add(grpc_call, team, a, b, "blocks")
    blocked = grpc_call(
        T,
        "Get",
        pb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=b),
        token=_t(team, "vic"),
    )
    assert blocked.is_blocked

    def move(who: str, override: bool) -> Any:
        return grpc_call(
            T,
            "Move",
            pb.TaskMoveRequest(
                workspace_id=team["ws"],
                project_id=team["project"],
                id=b,
                expected_version=blocked.version,
                status=team["done"],
                override_blocked=override,
            ),
            token=_t(team, who),
        )

    refusal = _refused(move, "max", True)
    assert refusal.code() is grpc.StatusCode.FAILED_PRECONDITION
    assert refusal.details().startswith("TASK_BLOCKED:")
    trailers = dict(refusal.trailing_metadata())
    assert trailers["x-error-blockers-bin"] == b"WEB-1"
    assert trailers["x-error-can_override-bin"] == b"false"
    assert move("zoe", True).status_category == "done"


def test_search_over_the_wire_returns_picker_rows_and_hides_private_projects(
    team: Any, grpc_call: GrpcCall
) -> None:
    found = grpc_call(
        L,
        "SearchTasks",
        pb.LinkSearchTasksRequest(workspace_id=team["ws"], query="layoffs"),
        token=_t(team, "vic"),
    )
    mine = grpc_call(
        L,
        "SearchTasks",
        pb.LinkSearchTasksRequest(workspace_id=team["ws"], query="t1"),
        token=_t(team, "vic"),
    )

    assert list(found.tasks) == []
    assert [(x.display_id, x.title, x.status_name) for x in mine.tasks] == [
        ("WEB-2", "T1", "To do")
    ]
    assert mine.tasks[0].project_id == team["project"]


def test_a_blocked_task_names_its_blockers_on_the_wire(team: Any, grpc_call: GrpcCall) -> None:
    a, b, _ = team["tasks"]
    _add(grpc_call, team, a, b, "blocks")

    got = grpc_call(
        T,
        "Get",
        pb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=b),
        token=_t(team, "vic"),
    )

    assert list(got.blocked_by) == ["WEB-1 (To do)"]
