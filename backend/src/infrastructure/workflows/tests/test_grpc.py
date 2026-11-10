"""WorkflowController (and TaskController.Move) over a real gRPC server: the contract, status
codes, titles and trailers. Rules are tested on the services."""

import json
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as projects
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.workflows.grpc import workflows_pb2 as pb
from infrastructure.workflows.grpc import workflows_pb2_grpc as stubs
from infrastructure.workflows.models import Status
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

W = stubs.WorkflowControllerStub
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


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _get(call: GrpcCall, team: dict[str, Any], who: str = "vic") -> Any:
    request = pb.WorkflowGetRequest(workspace_id=team["ws"], project_id=team["project"])
    return call(W, "Get", request, token=team["tokens"][who])


def _update_request(team: dict[str, Any], flow: Any, **changes: Any) -> Any:
    """An update request that re-sends ``flow`` (a Workflow message) with ``changes`` on top."""
    fields: dict[str, Any] = {
        "restrict_transitions": flow.restrict_transitions,
        "restrict_creation": flow.restrict_creation,
        "statuses": [
            pb.StatusInput(
                key=s.id, name=s.name, color=s.color, category=s.category, is_default=s.is_default
            )
            for s in flow.statuses
        ],
        "transitions": [
            pb.TransitionInput(
                from_key=t.from_status,
                to_key=t.to_status,
                required_role_id=t.required_role_id,
                require_assignee=t.require_assignee,
                require_subtasks_done=t.require_subtasks_done,
            )
            for t in flow.transitions
        ],
    }
    fields.update(changes)
    return pb.WorkflowUpdateRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        expected_version=flow.version,
        **fields,
    )


def test_get_returns_the_default_workflow_with_task_counts(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)

    assert [
        (s.name, s.category, s.is_default, s.position, s.task_count) for s in flow.statuses
    ] == [
        ("To do", "not_started", True, 0, 0),
        ("In progress", "active", False, 1, 0),
        ("Done", "done", False, 2, 0),
    ]
    assert flow.version == 1 and flow.restrict_transitions is False
    assert list(flow.transitions) == [] and flow.project_id == team["project"]


def test_update_renames_and_reorders_and_bumps_the_version(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)
    statuses = list(flow.statuses)
    renamed = [
        pb.StatusInput(
            key=s.id, name=n, color=s.color, category=s.category, is_default=s.is_default
        )
        for s, n in zip(reversed(statuses), ("Shipped", "Doing", "Backlog"), strict=True)
    ]
    renamed[2] = pb.StatusInput(
        key=statuses[0].id, name="Backlog", color="#112233", category="not_started", is_default=True
    )
    renamed[0] = pb.StatusInput(key=statuses[2].id, name="Shipped", color="", category="done")

    saved = grpc_call(
        W, "Update", _update_request(team, flow, statuses=renamed), token=team["tokens"]["zoe"]
    )

    assert [s.name for s in saved.statuses] == ["Shipped", "Doing", "Backlog"]
    assert saved.version == 2 and saved.statuses[2].color == "#112233"


def test_an_invalid_save_lists_every_problem_in_the_trailer(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)
    broken = [pb.StatusInput(key="only", name="Only", category="active")]

    refusal = _refused(
        grpc_call,
        W,
        "Update",
        _update_request(team, flow, statuses=broken),
        token=team["tokens"]["zoe"],
    )

    assert refusal.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert refusal.details().startswith("WORKFLOW_INVALID")
    problems = json.loads(dict(refusal.trailing_metadata())["x-error-errors-bin"])
    assert {"NO_DONE_STATUS", "NO_DEFAULT_STATUS"} <= {p["code"] for p in problems}


def test_a_stale_version_is_aborted(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)
    grpc_call(W, "Update", _update_request(team, flow), token=team["tokens"]["zoe"])

    refusal = _refused(
        grpc_call, W, "Update", _update_request(team, flow), token=team["tokens"]["zoe"]
    )

    assert refusal.code() == grpc.StatusCode.ABORTED
    assert refusal.details().startswith("VERSION_CONFLICT")


