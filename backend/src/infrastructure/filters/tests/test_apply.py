"""A filter applied to the list, the group counts, the board and the calendar."""

import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue
from infrastructure.tasks import board, calendar, services

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, title: str, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _ast(project: Any, text: str) -> str:
    return json.dumps(language.parse_text(text, Catalogue(project)))


def _list(team: Any, project: Any, text: str, **kw: Any) -> list[str]:
    page, _ = services.list_page(
        team.member, team.ws, str(project.pk), filter_ast=_ast(project, text), limit=500, **kw
    )
    return [t.title for t in page]


@pytest.fixture
def seeded(team: Any, project: Any) -> Any:
    _make(team, project, "urgent mine", priority="urgent", assignee_ids=[str(team.member.pk)])
    _make(team, project, "low mine", priority="low", assignee_ids=[str(team.member.pk)])
    _make(team, project, "high other", priority="high")
    return project


def test_the_list_is_narrowed(team: Any, seeded: Any) -> None:
    assert _list(team, seeded, "priority = urgent") == ["urgent mine"]
    assert sorted(_list(team, seeded, "assignee = me")) == ["low mine", "urgent mine"]
    assert _list(team, seeded, "assignee = me AND priority != low") == ["urgent mine"]
    assert _list(team, seeded, "") == ["urgent mine", "low mine", "high other"]


def test_order_by_in_the_filter_orders_the_list_unless_a_sort_is_given(
    team: Any, seeded: Any
) -> None:
    assert _list(team, seeded, "ORDER BY priority") == ["urgent mine", "high other", "low mine"]
    assert _list(team, seeded, "ORDER BY priority DESC") == [
        "low mine",
        "high other",
        "urgent mine",
    ]
    assert _list(team, seeded, "ORDER BY priority", sort=[("title", False)]) == [
        "high other", "low mine", "urgent mine"
    ]  # fmt: skip


def test_a_filtered_list_pages_without_gaps(team: Any, seeded: Any) -> None:
    for n in range(5):
        _make(team, seeded, f"extra {n}", priority="low")
    ast = _ast(seeded, "priority = low ORDER BY title")
    titles: list[str] = []
    cursor = ""
    while True:
        page, cursor = services.list_page(
            team.member, team.ws, str(seeded.pk), filter_ast=ast, cursor=cursor, limit=2
        )
        titles += [t.title for t in page]
        if not cursor:
            break

    assert titles == sorted(titles) and len(titles) == 6


def test_group_counts_follow_the_filter(team: Any, seeded: Any) -> None:
    counts = services.group_counts(
        team.member, team.ws, str(seeded.pk), "priority", filter_ast=_ast(seeded, "assignee = me")
    )

    assert dict(counts) == {"urgent": 1, "low": 1}


def test_the_board_follows_the_filter(team: Any, seeded: Any) -> None:
    ast = _ast(seeded, "priority in (urgent, high)")

    [lane] = board.get(team.member, team.ws, str(seeded.pk), filter_ast=ast)

    assert sum(c.count for c in lane.columns) == 2
    todo = next(c for c in lane.columns if c.count)
    page, _ = board.list_column(
        team.member, team.ws, str(seeded.pk), group_by="status", column=todo.key, filter_ast=ast
    )
    assert sorted(t.title for t in page) == ["high other", "urgent mine"]


def test_the_calendar_follows_the_filter(team: Any, project: Any) -> None:
    _make(team, project, "a", due_date="2026-11-05", priority="high")
    _make(team, project, "b", due_date="2026-11-06")
    ast = _ast(project, "priority = high")

    found = calendar.list_range(
        team.viewer, team.ws, str(project.pk), "2026-11-01", "2026-11-30", filter_ast=ast
    )

    assert [t.title for t in found] == ["a"]


def test_relative_dates_count_from_the_day_the_client_sends(team: Any, project: Any) -> None:
    _make(team, project, "soon", due_date="2026-11-14")
    _make(team, project, "later", due_date="2026-12-30")
    ast = _ast(project, "due <= +7d")

    def run(today: str) -> list[str]:
        page, _ = services.list_page(
            team.member, team.ws, str(project.pk), filter_ast=ast, today=today
        )
        return [t.title for t in page]

    assert run("2026-11-10") == ["soon"]
    assert run("2026-12-25") == ["soon", "later"]
    with pytest.raises(ApiError):
        run("yesterday")


def test_a_bad_filter_is_refused_with_where_it_is_wrong(team: Any, project: Any) -> None:
    bad = {"where": {"op": "cmp", "field": "nope", "cmp": "eq", "values": []}, "order": []}

    for raw in (json.dumps(bad), "not json", json.dumps([1, 2])):
        with pytest.raises(ApiError) as caught:
            services.list_page(team.member, team.ws, str(project.pk), filter_ast=raw)
        assert caught.value.title is ResponseTitle.FILTER_INVALID


def test_a_filter_never_reaches_beyond_what_the_caller_may_see(team: Any, project: Any) -> None:
    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")
    _make(team, project, "visible", priority="high")
    services.create(team.owner, team.ws, str(hidden.pk), "secret", priority="high")
    ast = _ast(project, "priority = high")

    with pytest.raises(ApiError):  # a stranger to the private project cannot even ask
        services.list_page(team.member, team.ws, str(hidden.pk), filter_ast=ast)
    page, _ = services.list_page(team.member, team.ws, str(project.pk), filter_ast=ast)
    assert [t.title for t in page] == ["visible"]


