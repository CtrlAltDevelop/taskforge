"""A goal reached or slipping: its owner and contributors are told, once per change.

``goal_progress_changed`` already says the rolled-up progress and the status it now has. Reaching
100 % is one kind (``goal.reached``); moving from on track to at risk or off track is another
(``goal.at_risk``). Both are about progress *moving*: a goal nobody touches is never re-judged as
the period runs out (ponytail: a daily sweep of open goals if that is ever wanted).
"""

from typing import Any

from infrastructure.goals import progress as math
from infrastructure.goals.models import Goal, GoalContributor, GoalStatus
from infrastructure.inbox import kinds, notify
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

_SLIPPING = frozenset({GoalStatus.AT_RISK, GoalStatus.OFF_TRACK})


def _status_before(goal: Goal, previous: float) -> str:
    from django.utils import timezone

    hint = math.risk_hint(previous, goal.period_start, goal.period_end, timezone.localdate())
    return math.status_of(goal.status_override, hint)


def _kind_for(goal: Goal, kw: dict[str, Any]) -> str | None:
    if kw["progress"] >= 1.0 > kw["previous"]:
        return kinds.GOAL_REACHED
    if kw["status"] in _SLIPPING and _status_before(goal, kw["previous"]) != kw["status"]:
        return kinds.GOAL_AT_RISK
    return None


def handle(**kw: Any) -> None:
    goal = Goal.objects.select_related("workspace").filter(pk=kw["goal_id"]).first()
    if goal is None:
        return
    kind = _kind_for(goal, kw)
    if kind is None:
        return
    involved = {
        *GoalContributor.objects.filter(goal=goal).values_list("user_id", flat=True),
        *([goal.owner_id] if goal.owner_id else []),
    }
    active = set(
        WorkspaceMember.objects.filter(
            workspace_id=goal.workspace_id, user_id__in=involved, status=MemberStatus.ACTIVE
        ).values_list("user_id", flat=True)
    )
    notify.notify(
        kind=kind,
        recipients=active,
        workspace=goal.workspace,
        project=None,
        task=None,
        actor_id=kw["actor_id"] or None,
        payload={
            "goal_id": str(goal.pk),
            "goal": goal.name,
            "progress": round(kw["progress"], 4),
            "status": kw["status"],
        },
        dedupe=f"{kind}:{goal.pk}:{kw['previous']}:{kw['progress']}",
        fold=False,
        allowed=active,
    )
