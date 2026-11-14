"""Turn live tasks and projects into template content. Reads only; the caller has already checked
who may save what (see ``services``)."""

from datetime import date
from typing import Any

from infrastructure.automations.models import Automation
from infrastructure.customfields import types, values
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.templates import content
from infrastructure.workflows import services as workflows

Json = dict[str, Any]


def _offset_of(day: date | None, anchor: date | None) -> int | None:
    return None if day is None or anchor is None else (day - anchor).days


def _wire_to_portable(field: FieldDefinition, wire: str) -> str:
    """Select options travel by label, so the values survive into a project whose options carry
    other ids."""
    labels = {o["id"]: o["label"] for o in field.options}
    if field.type == FieldType.SELECT:
        return labels.get(wire, "")
    if field.type == FieldType.MULTISELECT:
        return ",".join(labels[i] for i in wire.split(",") if i in labels)
    return wire


def _field_values(task: Task, defs: dict[str, FieldDefinition]) -> list[Json]:
    out: list[Json] = []
    for field_id, wire in task.custom_values.items():
        field = defs.get(field_id)
        if field is None:
            continue
        value = _wire_to_portable(field, wire)
        if value:
            out.append({"name": field.name, "type": field.type, "value": value})
    return out


def tasks_of(
    project: Project, roots: list[Task], *, assignees: bool, subtree: bool = True
) -> list[Json]:
    """The tasks (parents first) as template tasks; dates become offsets from the earliest date.

    ``roots`` of ``None`` kind: every live task of the project is taken when it is empty."""
    rows = Task.objects.filter(project=project, deleted_at__isnull=True).select_related("status")
    if roots:
        from django.db.models import Q

        query = Q()
        for root in roots:
            query |= Q(path__startswith=root.path) if subtree else Q(pk=root.pk)
        rows = rows.filter(query)
    found = list(rows.order_by("tree_key", "number").prefetch_related("assignees"))
    if len(found) > content.MAX_TASKS:
        raise content.bad(f"A template can hold at most {content.MAX_TASKS} tasks.")
    values.attach(found)
    defs = {str(f.pk): f for f in values.active_fields(project)}
    days = [d for t in found for d in (t.start_date, t.due_date) if d is not None]
    anchor = min(days) if days else None
    refs = {t.pk: f"t{i}" for i, t in enumerate(found, 1)}
    root_ids = {r.pk for r in roots}
    out: list[Json] = []
    for task in found:
        parent = refs.get(task.parent_id, "") if task.pk not in root_ids else ""
        out.append(
            {
                "ref": refs[task.pk],
                "parent": parent,
                "title": task.title,
                "description": task.description or {},
                "priority": task.priority,
                "status": task.status.name,
                "start_offset": _offset_of(task.start_date, anchor),
                "due_offset": _offset_of(task.due_date, anchor),
                "due_time": task.due_time.strftime("%H:%M") if task.due_time else "",
                "assignee_ids": [str(a) for a in task.assignee_ids()] if assignees else [],
                "fields": _field_values(task, defs),
            }
        )
    return out


def workflow_of(project: Project) -> Json:
    workflow = workflows.ensure(project)
    statuses = list(project.statuses.order_by("position", "name"))
    return {
        "restrict": workflow.restrict_transitions,
        "restrict_creation": workflow.restrict_creation,
        "statuses": [
            {
                "key": str(s.pk),
                "name": s.name,
                "color": s.color,
                "category": s.category,
                "is_default": s.is_default,
            }
            for s in statuses
        ],
        "transitions": [
            {
                "from": str(t.from_status_id),
                "to": str(t.to_status_id),
                "require_assignee": t.require_assignee,
                "require_subtasks_done": t.require_subtasks_done,
            }
            for t in project.transitions.all()
        ],
    }


def fields_of(project: Project) -> list[Json]:
    return [
        {
            "key": str(f.pk),
            "name": f.name,
            "type": f.type,
            "options": f.options,
            "required": f.required,
            "default": f.default if f.type != FieldType.USER else "",
            "hidden_views": f.hidden_views,
        }
        for f in values.active_fields(project)
        if f.type in types.FieldType.values
    ]


def automations_of(project: Project) -> list[Json]:
    return [
        {
            "name": a.name,
            "enabled": a.enabled,
            "trigger": a.trigger,
            "condition": a.condition_ast or {},
            "actions": a.actions,
        }
        for a in Automation.objects.filter(project=project).order_by("created_at")
    ]
