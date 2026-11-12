"""Every custom-field rule: definitions of a project's fields. gRPC renders the answer.

Reading needs ``workspace.view`` (and a visible project). Creating, editing, reordering,
archiving and restoring need ``project.update`` (a project's creator has it for their own
project) and a project that is not archived. Values on tasks are in ``values`` and are saved by
the task service under ``task.update``.

A definition is edited whole and guarded by its ``version`` (a stale one is ``VERSION_CONFLICT``).
Removing an option that tasks use needs a ``remap`` (old option id -> a kept option, or ``""`` to
clear those values) or the call answers ``OPTION_NEEDS_REMAP`` listing the options and how many
values each holds. A type may change only between text and url. Archiving keeps the values for
``RESTORE_DAYS``; ``purge_expired`` then deletes the field for good.
"""

import json
import uuid
from collections.abc import Mapping
from datetime import timedelta
from typing import Any, Final

from django.db import transaction
from django.db.models import F
from django.utils import timezone

from infrastructure.audit import changes as audit_changes
from infrastructure.audit import context as audit_context
from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import types, values
from infrastructure.customfields.models import FieldDefinition, FieldType, FieldValue
from infrastructure.customfields.signals import announce
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.tasks.signals import announce as announce_task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
EDIT = "project.update"
MAX_ACTIVE: Final = 50
RESTORE_DAYS: Final = 30
TOUCH_BATCH: Final = 500
EDITABLE: Final = ("name", "type", "options", "required", "default", "hidden_views")


def not_found() -> ApiError:
    return ApiError("No such field.", status=404)


def _name_taken() -> ApiError:
    return ApiError(
        "A field with that name already exists in this project.",
        status=409,
        title=ResponseTitle.FIELD_NAME_TAKEN,
    )


def _active(project: Project) -> Any:
    return FieldDefinition.objects.filter(project=project, archived_at__isnull=True)


def _writable(actor: Any, workspace: Workspace, project_id: str) -> Project:
    project = projects.authorize(actor, workspace, project_id, EDIT, lock=True)
    projects.writable(project)
    return project


def _load(project: Project, field_id: str, *, archived: bool = False) -> FieldDefinition:
    try:
        pk = uuid.UUID(str(field_id))
    except ValueError:
        raise not_found() from None
    rows = FieldDefinition.objects.select_for_update().filter(project=project, pk=pk)
    field = rows.filter(archived_at__isnull=not archived).first()
    if field is None:
        raise not_found()
    return field


def _check_free(project: Project, name: str, *, besides: FieldDefinition | None = None) -> None:
    rows = _active(project).filter(name__iexact=name)
    if besides is not None:
        rows = rows.exclude(pk=besides.pk)
    if rows.exists():
        raise _name_taken()


def _check_room(project: Project) -> None:
    if _active(project).count() >= MAX_ACTIVE:
        raise ApiError(
            f"A project can have at most {MAX_ACTIVE} active custom fields.",
            title=ResponseTitle.FIELD_LIMIT,
        )


def list_fields(
    actor: Any, workspace: Workspace, project_id: str, *, include_archived: bool = False
) -> list[FieldDefinition]:
    """The active fields in order; ``include_archived`` adds the ones still restorable (for
    people who may edit fields)."""
    if include_archived:
        project = projects.authorize(actor, workspace, project_id, EDIT)
    else:
        access.require(actor, VIEW, workspace)
        project = projects.load(actor, workspace, project_id)
    rows = FieldDefinition.objects.filter(project=project)
    if not include_archived:
        rows = rows.filter(archived_at__isnull=True)
    return list(rows.order_by(F("archived_at").asc(nulls_first=True), "position", "created_at"))


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    name: str,
    type: str,  # noqa: A002 - the field's own name on the wire
    options: list[dict[str, str]] = (),  # type: ignore[assignment]
    required: bool = False,
    default: str = "",
    hidden_views: list[str] = (),  # type: ignore[assignment]
) -> FieldDefinition:
    with transaction.atomic():
        project = _writable(actor, workspace, project_id)
        clean_name = types.clean_name(name)
        kind = types.clean_type(type)
        kept = types.clean_options(kind, options)
        _check_free(project, clean_name)
        _check_room(project)
        default_wire = _clean_default(project, kind, kept, default)
        last = _active(project).order_by("-position").first()
        field = FieldDefinition.objects.create(
            project=project,
            name=clean_name,
            type=kind,
            options=kept,
            required=required,
            default=default_wire,
            hidden_views=types.clean_hidden_views(hidden_views),
            position=last.position + 1 if last else 0,
        )
        announce(project, field.version)
    return field


