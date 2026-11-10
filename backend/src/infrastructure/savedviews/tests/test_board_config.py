from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.savedviews import config, services

BOARD = {
    "group_by": "priority",
    "swimlane": "assignee",
    "card_fields": ["assignee", "due_date"],
    "limits": {"high": 3, "": 10},
}


def test_a_board_layout_round_trips_beside_a_list_layout(team: Any, project: Any) -> None:
    services.save(team.member, team.ws, str(project.pk), name="Mine", config=BOARD, kind="board")
    services.save(
        team.member, team.ws, str(project.pk), name="Mine", config=config.clean({}), kind="list"
    )

    [board] = services.list_views(team.member, team.ws, str(project.pk), "board")

    assert board.config == BOARD
    assert len(services.list_views(team.member, team.ws, str(project.pk))) == 2


def test_an_empty_board_layout_gets_the_defaults() -> None:
    assert config.clean_board({}) == {
        "group_by": "status",
        "swimlane": "",
        "card_fields": ["assignee", "due_date", "priority", "progress"],
        "limits": {},
    }


@pytest.mark.parametrize(
    "bad",
    [
        {"group_by": "title"},
        {"swimlane": "status"},
        {"card_fields": ["title"]},
        {"card_fields": ["due_date", "due_date"]},
        {"limits": {"todo": 0}},
        {"limits": {"todo": "3"}},
        {"limits": {"todo": True}},
        {"limits": []},
        {"colour": "red"},
        "not an object",
    ],
)
def test_a_board_layout_that_means_nothing_is_refused(bad: Any) -> None:
    with pytest.raises(ApiError):
        config.clean_board(bad)


def test_a_calendar_layout_round_trips_and_gets_defaults(team: Any, project: Any) -> None:
    layout = {"mode": "week", "color_by": "priority", "week_start": 7, "hide_done": True}
    services.save(
        team.member, team.ws, str(project.pk), name="Mine", config=layout, kind="calendar"
    )

    [got] = services.list_views(team.member, team.ws, str(project.pk), "calendar")

    assert got.config == layout
    assert config.clean_calendar({}) == {
        "mode": "month",
        "color_by": "status",
        "week_start": 0,
        "hide_done": False,
    }


@pytest.mark.parametrize(
    "bad",
    [
        {"mode": "year"},
        {"color_by": "assignee"},
        {"week_start": -1},
        {"week_start": 8},
        {"week_start": True},
        {"hide_done": "yes"},
        {"zoom": 2},
        [],
    ],
)
def test_a_calendar_layout_that_means_nothing_is_refused(bad: Any) -> None:
    with pytest.raises(ApiError):
        config.clean_calendar(bad)
