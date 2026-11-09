import json
from dataclasses import replace
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workflows import services
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.models import Status, Transition
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _ids(view: Any) -> dict[str, str]:
    return {s.name: str(s.pk) for s in view.statuses}


def _draft_of(view: Any, **changes: Any) -> WorkflowDraft:
    """The saved workflow as a draft, with ``changes`` (draft fields) on top."""
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        ),
        transitions=tuple(
            TransitionDraft(
                str(t.from_status_id),
                str(t.to_status_id),
                str(t.required_role_id or ""),
                t.require_assignee,
            )
            for t in view.transitions
        ),
        restrict=view.workflow.restrict_transitions,
        restrict_creation=view.workflow.restrict_creation,
    )
    return replace(draft, **changes)


def _save(team: Any, project: Any, view: Any, draft: WorkflowDraft, migrate: Any = None) -> Any:
    return services.update(
        team.admin, team.ws, str(project.pk), view.workflow.version, draft, migrate or {}
    )


def _problems(error: ApiError) -> set[str]:
    assert error.data is not None
    return {p["code"] for p in json.loads(error.data["errors"])}


def test_a_new_project_gets_the_default_workflow_once(team: Any, project: Any) -> None:
    first = services.get(team.viewer, team.ws, str(project.pk))
    again = services.get(team.viewer, team.ws, str(project.pk))

    assert [(s.name, s.category, s.is_default) for s in first.statuses] == [
        ("To do", "not_started", True),
        ("In progress", "active", False),
        ("Done", "done", False),
    ]
    assert [s.pk for s in again.statuses] == [s.pk for s in first.statuses]
    assert first.workflow.restrict_transitions is False and first.workflow.version == 1
    assert Status.objects.filter(project=project).count() == 3


def test_reading_follows_project_visibility(team: Any, project: Any) -> None:
    with pytest.raises(ApiError) as outsider:
        services.get(team.outsider, team.ws, str(project.pk))
    assert outsider.value.status == 403
    private = team.create(team.owner, "PRV", visibility="private")
    with pytest.raises(ApiError) as hidden:
        services.get(team.member, team.ws, str(private.pk))
    assert hidden.value.status == 404


def test_only_those_who_may_update_the_project_can_edit_the_workflow(
    team: Any, project: Any
) -> None:
    view = services.get(team.owner, team.ws, str(project.pk))
    draft = _draft_of(view)
    with pytest.raises(access.PermissionDenied):
        services.update(team.viewer, team.ws, str(project.pk), 1, draft, {})
    with pytest.raises(access.PermissionDenied):
        services.update(team.member, team.ws, str(project.pk), 1, draft, {})
    mine = team.create(team.pm, "PM")  # a member who created it may manage it
    own = services.get(team.pm, team.ws, str(mine.pk))
    assert services.update(team.pm, team.ws, str(mine.pk), 1, _draft_of(own), {}).workflow
    assert services.update(team.admin, team.ws, str(project.pk), 1, draft, {}).workflow


