"""The values tasks hold for custom fields: validation against the project's active fields,
required and default rules, saving, and reading them back onto tasks.

Used by ``infrastructure.tasks.services`` inside its own transaction; it never opens a project
or checks a permission itself (the task service already did).
"""

import json
import uuid
from collections.abc import Iterable, Mapping
from dataclasses import dataclass
from typing import Any

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import types
from infrastructure.customfields.models import FieldDefinition, FieldValue
from infrastructure.customfields.types import Stored
from infrastructure.projects.models import Project, ProjectMember, Visibility
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

KEY_PREFIX = "field:"  # how a field appears in ``Task.field_versions``


@dataclass(frozen=True, slots=True)
class Change:
    field: FieldDefinition
    stored: Stored


def active_fields(project: Project) -> list[FieldDefinition]:
    return list(FieldDefinition.objects.filter(project=project, archived_at__isnull=True))


def user_check(project: Project) -> types.UserCheck:
    """Accepts the id of an active workspace member who can open ``project`` (as assignees do)."""

    def check(raw: str) -> str:
        try:
            pk = uuid.UUID(raw)
        except ValueError:
            raise types.invalid("Choose a member of this project.") from None
        member = WorkspaceMember.objects.filter(
            workspace_id=project.workspace_id, user_id=pk, status=MemberStatus.ACTIVE
        ).exists()
        if project.visibility == Visibility.PRIVATE:
            member = member and ProjectMember.objects.filter(project=project, user_id=pk).exists()
        if not member:
            raise types.invalid("Choose a member of this project.")
        return str(pk)

    return check


def _clean(field: FieldDefinition, raw: str, check: types.UserCheck) -> Stored:
    return types.clean_value(field.type, field.options, raw, check)


def _missing(
    fields: Mapping[str, FieldDefinition], changes: Mapping[str, Change], creating: bool
) -> list[FieldDefinition]:
    out = []
    for key, field in fields.items():
        change = changes.get(key)
        if field.required and (change.stored.is_empty if change else creating):
            out.append(field)
    return out


def prepare(project: Project, sent: Mapping[str, str], *, creating: bool = False) -> list[Change]:
    """Validate ``sent`` (field id -> wire value). Clearing a required field, or creating a task
    without one that has no default, is ``FIELD_REQUIRED`` naming every such field. On
    ``creating`` the defaults fill the fields that were not sent."""
    fields = {str(f.pk): f for f in active_fields(project)}
    unknown = [key for key in sent if key not in fields]
    if unknown:
        raise types.invalid("One of the custom fields does not exist (or is archived).")
    check = user_check(project)
    changes = {
        key: Change(fields[key], _clean(fields[key], raw, check)) for key, raw in sent.items()
    }
    if creating:
        for key, field in fields.items():
            if key not in changes and field.default:
                # A default that no longer fits (its user left, say) is skipped, never a
                # reason to refuse the task: a required field is then reported missing.
                try:
                    changes[key] = Change(field, _clean(field, field.default, check))
                except ApiError:
                    continue
    missing = _missing(fields, changes, creating)
    if missing:
        names = ", ".join(f.name for f in missing)
        raise ApiError(
            f"These fields need a value: {names}.",
            title=ResponseTitle.FIELD_REQUIRED,
            data={"fields": json.dumps([str(f.pk) for f in missing])},
        )
    return list(changes.values())


def save(task: Any, changes: Iterable[Change]) -> None:
    for change in changes:
        if change.stored.is_empty:
            FieldValue.objects.filter(task=task, field=change.field).delete()
            continue
        FieldValue.objects.update_or_create(
            task=task,
            field=change.field,
            defaults={
                "value_text": change.stored.text,
                "value_number": change.stored.number,
                "value_date": change.stored.day,
                "value_json": change.stored.json,
            },
        )


def stored_of(row: FieldValue) -> Stored:
    return Stored(
        text=row.value_text, number=row.value_number, day=row.value_date, json=row.value_json
    )


def attach(tasks: list[Any]) -> list[Any]:
    """Set ``task.custom_values`` (field id -> wire value, active fields only) on each task, in
    one query."""
    for task in tasks:
        task.custom_values = {}
    by_id = {t.pk: t for t in tasks}
    rows = FieldValue.objects.filter(
        task_id__in=list(by_id), field__archived_at__isnull=True
    ).select_related("field")
    for row in rows:
        by_id[row.task_id].custom_values[str(row.field_id)] = types.render(
            row.field.type, stored_of(row)
        )
    return tasks


def current(task: Any, field_id: str) -> str:
    """The wire value a task holds for a field (``""`` when none)."""
    row = FieldValue.objects.filter(task=task, field_id=field_id).select_related("field").first()
    return types.render(row.field.type, stored_of(row)) if row else ""
