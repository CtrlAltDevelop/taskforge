"""Home and Onboarding over the wire: the shapes, and the refusals."""

from typing import Any

import grpc
import pytest

from infrastructure.home.grpc import home_pb2 as pb
from infrastructure.home.grpc import home_pb2_grpc as stubs
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.grpc import tasks_pb2 as tpb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.tasks.models import Task
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

HM = stubs.HomeControllerStub
OB = stubs.OnboardingControllerStub


def test_summary_my_work_and_recent_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    owner = world.workspace.created_by
    set_actor(owner)
    token = world.tokens["Owner"]
    made = task_services.create(
        owner,
        world.workspace,
        world.project_id,
        "Ship it",
        due_date="2026-11-18",
        assignee_ids=[str(owner.pk)],
    )

    grpc_call(
        HM,
        "RecordRecent",
        pb.HomeRecordRecentRequest(workspace_id=world.ws, task_id=str(made.pk)),
        token=token,
    )
    got = grpc_call(
        HM, "Summary", pb.HomeSummaryRequest(workspace_id=world.ws, today="2026-11-18"), token=token
    )
    mine = grpc_call(HM, "MyWork", pb.HomeMyWorkRequest(workspace_id=world.ws), token=token)

    assert got.today_count == 1 and got.due_items[0].title == "Ship it"
    assert got.due_items[0].project_key == "WEB" and len(got.week) == 7
    assert [t.title for t in got.recent] == ["Ship it"]
    assert [(t.task.title, t.assigned) for t in mine.tasks] == [("Ship it", True)]


def test_starter_checklist_and_samples_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 1)
    token = world.tokens["Owner"]

    applied = grpc_call(
        OB,
        "ApplyStarter",
        pb.OnboardingApplyStarterRequest(workspace_id=world.ws, starter="bug-tracker"),
        token=token,
    )
    state = grpc_call(OB, "Get", pb.OnboardingGetRequest(workspace_id=world.ws), token=token)
    ticked = grpc_call(
        OB,
        "CompleteStep",
        pb.OnboardingCompleteStepRequest(workspace_id=world.ws, step="open_palette"),
        token=token,
    )
    removed = grpc_call(
        OB, "DeleteSamples", pb.OnboardingDeleteSamplesRequest(workspace_id=world.ws), token=token
    )
    dismissed = grpc_call(
        OB, "Dismiss", pb.OnboardingDismissRequest(workspace_id=world.ws), token=token
    )

    assert applied.task_count > 0 and state.sample_project_id == applied.project_id
    assert [s.key for s in state.starters] == ["software-team", "marketing", "bug-tracker", "blank"]
    assert state.visible and "create_task" not in [s.step for s in state.steps if s.done]
    assert "open_palette" in [s.step for s in ticked.steps if s.done]
    assert removed.deleted == applied.task_count
    assert dismissed.dismissed and not dismissed.visible


def test_unknown_step_is_invalid_argument(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 2)

    with pytest.raises(grpc.aio.AioRpcError) as bad:
        grpc_call(
            OB,
            "CompleteStep",
            pb.OnboardingCompleteStepRequest(workspace_id=world.ws, step="nope"),
            token=world.tokens["Owner"],
        )

    assert bad.value.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_a_task_message_says_whether_it_is_a_sample(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 3)
    owner = world.workspace.created_by
    set_actor(owner)
    made = task_services.create(owner, world.workspace, world.project_id, "Example")
    token = world.tokens["Owner"]

    def read() -> Any:
        request = tpb.TaskGetRequest(
            workspace_id=world.ws, project_id=world.project_id, id=str(made.pk)
        )
        return grpc_call(tstubs.TaskControllerStub, "Get", request, token=token)

    assert read().is_sample is False
    Task.objects.filter(pk=made.pk).update(is_sample=True)
    assert read().is_sample is True