def test_rename_recolor_and_reorder_leave_every_task_alone(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    made = tasks.create(team.member, team.ws, str(project.pk), "T", status=ids["In progress"])
    by_key = {s.key: s for s in _draft_of(view).statuses}
    draft = WorkflowDraft(
        statuses=(
            StatusDraft(ids["Done"], "Shipped", "#112233", "done"),
            StatusDraft(ids["In progress"], "Doing", "#445566", "active"),
            StatusDraft(ids["To do"], "Backlog", "", "not_started", True),
        ),
    )

    saved = _save(team, project, view, draft)

    assert [s.name for s in saved.statuses] == ["Shipped", "Doing", "Backlog"]
    assert [s.position for s in saved.statuses] == [0, 1, 2]
    assert {s.name: str(s.pk) for s in saved.statuses} == {
        "Shipped": ids["Done"],
        "Doing": ids["In progress"],
        "Backlog": ids["To do"],
    }
    made.refresh_from_db()
    assert str(made.status_id) == ids["In progress"] and made.version == 1
    assert by_key  # the original draft was untouched (frozen)
    assert saved.workflow.version == 2


def test_two_statuses_can_swap_names_in_one_save(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    draft = WorkflowDraft(
        statuses=(
            StatusDraft(ids["To do"], "In progress", "", "not_started", True),
            StatusDraft(ids["In progress"], "To do", "", "active"),
            StatusDraft(ids["Done"], "Done", "", "done"),
        )
    )

    saved = _save(team, project, view, draft)

    assert {str(s.pk): s.name for s in saved.statuses}[ids["To do"]] == "In progress"


def test_a_new_status_is_added_with_its_key_replaced_by_an_id(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    draft = _draft_of(
        view, statuses=(*_draft_of(view).statuses, StatusDraft("new-1", "QA", "#abcdef", "active"))
    )

    saved = _save(team, project, view, draft)

    qa = next(s for s in saved.statuses if s.name == "QA")
    assert qa.category == "active" and qa.color == "#ABCDEF" and qa.position == 3
    assert len(str(qa.pk)) == 36


def test_changing_the_default_moves_it(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.name == "In progress")
            for s in view.statuses
        )
    )

    saved = _save(team, project, view, draft)

    assert [s.name for s in saved.statuses if s.is_default] == ["In progress"]
    task = tasks.create(team.member, team.ws, str(project.pk), "New")
    assert str(task.status_id) == ids["In progress"]


def test_deleting_a_status_needs_somewhere_to_move_its_tasks(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    task = tasks.create(team.member, team.ws, str(project.pk), "T", status=ids["In progress"])
    without = _draft_of(
        view, statuses=tuple(s for s in _draft_of(view).statuses if s.key != ids["In progress"])
    )

    with pytest.raises(ApiError) as refused:
        _save(team, project, view, without)

    assert refused.value.status == 400 and "STATUS_NEEDS_MIGRATION" in _problems(refused.value)
    assert Status.objects.filter(project=project).count() == 3
    task.refresh_from_db()
    assert str(task.status_id) == ids["In progress"]


def test_deleting_a_status_moves_all_its_tasks_atomically(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    pid = str(project.pk)
    mine = tasks.create(team.member, team.ws, pid, "A", status=ids["In progress"])
    other = tasks.create(team.member, team.ws, pid, "B", status=ids["In progress"])
    trashed = tasks.create(team.member, team.ws, pid, "C", status=ids["In progress"])
    tasks.delete(team.member, team.ws, pid, str(trashed.pk))
    kept = tasks.create(team.member, team.ws, pid, "D", status=ids["Done"])
    without = _draft_of(
        view, statuses=tuple(s for s in _draft_of(view).statuses if s.key != ids["In progress"])
    )

    saved = _save(team, project, view, without, {ids["In progress"]: ids["To do"]})

    assert [s.name for s in saved.statuses] == ["To do", "Done"]
    for task in (mine, other, trashed):
        task.refresh_from_db()
        assert str(task.status_id) == ids["To do"]
    assert mine.version == 2 and mine.field_versions["status"] == 2  # others see a status change
    kept.refresh_from_db()
    assert str(kept.status_id) == ids["Done"] and kept.version == 1


def test_a_status_without_tasks_is_deleted_without_a_target(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    without = _draft_of(
        view, statuses=tuple(s for s in _draft_of(view).statuses if s.name != "In progress")
    )

    saved = _save(team, project, view, without)

    assert [s.name for s in saved.statuses] == ["To do", "Done"]


def test_the_migration_target_must_be_kept_and_different(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    tasks.create(team.member, team.ws, str(project.pk), "T", status=ids["In progress"])
    without = _draft_of(
        view, statuses=tuple(s for s in _draft_of(view).statuses if s.key != ids["In progress"])
    )

    for target in (ids["In progress"], "nope", ""):
        with pytest.raises(ApiError) as refused:
            _save(team, project, view, without, {ids["In progress"]: target})
        assert "STATUS_NEEDS_MIGRATION" in _problems(refused.value)


def test_an_invalid_workflow_is_rejected_whole_with_the_list_of_problems(
    team: Any, project: Any
) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    broken = WorkflowDraft(
        statuses=(StatusDraft("x", "Only", "", "active"),),
    )

    with pytest.raises(ApiError) as refused:
        _save(team, project, view, broken)

    assert refused.value.status == 400
    assert refused.value.title is ResponseTitle.WORKFLOW_INVALID
    assert {"NO_DONE_STATUS", "NO_NOT_STARTED_STATUS", "NO_DEFAULT_STATUS"} <= _problems(
        refused.value
    )
    assert [s.name for s in services.get(team.admin, team.ws, str(project.pk)).statuses] == [
        "To do",
        "In progress",
        "Done",
    ]


def test_a_stale_version_is_a_conflict(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    _save(team, project, view, _draft_of(view))

    with pytest.raises(ApiError) as conflict:
        _save(team, project, view, _draft_of(view))

    assert conflict.value.title is ResponseTitle.VERSION_CONFLICT


def test_validate_is_a_dry_run(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    draft = _draft_of(
        view, restrict=True, transitions=(TransitionDraft(ids["To do"], ids["Done"]),)
    )

    problems = services.validate_draft(team.admin, team.ws, str(project.pk), draft, {})

    assert {p.code for p in problems} == {"STATUS_UNREACHABLE", "STATUS_DEAD_END"}
    assert services.get(team.admin, team.ws, str(project.pk)).workflow.version == 1
    with pytest.raises(access.PermissionDenied):
        services.validate_draft(team.viewer, team.ws, str(project.pk), draft, {})


def test_an_archived_project_cannot_change_its_workflow(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError) as refused:
        _save(team, project, view, _draft_of(view))

    assert refused.value.title is ResponseTitle.PROJECT_ARCHIVED


def test_a_transition_may_only_name_a_known_role(team: Any, project: Any) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    draft = _draft_of(
        view,
        restrict=True,
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"], "999999"),
            TransitionDraft(ids["In progress"], ids["Done"]),
        ),
    )

    with pytest.raises(ApiError) as refused:
        _save(team, project, view, draft)

    assert "TRANSITION_ROLE_UNKNOWN" in _problems(refused.value)


def _restricted(team: Any, project: Any, **conditions: Any) -> Any:
    """To do -> In progress (with ``conditions``) -> Done, restricted."""
    view = services.get(team.admin, team.ws, str(project.pk))
    ids = _ids(view)
    draft = _draft_of(
        view,
        restrict=True,
        transitions=(
            TransitionDraft(ids["To do"], ids["In progress"], **conditions),
            TransitionDraft(ids["In progress"], ids["Done"]),
            TransitionDraft(ids["In progress"], ids["To do"]),
        ),
    )
    return _save(team, project, view, draft)


def _task(team: Any, project: Any, status_name: str = "To do", **kw: Any) -> Task:
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))
    return tasks.create(team.member, team.ws, str(project.pk), "T", status=ids[status_name], **kw)


def test_without_restriction_any_move_is_allowed(team: Any, project: Any) -> None:
    task = _task(team, project)
    done = _ids(services.get(team.admin, team.ws, str(project.pk)))["Done"]

    moved = tasks.update(team.member, team.ws, str(project.pk), str(task.pk), 1, {"status": done})

    assert str(moved.status_id) == done


def test_restricted_moves_follow_the_arrows(team: Any, project: Any) -> None:
    _restricted(team, project)
    task = _task(team, project)
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))
    pid, tid = str(project.pk), str(task.pk)

    with pytest.raises(ApiError) as refused:
        tasks.update(team.member, team.ws, pid, tid, 1, {"status": ids["Done"]})
    assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
    assert refused.value.data == {
        "from": ids["To do"],
        "to": ids["Done"],
        "reason": "To do → Done is not allowed.",
    }
    task.refresh_from_db()
    assert str(task.status_id) == ids["To do"] and task.version == 1

    step = tasks.update(team.member, team.ws, pid, tid, 1, {"status": ids["In progress"]})
    done = tasks.update(team.member, team.ws, pid, tid, step.version, {"status": ids["Done"]})
    assert str(done.status_id) == ids["Done"]


def test_staying_in_the_same_status_is_never_a_transition(team: Any, project: Any) -> None:
    _restricted(team, project)
    task = _task(team, project)
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))

    same = tasks.update(
        team.member, team.ws, str(project.pk), str(task.pk), 1, {"status": ids["To do"]}
    )

    assert str(same.status_id) == ids["To do"]


