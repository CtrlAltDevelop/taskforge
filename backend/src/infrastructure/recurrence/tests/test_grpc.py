"""The recurrence RPCs end to end: the wire shapes and the refusals."""

from typing import Any

import grpc
import pytest

from infrastructure.recurrence.grpc import recurrence_pb2 as pb
from infrastructure.recurrence.grpc import recurrence_pb2_grpc as stubs
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

RC = stubs.RecurrenceControllerStub


def _task(world: Any) -> dict[str, Any]:
    owner = world.workspace.created_by
    set_actor(owner)
    made = task_services.create(
        owner, world.workspace, world.project_id, "Report", due_date="2026-11-02"
    )
    return {"workspace_id": world.ws, "project_id": world.project_id, "task_id": str(made.pk)}


def test_set_get_pause_future_and_clear_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    ref = _task(world)
    token = world.tokens["Owner"]
    assert not grpc_call(RC, "Get", pb.RecurrenceGetRequest(**ref), token=token).repeats

    made = grpc_call(
        RC,
        "Set",
        pb.RecurrenceSetRequest(
            **ref, rrule="FREQ=WEEKLY;BYDAY=MO", mode="schedule", timezone="UTC", lead_days=1
        ),
        token=token,
    ).series
    assert (made.summary, made.mode, made.lead_days) == ("Every week on Mon", "schedule", 1)
    assert made.is_template and made.index == 0 and made.at_time == "09:00"
    assert made.next_due_on == "2026-11-09" and made.next_dates[:2] == ["2026-11-09", "2026-11-16"]

    got = grpc_call(RC, "Get", pb.RecurrenceGetRequest(**ref), token=token)
    assert got.repeats and got.series.id == made.id and got.series.task_id == ref["task_id"]

    paused = grpc_call(
        RC, "Pause", pb.RecurrencePauseRequest(**ref, paused=True), token=token
    ).series
    assert paused.paused and not paused.next_dates

    future = grpc_call(RC, "UpdateFuture", pb.RecurrenceUpdateFutureRequest(**ref), token=token)
    assert future.changed == 0 and future.series.id == made.id

    cleared = grpc_call(RC, "Clear", pb.RecurrenceClearRequest(**ref), token=token)
    assert cleared.task_id == ref["task_id"]
    assert not grpc_call(RC, "Get", pb.RecurrenceGetRequest(**ref), token=token).repeats


def test_preview_and_upcoming_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    ref = _task(world)
    token = world.tokens["Owner"]
    shown = grpc_call(
        RC,
        "Preview",
        pb.RecurrencePreviewRequest(
            workspace_id=world.ws, rrule="FREQ=DAILY", mode="schedule", starts_on="2026-11-02"
        ),
        token=token,
    )
    assert shown.summary == "Every day" and list(shown.dates)[:2] == ["2026-11-03", "2026-11-04"]
    assert len(shown.dates) == 5  # the default count

    grpc_call(
        RC,
        "Set",
        pb.RecurrenceSetRequest(**ref, rrule="FREQ=WEEKLY", mode="schedule"),
        token=token,
    )
    ghosts = grpc_call(
        RC,
        "Upcoming",
        pb.RecurrenceUpcomingRequest(workspace_id=world.ws, start="2026-11-01", end="2026-11-16"),
        token=token,
    ).ghosts
    assert [(g.title, g.due_date) for g in ghosts] == [
        ("Report", "2026-11-09"),
        ("Report", "2026-11-16"),
    ]


def test_a_bad_rule_is_invalid_argument_and_a_viewer_cannot_set(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    ref = _task(world)
    with pytest.raises(grpc.aio.AioRpcError) as bad:
        grpc_call(
            RC,
            "Set",
            pb.RecurrenceSetRequest(**ref, rrule="FREQ=HOURLY", mode="schedule"),
            token=world.tokens["Owner"],
        )
    assert bad.value.code() is grpc.StatusCode.INVALID_ARGUMENT
    with pytest.raises(grpc.aio.AioRpcError) as denied:
        grpc_call(
            RC,
            "Set",
            pb.RecurrenceSetRequest(**ref, rrule="FREQ=DAILY", mode="schedule"),
            token=world.tokens["Viewer"],
        )
    assert denied.value.code() is grpc.StatusCode.PERMISSION_DENIED
