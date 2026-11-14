"""Tell the rest of the system when a goal's progress moved."""

from collections.abc import Iterator
from contextlib import contextmanager
from typing import Any

from django.db import transaction

from infrastructure.goals import tree
from infrastructure.goals.signals import goal_progress_changed


@contextmanager
def tracking(workspace_id: Any, actor_id: Any = "") -> Iterator[None]:
    """Compare every goal's progress before and after the block; send ``goal_progress_changed``
    (after commit) for each goal whose rolled-up progress changed, parents included."""
    before = tree.load(workspace_id).snapshot()
    yield
    after = tree.load(workspace_id)
    now = after.snapshot()
    for goal_id, value in now.items():
        previous = before.get(goal_id, 0.0)
        if previous == value:
            continue
        payload = {
            "workspace_id": str(workspace_id),
            "goal_id": goal_id,
            "previous": previous,
            "progress": value,
            "status": after.status(after.goals[_key(after, goal_id)]),
            "actor_id": str(actor_id or ""),
        }
        transaction.on_commit(lambda p=payload: goal_progress_changed.send(sender=tree.Tree, **p))


def _key(loaded: tree.Tree, goal_id: str) -> Any:
    return next(pk for pk in loaded.goals if str(pk) == goal_id)