def test_a_new_task_may_start_in_any_status_even_when_restricted(team: Any, project: Any) -> None:
    _restricted(team, project)

    assert _task(team, project, "Done").status.name == "Done"


def test_the_assignee_condition_uses_the_assignees_after_the_edit(team: Any, project: Any) -> None:
    _restricted(team, project, require_assignee=True)
    task = _task(team, project)
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))
    pid, tid = str(project.pk), str(task.pk)

    with pytest.raises(ApiError) as refused:
        tasks.update(team.member, team.ws, pid, tid, 1, {"status": ids["In progress"]})
    assert "assignee" in (refused.value.data or {})["reason"].lower()

    both = tasks.update(
        team.member,
        team.ws,
        pid,
        tid,
        1,
        {"status": ids["In progress"], "assignee_ids": [str(team.member.pk)]},
    )
    assert str(both.status_id) == ids["In progress"]


def test_the_role_condition_lets_only_that_role_move_the_task(team: Any, project: Any) -> None:
    admin_role = access.builtin_role("Admin")
    _restricted(team, project, required_role_id=str(admin_role.pk))
    task = _task(team, project)
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))
    pid, tid = str(project.pk), str(task.pk)

    with pytest.raises(ApiError) as refused:
        tasks.update(team.member, team.ws, pid, tid, 1, {"status": ids["In progress"]})
    assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
    assert "Admin" in (refused.value.data or {})["reason"]

    moved = tasks.update(team.admin, team.ws, pid, tid, 1, {"status": ids["In progress"]})
    assert str(moved.status_id) == ids["In progress"]