def test_validate_answers_the_problems_without_saving(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)
    ids = {s.name: s.id for s in flow.statuses}
    request = pb.WorkflowValidateRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        restrict_transitions=True,
        statuses=[
            pb.StatusInput(key=s.id, name=s.name, category=s.category, is_default=s.is_default)
            for s in flow.statuses
        ],
        transitions=[pb.TransitionInput(from_key=ids["To do"], to_key=ids["Done"])],
    )

    found = grpc_call(W, "Validate", request, token=team["tokens"]["zoe"])

    assert {p.code for p in found.problems} == {"STATUS_UNREACHABLE", "STATUS_DEAD_END"}
    assert _get(grpc_call, team).version == 1


def test_deleting_a_status_with_tasks_needs_a_migration_entry(
    team: Any, grpc_call: GrpcCall
) -> None:
    flow = _get(grpc_call, team)
    ids = {s.name: s.id for s in flow.statuses}
    created = grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            title="T",
            status=ids["In progress"],
        ),
        token=team["tokens"]["max"],
    )
    kept = [s for s in _update_request(team, flow).statuses if s.key != ids["In progress"]]

    refusal = _refused(
        grpc_call,
        W,
        "Update",
        _update_request(team, flow, statuses=kept),
        token=team["tokens"]["zoe"],
    )
    saved = grpc_call(
        W,
        "Update",
        _update_request(
            team,
            flow,
            statuses=kept,
            migrations=[pb.MigrationInput(from_key=ids["In progress"], to_key=ids["To do"])],
        ),
        token=team["tokens"]["zoe"],
    )
    moved = grpc_call(
        T,
        "Get",
        tpb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=created.id),
        token=team["tokens"]["vic"],
    )

    assert refusal.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert [s.name for s in saved.statuses] == ["To do", "Done"] and saved.statuses[
        0
    ].task_count == 1
    assert (moved.status, moved.status_name) == (ids["To do"], "To do")


def test_permissions(team: Any, grpc_call: GrpcCall) -> None:
    flow = _get(grpc_call, team)
    viewer = _refused(
        grpc_call, W, "Update", _update_request(team, flow), token=team["tokens"]["vic"]
    )
    member = _refused(
        grpc_call, W, "Update", _update_request(team, flow), token=team["tokens"]["max"]
    )
    stranger = _refused(
        grpc_call,
        W,
        "Get",
        pb.WorkflowGetRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["eve"],
    )
    anonymous = _refused(
        grpc_call,
        W,
        "Get",
        pb.WorkflowGetRequest(workspace_id=team["ws"], project_id=team["project"]),
    )

    assert viewer.code() == member.code() == grpc.StatusCode.PERMISSION_DENIED
    assert dict(viewer.trailing_metadata())["x-error-permission-bin"] == b"project.update"
    assert stranger.code() == grpc.StatusCode.PERMISSION_DENIED
    assert anonymous.code() == grpc.StatusCode.UNAUTHENTICATED


