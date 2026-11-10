"""The calendar range query and the unscheduled tray, on the service."""

from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import calendar, services
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, title: str, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _range(team: Any, project: Any, first: str, last: str, **kw: Any) -> list[str]:
    tasks = calendar.list_range(team.viewer, team.ws, str(project.pk), first, last, **kw)
    return [t.title for t in tasks]


def test_a_task_shows_on_its_due_day_and_on_its_start_day(team: Any, project: Any) -> None:
    _make(team, project, "due", due_date="2026-11-05")
    _make(team, project, "start", start_date="2026-11-07")
    _make(team, project, "elsewhere", due_date="2026-12-01")

    assert _range(team, project, "2026-11-01", "2026-11-30") == ["due", "start"]


def test_a_bar_shows_on_every_range_it_touches(team: Any, project: Any) -> None:
    _make(team, project, "bar", start_date="2026-10-28", due_date="2026-11-10")

    assert _range(team, project, "2026-11-02", "2026-11-03") == ["bar"]  # inside the bar
    assert _range(team, project, "2026-10-01", "2026-10-28") == ["bar"]  # touches its start
    assert _range(team, project, "2026-11-10", "2026-11-20") == ["bar"]  # touches its end
    assert _range(team, project, "2026-11-11", "2026-11-20") == []


def test_the_first_and_the_last_day_are_inside_the_range(team: Any, project: Any) -> None:
    _make(team, project, "first", due_date="2026-11-01")
    _make(team, project, "last", due_date="2026-11-30")
    _make(team, project, "after", due_date="2026-12-01")

    assert _range(team, project, "2026-11-01", "2026-11-30") == ["first", "last"]


def test_deleted_tasks_are_left_out_and_subtasks_are_in(team: Any, project: Any) -> None:
    parent = _make(team, project, "parent")
    _make(team, project, "child", parent_id=str(parent.pk), due_date="2026-11-05")
    gone = _make(team, project, "gone", due_date="2026-11-05")
    services.delete(team.owner, team.ws, str(project.pk), str(gone.pk))

    assert _range(team, project, "2026-11-01", "2026-11-30") == ["child"]


def test_finished_tasks_can_be_hidden(team: Any, project: Any) -> None:
    workflows.ensure(project)
    done = Status.objects.get(project=project, name="Done")
    _make(team, project, "open", due_date="2026-11-05")
    _make(team, project, "closed", due_date="2026-11-05", status=str(done.pk))

    assert _range(team, project, "2026-11-01", "2026-11-30", include_done=False) == ["open"]
    assert len(_range(team, project, "2026-11-01", "2026-11-30")) == 2


@pytest.mark.parametrize(
    ("first", "last"),
    [
        ("nope", "2026-11-01"),
        ("2026-11-01", "11/05"),
        ("2026-11-05", "2026-11-01"),
        ("2026-01-01", "2026-12-31"),
    ],
)
def test_a_bad_range_is_refused(team: Any, project: Any, first: str, last: str) -> None:
    with pytest.raises(ApiError):
        calendar.list_range(team.viewer, team.ws, str(project.pk), first, last)


def test_a_date_stays_the_same_date(team: Any, project: Any) -> None:
    task = _make(team, project, "t", due_date="2026-11-05")

    [shown] = calendar.list_range(team.viewer, team.ws, str(project.pk), "2026-11-05", "2026-11-05")

    assert shown.pk == task.pk and shown.due_date.isoformat() == "2026-11-05"


def test_moving_a_bar_keeps_it_on_the_calendar(team: Any, project: Any) -> None:
    task = _make(team, project, "t", start_date="2026-11-02", due_date="2026-11-04")

    services.update(
        team.member,
        team.ws,
        str(project.pk),
        str(task.pk),
        1,
        {"start_date": "2026-12-02", "due_date": "2026-12-04"},
    )

    assert _range(team, project, "2026-11-01", "2026-11-30") == []
    assert _range(team, project, "2026-12-01", "2026-12-31") == ["t"]


def test_the_tray_holds_open_tasks_without_dates_in_pages(team: Any, project: Any) -> None:
    for n in range(5):
        _make(team, project, f"t{n}")
    _make(team, project, "dated", due_date="2026-11-05")

    first, cursor = calendar.list_unscheduled(team.viewer, team.ws, str(project.pk), limit=2)
    second, cursor2 = calendar.list_unscheduled(
        team.viewer, team.ws, str(project.pk), cursor, limit=2
    )
    last, end = calendar.list_unscheduled(team.viewer, team.ws, str(project.pk), cursor2, limit=2)

    assert [t.title for t in first + second + last] == ["t0", "t1", "t2", "t3", "t4"]
    assert cursor and cursor2 and end == ""


def test_the_tray_leaves_finished_tasks_out(team: Any, project: Any) -> None:
    workflows.ensure(project)
    done = Status.objects.get(project=project, name="Done")
    _make(team, project, "open")
    _make(team, project, "closed", status=str(done.pk))

    tray, _ = calendar.list_unscheduled(team.viewer, team.ws, str(project.pk))

    assert [t.title for t in tray] == ["open"]