def test_move_is_an_update_of_the_status_alone(team: Any, project: Any) -> None:
    _restricted(team, project)
    task = _task(team, project)
    ids = _ids(services.get(team.admin, team.ws, str(project.pk)))

    moved = tasks.move(team.member, team.ws, str(project.pk), str(task.pk), 1, ids["In progress"])

    assert str(moved.status_id) == ids["In progress"] and moved.version == 2
    with pytest.raises(ApiError):
        tasks.move(team.member, team.ws, str(project.pk), str(task.pk), 2, ids["To do"] + "x")


def test_a_status_of_another_project_is_not_accepted(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH")
    foreign = _ids(services.get(team.owner, team.ws, str(other.pk)))["Done"]
    task = _task(team, project)

    with pytest.raises(ApiError) as refused:
        tasks.update(team.member, team.ws, str(project.pk), str(task.pk), 1, {"status": foreign})

    assert refused.value.status == 400


def test_transition_rows_are_replaced_by_each_save(team: Any, project: Any) -> None:
    _restricted(team, project)
    assert Transition.objects.filter(project=project).count() == 3
    view = services.get(team.admin, team.ws, str(project.pk))
    _save(team, project, view, _draft_of(view, restrict=False, transitions=()))
    assert Transition.objects.filter(project=project).count() == 0


def test_statuses_are_scoped_to_their_project(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH")
    a = services.get(team.owner, team.ws, str(project.pk))
    b = services.get(team.owner, team.ws, str(other.pk))
    assert not {s.pk for s in a.statuses} & {s.pk for s in b.statuses}


def _creation_ruled(team: Any, project: Any) -> Any:
    view = services.get(team.admin, team.ws, str(project.pk))
    return _save(team, project, view, _draft_of(view, restrict_creation=True))


def test_creating_a_task_is_free_by_default(team: Any, project: Any) -> None:

    for name in ("To do", "In progress", "Done"):
        assert _task(team, project, name).status.name == name


def test_with_the_creation_rule_new_tasks_start_in_the_default_status_only(
    team: Any, project: Any
) -> None:
    saved = _creation_ruled(team, project)
    ids = _ids(saved)
    pid = str(project.pk)

    assert saved.workflow.restrict_creation is True and saved.workflow.version == 2
    assert tasks.create(team.member, team.ws, pid, "A").status.name == "To do"
    assert tasks.create(team.member, team.ws, pid, "B", status=ids["To do"]).number == 2
    for name in ("In progress", "Done"):
        with pytest.raises(ApiError) as refused:
            tasks.create(team.member, team.ws, pid, "C", status=ids[name])
        assert refused.value.title is ResponseTitle.TRANSITION_NOT_ALLOWED
        assert refused.value.data == {
            "from": "",
            "to": ids[name],
            "reason": "New tasks must start in To do.",
        }
    project.refresh_from_db()
    assert Task.objects.count() == 2 and project.task_counter == 2  # a refusal burns no number


def test_the_creation_rule_does_not_stop_moving_a_task_afterwards(team: Any, project: Any) -> None:
    saved = _creation_ruled(team, project)
    ids = _ids(saved)
    task = tasks.create(team.member, team.ws, str(project.pk), "T")

    moved = tasks.move(team.member, team.ws, str(project.pk), str(task.pk), 1, ids["Done"])

    assert moved.status.name == "Done"


def test_the_creation_rule_follows_a_changed_default(team: Any, project: Any) -> None:
    saved = _creation_ruled(team, project)
    ids = _ids(saved)
    draft = replace(
        _draft_of(saved),
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.name == "In progress")
            for s in saved.statuses
        ),
    )
    _save(team, project, saved, draft)

    assert tasks.create(team.member, team.ws, str(project.pk), "T").status.name == "In progress"
    with pytest.raises(ApiError):
        tasks.create(team.member, team.ws, str(project.pk), "U", status=ids["To do"])


