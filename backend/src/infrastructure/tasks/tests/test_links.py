from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.tasks import links, services
from infrastructure.tasks.models import Task, TaskLink
from infrastructure.tasks.tests.test_services import _make, _status
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _add(team: Any, a: Task, kind: str, b: Task, actor: Any = None, **kw: Any) -> Any:
    return links.add(actor or team.member, team.ws, str(a.pk), str(b.pk), kind, **kw)


def _kinds(team: Any, task: Task, actor: Any = None) -> dict[str, str]:
    """other display id (or 'restricted') -> kind, as ``actor`` sees the task's links."""
    rows = links.list_for_task(actor or team.member, team.ws, str(task.pk))
    return {(v.other.display_id if v.other else "restricted"): v.kind for v in rows}


def _done(team: Any, project: Any, task: Task) -> None:
    services.move(
        team.member, team.ws, str(project.pk), str(task.pk), task.version, _status(project, "Done")
    )


def test_a_link_shows_on_both_sides_with_the_matching_kind(team: Any, project: Any) -> None:
    a, b, c, d = (_make(team, project) for _ in range(4))

    _add(team, a, "blocks", b)
    _add(team, c, "relates", a)
    _add(team, d, "duplicates", a)

    assert _kinds(team, a) == {"WEB-2": "blocks", "WEB-3": "relates", "WEB-4": "duplicated_by"}
    assert _kinds(team, b) == {"WEB-1": "blocked_by"}
    assert _kinds(team, d) == {"WEB-1": "duplicates"}
    assert TaskLink.objects.count() == 3


def test_blocked_by_is_the_same_link_seen_from_the_other_end(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)

    _add(team, b, "blocked_by", a)

    assert _kinds(team, a) == {"WEB-2": "blocks"}
    assert TaskLink.objects.get().from_task_id == a.pk


def test_a_task_cannot_link_to_itself(team: Any, project: Any) -> None:
    a = _make(team, project)

    with pytest.raises(ApiError) as refusal:
        _add(team, a, "relates", a)

    assert refusal.value.status == 400


def test_the_same_link_twice_is_refused_even_mirrored_for_relates(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "relates", b)

    for first, second in ((a, b), (b, a)):
        with pytest.raises(ApiError) as refusal:
            _add(team, first, "relates", second)
        assert refusal.value.status == 409
    assert TaskLink.objects.count() == 1


def test_a_blocking_cycle_is_refused_with_the_readable_path(team: Any, project: Any) -> None:
    a, b, c = (_make(team, project) for _ in range(3))
    _add(team, a, "blocks", b)
    _add(team, b, "blocks", c)

    with pytest.raises(ApiError) as refusal:
        _add(team, c, "blocks", a)

    assert refusal.value.title is ResponseTitle.LINK_CYCLE
    assert refusal.value.data == {"path": "WEB-3 → WEB-1 → WEB-2 → WEB-3"}
    assert TaskLink.objects.count() == 2


def test_a_long_chain_is_walked_without_recursion(team: Any, project: Any) -> None:
    chain = [_make(team, project) for _ in range(300)]
    for before, after in zip(chain, chain[1:], strict=False):
        _add(team, before, "blocks", after)

    with pytest.raises(ApiError) as refusal:
        _add(team, chain[-1], "blocks", chain[0])

    assert refusal.value.title is ResponseTitle.LINK_CYCLE