def _clean_default(project: Project, kind: str, options: list[dict[str, str]], raw: str) -> str:
    """The default in its canonical wire form (``""``: none), or ``FIELD_INVALID``."""
    stored = types.clean_value(kind, options, raw, values.user_check(project))
    return types.render(kind, stored)


def _remap_wire(kind: str, wire: str, remap: Mapping[str, str], kept: set[str]) -> str:
    """``wire`` with removed options replaced by their remap target, and dropped when the result
    is not a kept option."""
    if not wire or kind not in types.SELECT_TYPES:
        return wire
    parts = [remap.get(part, part) for part in wire.split(",")]
    return ",".join(dict.fromkeys(p for p in parts if p in kept))


def _usage(field: FieldDefinition, removed: set[str]) -> dict[str, int]:
    """How many values hold each removed option."""
    counts = dict.fromkeys(removed, 0)
    rows = FieldValue.objects.filter(field=field)
    if field.type == FieldType.SELECT:
        for option in rows.filter(value_text__in=removed).values_list("value_text", flat=True):
            counts[option] += 1
    else:
        for ids in rows.filter(value_json__isnull=False).values_list("value_json", flat=True):
            for option in removed.intersection(ids):
                counts[option] += 1
    return {option: n for option, n in counts.items() if n}


def _needs_remap(usage: dict[str, int]) -> ApiError:
    return ApiError(
        "Some removed options are still used: choose what their values become.",
        status=409,
        title=ResponseTitle.OPTION_NEEDS_REMAP,
        data={"options": json.dumps(usage)},
    )


def _touch(field: FieldDefinition, task_ids: list[Any]) -> None:
    """Count an edit of ``field`` on each task (so holders of an older copy see a conflict)."""
    now = timezone.now()
    key = values.KEY_PREFIX + str(field.pk)
    for start in range(0, len(task_ids), TOUCH_BATCH):
        batch = list(
            Task.objects.select_for_update().filter(pk__in=task_ids[start : start + TOUCH_BATCH])
        )
        for task in batch:
            task.version += 1
            task.field_versions = {**task.field_versions, key: task.version}
            task.updated_at = now
        Task.objects.bulk_update(batch, ["version", "field_versions", "updated_at"])
        for task in batch:
            announce_task(task, "updated")


def _apply_remap(field: FieldDefinition, remap: Mapping[str, str], removed: set[str]) -> None:
    touched: list[Any] = []
    for row in FieldValue.objects.filter(field=field).select_for_update():
        if field.type == FieldType.SELECT:
            if row.value_text not in removed:
                continue
            target = remap.get(row.value_text, "")
            if target:
                row.value_text = target
                row.save(update_fields=["value_text"])
            else:
                row.delete()
        else:
            ids = row.value_json or []
            if not removed.intersection(ids):
                continue
            kept = [
                i for i in dict.fromkeys(remap.get(i, i) if i in removed else i for i in ids) if i
            ]
            if kept:
                row.value_json = kept
                row.save(update_fields=["value_json"])
            else:
                row.delete()
        touched.append(row.task_id)
    _touch(field, touched)


def _check_type_change(field: FieldDefinition, new_type: str) -> None:
    if (field.type, new_type) not in types.COMPATIBLE_CHANGES:
        raise types.invalid(
            f"A {field.type} field cannot become {new_type}: create a new field instead."
        )
    bad = 0
    for text in FieldValue.objects.filter(field=field).values_list("value_text", flat=True):
        try:
            types.clean_value(new_type, [], text, lambda raw: raw)
        except ApiError:
            bad += 1
    if bad:
        raise types.invalid(f"{bad} value(s) would not be valid as {new_type}: fix them first.")