def test_a_filter_from_another_project_does_not_apply(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    from infrastructure.workflows import services as workflows

    workflows.ensure(other)
    foreign = _ast(other, "status = Done")

    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), filter_ast=foreign)


def test_a_filter_is_cheap(team: Any, seeded: Any, django_assert_max_num_queries: Any) -> None:
    ast = _ast(seeded, "assignee = me AND priority != low ORDER BY due")

    with django_assert_max_num_queries(14):
        services.list_page(team.member, team.ws, str(seeded.pk), filter_ast=ast)


def test_a_filtered_read_that_runs_out_of_time_asks_for_a_narrower_filter() -> None:
    from django.db import OperationalError
    from django.db.models import Q

    from infrastructure.filters import query

    def too_slow() -> None:
        raise OperationalError("canceling statement due to statement timeout")

    with pytest.raises(ApiError) as slow:
        query.guarded(too_slow, Q(pk=1))
    assert slow.value.title is ResponseTitle.FILTER_INVALID

    with pytest.raises(OperationalError):  # other database errors are not hidden
        query.guarded(lambda: (_ for _ in ()).throw(OperationalError("disk full")), Q(pk=1))
    assert query.guarded(lambda: 7, Q()) == 7  # no filter, no guard


def test_a_filtered_ten_thousand_task_project_stays_fast(
    team: Any, project: Any, django_assert_max_num_queries: Any
) -> None:
    import time

    from infrastructure.tasks.tests.test_scale import _seed

    _seed(team, project)
    ast = _ast(project, 'priority = none AND due IS EMPTY AND title ~ "Task 99" ORDER BY id')

    started = time.monotonic()
    with django_assert_max_num_queries(14):
        page, _ = services.list_page(team.viewer, team.ws, str(project.pk), filter_ast=ast)
    assert time.monotonic() - started < 1.0
    assert page and all("Task 99" in t.title for t in page)


def test_a_filter_that_nests_absurdly_is_a_filter_error_not_a_crash(
    team: Any, project: Any
) -> None:
    for raw in ("[" * 100_000, '{"where": ' * 5000):
        with pytest.raises(ApiError) as caught:
            services.list_page(team.member, team.ws, str(project.pk), filter_ast=raw)
        assert caught.value.title is ResponseTitle.FILTER_INVALID


def test_a_huge_relative_date_in_a_client_ast_is_refused(team: Any, project: Any) -> None:
    ast = {
        "where": {
            "op": "cmp",
            "field": "due",
            "cmp": "lt",
            "values": [{"k": "rel", "n": 10**9, "u": "y"}],
        },
        "order": [],
    }

    with pytest.raises(ApiError):
        services.list_page(team.member, team.ws, str(project.pk), filter_ast=json.dumps(ast))


def _workspace_titles(team: Any, text: str, who: Any = None) -> list[str]:
    from infrastructure.filters import language as lang
    from infrastructure.tasks import calendar as cal

    ast = json.dumps(lang.parse_text(text, Catalogue(None, team.ws)))
    return sorted(
        t.title
        for chunk in cal.iter_workspace_range(
            who or team.member,
            team.ws,
            "2026-11-01",
            "2026-11-30",
            filter_ast=ast,
            today="2026-11-10",
        )
        for t in chunk
    )


def test_the_workspace_calendar_takes_a_workspace_level_filter(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    _make(team, project, "web high", priority="high", due_date="2026-11-05")
    services.create(
        team.owner, team.ws, str(other.pk), "api high mine", priority="high",
        due_date="2026-11-06", assignee_ids=[str(team.member.pk)],
    )  # fmt: skip
    services.create(team.owner, team.ws, str(other.pk), "api low", due_date="2026-11-07")

    assert _workspace_titles(team, "priority = high") == ["api high mine", "web high"]
    assert _workspace_titles(team, "priority = high AND assignee = me") == ["api high mine"]
    assert _workspace_titles(team, f"assignee = {team.member.username}") == ["api high mine"]
    assert _workspace_titles(team, "due >= +0d AND due <= +2d") == []
    assert _workspace_titles(team, "category = not_started AND title ~ \"api\"") == [
        "api high mine", "api low"
    ]  # fmt: skip


def test_a_workspace_level_filter_has_no_project_fields(team: Any) -> None:
    from infrastructure.filters import language as lang

    for text in ("status = Done", "id = 3", "sprint = currentSprint()", '"Points" > 3'):
        with pytest.raises(lang.QueryError) as caught:
            lang.parse_text(text, Catalogue(None, team.ws))
        assert caught.value.position == 0
    assert "status" not in Catalogue(None, team.ws).field_names()


def test_a_workspace_filter_never_widens_the_visible_projects(team: Any, project: Any) -> None:
    hidden = team.create(team.owner, "SEC", visibility="private", name="Secret")
    _make(team, project, "web", priority="high", due_date="2026-11-05")
    services.create(
        team.owner, team.ws, str(hidden.pk), "secret", priority="high", due_date="2026-11-05"
    )

    assert _workspace_titles(team, "priority = high") == ["web"]
    assert _workspace_titles(team, "priority = high", who=team.owner) == ["secret", "web"]


def test_a_workspace_level_filter_also_works_inside_a_project(team: Any, project: Any) -> None:
    from infrastructure.filters import language as lang

    _make(team, project, "hot", priority="high")
    _make(team, project, "cold")
    ast = json.dumps(lang.parse_text("priority = high", Catalogue(None, team.ws)))

    page, _ = services.list_page(team.member, team.ws, str(project.pk), filter_ast=ast)

    assert [t.title for t in page] == ["hot"]
