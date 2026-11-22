"""Planning: sprints (completed, active with a burndown, planned), time, workload, goals,
dashboards and recurring tasks. Run after ``core``; log in as owner to see all of it.

Fills ``ctx.extra``: ``sprints`` (past, active, future) and ``goals`` (name -> Goal).
"""

from infrastructure.common.demo import planning_goals, planning_sprints, planning_time
from infrastructure.common.demo.base import Ctx


def seed(ctx: Ctx) -> None:
    planning_sprints.seed(ctx)
    planning_time.seed(ctx)
    planning_goals.seed(ctx)