def update(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    field_id: str,
    expected_version: int,
    changes: Mapping[str, Any],
    remap: Mapping[str, str] | None = None,
) -> FieldDefinition:
    """Edit a definition. ``changes`` holds only the attributes to change (``EDITABLE``)."""
    unknown = set(changes) - set(EDITABLE)
    if unknown or not changes:
        raise types.invalid("Send at least one editable field attribute to change.")
    remap = dict(remap or {})
    with transaction.atomic():
        project = _writable(actor, workspace, project_id)
        field = _load(project, field_id)
        if field.version != expected_version:
            raise ApiError(
                "This field changed since you opened it; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        _apply_changes(project, field, changes, remap)
        field.version += 1
        field.save()
        announce(project, field.version)
    return field


def _apply_changes(
    project: Project, field: FieldDefinition, changes: Mapping[str, Any], remap: dict[str, str]
) -> None:
    kind = field.type
    if "type" in changes and changes["type"] != field.type:
        kind = types.clean_type(changes["type"])
        _check_type_change(field, kind)
    if "name" in changes:
        field.name = types.clean_name(changes["name"])
        _check_free(project, field.name, besides=field)
    if "required" in changes:
        field.required = bool(changes["required"])
    if "hidden_views" in changes:
        field.hidden_views = types.clean_hidden_views(changes["hidden_views"])
    old_options = field.options
    new_options = types.clean_options(kind, changes.get("options", old_options))
    removed = set(types.option_ids(old_options)) - set(types.option_ids(new_options))
    if removed:
        _remap_removed(field, new_options, removed, remap)
    kept_ids = set(types.option_ids(new_options))
    redo = "default" in changes or "options" in changes or kind != field.type
    default = (
        changes["default"]
        if "default" in changes
        else _remap_wire(kind, field.default, remap, kept_ids)
    )
    field.type, field.options = kind, new_options
    # An untouched default is left as stored: it is not re-checked against who is a member now.
    if redo:
        field.default = _clean_default(project, kind, new_options, default)


def _remap_removed(
    field: FieldDefinition, kept: list[dict[str, str]], removed: set[str], remap: dict[str, str]
) -> None:
    usage = _usage(field, removed)
    if any(option not in remap for option in usage):
        raise _needs_remap(usage)
    allowed = set(types.option_ids(kept))
    if any(target and target not in allowed for target in remap.values()):
        raise types.invalid("A value cannot be remapped to an option that does not exist.")
    if usage:
        _apply_remap(field, remap, removed)


def reorder(
    actor: Any, workspace: Workspace, project_id: str, field_ids: list[str]
) -> list[FieldDefinition]:
    """Give the active fields the order of ``field_ids``, which must name every one of them."""
    with transaction.atomic():
        project = _writable(actor, workspace, project_id)
        fields = {str(f.pk): f for f in _active(project).select_for_update()}
        if sorted(field_ids) != sorted(fields):
            raise types.invalid("Send every active field exactly once to reorder them.")
        for position, key in enumerate(field_ids):
            audit_changes.update_rows(
                FieldDefinition.objects.filter(pk=fields[key].pk), position=position
            )
        announce(project)
    return list_fields(actor, workspace, project_id)


def archive(
    actor: Any, workspace: Workspace, project_id: str, field_id: str, expected_version: int
) -> FieldDefinition:
    return _flip(actor, workspace, project_id, field_id, expected_version, archiving=True)


def restore(
    actor: Any, workspace: Workspace, project_id: str, field_id: str, expected_version: int
) -> FieldDefinition:
    return _flip(actor, workspace, project_id, field_id, expected_version, archiving=False)


def _flip(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    field_id: str,
    expected_version: int,
    *,
    archiving: bool,
) -> FieldDefinition:
    with transaction.atomic():
        project = _writable(actor, workspace, project_id)
        field = _load(project, field_id, archived=not archiving)
        if field.version != expected_version:
            raise ApiError(
                "This field changed since you opened it; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        if archiving:
            field.archived_at = timezone.now()
        else:
            expires = field.archived_at + timedelta(days=RESTORE_DAYS)
            if expires <= timezone.now():
                raise not_found()
            _check_free(project, field.name)
            _check_room(project)
            field.archived_at = None
        field.version += 1
        field.save()
        _touch_holders(field)
        announce(project, field.version)
    return field


def _touch_holders(field: FieldDefinition) -> None:
    """Archiving or restoring changes what every task shows: count it as an edit on each holder."""
    _touch(field, list(FieldValue.objects.filter(field=field).values_list("task_id", flat=True)))


def purge_expired(now: Any = None) -> int:
    """Delete fields archived more than ``RESTORE_DAYS`` ago, with their values."""
    cutoff = (now or timezone.now()) - timedelta(days=RESTORE_DAYS)
    expired = FieldDefinition.objects.filter(archived_at__lt=cutoff)
    count = expired.count()
    with transaction.atomic(), audit_context.suppressed():
        # Their values go with them: one entry per field, not one per value.
        for field in expired.select_related("project"):
            recorder.record(
                workspace_id=field.project.workspace_id,
                action="field.purged",
                target_type="project",
                target_id=field.project_id,
                project_id=field.project_id,
                actor_type="system",
                changes={"field_id": field.pk, "name": field.name},
            )
        expired.delete()
    return count
