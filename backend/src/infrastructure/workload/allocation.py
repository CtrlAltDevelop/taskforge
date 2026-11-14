"""The one allocation rule: how a task's estimate lands on days. Free of the database, so it is
easy to test; the workload grid and the timeline's working calendar both build on it.

A task's estimate (seconds) is spread over the days from its start to its due date, counting only
the days ``is_working`` accepts, in whole seconds that add up exactly (the first days take the
remainder). A task with one date, or a start after its due date, is a one-day range. When the
range holds no working day the whole estimate lands on the due date and ``warning`` says so.
Everything works on calendar dates (ordinals), never on clock times, so a daylight-saving change
cannot move or add an hour of load.
"""

from collections.abc import Callable, Mapping, Sequence
from dataclasses import dataclass, field
from datetime import date, timedelta
from typing import Final

MAX_SPAN_DAYS: Final = 3660  # a longer range is cut back to its due date
WorkingDay = Callable[[date], bool]


@dataclass(frozen=True, slots=True)
class Spread:
    """``days`` maps a date to the seconds on it; ``warning`` is set when no working day existed."""

    days: Mapping[date, int] = field(default_factory=dict)
    warning: bool = False


def task_range(start: date | None, due: date | None) -> tuple[date, date] | None:
    """The first and last day of the task, or None when it has no date at all."""
    first, last = start or due, due or start
    if first is None or last is None:
        return None
    first = min(first, last)
    if (last - first).days >= MAX_SPAN_DAYS:
        first = last - timedelta(days=MAX_SPAN_DAYS - 1)
    return first, last


def working_days_between(first: date, last: date, is_working: WorkingDay) -> list[date]:
    """The days from ``first`` to ``last`` inclusive that work, in order."""
    return [
        day
        for day in (date.fromordinal(n) for n in range(first.toordinal(), last.toordinal() + 1))
        if is_working(day)
    ]


def spread(
    estimate_sec: int, start: date | None, due: date | None, is_working: WorkingDay
) -> Spread:
    """Where ``estimate_sec`` falls: equal shares on working days, or all on the due date."""
    found = task_range(start, due)
    if found is None or estimate_sec <= 0:
        return Spread()
    first, last = found
    days = working_days_between(first, last, is_working)
    if not days:
        return Spread({last: estimate_sec}, warning=True)
    share, extra = divmod(estimate_sec, len(days))
    return Spread({day: share + (1 if i < extra else 0) for i, day in enumerate(days)})


def split_estimate(
    estimate_sec: int | None, assignees: Sequence[str], own: Mapping[str, int]
) -> dict[str, int]:
    """Each assignee's share of the task, in seconds. People with an estimate of their own get it;
    the rest share what is left of the task's estimate equally (in whole seconds, the first of
    them taking the remainder). Without any estimate at all nobody carries load."""
    shares = {a: own[a] for a in assignees if own.get(a, 0) > 0}
    rest = [a for a in assignees if a not in shares]
    if estimate_sec and rest:
        left = max(0, estimate_sec - sum(shares.values()))
        each, extra = divmod(left, len(rest))
        for i, person in enumerate(rest):
            shares[person] = each + (1 if i < extra else 0)
    return {a: s for a, s in shares.items() if s > 0}
