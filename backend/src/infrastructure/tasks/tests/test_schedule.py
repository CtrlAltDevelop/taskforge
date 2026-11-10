"""The schedule engine: working days, cascading a move through blocking links, critical path."""

from datetime import date

from infrastructure.tasks import schedule
from infrastructure.tasks.schedule import Item, WorkingCalendar

ALL_DAYS = WorkingCalendar()
MON_FRI = WorkingCalendar(days=frozenset({0, 1, 2, 3, 4}))


def d(day: int) -> date:  # November 2026: the 2nd is a Monday
    return date(2026, 11, day)


def test_every_day_works_by_default() -> None:
    assert ALL_DAYS.is_working(d(7)) and ALL_DAYS.is_working(d(8))


def test_a_weekend_and_a_holiday_do_not_work() -> None:
    cal = WorkingCalendar(days=frozenset({0, 1, 2, 3, 4}), holidays=frozenset({d(4)}))
    assert not cal.is_working(d(7)) and not cal.is_working(d(4)) and cal.is_working(d(5))


def test_next_working_day_skips_the_weekend() -> None:
    assert MON_FRI.next_working(d(6)) == d(9)  # Friday -> Monday
    assert MON_FRI.next_working(d(9)) == d(10)


def test_a_calendar_with_no_working_day_does_not_loop() -> None:
    assert WorkingCalendar(days=frozenset()).next_working(d(2)) == d(3)


def test_span_counts_working_days_inclusive() -> None:
    assert MON_FRI.span(d(2), d(6)) == 5
    assert MON_FRI.span(d(6), d(9)) == 2  # Friday and Monday
    assert ALL_DAYS.span(d(2), d(2)) == 1


def test_add_span_ends_after_that_many_working_days() -> None:
    assert MON_FRI.end_of(d(6), 2) == d(9)  # starts Friday, 2 working days -> Monday
    assert ALL_DAYS.end_of(d(2), 1) == d(2)


def test_moving_a_blocker_past_its_dependent_shifts_the_dependent_by_the_overlap() -> None:
    items = {"a": Item(d(2), d(4)), "b": Item(d(5), d(6))}
    moved = schedule.cascade(items, [("a", "b")], "a", Item(d(2), d(10)), ALL_DAYS)
    assert moved == {"a": Item(d(2), d(10)), "b": Item(d(11), d(12))}


def test_a_dependent_that_still_starts_after_the_blocker_stays() -> None:
    items = {"a": Item(d(2), d(4)), "b": Item(d(9), d(10))}
    moved = schedule.cascade(items, [("a", "b")], "a", Item(d(2), d(6)), ALL_DAYS)
    assert moved == {"a": Item(d(2), d(6))}


def test_cascade_keeps_a_dependents_length_in_working_days() -> None:
    items = {"a": Item(d(2), d(3)), "b": Item(d(4), d(9))}  # Wed..Mon = 4 working days
    moved = schedule.cascade(items, [("a", "b")], "a", Item(d(2), d(6)), MON_FRI)
    assert moved["b"] == Item(d(9), d(12))  # Mon..Thu = 4 working days


def test_cascade_runs_down_a_chain() -> None:
    items = {"a": Item(d(2), d(3)), "b": Item(d(4), d(5)), "c": Item(d(6), d(7))}
    moved = schedule.cascade(items, [("a", "b"), ("b", "c")], "a", Item(d(2), d(5)), ALL_DAYS)
    assert moved["b"] == Item(d(6), d(7)) and moved["c"] == Item(d(8), d(9))


def test_cascade_moves_a_milestone_by_its_single_date() -> None:
    items = {"a": Item(d(2), d(4)), "m": Item(None, d(5))}
    moved = schedule.cascade(items, [("a", "m")], "a", Item(d(2), d(8)), ALL_DAYS)
    assert moved["m"] == Item(None, d(9))


def test_cascade_leaves_unscheduled_dependents_alone() -> None:
    items = {"a": Item(d(2), d(4)), "b": Item(None, None)}
    assert schedule.cascade(items, [("a", "b")], "a", Item(d(2), d(9)), ALL_DAYS) == {
        "a": Item(d(2), d(9))
    }


def test_cascade_survives_a_cycle_in_bad_data() -> None:
    items = {"a": Item(d(2), d(3)), "b": Item(d(4), d(5))}
    moved = schedule.cascade(items, [("a", "b"), ("b", "a")], "a", Item(d(2), d(9)), ALL_DAYS)
    assert moved["a"] == Item(d(2), d(9)) and moved["b"] == Item(d(10), d(11))


def test_critical_path_is_the_longest_chain_by_working_days() -> None:
    items = {
        "a": Item(d(2), d(3)),  # 2
        "b": Item(d(4), d(5)),  # 2
        "c": Item(d(6), d(9)),  # 4
        "x": Item(d(2), d(2)),  # 1
    }
    edges = [("a", "b"), ("a", "c"), ("x", "b")]
    assert schedule.critical_path(items, edges, ALL_DAYS) == ["a", "c"]


def test_critical_path_is_empty_without_a_chain() -> None:
    items = {"a": Item(d(2), d(3)), "b": Item(d(4), d(5))}
    assert schedule.critical_path(items, [], ALL_DAYS) == []


def test_critical_path_ignores_unscheduled_tasks_and_cycles() -> None:
    items = {"a": Item(d(2), d(3)), "b": Item(d(4), d(5)), "u": Item(None, None)}
    edges = [("a", "b"), ("b", "u"), ("b", "a")]
    assert schedule.critical_path(items, edges, ALL_DAYS) == []


def test_two_thousand_linked_tasks_are_worked_out_in_a_blink() -> None:
    import time

    items = {f"t{n:04d}": Item(d(2) if n % 2 else d(3), d(4)) for n in range(2000)}
    edges = [(f"t{n:04d}", f"t{n + 1:04d}") for n in range(1999)]
    edges += [(f"t{n:04d}", f"t{n + 7:04d}") for n in range(0, 1990, 3)]

    started = time.perf_counter()
    path = schedule.critical_path(items, edges, ALL_DAYS)
    moved = schedule.cascade(items, edges, "t0000", Item(d(2), d(20)), ALL_DAYS)

    assert time.perf_counter() - started < 2
    assert path[0] == "t0000" and len(path) == 2000
    assert len(moved) == 2000


def test_milestones_count_on_the_critical_path() -> None:
    items = {
        "a": Item(d(2), d(4)),  # 3
        "m": Item(None, d(5)),  # milestone, 0
        "n": Item(None, d(6)),  # milestone, 0
        "t": Item(d(6), d(10)),  # 5
    }

    assert schedule.critical_path(items, [("m", "t")], ALL_DAYS) == ["m", "t"]
    assert schedule.critical_path(items, [("a", "m"), ("m", "n")], ALL_DAYS) == ["a", "m", "n"]