def test_a_bad_tray_cursor_is_refused(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        calendar.list_unscheduled(team.viewer, team.ws, str(project.pk), "x")


def test_strangers_and_foreign_projects_see_nothing(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    _make(team, project, "t", due_date="2026-11-05")

    with pytest.raises(ApiError):
        calendar.list_range(team.outsider, team.ws, str(project.pk), "2026-11-01", "2026-11-30")
    with pytest.raises(ApiError):
        calendar.list_unscheduled(team.outsider, team.ws, str(project.pk))
    assert (
        calendar.list_range(team.viewer, team.ws, str(other.pk), "2026-11-01", "2026-11-30") == []
    )


def test_a_range_is_never_cut_and_never_repeats_across_chunks(
    team: Any, project: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(calendar, "CHUNK", 3)
    for n in range(10):
        _make(team, project, f"t{n}", due_date="2026-11-05")

    chunks = list(
        calendar.iter_range(team.viewer, team.ws, str(project.pk), "2026-11-01", "2026-11-30")
    )

    assert [len(c) for c in chunks] == [3, 3, 3, 1]
    assert [t.title for c in chunks for t in c] == [f"t{n}" for n in range(10)]


def test_a_task_carries_the_due_dates_of_what_it_is_linked_to(team: Any, project: Any) -> None:
    from infrastructure.tasks import links

    blocker = _make(team, project, "blocker", due_date="2026-11-10")
    other = _make(team, project, "other blocker", due_date="2026-11-20")
    blocked = _make(team, project, "blocked", due_date="2026-11-15")
    for first in (blocker, other):
        links.add(team.owner, team.ws, str(first.pk), str(blocked.pk), "blocks")

    tasks = {
        t.title: t
        for t in calendar.list_range(
            team.viewer, team.ws, str(project.pk), "2026-11-01", "2026-11-30"
        )
    }

    assert tasks["blocked"].blockers_due == "2026-11-20"
    assert tasks["blocked"].blocks_due == ""
    assert tasks["blocker"].blocks_due == "2026-11-15"
    assert tasks["blocker"].blockers_due == ""


def _workspace(team: Any, **kw: Any) -> list[str]:
    tasks = [
        t
        for chunk in calendar.iter_workspace_range(
            team.member, team.ws, "2026-11-01", "2026-11-30", **kw
        )
        for t in chunk
    ]
    return sorted(t.title for t in tasks)


def test_the_workspace_calendar_spans_every_visible_project(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    _make(team, project, "web", due_date="2026-11-05")
    services.create(team.owner, team.ws, str(other.pk), "api", due_date="2026-11-06")
    _make(team, project, "later", due_date="2026-12-20")

    assert _workspace(team) == ["api", "web"]


def test_private_and_archived_projects_stay_out(team: Any, project: Any) -> None:
    from infrastructure.projects import services as projects

    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")
    old = team.create(team.owner, "OLD", name="Old")
    _make(team, project, "web", due_date="2026-11-05")
    services.create(team.owner, team.ws, str(hidden.pk), "secret", due_date="2026-11-05")
    services.create(team.owner, team.ws, str(old.pk), "old", due_date="2026-11-05")
    projects.archive(team.owner, team.ws, str(old.pk), old.version)

    assert _workspace(team) == ["web"]
    seen_by_owner = [
        t.title
        for chunk in calendar.iter_workspace_range(team.owner, team.ws, "2026-11-01", "2026-11-30")
        for t in chunk
    ]
    assert "secret" in seen_by_owner and "old" not in seen_by_owner


def test_project_ids_narrow_it_and_foreign_ids_are_ignored(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")
    _make(team, project, "web", due_date="2026-11-05")
    services.create(team.owner, team.ws, str(other.pk), "api", due_date="2026-11-05")
    services.create(team.owner, team.ws, str(hidden.pk), "secret", due_date="2026-11-05")

    assert _workspace(team, project_ids=[str(other.pk)]) == ["api"]
    assert _workspace(team, project_ids=[str(hidden.pk)]) == []  # not the caller's to see
    assert _workspace(team, project_ids=["nope"]) == []


def test_the_workspace_range_pages_without_repeats_and_is_refused_to_strangers(
    team: Any, project: Any, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(calendar, "CHUNK", 3)
    other = team.create(team.owner, "API", name="Api")
    for n in range(4):
        _make(team, project, f"w{n}", due_date="2026-11-05")
        services.create(team.owner, team.ws, str(other.pk), f"a{n}", due_date="2026-11-05")

    titles = _workspace(team)

    assert titles == sorted([f"w{n}" for n in range(4)] + [f"a{n}" for n in range(4)])
    with pytest.raises(ApiError):
        list(calendar.iter_workspace_range(team.outsider, team.ws, "2026-11-01", "2026-11-30"))
    with pytest.raises(ApiError):
        list(calendar.iter_workspace_range(team.member, team.ws, "2026-11-30", "2026-11-01"))


def test_another_workspace_never_leaks_in_even_for_a_member_of_both(
    team: Any, project: Any
) -> None:
    from infrastructure.workspaces import services as workspace_services

    _make(team, project, "here", due_date="2026-11-05")
    there = workspace_services.create(team.member, "Elsewhere", "elsewhere")
    theirs = team.create(team.member, "OTH", name="Other")  # a project of this workspace
    away = workspace_services.create(team.owner, "Away", "away")
    away_project = (
        __import__("infrastructure.projects.services", fromlist=["create"])
        .create(team.owner, away, "Away", "AWY")
        .project
    )
    services.create(team.owner, away, str(away_project.pk), "away task", due_date="2026-11-05")

    here_only = _workspace(team)
    narrowed = _workspace(team, project_ids=[str(away_project.pk)])

    assert here_only == ["here"]
    assert narrowed == []
    assert there and theirs
