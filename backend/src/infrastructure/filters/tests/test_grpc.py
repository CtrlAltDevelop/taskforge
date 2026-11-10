"""QueryController and FilterController over a real gRPC server: the contract and status codes."""

import json
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.filters.grpc import filters_pb2 as pb
from infrastructure.filters.grpc import filters_pb2_grpc as stubs
from infrastructure.projects import services as projects
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

Q = stubs.QueryControllerStub
F = stubs.FilterControllerStub
T = tstubs.TaskControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic", "eve")  # owner, member, viewer, outsider


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


def _validate(call: GrpcCall, team: dict[str, Any], who: str = "vic", **fields: Any) -> Any:
    request = pb.QueryValidateRequest(workspace_id=team["ws"], project_id=team["project"], **fields)
    return call(Q, "Validate", request, token=team["tokens"][who])


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def test_validate_answers_in_band(team: Any, grpc_call: GrpcCall) -> None:
    good = _validate(grpc_call, team, tfql="priority=high and assignee = me ORDER BY due")
    bad = _validate(grpc_call, team, tfql="priority = huge")

    assert good.ok and good.tfql == "priority = high AND assignee = me ORDER BY due"
    assert json.loads(good.ast_json)["where"]["op"] == "and"
    assert not bad.ok and bad.ast_json == ""
    assert [(e.position, e.length) for e in bad.errors] == [(11, 4)]
    assert "huge" in bad.errors[0].message


def test_validate_takes_an_ast_back(team: Any, grpc_call: GrpcCall) -> None:
    first = _validate(grpc_call, team, tfql="priority = high")

    again = _validate(grpc_call, team, ast_json=first.ast_json)

    assert again.ok and again.tfql == "priority = high"


def test_suggest_offers_what_comes_next(team: Any, grpc_call: GrpcCall) -> None:
    request = pb.QuerySuggestRequest(
        workspace_id=team["ws"], project_id=team["project"], partial="priority = h", cursor=13
    )

    items = grpc_call(Q, "Suggest", request, token=team["tokens"]["vic"]).items

    assert [(i.text, i.kind, i.start) for i in items] == [("high", "value", 11)]


def test_filters_save_list_and_delete_and_apply_to_tasks(team: Any, grpc_call: GrpcCall) -> None:
    for title, priority in (("hot", "high"), ("cold", "low")):
        grpc_call(
            T,
            "Create",
            tpb.TaskCreateRequest(
                workspace_id=team["ws"], project_id=team["project"], title=title, priority=priority
            ),
            token=team["tokens"]["max"],
        )
    saved = grpc_call(
        F,
        "Save",
        pb.FilterSaveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            name="Hot",
            tfql="priority = high",
        ),
        token=team["tokens"]["max"],
    )
    assert (saved.name, saved.visibility, saved.version) == ("Hot", "private", 1)
    assert saved.tfql == "priority = high" and saved.id

    listed = grpc_call(
        F,
        "List",
        pb.FilterListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["max"],
    )
    assert [f.name for f in listed.filters] == ["Hot"]
    tasks = grpc_call(
        T,
        "List",
        tpb.TaskListRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            filter_ast=listed.filters[0].ast_json,
        ),
        token=team["tokens"]["max"],
    )
    assert [t.title for t in tasks] == ["hot"]
    counts = grpc_call(
        T,
        "GroupCounts",
        tpb.TaskGroupCountsRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            group_by="priority",
            filter_ast=saved.ast_json,
        ),
        token=team["tokens"]["max"],
    )
    assert [(g.key, g.count) for g in counts.groups] == [("high", 1)]

    grpc_call(
        F,
        "Delete",
        pb.FilterDeleteRequest(workspace_id=team["ws"], project_id=team["project"], id=saved.id),
        token=team["tokens"]["max"],
    )
    gone = grpc_call(
        F,
        "List",
        pb.FilterListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["max"],
    )
    assert list(gone.filters) == []


def test_refusals_map_to_the_usual_statuses(team: Any, grpc_call: GrpcCall) -> None:
    bad = pb.FilterSaveRequest(
        workspace_id=team["ws"], project_id=team["project"], name="x", tfql="nope = 1"
    )
    shared = pb.FilterSaveRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        name="all",
        tfql="priority = high",
        visibility="project",
    )
    task_bad = tpb.TaskListRequest(
        workspace_id=team["ws"], project_id=team["project"], filter_ast="{not json"
    )

    invalid = _refused(grpc_call, F, "Save", bad, token=team["tokens"]["max"])
    forbidden = _refused(grpc_call, F, "Save", shared, token=team["tokens"]["max"])
    stranger = _refused(
        grpc_call,
        F,
        "List",
        pb.FilterListRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["eve"],
    )
    on_tasks = _refused(grpc_call, T, "List", task_bad, token=team["tokens"]["max"])

    assert invalid.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert invalid.details().startswith("FILTER_INVALID:")
    assert forbidden.code() is grpc.StatusCode.PERMISSION_DENIED
    assert stranger.code() in (grpc.StatusCode.PERMISSION_DENIED, grpc.StatusCode.NOT_FOUND)
    assert on_tasks.code() is grpc.StatusCode.INVALID_ARGUMENT
