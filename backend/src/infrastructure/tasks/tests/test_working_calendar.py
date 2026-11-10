"""The workspace's working-day calendar: who may read and change it, and what it accepts."""

from datetime import date
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.tasks import timeline
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def test_a_workspace_without_a_setting_works_every_day(team: Any) -> None:
    cal = timeline.working_calendar(team.ws)

    assert cal.is_working(date(2026, 11, 7)) and cal.holidays == frozenset()
    assert timeline.get_working_days(team.viewer, team.ws) == ([0, 1, 2, 3, 4, 5, 6], [])


def test_an_admin_sets_working_days_and_holidays(team: Any) -> None:
    timeline.set_working_days(team.admin, team.ws, [4, 0, 1, 2, 3], ["2026-12-25", "2026-11-26"])

    days, holidays = timeline.get_working_days(team.member, team.ws)
    assert days == [0, 1, 2, 3, 4] and holidays == ["2026-11-26", "2026-12-25"]
    assert not timeline.working_calendar(team.ws).is_working(date(2026, 11, 7))


def test_setting_it_again_replaces_it(team: Any) -> None:
    timeline.set_working_days(team.owner, team.ws, [0, 1], ["2026-12-25"])
    timeline.set_working_days(team.owner, team.ws, [2], [])

    assert timeline.get_working_days(team.owner, team.ws) == ([2], [])


def test_only_those_who_may_update_the_workspace_change_it(team: Any) -> None:
    with pytest.raises(access.PermissionDenied):
        timeline.set_working_days(team.member, team.ws, [0], [])
    with pytest.raises(access.PermissionDenied):
        timeline.set_working_days(team.viewer, team.ws, [0], [])


def test_an_outsider_cannot_read_it(team: Any) -> None:
    with pytest.raises(ApiError):
        timeline.get_working_days(team.outsider, team.ws)


def test_another_workspace_keeps_its_own(team: Any) -> None:
    timeline.set_working_days(team.owner, team.ws, [0], [])

    assert timeline.working_calendar(team.other_ws).is_working(date(2026, 11, 7))


@pytest.mark.parametrize(
    ("days", "holidays"),
    [([7], []), ([-1], []), (["x"], []), ([0], ["soon"]), ([0], ["2026-13-01"]), ([True], [])],
)
def test_bad_values_are_refused(team: Any, days: list[Any], holidays: list[str]) -> None:
    with pytest.raises(ApiError):
        timeline.set_working_days(team.owner, team.ws, days, holidays)


def test_too_many_holidays_are_refused(team: Any) -> None:
    many = [date.fromordinal(739000 + n).isoformat() for n in range(timeline.MAX_HOLIDAYS + 1)]
    with pytest.raises(ApiError):
        timeline.set_working_days(team.owner, team.ws, [0], many)


def test_a_calendar_saved_with_no_working_weekday_reads_back_as_every_day(team: Any) -> None:
    timeline.set_working_days(team.owner, team.ws, [], [])

    assert timeline.get_working_days(team.owner, team.ws) == ([0, 1, 2, 3, 4, 5, 6], [])
