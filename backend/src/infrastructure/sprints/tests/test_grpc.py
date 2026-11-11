"""The sprint and backlog controllers over a real gRPC server: the contract."""

from typing import Any

import grpc
import pytest

from infrastructure.projects import services as projects
from infrastructure.sprints.grpc import sprints_pb2 as pb
from infrastructure.sprints.grpc import sprints_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused
from infrastructure.workspaces.models import Workspace

base_team = base.team
S = stubs.SprintControllerStub
B = stubs.BacklogControllerStub


@pytest.fixture
def team(base_team: dict[str, Any]) -> dict[str, Any]:
    ws = Workspace.objects.get(pk=base_team["ws"])
    owner = base_team["users"]["zoe"]
    version = projects.get(owner, ws, base_team["project"]).project.version
    projects.set_features(owner, ws, base_team["project"], {"sprints"}, version)
    return base_team


def _ref(team: dict[str, Any]) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "project_id": team["project"]}


def _plan(call: GrpcCall, team: dict[str, Any], name: str = "S1", **dates: str) -> Any:
    request = pb.SprintCreateRequest(
        **_ref(team),
        name=name,
        goal="Ship",
        start_date=dates.get("start", "2026-11-02"),
        end_date=dates.get("end", "2026-11-06"),
    )
    return call(S, "Create", request, token=team["tokens"]["max"])


