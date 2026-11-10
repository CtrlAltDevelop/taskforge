"""Scheduling rules the timeline needs, free of the database so they are easy to test.

A task is an ``Item``: both dates is a bar, one date is a milestone (a point), none is
unscheduled. A blocking link ``(blocker, dependent)`` means the dependent starts after the blocker
finishes. A ``WorkingCalendar`` says which weekdays and dates count when shifting and measuring.
"""

from collections import deque
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, field
from datetime import date, timedelta
from typing import Final

SEARCH_DAYS: Final = 3660  # how far to look for a working day before giving up
Edge = tuple[str, str]


@dataclass(frozen=True, slots=True)
class WorkingCalendar:
    """``days`` are weekdays that work (0 Monday ... 6 Sunday); ``holidays`` never do. A calendar
    with no working weekday counts every day, so a bad setting cannot stop a shift."""

    days: frozenset[int] = frozenset(range(7))
    holidays: frozenset[date] = field(default_factory=frozenset)

    def is_working(self, day: date) -> bool:
        if day in self.holidays:
            return False
        return not self.days or day.weekday() in self.days

    def next_working(self, day: date) -> date:
        """The first working day after ``day``."""
        for step in range(1, SEARCH_DAYS):
            if self.is_working(day + timedelta(days=step)):
                return day + timedelta(days=step)
        return day + timedelta(days=1)  # every day is a holiday: ponytail: no better answer

    def span(self, first: date, last: date) -> int:
        """Working days from ``first`` to ``last`` inclusive (at least 1)."""
        count = sum(
            self.is_working(first + timedelta(days=n)) for n in range((last - first).days + 1)
        )
        return max(1, count)

    def end_of(self, first: date, length: int) -> date:
        """The day a bar of ``length`` working days that starts on ``first`` ends."""
        remaining, day = max(1, length), first
        for _ in range(SEARCH_DAYS):
            if self.is_working(day):
                remaining -= 1
                if remaining == 0:
                    return day
            day += timedelta(days=1)
        return day


@dataclass(frozen=True, slots=True)
class Item:
    start: date | None
    due: date | None

    @property
    def scheduled(self) -> bool:
        return self.start is not None or self.due is not None

    @property
    def finish(self) -> date | None:
        return self.due or self.start

    @property
    def begin(self) -> date | None:
        return self.start or self.due

    def weight(self, cal: WorkingCalendar) -> int:
        """Working days it takes: a bar's length, 0 for a milestone."""
        return cal.span(self.start, self.due) if self.start and self.due else 0


def _shifted(item: Item, after: date, cal: WorkingCalendar) -> Item:
    """``item`` moved so it starts on the first working day after ``after``, same length."""
    first = cal.next_working(after)
    if item.start and item.due:
        return Item(first, cal.end_of(first, cal.span(item.start, item.due)))
    if item.start:
        return Item(first, None)
    return Item(None, first)


def _successors(edges: Iterable[Edge], items: Mapping[str, Item]) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    for blocker, dependent in edges:
        if blocker in items and dependent in items:
            out.setdefault(blocker, []).append(dependent)
    return out


def _reachable(start: str, out: Mapping[str, list[str]]) -> set[str]:
    seen, queue = {start}, deque([start])
    while queue:
        for nxt in out.get(queue.popleft(), ()):
            if nxt not in seen:
                seen.add(nxt)
                queue.append(nxt)
    return seen


def cascade(
    items: Mapping[str, Item],
    edges: Sequence[Edge],
    moved_id: str,
    moved: Item,
    cal: WorkingCalendar,
) -> dict[str, Item]:
    """Where every task that has to move ends up when ``moved_id`` becomes ``moved``: the task
    itself plus each dependent (through any chain) that would start before its blockers finish,
    pushed to the first working day after them with its length kept. Unscheduled tasks stay. A
    cycle in bad data leaves the tasks on it where they are instead of looping."""
    out = _successors(edges, items)
    reach = _reachable(moved_id, out)
    waiting = {n: 0 for n in reach}
    for blocker, nexts in out.items():
        if blocker in reach:
            for nxt in nexts:
                if nxt != moved_id:
                    waiting[nxt] += 1
    now = {**items, moved_id: moved}
    result = {moved_id: moved}
    queue = deque([moved_id])
    while queue:
        blocker = queue.popleft()
        for nxt in out.get(blocker, ()):
            if nxt == moved_id:
                continue
            finish = now[blocker].finish
            item = now[nxt]
            if finish and item.scheduled and item.begin is not None and item.begin <= finish:
                now[nxt] = result[nxt] = _shifted(item, finish, cal)
            waiting[nxt] -= 1
            if waiting[nxt] == 0:
                queue.append(nxt)
    return result


def critical_path(
    items: Mapping[str, Item], edges: Sequence[Edge], cal: WorkingCalendar
) -> list[str]:
    """The longest chain of linked scheduled tasks by working days, first blocker first; empty
    when no two tasks are linked. Ties go to the smaller id so the answer is stable."""
    live = {k: v for k, v in items.items() if v.scheduled}
    out = _successors(edges, live)
    waiting = {k: 0 for k in live}
    for nexts in out.values():
        for nxt in nexts:
            waiting[nxt] += 1
    best = {k: live[k].weight(cal) for k in live}
    came: dict[str, str] = {}
    hops = {k: 0 for k in live}  # tasks before it on its chain
    queue = deque(sorted(k for k, n in waiting.items() if n == 0))
    order: list[str] = []
    while queue:
        node = queue.popleft()
        order.append(node)
        for nxt in sorted(out.get(node, ())):
            total = best[node] + live[nxt].weight(cal)
            if nxt not in came or total > best[nxt] or (total == best[nxt] and node < came[nxt]):
                best[nxt], came[nxt], hops[nxt] = total, node, hops[node] + 1
            waiting[nxt] -= 1
            if waiting[nxt] == 0:
                queue.append(nxt)
    ends = [k for k in order if k in came]  # only chains of two or more
    if not ends:
        return []
    end = min(ends, key=lambda k: (-best[k], -hops[k], k))  # a longer chain wins a tie
    path = [end]
    while path[-1] in came:
        path.append(came[path[-1]])
    return path[::-1]
