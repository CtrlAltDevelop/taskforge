"""The timeline on the service: the chart's read, the critical path, and shifting with cascade."""

from datetime import date
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import links, services, timeline
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db

D = "2026-11-{:02d}"


def _make(team: Any, project: Any, title: str, start: int = 0, due: int = 0, **kw: Any) -> Any:
    return services.create(
        team.owner,
        team.ws,
        str(project.pk),
        title,
        start_date=D.format(start) if start else "",
        due_date=D.format(due) if due else "",
        **kw,
    )


def _block(team: Any, blocker: Any, dependent: Any) -> None:
    links.add(team.owner, team.ws, str(blocker.pk), str(dependent.pk), "blocks")


def _dates(task_id: Any) -> tuple[str, str]:
    t = Task.objects.get(pk=task_id)
    return (
        t.start_date.isoformat() if t.start_date else "",
        t.due_date.isoformat() if t.due_date else "",
    )


def _read(team: Any, project: Any, first: str, last: str, **kw: Any) -> tuple[list[Any], list[Any]]:
    tasks: list[Any] = []
    pairs: list[Any] = []
    for chunk, chunk_links in timeline.iter_chunks(
        team.viewer, team.ws, str(project.pk), first, last, **kw
    ):
        tasks += chunk
        pairs += chunk_links
    return tasks, pairs


# --- the chart's read ------------------------------------------------------------------------


def test_the_read_lists_tasks_in_range_with_the_blocking_links_between_them(
    team: Any, project: Any
) -> None:
    a = _make(team, project, "a", 2, 4)
    b = _make(team, project, "b", 5, 6)
    _make(team, project, "later", 1, 28)
    _block(team, a, b)

    tasks, pairs = _read(team, project, "2026-11-01", "2026-11-10")

    assert {t.title for t in tasks} == {"a", "b", "later"}
    assert pairs == [(str(a.pk), str(b.pk))]


def test_a_link_is_listed_once_even_when_both_ends_are_in_the_range(
    team: Any, project: Any
) -> None:
    a, b = _make(team, project, "a", 2, 3), _make(team, project, "b", 4, 5)
    _block(team, a, b)

    assert len(_read(team, project, "2026-11-01", "2026-11-30")[1]) == 1


def test_a_link_to_a_task_outside_the_range_is_still_listed(team: Any, project: Any) -> None:
    a, far = _make(team, project, "a", 2, 3), _make(team, project, "far", 20, 21)
    _block(team, a, far)

    assert _read(team, project, "2026-11-01", "2026-11-05")[1] == [(str(a.pk), str(far.pk))]


def test_the_range_may_span_a_year_but_not_much_more(team: Any, project: Any) -> None:
    _read(team, project, "2026-01-01", "2026-12-31")
    with pytest.raises(ApiError):
        _read(team, project, "2020-01-01", "2026-12-31")


