"""Bulk edits: one outcome per task, atomic per task, and the whole call checked up front."""

import time
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.common.tests.perf import budget
from infrastructure.tasks import bulk, services
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db

BUDGET_SECONDS = 2.0
# Each task costs a few dozen queries (about 8 s for 200 tasks on PostgreSQL): see perf.budget.
# ponytail: scaled budget, bulk.py batching the per-task queries would remove the need.


def _make(team: Any, project: Any, title: str = "t", **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _status(project: Any, name: str) -> str:
    workflows.ensure(project)
    return str(Status.objects.get(project=project, name=name).pk)


def _run(team: Any, project: Any, ids: list[Any], who: Any = None, **kw: Any) -> list[Any]:
    return list(
        bulk.update_many(who or team.member, team.ws, str(project.pk), [str(i) for i in ids], **kw)
    )


def test_every_task_gets_its_change_and_its_own_result(team: Any, project: Any) -> None:
    tasks = [_make(team, project, f"t{i}") for i in range(3)]

    results = _run(team, project, [t.pk for t in tasks], changes={"priority": "urgent"})

    assert [r.task_id for r in results] == [str(t.pk) for t in tasks]
    assert all(r.error is None and r.task.priority == "urgent" for r in results)
    assert set(Task.objects.values_list("priority", flat=True)) == {"urgent"}


def test_assign_status_and_priority_together(team: Any, project: Any) -> None:
    task = _make(team, project)
    done = _status(project, "Done")

    [result] = _run(
        team,
        project,
        [task.pk],
        changes={"status": done, "assignee_ids": [str(team.member.pk)]},
    )

    assert str(result.task.status_id) == done
    assert result.task.assignee_ids() == [team.member.pk]


def test_one_refusal_does_not_stop_the_others(team: Any, project: Any) -> None:
    blocker = _make(team, project, "blocker")
    blocked = _make(team, project, "blocked")
    free = _make(team, project, "free")
    from infrastructure.tasks import links

    links.add(team.owner, team.ws, str(blocker.pk), str(blocked.pk), "blocks")

    results = _run(
        team,
        project,
        [blocked.pk, free.pk],
        changes={"status": _status(project, "Done")},
    )

    refused, accepted = results
    assert refused.error is not None
    assert refused.error.title is ResponseTitle.TASK_BLOCKED
    assert refused.task is None
    assert accepted.error is None
    assert Task.objects.get(pk=free.pk).status.name == "Done"
    assert Task.objects.get(pk=blocked.pk).status.name == "To do"  # atomic per task


def test_a_missing_or_foreign_or_trashed_task_is_a_failed_result_not_a_failed_call(
    team: Any, project: Any
) -> None:
    other = team.create(team.owner, "API", name="Api")
    foreign = services.create(team.owner, team.ws, str(other.pk), "elsewhere")
    gone = _make(team, project, "gone")
    services.delete(team.owner, team.ws, str(project.pk), str(gone.pk))
    ok = _make(team, project, "ok")

    results = _run(
        team,
        project,
        [foreign.pk, gone.pk, "not-an-id", ok.pk],
        changes={"priority": "low"},
    )

    assert [r.error is not None for r in results] == [True, True, True, False]
    assert Task.objects.get(pk=foreign.pk).priority == "none"


def test_the_same_id_twice_is_done_once(team: Any, project: Any) -> None:
    task = _make(team, project)

    results = _run(team, project, [task.pk, task.pk], changes={"priority": "high"})

    assert len(results) == 1


def test_an_edit_in_between_does_not_make_a_bulk_edit_fail(team: Any, project: Any) -> None:
    task = _make(team, project)
    services.update(team.owner, team.ws, str(project.pk), str(task.pk), 1, {"title": "renamed"})

    [result] = _run(team, project, [task.pk], changes={"priority": "high"})

    assert result.error is None
    assert result.task.title == "renamed"
    assert result.task.priority == "high"


def test_bulk_delete_takes_a_parent_and_its_selected_children_together(
    team: Any, project: Any
) -> None:
    parent = _make(team, project, "parent")
    child = _make(team, project, "child", parent_id=str(parent.pk))

    results = _run(team, project, [parent.pk, child.pk], delete="")

    assert all(r.error is None for r in results)
    assert not Task.objects.filter(deleted_at__isnull=True).exists()

    services.restore(team.owner, team.ws, str(project.pk), str(parent.pk))

    assert Task.objects.filter(deleted_at__isnull=True).count() == 2  # the child came back too


def test_deleting_a_parent_whose_subtasks_are_not_chosen_asks_what_to_do(
    team: Any, project: Any
) -> None:
    parent = _make(team, project, "parent")
    _make(team, project, "child", parent_id=str(parent.pk))

    [refused] = _run(team, project, [parent.pk], delete="")
    [done] = _run(team, project, [parent.pk], delete="subtree")

    assert refused.error is not None and refused.error.title is ResponseTitle.HAS_SUBTASKS
    assert done.error is None
    assert Task.objects.filter(deleted_at__isnull=False).count() == 2


@pytest.mark.parametrize(
    "kwargs",
    [
        {},
        {"changes": {}, "delete": None},
        {"changes": {"priority": "low"}, "delete": ""},
        {"changes": {"title": "x"}},
        {"changes": {"priority": "bogus"}},
    ],
)
def test_a_malformed_call_is_refused_before_anything_changes(
    team: Any, project: Any, kwargs: dict[str, Any]
) -> None:
    task = _make(team, project)

    with pytest.raises(ApiError):
        _run(team, project, [task.pk], **kwargs)

    assert Task.objects.get(pk=task.pk).version == 1


def test_the_id_list_is_bounded(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        _run(team, project, [], changes={"priority": "low"})
    with pytest.raises(ApiError):
        _run(team, project, list(range(bulk.MAX_IDS + 1)), changes={"priority": "low"})


def test_the_whole_call_needs_the_permission_and_a_writable_project(
    team: Any, project: Any
) -> None:
    task = _make(team, project)

    with pytest.raises(access.PermissionDenied):
        _run(team, project, [task.pk], who=team.viewer, changes={"priority": "low"})
    with pytest.raises(ApiError):
        _run(team, project, [task.pk], who=team.outsider, changes={"priority": "low"})


def test_deleting_needs_the_delete_permission(team: Any, project: Any) -> None:
    task = _make(team, project)

    with pytest.raises(access.PermissionDenied):
        _run(team, project, [task.pk], who=team.viewer, delete="subtree")


def test_two_hundred_tasks_change_inside_the_budget(team: Any, project: Any) -> None:
    ids = [_make(team, project, f"t{i}").pk for i in range(200)]

    started = time.perf_counter()
    results = _run(team, project, ids, changes={"priority": "high"})
    elapsed = time.perf_counter() - started

    assert len(results) == 200 and all(r.error is None for r in results)
    assert elapsed < budget(BUDGET_SECONDS)
