import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import members as project_members
from infrastructure.projects import services as projects
from infrastructure.tasks import services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, actor: Any = None, **kw: Any) -> Task:
    title = kw.pop("title", "T")
    return services.create(actor or team.member, team.ws, str(project.pk), title, **kw)


def test_create_numbers_tasks_from_the_project_counter(team: Any, project: Any) -> None:
    first, second = _make(team, project), _make(team, project)

    assert (first.number, second.number) == (1, 2)
    assert first.display_id == "WEB-1"
    assert first.status == "todo" and first.priority == "none" and first.version == 1
    assert first.position < second.position
    project.refresh_from_db()
    assert project.task_counter == 2


def test_create_validates_and_stores_every_field(team: Any, project: Any) -> None:
    doc = json.dumps({"type": "doc", "content": [{"type": "paragraph"}]})
    task = _make(
        team,
        project,
        title=" Ship ",
        description=doc,
        priority="high",
        status="in_progress",
        start_date="2026-03-01",
        due_date="2026-03-05",
        assignee_ids=[str(team.member.pk)],
    )

    assert task.title == "Ship" and task.priority == "high"
    assert str(task.due_date) == "2026-03-05"
    assert task.assignee_ids() == [team.member.pk]
    assert task.created_by == team.member


@pytest.mark.parametrize(
    "bad",
    [
        {"title": ""},
        {"priority": "x"},
        {"status": "x"},
        {"due_date": "nope"},
        {"start_date": "2026-03-05", "due_date": "2026-03-01"},
        {"description": "{"},
    ],
)
def test_create_refuses_invalid_input(team: Any, project: Any, bad: dict[str, Any]) -> None:
    with pytest.raises(ApiError) as refused:
        _make(team, project, **{"title": "T", **bad})
    assert refused.value.status == 400
    project.refresh_from_db()
    assert Task.objects.count() == 0 and project.task_counter == 0


def test_viewer_cannot_write_but_can_read(team: Any, project: Any) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    with pytest.raises(access.PermissionDenied):
        _make(team, project, actor=team.viewer)
    with pytest.raises(access.PermissionDenied):
        services.update(team.viewer, team.ws, pid, tid, 1, {"title": "x"})
    with pytest.raises(access.PermissionDenied):
        services.delete(team.viewer, team.ws, pid, tid)
    assert services.get(team.viewer, team.ws, pid, tid).pk == task.pk


def test_other_workspace_and_private_project_are_not_found(team: Any, project: Any) -> None:
    task = _make(team, project)
    with pytest.raises(ApiError) as refused:
        services.get(team.outsider, team.ws, str(project.pk), str(task.pk))
    assert refused.value.status == 403  # not a member of this workspace at all

    private = team.create(team.owner, "PRV", visibility="private")
    secret = services.create(team.owner, team.ws, str(private.pk), "S")
    with pytest.raises(ApiError) as hidden:
        services.get(team.member, team.ws, str(private.pk), str(secret.pk))
    assert hidden.value.status == 404
    with pytest.raises(ApiError):
        services.create(team.member, team.ws, str(private.pk), "nope")