def test_plan_start_move_complete_round_trip(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    task = _create(grpc_call, team, who="zoe", title="Fix")
    sprint = _plan(grpc_call, team).sprint
    ref = {**_ref(team), "sprint_id": sprint.id}
    nxt = _plan(grpc_call, team, "S2", start="2026-11-09", end="2026-11-13").sprint

    pointed = grpc_call(
        S,
        "SetPoints",
        pb.PointsSetRequest(**_ref(team), task_id=task.id, points="3.5"),
        token=token,
    )
    added = grpc_call(
        S, "AddTasks", pb.SprintTasksChangeRequest(**ref, task_ids=[task.id]), token=token
    )
    started = grpc_call(S, "Start", pb.SprintStartRequest(**ref), token=token)
    listed = grpc_call(S, "Tasks", pb.SprintTasksRequest(**ref), token=token)
    burn = grpc_call(S, "Burndown", pb.BurndownRequest(**ref), token=token)
    done = grpc_call(S, "Complete", pb.SprintCompleteRequest(**ref, carry_over="next"), token=token)
    backlog = grpc_call(B, "List", pb.BacklogListRequest(**_ref(team)), token=token)

    assert pointed.points == 3.5 and pointed.has_points and added.changed == 1
    assert (started.sprint.state, started.sprint.baseline_points) == ("active", 3.5)
    assert [(t.key, t.points, t.late) for t in listed.tasks] == [("WEB-1", 3.5, False)]
    assert burn.baseline_points == 3.5 and burn.days and burn.days[0].ideal_points < 3.5
    assert done.sprint.state == "completed" and done.sprint.unfinished_tasks == 1
    assert backlog.total == 0  # carried to S2, which is planned
    moved = grpc_call(
        S, "Tasks", pb.SprintTasksRequest(**{**ref, "sprint_id": nxt.id}), token=token
    )
    assert [t.id for t in moved.tasks] == [task.id]


def test_list_update_remove_and_warnings(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    first = _plan(grpc_call, team).sprint
    clash = _plan(grpc_call, team, "S2", start="2026-11-04", end="2026-11-10")

    updated = grpc_call(
        S,
        "Update",
        pb.SprintUpdateRequest(
            **_ref(team), sprint_id=first.id, fields=["name"], name="Renamed", expected_version=1
        ),
        token=token,
    )
    listed = grpc_call(
        S, "List", pb.SprintListRequest(**_ref(team), states=["planned"]), token=token
    )

    assert len(clash.warnings) == 1 and updated.sprint.name == "Renamed"
    assert updated.sprint.version == 2 and len(listed.sprints) == 2
    task = _create(grpc_call, team, who="zoe", title="T")
    ref = {**_ref(team), "sprint_id": first.id, "task_ids": [task.id]}
    grpc_call(S, "AddTasks", pb.SprintTasksChangeRequest(**ref), token=token)
    removed = grpc_call(S, "RemoveTasks", pb.SprintTasksChangeRequest(**ref), token=token)
    assert removed.changed == 1


def test_errors_map_to_status_codes(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    first = _plan(grpc_call, team).sprint
    second = _plan(grpc_call, team, "S2", start="2026-11-09", end="2026-11-13").sprint
    grpc_call(S, "Start", pb.SprintStartRequest(**_ref(team), sprint_id=first.id), token=token)

    second_start = _refused(
        grpc_call, S, "Start", pb.SprintStartRequest(**_ref(team), sprint_id=second.id), token=token
    )
    bad_dates = _refused(
        grpc_call,
        S,
        "Create",
        pb.SprintCreateRequest(
            **_ref(team), name="x", start_date="2026-11-09", end_date="2026-11-01"
        ),
        token=token,
    )
    unknown = _refused(
        grpc_call,
        S,
        "Update",
        pb.SprintUpdateRequest(**_ref(team), sprint_id=first.id, fields=["state"]),
        token=token,
    )
    missing = _refused(
        grpc_call,
        S,
        "Burndown",
        pb.BurndownRequest(**_ref(team), sprint_id="00000000-0000-0000-0000-000000000000"),
        token=token,
    )

    assert second_start.code() == grpc.StatusCode.ALREADY_EXISTS
    assert bad_dates.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert unknown.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert missing.code() == grpc.StatusCode.NOT_FOUND


def test_viewer_reads_but_cannot_change_and_outsider_sees_nothing(
    team: Any, grpc_call: GrpcCall
) -> None:
    sprint = _plan(grpc_call, team).sprint
    ref = {**_ref(team), "sprint_id": sprint.id}

    seen = grpc_call(S, "List", pb.SprintListRequest(**_ref(team)), token=team["tokens"]["vic"])
    start = _refused(
        grpc_call, S, "Start", pb.SprintStartRequest(**ref), token=team["tokens"]["vic"]
    )
    stranger = _refused(
        grpc_call, S, "List", pb.SprintListRequest(**_ref(team)), token=team["tokens"]["eve"]
    )

    assert len(seen.sprints) == 1
    assert start.code() == grpc.StatusCode.PERMISSION_DENIED
    assert stranger.code() in (grpc.StatusCode.NOT_FOUND, grpc.StatusCode.PERMISSION_DENIED)


def test_capacity_round_trips_and_an_empty_one_clears(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    made = grpc_call(
        S,
        "Create",
        pb.SprintCreateRequest(
            **_ref(team),
            name="Cap",
            start_date="2026-11-02",
            end_date="2026-11-06",
            capacity_points="25.5",
            capacity_sec=72000,
        ),
        token=token,
    ).sprint
    bare = _plan(grpc_call, team, "Bare", start="2026-11-09", end="2026-11-13").sprint

    cleared = grpc_call(
        S,
        "Update",
        pb.SprintUpdateRequest(
            **_ref(team), sprint_id=made.id, fields=["capacity_points", "capacity_sec"]
        ),
        token=token,
    ).sprint
    set_later = grpc_call(
        S,
        "Update",
        pb.SprintUpdateRequest(
            **_ref(team), sprint_id=bare.id, fields=["capacity_points"], capacity_points="8"
        ),
        token=token,
    ).sprint

    assert (made.capacity_points, made.has_capacity_points) == (25.5, True)
    assert (made.capacity_sec, made.has_capacity_sec) == (72000, True)
    assert (bare.has_capacity_points, bare.has_capacity_sec) == (False, False)
    assert (cleared.has_capacity_points, cleared.has_capacity_sec) == (False, False)
    assert (set_later.capacity_points, set_later.has_capacity_points) == (8.0, True)
