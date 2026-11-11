"""The time controller over a real gRPC server: the contract."""

from datetime import UTC, datetime, timedelta
from typing import Any

import grpc
import pytest

from infrastructure.projects import services as projects
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused
from infrastructure.timetracking.grpc import timetracking_pb2 as pb
from infrastructure.timetracking.grpc import timetracking_pb2_grpc as stubs
from infrastructure.workspaces.models import Workspace

base_team = base.team
T = stubs.TimeControllerStub


@pytest.fixture
def team(base_team: dict[str, Any]) -> dict[str, Any]:
    ws = Workspace.objects.get(pk=base_team["ws"])
    owner = base_team["users"]["zoe"]
    version = projects.get(owner, ws, base_team["project"]).project.version
    projects.set_features(owner, ws, base_team["project"], {"time_tracking"}, version)
    return base_team


def _ref(team: dict[str, Any], task_id: str) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "project_id": team["project"], "task_id": task_id}


def test_start_current_stop_round_trip(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, who="zoe", title="Fix")
    token = team["tokens"]["max"]

    started = grpc_call(
        T, "Start", pb.TimeStartRequest(**_ref(team, task.id), note="go"), token=token
    )
    state = grpc_call(T, "Current", pb.TimeCurrentRequest(workspace_id=team["ws"]), token=token)
    stopped = grpc_call(T, "Stop", pb.TimeStopRequest(workspace_id=team["ws"]), token=token)

    assert started.entry.task_id == task.id and started.entry.flags == ["running"]
    assert started.entry.key == "WEB-1" and started.server_now and not started.stopped.id
    assert state.running and state.entry.id == started.entry.id
    assert stopped.entry.ended_at and "running" not in stopped.entry.flags
    again = grpc_call(T, "Current", pb.TimeCurrentRequest(workspace_id=team["ws"]), token=token)
    assert not again.running


def test_entries_summary_estimate_and_timesheet(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, who="zoe", title="Fix")
    token = team["tokens"]["max"]
    when = (datetime(2026, 11, 2, 9, tzinfo=UTC)).isoformat()
    made = grpc_call(
        T,
        "CreateEntry",
        pb.EntryCreateRequest(
            **_ref(team, task.id), started_at=when, duration_sec=5400, billable=True
        ),
        token=token,
    )
    grpc_call(
        T,
        "SetEstimate",
        pb.EstimateSetRequest(**_ref(team, task.id), estimate_sec=7200),
        token=team["tokens"]["zoe"],
    )

    listed = grpc_call(T, "Entries", pb.EntriesRequest(**_ref(team, task.id)), token=token)
    summary = grpc_call(T, "Summary", pb.TimeSummaryRequest(**_ref(team, task.id)), token=token)
    sheet = grpc_call(
        T,
        "Timesheet",
        pb.TimesheetRequest(workspace_id=team["ws"], week_start="2026-11-02", timezone="UTC"),
        token=token,
    )
    updated = grpc_call(
        T,
        "UpdateEntry",
        pb.EntryUpdateRequest(workspace_id=team["ws"], id=made.id, fields=["note"], note="n"),
        token=token,
    )

    assert [e.id for e in listed.entries] == [made.id]
    assert (summary.estimate_sec, summary.logged_sec, summary.billable_sec) == (7200, 5400, 5400)
    assert list(sheet.rows[0].seconds) == [5400, 0, 0, 0, 0, 0, 0] and sheet.total == 5400
    assert updated.note == "n" and updated.duration_sec == 5400
    grpc_call(
        T, "DeleteEntry", pb.EntryDeleteRequest(workspace_id=team["ws"], id=made.id), token=token
    )
    assert not grpc_call(
        T, "Entries", pb.EntriesRequest(**_ref(team, task.id)), token=token
    ).entries


def test_refusals_map_to_statuses(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, who="zoe", title="Fix")
    future = (datetime.now(UTC) + timedelta(days=2)).isoformat()

    bad = _refused(
        grpc_call,
        T,
        "CreateEntry",
        pb.EntryCreateRequest(**_ref(team, task.id), started_at=future, duration_sec=60),
        token=team["tokens"]["max"],
    )
    naive = _refused(
        grpc_call,
        T,
        "CreateEntry",
        pb.EntryCreateRequest(
            **_ref(team, task.id), started_at="2026-11-02T09:00:00", duration_sec=60
        ),
        token=team["tokens"]["max"],
    )
    viewer = _refused(
        grpc_call,
        T,
        "Start",
        pb.TimeStartRequest(**_ref(team, task.id)),
        token=team["tokens"]["vic"],
    )
    stranger = _refused(
        grpc_call,
        T,
        "Current",
        pb.TimeCurrentRequest(workspace_id=team["ws"]),
        token=team["tokens"]["eve"],
    )

    assert bad.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert naive.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED
    assert stranger.code() == grpc.StatusCode.PERMISSION_DENIED
