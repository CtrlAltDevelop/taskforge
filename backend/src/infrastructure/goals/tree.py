"""A workspace's goals in memory, with every goal's rolled-up progress and status.

Loading the whole workspace costs three queries and makes the roll-up (a child's progress counts in
its parent) a plain walk, so the same numbers come out of the list, the detail and the events.
"""

from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date
from typing import Any

from infrastructure.goals import progress as math
from infrastructure.goals.models import Goal, GoalContributor, KeyResult


def kr_value(kr: KeyResult) -> float:
    return math.kr_progress(
        kr.type, kr.start_value, kr.target_value, kr.current_value, kr.linked_done, kr.linked_total
    )


@dataclass(slots=True)
class Tree:
    goals: dict[Any, Goal]
    krs: dict[Any, list[KeyResult]]
    children: dict[Any, list[Goal]]
    contributors: dict[Any, list[Any]]
    today: date
    _memo: dict[Any, float] = field(default_factory=dict)

    def progress(self, goal_id: Any, _seen: frozenset[Any] = frozenset()) -> float:
        if goal_id in self._memo:
            return self._memo[goal_id]
        if goal_id in _seen:  # a cycle cannot be made, but a bad row must not recurse forever
            return 0.0
        seen = _seen | {goal_id}
        items = [(kr_value(kr), kr.weight) for kr in self.krs.get(goal_id, [])]
        items += [(self.progress(c.pk, seen), c.weight) for c in self.children.get(goal_id, [])]
        value = math.weighted(items)
        self._memo[goal_id] = value
        return value

    def hint(self, goal: Goal) -> str:
        return math.risk_hint(
            self.progress(goal.pk), goal.period_start, goal.period_end, self.today
        )

    def status(self, goal: Goal) -> str:
        return math.status_of(goal.status_override, self.hint(goal))

    def snapshot(self) -> dict[str, float]:
        return {str(pk): round(self.progress(pk), 4) for pk in self.goals}


def load(workspace_id: Any, today: date | None = None) -> Tree:
    goals = {g.pk: g for g in Goal.objects.filter(workspace_id=workspace_id)}
    krs: dict[Any, list[KeyResult]] = defaultdict(list)
    for kr in KeyResult.objects.filter(goal__in=goals).order_by("position", "created_at"):
        krs[kr.goal_id].append(kr)
    children: dict[Any, list[Goal]] = defaultdict(list)
    for goal in goals.values():
        if goal.parent_id in goals:
            children[goal.parent_id].append(goal)
    people: dict[Any, list[Any]] = defaultdict(list)
    for row in GoalContributor.objects.filter(goal__in=goals):
        people[row.goal_id].append(row.user_id)
    return Tree(goals, dict(krs), dict(children), dict(people), today or date.today())