def test_a_link_to_a_task_in_a_hidden_project_is_not_listed(team: Any, project: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    a = _make(team, project, "a", 2, 3)
    other = services.create(team.pm, team.ws, str(secret.pk), "s", due_date=D.format(4))
    links.add(team.pm, team.ws, str(a.pk), str(other.pk), "blocks")

    assert all(
        str(other.pk) not in pair for pair in _read(team, project, "2026-11-01", "2026-11-30")[1]
    )


# --- critical path ---------------------------------------------------------------------------


def test_the_critical_path_is_the_longest_chain_of_open_tasks(team: Any, project: Any) -> None:
    a, b, c = (
        _make(team, project, "a", 2, 3),
        _make(team, project, "b", 4, 4),
        _make(team, project, "c", 5, 9),
    )
    _block(team, a, b)
    _block(team, a, c)

    ids = timeline.critical_path(team.viewer, team.ws, str(project.pk))

    assert ids == [str(a.pk), str(c.pk)]


def test_finished_tasks_are_not_on_the_critical_path(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 3), _make(team, project, "b", 4, 5)
    _block(team, a, b)
    workflows.ensure(project)
    done = Status.objects.get(project=project, name="Done")
    services.update(
        team.owner, team.ws, str(project.pk), str(a.pk), a.version, {"status": str(done.pk)}
    )

    assert timeline.critical_path(team.viewer, team.ws, str(project.pk)) == []


# --- shifting --------------------------------------------------------------------------------


def test_preview_lists_the_dependents_a_move_would_push(team: Any, project: Any) -> None:
    a, b, c = (
        _make(team, project, "a", 2, 4),
        _make(team, project, "b", 5, 6),
        _make(team, project, "c", 7, 8),
    )
    _block(team, a, b)
    _block(team, b, c)

    shifts = timeline.preview_shift(
        team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
    )

    assert [(s.task.title, s.new.start, s.new.due) for s in shifts] == [
        ("b", date(2026, 11, 11), date(2026, 11, 12)),
        ("c", date(2026, 11, 13), date(2026, 11, 14)),
    ]
    assert _dates(b.pk) == (D.format(5), D.format(6))  # a preview changes nothing


def test_preview_skips_weekends_with_the_workspace_calendar(team: Any, project: Any) -> None:
    timeline.set_working_days(team.owner, team.ws, [0, 1, 2, 3, 4], [])
    a, b = _make(team, project, "a", 2, 3), _make(team, project, "b", 4, 5)
    _block(team, a, b)

    shifts = timeline.preview_shift(
        team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(6)
    )

    assert [(s.new.start, s.new.due) for s in shifts] == [(date(2026, 11, 9), date(2026, 11, 10))]


def test_moving_earlier_or_clear_of_the_dependents_pushes_nothing(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 9, 10)
    _block(team, a, b)

    assert (
        timeline.preview_shift(
            team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(6)
        )
        == []
    )


def test_finished_dependents_stay_where_they_are(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 5, 6)
    workflows.ensure(project)
    done = Status.objects.get(project=project, name="Done")
    services.update(
        team.owner, team.ws, str(project.pk), str(b.pk), b.version, {"status": str(done.pk)}
    )
    _block(team, a, b)

    assert (
        timeline.preview_shift(
            team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
        )
        == []
    )


def test_apply_moves_the_task_and_its_dependents_together(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 5, 6)
    _block(team, a, b)
    seen = [
        s.task.pk
        for s in timeline.preview_shift(
            team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
        )
    ]

    moved = timeline.apply_shift(
        team.owner,
        team.ws,
        str(project.pk),
        str(a.pk),
        a.version,
        D.format(2),
        D.format(10),
        [str(i) for i in seen],
    )

    assert [t.title for t in moved] == ["a", "b"]
    assert _dates(a.pk) == (D.format(2), D.format(10)) and _dates(b.pk) == (
        D.format(11),
        D.format(12),
    )


def test_apply_refuses_when_the_cascade_is_not_what_was_previewed(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 5, 6)
    _block(team, a, b)

    with pytest.raises(ApiError):
        timeline.apply_shift(
            team.owner,
            team.ws,
            str(project.pk),
            str(a.pk),
            a.version,
            D.format(2),
            D.format(10),
            [],
        )

    assert _dates(a.pk) == (D.format(2), D.format(4))  # nothing moved


def test_apply_is_all_or_nothing(team: Any, project: Any) -> None:
    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 5, 6)
    _block(team, a, b)

    with pytest.raises(ApiError):  # a stale version of the task itself
        timeline.apply_shift(
            team.owner,
            team.ws,
            str(project.pk),
            str(a.pk),
            99,
            D.format(2),
            D.format(10),
            [str(b.pk)],
        )

    assert _dates(a.pk) == (D.format(2), D.format(4)) and _dates(b.pk) == (D.format(5), D.format(6))


def test_a_viewer_cannot_apply_and_an_outsider_cannot_preview(team: Any, project: Any) -> None:
    a = _make(team, project, "a", 2, 4)
    with pytest.raises(ApiError):
        timeline.apply_shift(
            team.viewer,
            team.ws,
            str(project.pk),
            str(a.pk),
            a.version,
            D.format(2),
            D.format(10),
            [],
        )
    with pytest.raises(ApiError):
        timeline.preview_shift(
            team.outsider, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
        )


