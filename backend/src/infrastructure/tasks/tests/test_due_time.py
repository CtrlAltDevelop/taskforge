"""The optional due time: a UTC clock time on a due date, which never shifts the date."""

from datetime import time
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import calendar, services

pytestmark = pytest.mark.django_db


def _make(team: Any, project: Any, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), "t", **kw)


def _update(team: Any, project: Any, task: Any, version: int, **changes: Any) -> Any:
    return services.update(team.member, team.ws, str(project.pk), str(task.pk), version, changes)


def test_a_due_time_is_kept_with_its_date(team: Any, project: Any) -> None:
    task = _make(team, project, due_date="2026-11-05", due_time="14:30")

    assert task.due_time == time(14, 30) and task.due_date.isoformat() == "2026-11-05"


def test_a_time_can_be_set_changed_and_cleared(team: Any, project: Any) -> None:
    task = _make(team, project, due_date="2026-11-05")

    set_ = _update(team, project, task, 1, due_time="09:15")
    cleared = _update(team, project, set_, set_.version, due_time="")

    assert set_.due_time == time(9, 15) and cleared.due_time is None
    assert cleared.due_date.isoformat() == "2026-11-05"


def test_a_time_needs_a_date_and_goes_with_it(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        _make(team, project, due_time="09:00")
    task = _make(team, project, due_date="2026-11-05", due_time="09:00")

    dateless = _update(team, project, task, 1, due_date="")

    assert dateless.due_date is None and dateless.due_time is None


@pytest.mark.parametrize("bad", ["9", "25:00", "noon", "09:00:61"])
def test_a_bad_time_is_refused(team: Any, project: Any, bad: str) -> None:
    with pytest.raises(ApiError):
        _make(team, project, due_date="2026-11-05", due_time=bad)


def test_the_calendar_day_does_not_move_with_the_time(team: Any, project: Any) -> None:
    _make(team, project, due_date="2026-11-05", due_time="23:30")

    on_day = calendar.list_range(team.viewer, team.ws, str(project.pk), "2026-11-05", "2026-11-05")
    next_day = calendar.list_range(
        team.viewer, team.ws, str(project.pk), "2026-11-06", "2026-11-06"
    )

    assert len(on_day) == 1 and next_day == []
