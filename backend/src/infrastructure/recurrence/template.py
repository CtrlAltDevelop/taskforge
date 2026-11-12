"""The snapshot a series makes its instances from, and making one: title, description, priority,
people, custom field values and the subtasks (all open again: a fresh checklist)."""

import json
from collections import defaultdict
from datetime import date, timedelta
from typing import Any

from infrastructure.audit import context as audit_context
from infrastructure.common.errors import ApiError
from infrastructure.customfields import values as custom
from infrastructure.recurrence.models import Occurrence, RecurrenceSeries
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task, TaskAssignee


def snapshot(task: Task) -> dict[str, Any]:
    """The task and everything under it, as plain data a series can keep."""
    subs = list(
        Task.objects.filter(project_id=task.project_id, path__startswith=task.path, deleted_at=None)
        .exclude(pk=task.pk)
        .order_by("tree_key")
    )
    everyone = [task, *subs]
    custom.attach(everyone)
    people: dict[Any, list[str]] = defaultdict(list)
    for row in TaskAssignee.objects.filter(task__in=everyone).order_by("pk"):
        people[row.task_id].append(str(row.user_id))
    children: dict[Any, list[Task]] = defaultdict(list)
    for sub in subs:
        children[sub.parent_id].append(sub)

    def node(row: Task) -> dict[str, Any]:
        return {
            "title": row.title,
            "description": row.description or {},
            "priority": row.priority,
            "assignee_ids": people[row.pk],
            "field_values": dict(row.custom_values),
            "subtasks": [node(child) for child in children[row.pk]],
        }

    out = node(task)
    out["due_time"] = task.due_time.strftime("%H:%M") if task.due_time else ""
    out["start_offset_days"] = (
        (task.due_date - task.start_date).days if task.due_date and task.start_date else None
    )
    return out


def _create(series: RecurrenceSeries, node: dict[str, Any], parent_id: str, **extra: Any) -> Task:
    """Make one task; an assignee who may no longer open the project is dropped, not fatal."""
    owner, ws, project = series.created_by, series.workspace, str(series.project_id)
    sent: dict[str, Any] = {
        "description": json.dumps(node["description"]) if node.get("description") else "",
        "priority": node.get("priority") or "none",
        "parent_id": parent_id,
        "field_values": node.get("field_values") or {},
        **extra,
    }
    try:
        return tasks.create(
            owner, ws, project, node["title"], assignee_ids=node.get("assignee_ids") or [], **sent
        )
    except ApiError:
        if not node.get("assignee_ids"):
            raise
    return tasks.create(owner, ws, project, node["title"], assignee_ids=[], **sent)


def _subtasks(series: RecurrenceSeries, nodes: list[dict[str, Any]], parent: Task) -> None:
    for node in nodes:
        child = _create(series, node, str(parent.pk))
        _subtasks(series, node.get("subtasks") or [], child)


def instantiate(series: RecurrenceSeries, due: date, index: int) -> Task:
    """Make instance ``index`` of ``series`` due on ``due`` as the series' owner, recorded as the
    system's doing. Call inside a transaction: the occurrence and the subtasks stand or fall
    together."""
    node = series.template
    offset = node.get("start_offset_days")
    with audit_context.as_system():
        task = _create(
            series,
            node,
            "",
            due_date=due.isoformat(),
            due_time=node.get("due_time") or "",
            start_date=(due - timedelta(days=offset)).isoformat() if offset is not None else "",
        )
        _subtasks(series, node.get("subtasks") or [], task)
    Occurrence.objects.create(task_id=task.pk, series=series, index=index, occurs_on=due)
    return task
