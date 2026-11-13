"""Names for the ids that entries mention, looked up together (one query per kind)."""

from collections.abc import Iterable
from typing import Any

# changes keys whose values (or before/after pair) are ids of a kind we can name.
STATUS_KEYS = ("status_id", "from_status_id", "to_status_id")
SPRINT_KEYS = ("sprint_id",)
TASK_KEYS = ("parent_id", "to_task_id")
PERSON_KEYS = ("user_id", "owner_id")


def _ids(entries: Iterable[Any], keys: tuple[str, ...]) -> set[str]:
    found: set[str] = set()
    for entry in entries:
        for key in keys:
            value = entry.changes.get(key)
            for one in value if isinstance(value, list) else [value]:
                if isinstance(one, str) and one:
                    found.add(one)
    return found


def _people(entries: Iterable[Any]) -> set[str]:
    found = {e.actor for e in entries if e.actor_type == "user" and e.actor}
    found |= _ids(entries, PERSON_KEYS)
    for entry in entries:
        for pair in entry.changes.get("assignees", []) if entry.changes else []:
            found |= {str(p) for p in pair} if isinstance(pair, list) else set()
    if "member" in {e.target_type for e in entries}:
        found |= {e.target_id for e in entries if e.target_type == "member"}
    return found


def label_ids(workspace: Any, entries: list[Any], *, reader: Any = None) -> dict[str, str]:
    """``{id: name}`` for every person, status, sprint and task the entries refer to (those of
    this workspace only). With a ``reader``, titles of tasks in projects they cannot open are left
    out: a task's history must not name a private task it once linked to."""
    from django.contrib.auth import get_user_model

    from infrastructure.sprints.models import Sprint
    from infrastructure.tasks.models import Task
    from infrastructure.workflows.models import Status

    names: dict[str, str] = {}
    statuses = _ids(entries, STATUS_KEYS)
    if statuses:
        for pk, name in Status.objects.filter(
            pk__in=statuses, project__workspace=workspace
        ).values_list("pk", "name"):
            names[str(pk)] = name
    sprints = _ids(entries, SPRINT_KEYS)
    if sprints:
        for pk, name in Sprint.objects.filter(pk__in=sprints, workspace=workspace).values_list(
            "pk", "name"
        ):
            names[str(pk)] = name
    tasks = _ids(entries, TASK_KEYS)
    if tasks:
        rows = Task.objects.filter(pk__in=tasks, workspace=workspace)
        if reader is not None:
            from infrastructure.projects.models import Project

            rows = rows.filter(project__in=Project.objects.visible_to(reader, workspace))
        for pk, title in rows.values_list("pk", "title"):
            names[str(pk)] = title
    forms = {e.actor for e in entries if e.actor_type == "form" and e.actor}
    if forms:
        from infrastructure.forms.models import Form

        for pk, name in Form.objects.filter(pk__in=_valid(forms), workspace=workspace).values_list(
            "pk", "name"
        ):
            names[str(pk)] = f"Form: {name}"
    people = _people(entries)
    if people:
        for user in get_user_model().objects.filter(pk__in=_valid(people)):
            names[str(user.pk)] = user.get_full_name() or user.get_username()
    return names


def _valid(ids: set[str]) -> list[str]:
    import uuid

    ok = []
    for raw in ids:
        try:
            ok.append(str(uuid.UUID(raw)))
        except ValueError:
            continue
    return ok


def name_of(names: dict[str, str], key: str) -> str:
    return names.get(key, "")
