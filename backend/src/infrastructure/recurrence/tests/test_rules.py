"""Repeat rules: the dates they make, the clamps, the refusals, the words."""

from datetime import date

import pytest

from infrastructure.recurrence import rules


def d(
    text: str, start: str, *, after: str | None = None, limit: int = 6, **kw: object
) -> list[str]:
    found = rules.dates(
        rules.parse(text),
        date.fromisoformat(start),
        after=date.fromisoformat(after) if after else None,
        limit=limit,
        **kw,  # type: ignore[arg-type]
    )
    return [x.isoformat() for x in found]


def test_every_two_weeks_on_monday_and_thursday() -> None:
    assert d("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH", "2026-11-02", limit=5) == [
        "2026-11-02", "2026-11-05", "2026-11-16", "2026-11-19", "2026-11-30",
    ]  # fmt: skip


def test_a_weekly_rule_without_days_repeats_the_starting_weekday() -> None:
    assert d("FREQ=WEEKLY", "2026-11-04", limit=3) == ["2026-11-04", "2026-11-11", "2026-11-18"]


def test_the_first_monday_of_every_month_and_the_last_friday() -> None:
    assert d("FREQ=MONTHLY;BYDAY=1MO", "2026-11-01", limit=4) == [
        "2026-11-02", "2026-12-07", "2027-01-04", "2027-02-01",
    ]  # fmt: skip
    assert d("FREQ=MONTHLY;BYDAY=-1FR", "2026-11-01", limit=3) == [
        "2026-11-27", "2026-12-25", "2027-01-29",
    ]  # fmt: skip


def test_the_31st_lands_on_the_last_day_of_a_short_month() -> None:
    assert d("FREQ=MONTHLY;BYMONTHDAY=31", "2026-01-31", limit=6) == [
        "2026-01-31", "2026-02-28", "2026-03-31", "2026-04-30", "2026-05-31", "2026-06-30",
    ]  # fmt: skip
    assert d("FREQ=MONTHLY;BYMONTHDAY=30", "2026-01-30", limit=3) == [
        "2026-01-30", "2026-02-28", "2026-03-30",
    ]  # fmt: skip
    assert d("FREQ=MONTHLY", "2026-01-31", limit=3) == ["2026-01-31", "2026-02-28", "2026-03-31"]


def test_feb_29_is_the_28th_in_other_years_and_the_29th_in_leap_years() -> None:
    assert d("FREQ=YEARLY", "2024-02-29", limit=5) == [
        "2024-02-29", "2025-02-28", "2026-02-28", "2027-02-28", "2028-02-29",
    ]  # fmt: skip


def test_count_and_until_end_the_series() -> None:
    assert d("FREQ=DAILY;COUNT=3", "2026-11-01", limit=10) == [
        "2026-11-01", "2026-11-02", "2026-11-03",
    ]  # fmt: skip
    assert d("FREQ=DAILY;UNTIL=20261103", "2026-11-01", limit=10) == [
        "2026-11-01", "2026-11-02", "2026-11-03",
    ]  # fmt: skip
    assert d("FREQ=DAILY", "2026-11-01", limit=10, until=date(2026, 11, 2)) == [
        "2026-11-01", "2026-11-02",
    ]  # fmt: skip


def test_after_asks_for_what_comes_next_and_weekends_can_be_skipped() -> None:
    assert d("FREQ=DAILY", "2026-11-05", after="2026-11-05", limit=2) == [
        "2026-11-06",
        "2026-11-07",
    ]
    assert d("FREQ=DAILY", "2026-11-05", after="2026-11-05", limit=3, skip_weekends=True) == [
        "2026-11-06", "2026-11-09", "2026-11-10",
    ]  # fmt: skip


@pytest.mark.parametrize(
    ("done", "text", "expected"),
    [
        ("2026-11-12", "FREQ=DAILY;INTERVAL=3", "2026-11-15"),
        ("2026-11-12", "FREQ=WEEKLY;INTERVAL=2", "2026-11-26"),
        ("2026-01-31", "FREQ=MONTHLY", "2026-02-28"),
        ("2024-02-29", "FREQ=YEARLY", "2025-02-28"),
        ("2026-12-31", "FREQ=MONTHLY", "2027-01-31"),
    ],
)
def test_after_completion_counts_from_the_day_it_was_finished(
    done: str, text: str, expected: str
) -> None:
    got = rules.after_completion(rules.parse(text), date.fromisoformat(done))
    assert got == date.fromisoformat(expected)


def test_after_completion_can_skip_a_weekend() -> None:
    sat = rules.after_completion(rules.parse("FREQ=DAILY"), date(2026, 11, 6), skip_weekends=True)
    assert sat == date(2026, 11, 9)  # the day after was a Saturday


@pytest.mark.parametrize(
    "bad",
    [
        "", "FREQ=HOURLY", "INTERVAL=2", "FREQ=DAILY;INTERVAL=0", "FREQ=DAILY;BYHOUR=9",
        "FREQ=WEEKLY;BYDAY=XX", "FREQ=WEEKLY;BYDAY=1MO", "FREQ=DAILY;COUNT=3;UNTIL=20261231",
        "FREQ=DAILY;FREQ=WEEKLY", "FREQ=MONTHLY;BYMONTHDAY=40",
        "FREQ=MONTHLY;BYMONTHDAY=1;BYDAY=MO",
        "FREQ=WEEKLY;BYMONTH=2", "FREQ=DAILY;UNTIL=soon", "FREQ=MONTHLY;BYMONTHDAY=29,31",
        "FREQ=DAILY;INTERVAL=9999",
    ],
)  # fmt: skip
def test_a_rule_that_means_nothing_is_refused(bad: str) -> None:
    with pytest.raises(rules.RuleError):
        rules.parse(bad)


def test_the_text_round_trips_and_an_rrule_prefix_is_fine() -> None:
    text = "FREQ=MONTHLY;INTERVAL=2;BYDAY=1MO,3MO;COUNT=6"
    assert rules.render(rules.parse("RRULE:" + text.lower())) == text


@pytest.mark.parametrize(
    ("text", "mode", "words"),
    [
        ("FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH", "schedule", "Every 2 weeks on Mon, Thu"),
        ("FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR", "schedule", "Every weekday"),
        ("FREQ=DAILY", "schedule", "Every day"),
        ("FREQ=MONTHLY;BYDAY=1MO", "schedule", "Every month on the 1st Mon"),
        ("FREQ=MONTHLY;BYMONTHDAY=22", "schedule", "Every month on the 22nd"),
        ("FREQ=MONTHLY;BYMONTHDAY=31", "schedule", "Every month on the 31st"),
        ("FREQ=YEARLY;BYMONTH=3", "schedule", "Every year in Mar"),
        ("FREQ=DAILY;INTERVAL=3", "after_completion", "3 days after it is completed"),
        ("FREQ=WEEKLY", "after_completion", "1 week after it is completed"),
        ("FREQ=DAILY;COUNT=3", "schedule", "Every day, 3 times"),
    ],
)
def test_the_rule_in_words(text: str, mode: str, words: str) -> None:
    assert rules.describe(rules.parse(text), mode) == words
