"""TimelineController over a real gRPC server: the contract (field names, streaming, status
codes). The rules are tested on the services in ``test_timeline``."""

from typing import Any

import grpc

from infrastructure.tasks.grpc import tasks_pb2 as pb
from infrastructure.tasks.grpc import tasks_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

team = base.team  # the fixture, registered here by name

TL = stubs.TimelineControllerStub
LINK = stubs.LinkControllerStub


def _linked(grpc_call: GrpcCall, team: dict[str, Any]) -> tuple[Any, Any]:
    a = _create(grpc_call, team, title="a", start_date="2026-11-02", due_date="2026-11-04")
    b = _create(grpc_call, team, title="b", start_date="2026-11-05", due_date="2026-11-06")
    link = pb.LinkAddRequest(
        workspace_id=team["ws"], task_id=a.id, other_task_id=b.id, kind="blocks"
    )
    grpc_call(LINK, "Add", link, token=team["tokens"]["max"])
    return a, b


def _move(team: dict[str, Any], task: Any, due: str, **kw: Any) -> dict[str, Any]:
    return {
        "workspace_id": team["ws"],
        "project_id": team["project"],
        "task_id": task.id,
        "start_date": "2026-11-02",
        "due_date": due,
        **kw,
    }


def test_the_chart_streams_tasks_with_their_links(team: Any, grpc_call: GrpcCall) -> None:
    a, b = _linked(grpc_call, team)

    chunks = grpc_call(
        TL,
        "Get",
        pb.TimelineGetRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            range_start="2026-01-01",
            range_end="2026-12-31",
            include_done=True,
        ),
        token=team["tokens"]["vic"],
    )

    assert [t.title for c in chunks for t in c.tasks] == ["a", "b"]
    assert [(link.from_id, link.to_id) for c in chunks for link in c.links] == [(a.id, b.id)]


def test_a_range_beyond_three_years_is_invalid_argument(team: Any, grpc_call: GrpcCall) -> None:
    bad = pb.TimelineGetRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        range_start="2020-01-01",
        range_end="2026-12-31",
    )

    assert _refused(grpc_call, TL, "Get", bad, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.INVALID_ARGUMENT
    )


def test_the_critical_path_names_the_longest_chain(team: Any, grpc_call: GrpcCall) -> None:
    a, b = _linked(grpc_call, team)

    got = grpc_call(
        TL,
        "CriticalPath",
        pb.TimelineCriticalPathRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["vic"],
    )

    assert list(got.task_ids) == [a.id, b.id]


def test_preview_then_apply_moves_the_chain(team: Any, grpc_call: GrpcCall) -> None:
    a, b = _linked(grpc_call, team)
    max_token = team["tokens"]["max"]

    preview = grpc_call(
        TL,
        "PreviewShift",
        pb.TimelinePreviewRequest(**_move(team, a, "2026-11-10")),
        token=max_token,
    )
    assert [(s.task.title, s.new_start, s.new_due) for s in preview.shifts] == [
        ("b", "2026-11-11", "2026-11-12")
    ]

    applied = grpc_call(
        TL,
        "ApplyShift",
        pb.TimelineApplyRequest(
            **_move(team, a, "2026-11-10", expected_version=a.version, affected_ids=[b.id])
        ),
        token=max_token,
    )
    assert [t.title for t in applied.tasks] == ["a", "b"]
    assert applied.tasks[1].start_date == "2026-11-11"


def test_a_stale_preview_is_aborted_and_a_viewer_cannot_apply(
    team: Any, grpc_call: GrpcCall
) -> None:
    a, _ = _linked(grpc_call, team)
    stale = pb.TimelineApplyRequest(**_move(team, a, "2026-11-10", expected_version=a.version))

    assert _refused(grpc_call, TL, "ApplyShift", stale, token=team["tokens"]["max"]).code() is (
        grpc.StatusCode.ABORTED
    )
    assert _refused(grpc_call, TL, "ApplyShift", stale, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.PERMISSION_DENIED
    )


def test_working_days_are_read_by_all_and_set_by_the_owner(team: Any, grpc_call: GrpcCall) -> None:
    set_request = pb.TimelineWorkingDaysSetRequest(
        workspace_id=team["ws"], days=[0, 1, 2, 3, 4], holidays=["2026-12-25"]
    )

    set_ = grpc_call(TL, "SetWorkingDays", set_request, token=team["tokens"]["zoe"])
    got = grpc_call(
        TL,
        "GetWorkingDays",
        pb.TimelineWorkingDaysGetRequest(workspace_id=team["ws"]),
        token=team["tokens"]["vic"],
    )

    assert list(set_.days) == list(got.days) == [0, 1, 2, 3, 4]
    assert list(got.holidays) == ["2026-12-25"]
    assert (
        _refused(grpc_call, TL, "SetWorkingDays", set_request, token=team["tokens"]["max"]).code()
        is grpc.StatusCode.PERMISSION_DENIED
    )