def test_a_bar_must_end_after_it_starts(team: Any, project: Any) -> None:
    a = _make(team, project, "a", 2, 4)
    with pytest.raises(ApiError):
        timeline.preview_shift(
            team.owner, team.ws, str(project.pk), str(a.pk), D.format(9), D.format(5)
        )
    with pytest.raises(ApiError):
        timeline.preview_shift(team.owner, team.ws, str(project.pk), str(a.pk), "", "")


def test_a_task_of_another_workspace_is_not_found(team: Any, project: Any) -> None:
    a = _make(team, project, "a", 2, 4)
    with pytest.raises(ApiError):
        timeline.preview_shift(
            team.outsider, team.other_ws, str(project.pk), str(a.pk), D.format(2), D.format(9)
        )


def test_a_cascade_announces_every_moved_task_only_once_it_is_committed(
    team: Any, project: Any, django_capture_on_commit_callbacks: Any
) -> None:
    from infrastructure.tasks.signals import task_changed

    a, b = _make(team, project, "a", 2, 4), _make(team, project, "b", 5, 6)
    _block(team, a, b)
    heard: list[str] = []

    def listen(sender: Any, **kw: Any) -> None:
        heard.append(str(kw["task_id"]))

    task_changed.connect(listen)
    try:
        with django_capture_on_commit_callbacks(execute=True), pytest.raises(ApiError):
            timeline.apply_shift(  # a stale version: rolled back
                team.owner, team.ws, str(project.pk), str(a.pk), 99,
                D.format(2), D.format(10), [str(b.pk)],
            )  # fmt: skip
        assert heard == []
        with django_capture_on_commit_callbacks(execute=True):
            timeline.apply_shift(
                team.owner, team.ws, str(project.pk), str(a.pk), a.version,
                D.format(2), D.format(10), [str(b.pk)],
            )  # fmt: skip
        assert sorted(heard) == sorted([str(a.pk), str(b.pk)])
    finally:
        task_changed.disconnect(listen)


def test_dependents_in_an_archived_project_are_not_pushed(team: Any, project: Any) -> None:
    from infrastructure.projects import services as projects

    old = team.create(team.owner, "OLD")
    a = _make(team, project, "a", 2, 4)
    b = services.create(
        team.owner, team.ws, str(old.pk), "b", start_date=D.format(5), due_date=D.format(6)
    )
    _block(team, a, b)
    projects.archive(team.owner, team.ws, str(old.pk), old.version)

    shifts = timeline.preview_shift(
        team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
    )

    assert shifts == []


def test_a_dependent_in_a_project_the_actor_cannot_open_is_neither_listed_nor_moved(
    team: Any, project: Any
) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    a = _make(team, project, "a", 2, 4)
    hidden = services.create(
        team.pm, team.ws, str(secret.pk), "h", start_date=D.format(5), due_date=D.format(6)
    )
    links.add(team.pm, team.ws, str(a.pk), str(hidden.pk), "blocks")

    shifts = timeline.preview_shift(
        team.member, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
    )
    timeline.apply_shift(
        team.member, team.ws, str(project.pk), str(a.pk), a.version, D.format(2), D.format(10), []
    )

    assert shifts == []
    assert _dates(hidden.pk) == (D.format(5), D.format(6))


def test_a_pushed_dependent_comes_back_as_a_client_shows_it(team: Any, project: Any) -> None:
    a = _make(team, project, "a", 2, 4)
    b = _make(team, project, "b", 5, 6, assignee_ids=[str(team.member.pk)])
    _block(team, a, b)

    [shift] = timeline.preview_shift(
        team.owner, team.ws, str(project.pk), str(a.pk), D.format(2), D.format(10)
    )

    assert shift.task.is_blocked is True
    assert [str(i) for i in shift.task.assignee_ids()] == [str(team.member.pk)]