def test_only_blocking_links_can_form_a_cycle(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    _add(team, b, "relates", a)
    _add(team, b, "duplicates", a)

    assert TaskLink.objects.count() == 3


def test_links_cross_projects_inside_a_workspace_but_not_workspaces(
    team: Any, project: Any
) -> None:
    other = team.create(team.owner, "API", name="Api")
    a, b = _make(team, project), _make(team, other)

    _add(team, a, "blocks", b)

    assert _kinds(team, a) == {"API-1": "blocks"}
    with pytest.raises(ApiError) as refusal:
        links.add(team.member, team.other_ws, str(a.pk), str(b.pk), "blocks")
    assert refusal.value.status in (403, 404)


def test_unknown_kind_and_unknown_task_are_refused(team: Any, project: Any) -> None:
    a = _make(team, project)

    with pytest.raises(ApiError):
        links.add(team.member, team.ws, str(a.pk), str(a.pk), "nonsense")
    with pytest.raises(ApiError) as refusal:
        links.add(team.member, team.ws, str(a.pk), "00000000-0000-0000-0000-000000000000", "blocks")
    assert refusal.value.status == 404


def test_remove_deletes_the_link_from_both_sides(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    link = _add(team, a, "blocks", b)

    links.remove(team.member, team.ws, str(link.pk))

    assert _kinds(team, a) == {} and _kinds(team, b) == {}


def test_viewer_may_read_links_but_not_change_them(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    link = _add(team, a, "blocks", b)

    assert _kinds(team, a, team.viewer) == {"WEB-2": "blocks"}
    with pytest.raises(access.PermissionDenied):
        _add(team, b, "relates", a, team.viewer)
    with pytest.raises(access.PermissionDenied):
        links.remove(team.viewer, team.ws, str(link.pk))


def test_a_far_end_the_caller_cannot_see_is_restricted_and_leaks_nothing(
    team: Any, project: Any
) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    open_task = _make(team, project)
    secret = _make(team, secret_project, team.pm, title="Layoffs plan")
    _add(team, open_task, "blocks", secret, team.pm)

    seen = links.list_for_task(team.viewer, team.ws, str(open_task.pk))

    assert [(v.kind, v.other) for v in seen] == [("blocks", None)]
    assert seen[0].other_is_restricted
    assert _kinds(team, open_task, team.pm) == {"SEC-1": "blocks"}


def test_a_cycle_path_never_names_a_restricted_task(team: Any, project: Any) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    a, c = _make(team, project), _make(team, project)
    secret = _make(team, secret_project, team.pm)
    _add(team, a, "blocks", secret, team.pm)
    _add(team, secret, "blocks", c, team.pm)

    with pytest.raises(ApiError) as refusal:
        _add(team, c, "blocks", a, team.member)

    assert refusal.value.title is ResponseTitle.LINK_CYCLE
    assert "SEC" not in (refusal.value.data or {})["path"]
    assert "Restricted task" in (refusal.value.data or {})["path"]


def test_linking_to_an_invisible_task_looks_like_a_missing_task(team: Any, project: Any) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    secret = _make(team, secret_project, team.pm)
    a = _make(team, project)

    with pytest.raises(ApiError) as refusal:
        _add(team, a, "blocks", secret, team.member)

    assert refusal.value.status == 404


def test_blocked_tasks_are_reported_until_the_blocker_is_done(team: Any, project: Any) -> None:
    a, b, c = (_make(team, project) for _ in range(3))
    _add(team, a, "blocks", b)
    _add(team, c, "relates", b)

    assert links.blocked_ids([a, b, c]) == {b.pk}

    _done(team, project, a)

    assert links.blocked_ids([a, b, c]) == set()


def test_a_deleted_blocker_stops_blocking(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    services.delete(team.member, team.ws, str(project.pk), str(a.pk))

    assert links.blocked_ids([b]) == set()


def test_a_blocked_task_cannot_be_completed(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    with pytest.raises(ApiError) as refusal:
        _done(team, project, b)

    assert refusal.value.status == 409
    assert refusal.value.title is ResponseTitle.TASK_BLOCKED
    assert (refusal.value.data or {})["blockers"] == "WEB-1"
    b.refresh_from_db()
    assert b.status.name == "To do"


def test_a_blocked_task_can_still_move_to_a_non_done_status(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    moved = services.move(
        team.member, team.ws, str(project.pk), str(b.pk), b.version, _status(project, "In progress")
    )

    assert moved.status.name == "In progress"


def test_completing_works_once_every_blocker_is_done(team: Any, project: Any) -> None:
    a, b, c = (_make(team, project) for _ in range(3))
    _add(team, a, "blocks", c)
    _add(team, b, "blocks", c)
    _done(team, project, a)

    with pytest.raises(ApiError) as refusal:
        _done(team, project, c)
    assert (refusal.value.data or {})["blockers"] == "WEB-2"

    _done(team, project, b)
    _done(team, project, c)
    c.refresh_from_db()
    assert c.status.name == "Done"


def test_an_admin_can_override_the_guard_and_it_is_recorded(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    done = services.update(
        team.admin,
        team.ws,
        str(project.pk),
        str(b.pk),
        b.version,
        {"status": _status(project, "Done")},
        override_blocked=True,
    )

    assert done.status.name == "Done"
    record = links.BlockOverride.objects.get()
    assert (record.task_id, record.actor_id, record.blockers) == (b.pk, team.admin.pk, "WEB-1")


def test_a_member_without_manage_rights_cannot_override(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    with pytest.raises(ApiError) as refusal:
        services.update(
            team.member,
            team.ws,
            str(project.pk),
            str(b.pk),
            b.version,
            {"status": _status(project, "Done")},
            override_blocked=True,
        )

    assert refusal.value.title is ResponseTitle.TASK_BLOCKED
    assert not links.BlockOverride.objects.exists()


def test_a_duplicates_link_can_close_the_duplicate(team: Any, project: Any) -> None:
    original, duplicate = _make(team, project), _make(team, project)

    _add(team, duplicate, "duplicates", original, close_duplicate=True)

    duplicate.refresh_from_db()
    assert duplicate.status.category == "done"
    original.refresh_from_db()
    assert original.status.category == "not_started"


def test_a_duplicates_link_leaves_the_duplicate_open_by_default(team: Any, project: Any) -> None:
    original, duplicate = _make(team, project), _make(team, project)

    _add(team, duplicate, "duplicates", original)

    duplicate.refresh_from_db()
    assert duplicate.status.category == "not_started"


def test_links_are_refused_in_an_archived_project(team: Any, project: Any) -> None:
    from infrastructure.projects import services as projects

    a, b = _make(team, project), _make(team, project)
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError) as refusal:
        _add(team, a, "blocks", b)

    assert refusal.value.title is ResponseTitle.PROJECT_ARCHIVED


def test_a_deleted_task_in_the_middle_does_not_make_a_loop(team: Any, project: Any) -> None:
    a, b, c = (_make(team, project) for _ in range(3))
    _add(team, a, "blocks", b)
    _add(team, b, "blocks", c)
    services.delete(team.member, team.ws, str(project.pk), str(b.pk))

    _add(team, c, "blocks", a)

    assert TaskLink.objects.count() == 3


def test_soft_delete_keeps_the_links_and_restore_brings_them_back(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    services.delete(team.member, team.ws, str(project.pk), str(b.pk))
    assert _kinds(team, a) == {}
    assert TaskLink.objects.count() == 1

    services.restore(team.member, team.ws, str(project.pk), str(b.pk))
    assert _kinds(team, a) == {"WEB-2": "blocks"}


def test_closing_a_duplicate_uses_cancelled_when_the_project_has_it(
    team: Any, project: Any
) -> None:
    from infrastructure.workflows.models import Category, Status

    _status(project, "Done")
    Status.objects.create(project=project, name="Won't do", category=Category.CANCELLED, position=9)
    original, duplicate = _make(team, project), _make(team, project)

    _add(team, duplicate, "duplicates", original, close_duplicate=True)

    duplicate.refresh_from_db()
    assert duplicate.status.name == "Won't do"


def test_closing_an_already_finished_duplicate_changes_nothing(team: Any, project: Any) -> None:
    original, duplicate = _make(team, project), _make(team, project)
    _done(team, project, duplicate)
    duplicate.refresh_from_db()

    _add(team, duplicate, "duplicates", original, close_duplicate=True)

    after = Task.objects.get(pk=duplicate.pk)
    assert after.version == duplicate.version


def test_close_duplicate_is_refused_for_other_kinds(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)

    with pytest.raises(ApiError):
        _add(team, a, "blocks", b, close_duplicate=True)


def test_a_blocker_in_a_private_project_is_restricted_in_the_refusal(
    team: Any, project: Any
) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    secret = _make(team, secret_project, team.pm, title="Layoffs plan")
    task = _make(team, project)
    _add(team, secret, "blocks", task, team.pm)

    with pytest.raises(ApiError) as refusal:
        _done(team, project, task)

    assert (refusal.value.data or {})["blockers"] == "Restricted task"
    assert "SEC" not in str(refusal.value) and "Layoffs" not in str(refusal.value)


def test_the_override_record_keeps_the_real_blockers(team: Any, project: Any) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    secret = _make(team, secret_project, team.pm)
    task = _make(team, project)
    _add(team, secret, "blocks", task, team.pm)

    services.update(
        team.admin,
        team.ws,
        str(project.pk),
        str(task.pk),
        task.version,
        {"status": _status(project, "Done")},
        override_blocked=True,
    )

    assert links.BlockOverride.objects.get().blockers == "SEC-1"


def test_a_link_into_an_archived_project_is_refused(team: Any, project: Any) -> None:
    from infrastructure.projects import services as projects

    other = team.create(team.owner, "OPS", name="Ops")
    a, b = _make(team, project), _make(team, other)
    projects.archive(team.owner, team.ws, str(other.pk), other.version)

    with pytest.raises(ApiError) as refusal:
        _add(team, a, "blocks", b)

    assert refusal.value.title is ResponseTitle.PROJECT_ARCHIVED


def test_a_blocking_link_takes_the_workspace_lock_before_checking_for_loops(
    team: Any, project: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    taken: list[Any] = []
    real = access.lock

    def spy(ws: Any) -> None:
        taken.append(ws)
        real(ws)

    monkeypatch.setattr(access, "lock", spy)
    a, b = _make(team, project), _make(team, project)

    _add(team, a, "relates", b)
    assert taken == []
    _add(team, a, "blocks", b)

    assert taken == [team.ws]


def test_blocked_tasks_carry_the_names_of_their_open_blockers(team: Any, project: Any) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    open_blocker, task = _make(team, project), _make(team, project)
    hidden = _make(team, secret_project, team.pm)
    _add(team, open_blocker, "blocks", task)
    _add(team, hidden, "blocks", task, team.pm)

    seen = services.get(team.member, team.ws, str(project.pk), str(task.pk))
    owner_sees = services.get(team.owner, team.ws, str(project.pk), str(task.pk))

    assert seen.is_blocked and sorted(seen.blockers) == ["Restricted task", "WEB-1 (To do)"]
    assert sorted(owner_sees.blockers) == ["Restricted task", "WEB-1 (To do)"]
    assert services.get(team.member, team.ws, str(project.pk), str(open_blocker.pk)).blockers == ()


def test_the_trash_list_marks_blocked_tasks(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)
    services.delete(team.member, team.ws, str(project.pk), str(b.pk))

    trashed = services.list_trash(team.owner, team.ws, str(project.pk))

    assert [(t.display_id, t.is_blocked) for t in trashed] == [("WEB-2", True)]


def test_the_refusal_says_whether_the_caller_may_override(team: Any, project: Any) -> None:
    a, b = _make(team, project), _make(team, project)
    _add(team, a, "blocks", b)

    def refused(actor: Any) -> dict[str, str]:
        with pytest.raises(ApiError) as refusal:
            services.update(
                actor,
                team.ws,
                str(project.pk),
                str(b.pk),
                b.version,
                {"status": _status(project, "Done")},
            )
        return refusal.value.data or {}

    assert refused(team.member)["can_override"] == "false"
    assert refused(team.admin)["can_override"] == "true"


def test_adding_and_removing_a_link_announces_both_tasks(
    team: Any, project: Any, _commit_hooks_run_now: Any
) -> None:
    from infrastructure.tasks.signals import task_changed

    a, b = _make(team, project), _make(team, project)
    heard: list[tuple[str, str]] = []

    def listen(sender: Any, task_id: str, action: str, **_: Any) -> None:
        heard.append((task_id, action))

    task_changed.connect(listen)
    try:
        link = _add(team, a, "blocks", b)
        links.remove(team.member, team.ws, str(link.pk))
    finally:
        task_changed.disconnect(listen)

    assert sorted(heard) == sorted(
        [(str(a.pk), "linked"), (str(b.pk), "linked")]
        + [(str(a.pk), "unlinked"), (str(b.pk), "unlinked")]
    )


def test_search_finds_tasks_across_projects_by_title_or_display_id(team: Any, project: Any) -> None:
    other = team.create(team.owner, "OPS", name="Ops")
    _make(team, project, title="Fix login")
    ops = _make(team, other, title="Rotate keys")

    by_title = links.search_tasks(team.member, team.ws, "login")
    by_id = links.search_tasks(team.member, team.ws, "ops-1")
    everything = links.search_tasks(team.member, team.ws, "")

    assert [t.title for t in by_title] == ["Fix login"]
    assert [t.pk for t in by_id] == [ops.pk]
    assert len(everything) == 2


def test_search_never_returns_a_task_from_a_project_the_caller_cannot_open(
    team: Any, project: Any
) -> None:
    secret_project = team.create(team.pm, "SEC", visibility="private", name="Secret")
    _make(team, secret_project, team.pm, title="Layoffs plan")
    _make(team, project, title="Layoffs FAQ")

    seen = [t.title for t in links.search_tasks(team.viewer, team.ws, "layoffs")]
    creator_sees = [t.title for t in links.search_tasks(team.pm, team.ws, "layoffs")]

    assert seen == ["Layoffs FAQ"]
    assert sorted(creator_sees) == ["Layoffs FAQ", "Layoffs plan"]