def test_a_task_id_from_another_project_is_not_found(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OTH")
    task = _make(team, project)
    with pytest.raises(ApiError) as refused:
        services.get(team.owner, team.ws, str(other.pk), str(task.pk))
    assert refused.value.status == 404


def test_assignee_must_be_able_to_open_the_project(team: Any, project: Any) -> None:
    private = team.create(team.owner, "PRV", visibility="private")
    pid, uid = str(private.pk), str(team.member.pk)
    with pytest.raises(ApiError) as refused:
        services.create(team.owner, team.ws, pid, "T", assignee_ids=[uid])
    assert refused.value.status == 400
    project_members.add_member(team.owner, team.ws, pid, uid)
    task = services.create(team.owner, team.ws, pid, "T", assignee_ids=[uid])
    assert task.assignee_ids() == [team.member.pk]

    with pytest.raises(ApiError):  # a member of another workspace only
        _make(team, project, assignee_ids=[str(team.outsider.pk)])
    with pytest.raises(ApiError):  # not a user at all
        _make(team, project, assignee_ids=["nope"])


def test_update_changes_only_the_sent_fields_and_bumps_the_version(team: Any, project: Any) -> None:
    task = _make(team, project, priority="low")
    updated = services.update(
        team.member, team.ws, str(project.pk), str(task.pk), 1, {"title": "New", "status": "done"}
    )

    assert (updated.title, updated.status, updated.priority) == ("New", "done", "low")
    assert updated.version == 2


def test_different_fields_merge_even_with_a_stale_version(team: Any, project: Any) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    services.update(team.member, team.ws, pid, tid, 1, {"title": "Mine"})
    merged = services.update(team.admin, team.ws, pid, tid, 1, {"priority": "urgent"})

    assert (merged.title, merged.priority, merged.version) == ("Mine", "urgent", 3)


def test_same_field_with_a_stale_version_conflicts_with_the_current_value(
    team: Any, project: Any
) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    services.update(team.member, team.ws, pid, tid, 1, {"title": "Theirs"})

    with pytest.raises(ApiError) as conflict:
        services.update(team.admin, team.ws, pid, tid, 1, {"title": "Mine"})

    assert conflict.value.status == 409
    assert conflict.value.title is ResponseTitle.VERSION_CONFLICT
    assert conflict.value.data == {"field": "title", "current": "Theirs", "version": 2}
    task.refresh_from_db()
    assert task.title == "Theirs" and task.version == 2


def test_assignee_edits_conflict_like_any_field(team: Any, project: Any) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    services.update(team.member, team.ws, pid, tid, 1, {"assignee_ids": [str(team.admin.pk)]})
    with pytest.raises(ApiError) as conflict:
        services.update(team.admin, team.ws, pid, tid, 1, {"assignee_ids": [str(team.member.pk)]})
    assert (conflict.value.data or {})["field"] == "assignee_ids"


def test_update_rejects_empty_unknown_and_invalid_changes(team: Any, project: Any) -> None:
    task = _make(team, project)
    args = (team.member, team.ws, str(project.pk), str(task.pk), 1)
    for bad in ({}, {"nope": 1}, {"title": ""}, {"due_date": "x"}):
        with pytest.raises(ApiError) as refused:
            services.update(*args, bad)
        assert refused.value.status == 400
    task.refresh_from_db()
    assert task.version == 1


def test_update_checks_the_date_range_against_the_stored_other_date(
    team: Any, project: Any
) -> None:
    task = _make(team, project, start_date="2026-03-05")
    with pytest.raises(ApiError):
        services.update(
            team.member, team.ws, str(project.pk), str(task.pk), 1, {"due_date": "2026-03-01"}
        )


def test_delete_is_soft_and_restore_brings_it_back(team: Any, project: Any) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    gone = services.delete(team.member, team.ws, pid, tid)
    assert gone.deleted_at is not None and gone.version == 2

    assert services.list_page(team.member, team.ws, pid)[0] == []
    with pytest.raises(ApiError) as refused:
        services.get(team.member, team.ws, pid, tid)
    assert refused.value.status == 404
    with pytest.raises(ApiError):
        services.update(team.member, team.ws, pid, tid, 2, {"title": "x"})

    back = services.restore(team.member, team.ws, pid, tid)
    assert back.deleted_at is None and back.number == task.number and back.version == 3
    assert [t.pk for t in services.list_page(team.member, team.ws, pid)[0]] == [task.pk]


def test_deleted_numbers_are_not_reused(team: Any, project: Any) -> None:
    task = _make(team, project)
    services.delete(team.member, team.ws, str(project.pk), str(task.pk))
    assert _make(team, project).number == 2


def test_archived_project_is_read_only(team: Any, project: Any) -> None:
    task = _make(team, project)
    pid, tid = str(project.pk), str(task.pk)
    projects.archive(team.owner, team.ws, pid, project.version)
    with pytest.raises(ApiError) as refused:
        _make(team, project)
    assert refused.value.title is ResponseTitle.PROJECT_ARCHIVED
    with pytest.raises(ApiError):
        services.update(team.member, team.ws, pid, tid, 1, {"title": "x"})
    assert services.get(team.member, team.ws, pid, tid).pk == task.pk


def test_list_pages_by_cursor_in_position_order(team: Any, project: Any) -> None:
    made = [_make(team, project, title=f"t{i}") for i in range(7)]

    seen: list[Task] = []
    cursor = ""
    pages = 0
    while True:
        page, cursor = services.list_page(
            team.viewer, team.ws, str(project.pk), cursor=cursor, limit=3
        )
        seen += page
        pages += 1
        if not cursor:
            break

    assert [t.pk for t in seen] == [t.pk for t in made]
    assert pages == 3


def test_list_filters_by_status_and_assignee(team: Any, project: Any) -> None:
    mine = _make(team, project, assignee_ids=[str(team.member.pk)])
    done = _make(team, project, status="done")
    _make(team, project)
    pid = str(project.pk)

    by_status, _ = services.list_page(team.viewer, team.ws, pid, status="done")
    by_user, _ = services.list_page(team.viewer, team.ws, pid, assignee_id=str(team.member.pk))
    assert [t.pk for t in by_status] == [done.pk]
    assert [t.pk for t in by_user] == [mine.pk]
    with pytest.raises(ApiError):
        services.list_page(team.viewer, team.ws, pid, status="bogus")


def test_list_refuses_a_malformed_cursor_and_clamps_the_limit(team: Any, project: Any) -> None:
    pid = str(project.pk)
    with pytest.raises(ApiError) as refused:
        services.list_page(team.viewer, team.ws, pid, cursor="!!!")
    assert refused.value.status == 400
    _make(team, project)
    page, _ = services.list_page(team.viewer, team.ws, pid, limit=10**6)
    assert len(page) == 1


def test_list_query_count_does_not_grow_with_the_page(
    team: Any, project: Any, django_assert_max_num_queries: Any
) -> None:
    for i in range(30):
        _make(team, project, title=str(i), assignee_ids=[str(team.member.pk)])
    with django_assert_max_num_queries(8):
        page, _ = services.list_page(team.viewer, team.ws, str(project.pk), limit=30)
        assert page[0].display_id == "WEB-1"
        assert all(t.assignee_ids() for t in page)


def test_trash_lists_deleted_tasks_newest_first_for_those_who_may_restore(
    team: Any, project: Any
) -> None:
    pid = str(project.pk)
    first, second, kept = (_make(team, project, title=t) for t in ("one", "two", "kept"))
    services.delete(team.member, team.ws, pid, str(first.pk))
    services.delete(team.member, team.ws, pid, str(second.pk))

    trashed = services.list_trash(team.member, team.ws, pid)

    assert [t.pk for t in trashed] == [second.pk, first.pk]
    assert all(t.deleted_at is not None for t in trashed) and kept.pk not in {t.pk for t in trashed}
    with pytest.raises(access.PermissionDenied):
        services.list_trash(team.viewer, team.ws, pid)
    services.restore(team.member, team.ws, pid, str(first.pk))
    assert [t.pk for t in services.list_trash(team.member, team.ws, pid)] == [second.pk]


def test_trash_is_scoped_to_the_project_and_visibility(team: Any, project: Any) -> None:
    private = team.create(team.owner, "PRV", visibility="private")
    secret = services.create(team.owner, team.ws, str(private.pk), "S")
    services.delete(team.owner, team.ws, str(private.pk), str(secret.pk))
    with pytest.raises(ApiError) as hidden:
        services.list_trash(team.member, team.ws, str(private.pk))
    assert hidden.value.status == 404
    assert services.list_trash(team.member, team.ws, str(project.pk)) == []


@pytest.mark.parametrize("version", [0, -1, 2, 2**31 - 1])
def test_update_refuses_a_version_the_task_never_had(team: Any, project: Any, version: int) -> None:
    task = _make(team, project)
    with pytest.raises(ApiError) as refused:
        services.update(
            team.member, team.ws, str(project.pk), str(task.pk), version, {"title": "x"}
        )
    assert refused.value.status == 400
    task.refresh_from_db()
    assert task.version == 1 and task.title == "T"


def test_the_same_assignee_in_any_letter_case_counts_once(team: Any, project: Any) -> None:
    uid = str(team.member.pk)
    task = _make(team, project, assignee_ids=[uid, uid.upper(), uid])
    assert task.assignee_ids() == [team.member.pk]
