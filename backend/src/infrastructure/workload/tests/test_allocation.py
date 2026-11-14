from datetime import date

from infrastructure.workload.allocation import (
    MAX_SPAN_DAYS,
    split_estimate,
    spread,
    task_range,
    working_days_between,
)


def weekdays(day: date) -> bool:
    return day.weekday() < 5


MON, TUE, FRI, SAT, SUN = (date(2026, 3, d) for d in (2, 3, 6, 7, 8))


def test_spread_is_exact_and_remainder_goes_first() -> None:
    result = spread(10, MON, TUE, weekdays)
    assert result.days == {MON: 5, TUE: 5}
    result = spread(11, MON, TUE, weekdays)
    assert result.days == {MON: 6, TUE: 5}
    assert sum(spread(100, MON, FRI, weekdays).days.values()) == 100


def test_weekend_is_skipped() -> None:
    result = spread(60, FRI, date(2026, 3, 9), weekdays)
    assert set(result.days) == {FRI, date(2026, 3, 9)}


def test_no_working_day_lands_on_due_with_warning() -> None:
    result = spread(60, SAT, SUN, weekdays)
    assert result.days == {SUN: 60}
    assert result.warning


def test_holiday_predicate_is_honoured() -> None:
    result = spread(10, MON, TUE, lambda d: d != MON)
    assert result.days == {TUE: 10}


def test_single_date_and_inverted_range() -> None:
    assert spread(5, None, TUE, weekdays).days == {TUE: 5}
    assert spread(5, TUE, None, weekdays).days == {TUE: 5}
    assert spread(6, FRI, MON, weekdays).days == {MON: 6}
    assert task_range(FRI, MON) == (MON, MON)


def test_no_dates_or_no_estimate_is_empty() -> None:
    assert spread(5, None, None, weekdays).days == {}
    assert spread(0, MON, TUE, weekdays).days == {}


def test_overlong_range_is_cut_back() -> None:
    first, last = task_range(date(2000, 1, 1), date(2026, 1, 1)) or (None, None)
    assert first is not None and last is not None
    assert (last - first).days == MAX_SPAN_DAYS - 1


def test_working_days_between_inclusive() -> None:
    assert len(working_days_between(MON, SUN, weekdays)) == 5


def test_split_estimate_multi_assignee() -> None:
    assert split_estimate(10, ["a", "b", "c"], {}) == {"a": 4, "b": 3, "c": 3}
    assert split_estimate(10, ["a", "b"], {"a": 6}) == {"a": 6, "b": 4}
    assert split_estimate(None, ["a"], {}) == {}
    assert split_estimate(5, [], {}) == {}
    assert split_estimate(5, ["a", "b"], {"a": 9}) == {"a": 9}