def test_a_disallowed_move_is_a_failed_precondition_with_the_reason(
    team: Any, grpc_call: GrpcCall
) -> None:
    flow = _get(grpc_call, team)
    ids = {s.name: s.id for s in flow.statuses}
    grpc_call(
        W,
        "Update",
        _update_request(
            team,
            flow,
            restrict_transitions=True,
            transitions=[
                pb.TransitionInput(from_key=ids["To do"], to_key=ids["In progress"]),
                pb.TransitionInput(from_key=ids["In progress"], to_key=ids["Done"]),
                pb.TransitionInput(from_key=ids["In progress"], to_key=ids["To do"]),
            ],
        ),
        token=team["tokens"]["zoe"],
    )
    created = grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title="T"),
        token=team["tokens"]["max"],
    )
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}

    refusal = _refused(
        grpc_call,
        T,
        "Move",
        tpb.TaskMoveRequest(**base, expected_version=1, status=ids["Done"]),
        token=team["tokens"]["max"],
    )
    update_refusal = _refused(
        grpc_call,
        T,
        "Update",
        tpb.TaskUpdateRequest(**base, expected_version=1, status=ids["Done"]),
        token=team["tokens"]["max"],
    )
    allowed = grpc_call(
        T,
        "Move",
        tpb.TaskMoveRequest(**base, expected_version=1, status=ids["In progress"]),
        token=team["tokens"]["max"],
    )

    for r in (refusal, update_refusal):
        assert r.code() == grpc.StatusCode.FAILED_PRECONDITION
        assert r.details().startswith("TRANSITION_NOT_ALLOWED")
        trailers = dict(r.trailing_metadata())
        assert trailers["x-error-from-bin"] == ids["To do"].encode()
        assert trailers["x-error-to-bin"] == ids["Done"].encode()
        assert trailers["x-error-reason-bin"].decode() == "To do → Done is not allowed."
    assert allowed.status_name == "In progress" and allowed.version == 2
    assert Status.objects.filter(project_id=team["project"]).count() == 3


def test_the_creation_rule_round_trips_and_refuses_over_the_wire(
    team: Any, grpc_call: GrpcCall
) -> None:
    flow = _get(grpc_call, team)
    ids = {s.name: s.id for s in flow.statuses}
    saved = grpc_call(
        W,
        "Update",
        _update_request(team, flow, restrict_creation=True),
        token=team["tokens"]["zoe"],
    )
    free = grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title="T"),
        token=team["tokens"]["max"],
    )
    refusal = _refused(
        grpc_call,
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            title="U",
            status=ids["Done"],
        ),
        token=team["tokens"]["max"],
    )

    assert flow.restrict_creation is False and saved.restrict_creation is True
    assert _get(grpc_call, team).restrict_creation is True
    assert free.status_name == "To do"
    assert refusal.code() == grpc.StatusCode.FAILED_PRECONDITION
    assert refusal.details().startswith("TRANSITION_NOT_ALLOWED")
    assert (
        dict(refusal.trailing_metadata())["x-error-reason-bin"] == b"New tasks must start in To do."
    )


def test_the_subtasks_condition_round_trips_and_blocks_over_the_wire(
    team: Any, grpc_call: GrpcCall
) -> None:
    flow = _get(grpc_call, team)
    ids = {s.name: s.id for s in flow.statuses}
    saved = grpc_call(
        W,
        "Update",
        _update_request(
            team,
            flow,
            restrict_transitions=True,
            transitions=[
                pb.TransitionInput(from_key=ids["To do"], to_key=ids["In progress"]),
                pb.TransitionInput(
                    from_key=ids["In progress"], to_key=ids["Done"], require_subtasks_done=True
                ),
                pb.TransitionInput(from_key=ids["In progress"], to_key=ids["To do"]),
            ],
        ),
        token=team["tokens"]["zoe"],
    )
    token = team["tokens"]["max"]
    parent = grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            title="P",
            status=ids["In progress"],
        ),
        token=token,
    )
    grpc_call(
        T,
        "Create",
        tpb.TaskCreateRequest(
            workspace_id=team["ws"], project_id=team["project"], title="K", parent_id=parent.id
        ),
        token=token,
    )

    refusal = _refused(
        grpc_call,
        T,
        "Move",
        tpb.TaskMoveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            id=parent.id,
            expected_version=1,
            status=ids["Done"],
        ),
        token=token,
    )

    flagged = [t for t in saved.transitions if t.require_subtasks_done]
    assert [(t.from_status, t.to_status) for t in flagged] == [(ids["In progress"], ids["Done"])]
    assert refusal.code() == grpc.StatusCode.FAILED_PRECONDITION
    assert (
        "needs all subtasks done first"
        in dict(refusal.trailing_metadata())["x-error-reason-bin"].decode()
    )
