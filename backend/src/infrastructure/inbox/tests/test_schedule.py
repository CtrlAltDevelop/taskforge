from datetime import UTC, datetime, time
from typing import Any

import pytest

from infrastructure.inbox import schedule


class Prefs:
    def __init__(self, tz: str = "UTC", start: str = "", end: str = "", hour: int = 8) -> None:
        self.timezone = tz
        self.quiet_start = time.fromisoformat(start) if start else None
        self.quiet_end = time.fromisoformat(end) if end else None
        self.digest_hour = hour

    @property
    def quiet(self) -> Any:
        if self.quiet_start is None or self.quiet_end is None:
            return None
        return self.quiet_start, self.quiet_end


def utc(year: int, month: int, day: int, hour: int = 0, minute: int = 0) -> datetime:
    return datetime(year, month, day, hour, minute, tzinfo=UTC)


@pytest.mark.parametrize(
    ("now", "quiet"),
    [
        (utc(2026, 5, 1, 21, 59), False),
        (utc(2026, 5, 1, 22, 0), True),  # the start is inside
        (utc(2026, 5, 2, 3, 0), True),  # past midnight
        (utc(2026, 5, 2, 6, 59), True),
        (utc(2026, 5, 2, 7, 0), False),  # the end is outside
    ],
)
def test_a_window_that_crosses_midnight(now: datetime, quiet: bool) -> None:
    assert schedule.in_quiet(now, Prefs(start="22:00", end="07:00")) is quiet


def test_a_window_inside_one_day_and_no_window() -> None:
    day = Prefs(start="13:00", end="14:00")

    assert schedule.in_quiet(utc(2026, 5, 1, 13, 30), day)
    assert not schedule.in_quiet(utc(2026, 5, 1, 14, 0), day)
    assert not schedule.in_quiet(utc(2026, 5, 1, 13, 30), Prefs())


def test_the_window_is_read_in_the_persons_own_zone() -> None:
    tehran = Prefs(tz="Asia/Tehran", start="22:00", end="07:00")  # UTC+3:30, no DST

    assert schedule.in_quiet(utc(2026, 5, 1, 19, 0), tehran)  # 22:30 there
    assert not schedule.in_quiet(utc(2026, 5, 1, 18, 0), tehran)  # 21:30 there
    assert schedule.release_time(utc(2026, 5, 1, 19, 0), tehran) == utc(2026, 5, 2, 3, 30)


def test_a_send_outside_quiet_hours_goes_now_and_inside_waits_for_the_end() -> None:
    prefs = Prefs(start="22:00", end="07:00")

    assert schedule.release_time(utc(2026, 5, 1, 12, 0), prefs) == utc(2026, 5, 1, 12, 0)
    assert schedule.release_time(utc(2026, 5, 1, 23, 0), prefs) == utc(2026, 5, 2, 7, 0)
    assert schedule.release_time(utc(2026, 5, 2, 3, 0), prefs) == utc(2026, 5, 2, 7, 0)


def test_the_end_of_quiet_hours_follows_daylight_saving() -> None:
    new_york = Prefs(tz="America/New_York", start="22:00", end="07:00")

    winter = schedule.release_time(utc(2026, 3, 7, 5, 0), new_york)  # 00:00 EST, the night before
    summer = schedule.release_time(utc(2026, 3, 9, 4, 0), new_york)  # 00:00 EDT after the change

    assert winter == utc(2026, 3, 7, 12, 0)  # 07:00 EST is 12:00 UTC
    assert summer == utc(2026, 3, 9, 11, 0)  # 07:00 EDT is 11:00 UTC


def test_the_next_digest_is_the_next_time_the_hour_comes_round() -> None:
    prefs = Prefs(hour=8)

    assert schedule.next_digest(utc(2026, 5, 1, 7, 0), prefs) == utc(2026, 5, 1, 8, 0)
    assert schedule.next_digest(utc(2026, 5, 1, 8, 0), prefs) == utc(2026, 5, 2, 8, 0)
    assert schedule.next_digest(utc(2026, 5, 1, 20, 0), prefs) == utc(2026, 5, 2, 8, 0)
    assert schedule.next_digest(utc(2026, 5, 1, 20, 0), Prefs(tz="Asia/Tehran", hour=8)) == utc(
        2026, 5, 2, 4, 30
    )


def test_an_unknown_zone_falls_back_to_utc() -> None:
    assert schedule.in_quiet(
        utc(2026, 5, 1, 23, 0), Prefs(tz="Mars/Olympus", start="22:00", end="07:00")
    )
