"""The board and sprints together: a sprint's tasks on the board, and plan -> start -> move cards
-> complete with carry-over, end to end on the services."""

import json
from typing import Any

from infrastructure.sprints import services
from infrastructure.sprints.models import State
from infrastructure.sprints.tests.conftest import at, make_task, new_sprint
from infrastructure.sprints.tests.test_sprints import add, refresh, start
from infrastructure.tasks import board
from infrastructure.tasks import services as tasks
from infrastructure.workflows.models import Category, Status

CURRENT_SPRINT = json.dumps(
    {
        "where": {
            "op": "cmp",
            "field": "sprint",
            "cmp": "eq",
            "values": [{"k": "func", "v": "currentSprint"}],
        },
        "order": [],
    }
)


def _status(web: Any, category: str) -> str:
    return str(Status.objects.filter(project=web, category=category).order_by("position")[0].pk)


def _cards(team: Any, web: Any, **kw: Any) -> dict[str, list[str]]:
    [lane] = board.get(team.owner, team.ws, str(web.pk), **kw)
    return {c.key: sorted(t.title for t in c.tasks) for c in lane.columns}


def _titles(team: Any, web: Any, **kw: Any) -> list[str]:
    return sorted(t for titles in _cards(team, web, **kw).values() for t in titles)


def _drop(team: Any, web: Any, task: Any, category: str) -> Any:
    current = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    return board.move_card(
        team.owner,
        team.ws,
        str(web.pk),
        str(task.pk),
        group_by="status",
        column=_status(web, category),
        expected_version=current.version,
    )


def test_the_board_can_show_only_the_active_sprints_tasks(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    inside, _outside = make_task(team, web, "in"), make_task(team, web, "out")
    add(team, web, sprint, inside)

    planned_only = _titles(team, web, filter_ast=CURRENT_SPRINT)
    start(team, web, sprint)

    assert planned_only == []  # a planned sprint is not the current one
    assert _titles(team, web, filter_ast=CURRENT_SPRINT) == ["in"]
    assert _titles(team, web) == ["in", "out"]  # no filter: the whole board
    counts = {c.key: c.count for c in board.get(team.owner, team.ws, str(web.pk))[0].columns}
    filtered = board.get(team.owner, team.ws, str(web.pk), filter_ast=CURRENT_SPRINT)[0]
    assert sum(c.count for c in filtered.columns) == 1 and sum(counts.values()) == 2


def test_the_sprint_filter_pages_a_column_too(team: Any, web: Any) -> None:
    sprint = new_sprint(team, web)
    rows = [make_task(team, web, f"t{n}") for n in range(3)]
    make_task(team, web, "out")
    add(team, web, sprint, *rows)
    start(team, web, sprint)

    page, _ = board.list_column(
        team.owner,
        team.ws,
        str(web.pk),
        group_by="status",
        column=_status(web, Category.NOT_STARTED),
        filter_ast=CURRENT_SPRINT,
    )

    assert sorted(t.title for t in page) == ["t0", "t1", "t2"]


def test_plan_start_move_cards_on_the_board_complete_with_carry_over(team: Any, web: Any) -> None:
    first = new_sprint(team, web)
    second = new_sprint(team, web, "S2", "2026-11-09", "2026-11-13")
    shipped = make_task(team, web, "shipped", "3")
    stuck = make_task(team, web, "stuck", "2")
    later = make_task(team, web, "later", "1")
    add(team, web, first, shipped, stuck)
    start(team, web, first)

    # the team works the sprint on the board
    _drop(team, web, stuck, Category.ACTIVE)
    _drop(team, web, shipped, Category.DONE)
    on_board = _titles(team, web, filter_ast=CURRENT_SPRINT)

    done = services.complete(
        team.owner, team.ws, str(web.pk), str(first.pk), "next", str(second.pk), at(6)
    ).sprint

    assert on_board == ["shipped", "stuck"] and "later" not in on_board
    assert done.state == State.COMPLETED
    assert (done.completed_tasks, done.completed_points, done.unfinished_tasks) == (1, 3, 1)
    assert tasks.get(team.owner, team.ws, str(web.pk), str(stuck.pk)).sprint_id == second.pk
    assert tasks.get(team.owner, team.ws, str(web.pk), str(shipped.pk)).sprint_id == first.pk
    assert tasks.get(team.owner, team.ws, str(web.pk), str(later.pk)).sprint_id is None
    assert _titles(team, web, filter_ast=CURRENT_SPRINT) == []  # S2 is planned, nothing active
    assert refresh(second).state == State.PLANNED