def test_turning_the_creation_rule_off_makes_creation_free_again(team: Any, project: Any) -> None:
    saved = _creation_ruled(team, project)
    ids = _ids(saved)
    _save(team, project, saved, _draft_of(saved, restrict_creation=False))

    created = tasks.create(team.member, team.ws, str(project.pk), "T", status=ids["Done"])

    assert created.status.name == "Done"


def test_the_creation_rule_and_the_transition_rule_are_independent(team: Any, project: Any) -> None:
    _creation_ruled(team, project)
    view = services.get(team.admin, team.ws, str(project.pk))
    assert view.workflow.restrict_transitions is False
    ids = _ids(view)
    task = tasks.create(team.member, team.ws, str(project.pk), "T")

    # Transitions are not restricted, so any move is fine even though creation is.
    assert (
        tasks.move(team.member, team.ws, str(project.pk), str(task.pk), 1, ids["Done"]).status.name
        == "Done"
    )


def test_only_those_who_may_edit_the_workflow_can_set_the_creation_rule(
    team: Any, project: Any
) -> None:
    view = services.get(team.admin, team.ws, str(project.pk))
    draft = _draft_of(view, restrict_creation=True)

    with pytest.raises(access.PermissionDenied):
        services.update(team.member, team.ws, str(project.pk), 1, draft, {})
    with pytest.raises(access.PermissionDenied):
        services.update(team.viewer, team.ws, str(project.pk), 1, draft, {})
    assert services.update(
        team.admin, team.ws, str(project.pk), 1, draft, {}
    ).workflow.restrict_creation
