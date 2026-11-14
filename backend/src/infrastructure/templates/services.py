"""Templates, the management side: gallery, read, create, edit, delete and save-from-live.

Anyone who can see the workspace sees its shared templates, the built-in ones and their own
private ones (somebody else's private template is a 404). Saving needs ``template.create``;
editing or deleting needs to be the creator or to hold ``template.manage``. Applying is in
``apply``.
"""

import json
import uuid
from dataclasses import dataclass
from typing import Any, Final

from django.db import transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.tasks import services as task_services
from infrastructure.templates import builtin, content, snapshot
from infrastructure.templates.models import Template, TemplateKind, TemplateVisibility
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

CREATE: Final = "template.create"
MANAGE: Final = "template.manage"
VIEW: Final = "workspace.view"
EDITABLE: Final = frozenset({"name", "description", "visibility", "content_json"})


@dataclass(frozen=True, slots=True)
class TemplateView:
    id: str
    kind: str
    name: str
    description: str
    visibility: str
    is_builtin: bool
    created_by: str
    created_at: str
    updated_at: str
    version: int
    task_count: int
    variables: list[str]
    includes: list[str]
    status_names: list[str]
    can_edit: bool
    content: dict[str, Any]


def not_found() -> ApiError:
    return ApiError("No such template.", status=404, title=ResponseTitle.NOT_FOUND)


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _clean_name(raw: str) -> str:
    name = raw.strip()
    if not name or len(name) > 80:
        raise ApiError("The name must be 1-80 characters.")
    return name


def _clean_description(raw: str) -> str:
    text = raw.strip()
    if len(text) > 500:
        raise ApiError("The description must be at most 500 characters.")
    return text


def _clean_visibility(raw: str) -> str:
    if raw not in TemplateVisibility.values:
        raise ApiError("Visibility must be 'workspace' or 'private'.")
    return raw


def _can_edit(actor: Any, workspace: Workspace, row: Template) -> bool:
    if (
        row.created_by_id == getattr(actor, "pk", None)
        and access.can(actor, CREATE, workspace).allowed
    ):
        return True
    return access.can(actor, MANAGE, workspace).allowed


def _view(actor: Any, workspace: Workspace, row: Template) -> TemplateView:
    return TemplateView(
        id=str(row.pk),
        kind=row.kind,
        name=row.name,
        description=row.description,
        visibility=row.visibility,
        is_builtin=False,
        created_by=str(row.created_by_id or ""),
        created_at=_iso(row.created_at),
        updated_at=_iso(row.updated_at),
        version=row.version,
        task_count=row.task_count,
        variables=content.variables(row.content),
        includes=content.includes(row.content),
        status_names=content.status_names(row.content),
        can_edit=_can_edit(actor, workspace, row),
        content=row.content,
    )


def _builtin_view(item: builtin.Builtin) -> TemplateView:
    body = content.clean(TemplateKind.PROJECT, item.content)
    return TemplateView(
        id=item.id,
        kind=TemplateKind.PROJECT,
        name=item.name,
        description=item.description,
        visibility=TemplateVisibility.WORKSPACE,
        is_builtin=True,
        created_by="",
        created_at="",
        updated_at="",
        version=1,
        task_count=len(body["tasks"]),
        variables=content.variables(body),
        includes=content.includes(body),
        status_names=content.status_names(body),
        can_edit=False,
        content=body,
    )


def _visible(actor: Any, workspace: Workspace) -> Any:
    return Template.objects.filter(workspace=workspace).filter(
        Q(visibility=TemplateVisibility.WORKSPACE) | Q(created_by=actor)
    )


def _row(actor: Any, workspace: Workspace, template_id: str, *, lock: bool = False) -> Template:
    try:
        pk = uuid.UUID(str(template_id))
    except ValueError:
        raise not_found() from None
    rows = _visible(actor, workspace).filter(pk=pk)
    row = (rows.select_for_update() if lock else rows).first()
    if row is None:
        raise not_found()
    return row


def _writable(actor: Any, workspace: Workspace, template_id: str) -> Template:
    if template_id.startswith(builtin.PREFIX):
        raise ApiError("Built-in templates cannot be changed.", status=403)
    row = _row(actor, workspace, template_id, lock=True)
    if not _can_edit(actor, workspace, row):
        access.require(actor, MANAGE, workspace)
    return row


def load_content(actor: Any, workspace: Workspace, template_id: str) -> tuple[str, str, Any]:
    """``(kind, name, content)`` of a template the caller may use."""
    access.require(actor, VIEW, workspace)
    if template_id.startswith(builtin.PREFIX):
        item = builtin.BY_ID.get(template_id)
        if item is None:
            raise not_found()
        return TemplateKind.PROJECT, item.name, content.clean(TemplateKind.PROJECT, item.content)
    row = _row(actor, workspace, template_id)
    return row.kind, row.name, row.content


def list_templates(
    actor: Any, workspace: Workspace, query: str = "", kind: str = ""
) -> list[TemplateView]:
    """Built-ins first, then saved ones by name; ``query`` matches name and description."""
    access.require(actor, VIEW, workspace)
    needle = query.strip().lower()

    def wanted(name: str, description: str, one_kind: str) -> bool:
        if kind and kind != one_kind:
            return False
        return not needle or needle in name.lower() or needle in description.lower()

    found = [
        _builtin_view(b)
        for b in builtin.BUILTINS
        if wanted(b.name, b.description, TemplateKind.PROJECT)
    ]
    rows = _visible(actor, workspace).order_by("name", "created_at")
    found += [_view(actor, workspace, r) for r in rows if wanted(r.name, r.description, r.kind)]
    return found


def get(actor: Any, workspace: Workspace, template_id: str) -> TemplateView:
    access.require(actor, VIEW, workspace)
    if template_id.startswith(builtin.PREFIX):
        item = builtin.BY_ID.get(template_id)
        if item is None:
            raise not_found()
        return _builtin_view(item)
    return _view(actor, workspace, _row(actor, workspace, template_id))


def _audit(row: Template, action: str, changes: dict[str, Any], actor: Any) -> None:
    recorder.record(
        workspace_id=row.workspace_id,
        action=action,
        target_type="template",
        target_id=row.pk,
        changes=changes,
        actor=actor,
    )


def _store(
    actor: Any,
    workspace: Workspace,
    kind: str,
    name: str,
    description: str,
    visibility: str,
    body: dict[str, Any],
) -> TemplateView:
    access.require(actor, CREATE, workspace)
    row = Template.objects.create(
        workspace=workspace,
        kind=kind,
        name=_clean_name(name),
        description=_clean_description(description),
        visibility=_clean_visibility(visibility),
        content=body,
        task_count=len(body["tasks"]),
        created_by=actor,
    )
    _audit(row, "template.created", {"name": row.name, "kind": kind}, actor)
    return _view(actor, workspace, row)


def create(
    actor: Any,
    workspace: Workspace,
    kind: str,
    name: str,
    description: str,
    visibility: str,
    content_json: str,
) -> TemplateView:
    if kind not in TemplateKind.values:
        raise ApiError("The kind must be 'task' or 'project'.")
    try:
        raw = json.loads(content_json or "{}")
    except (ValueError, RecursionError):
        raise ApiError("The content is not JSON.") from None
    with transaction.atomic():
        return _store(
            actor, workspace, kind, name, description, visibility, content.clean(kind, raw)
        )


def update(
    actor: Any,
    workspace: Workspace,
    template_id: str,
    expected_version: int,
    **changes: str,
) -> TemplateView:
    with transaction.atomic():
        row = _writable(actor, workspace, template_id)
        if row.version != expected_version:
            raise ApiError(
                "The template changed since you loaded it; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
            )
        done: dict[str, Any] = {}
        if "name" in changes:
            row.name = _clean_name(changes["name"])
            done["name"] = row.name
        if "description" in changes:
            row.description = _clean_description(changes["description"])
            done["description"] = row.description
        if "visibility" in changes:
            row.visibility = _clean_visibility(changes["visibility"])
            done["visibility"] = row.visibility
        if "content_json" in changes:
            try:
                raw = json.loads(changes["content_json"] or "{}")
            except (ValueError, RecursionError):
                raise ApiError("The content is not JSON.") from None
            row.content = content.clean(row.kind, raw)
            row.task_count = len(row.content["tasks"])
            done["content"] = True
        row.version += 1
        row.updated_at = timezone.now()
        row.save()
        _audit(row, "template.updated", done, actor)
        return _view(actor, workspace, row)


def delete(actor: Any, workspace: Workspace, template_id: str) -> None:
    with transaction.atomic():
        row = _writable(actor, workspace, template_id)
        _audit(row, "template.deleted", {"name": row.name}, actor)
        row.delete()


def save_from_task(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    name: str,
    description: str,
    visibility: str,
    include_assignees: bool,
) -> TemplateView:
    """The task and everything under it, with dates as offsets from the earliest one."""
    access.require(actor, CREATE, workspace)
    access.require(actor, VIEW, workspace)
    project = projects.load(actor, workspace, project_id)
    root = task_services.load_task(project, task_id)
    body = {
        "schema": content.SCHEMA,
        "tasks": snapshot.tasks_of(project, [root], assignees=include_assignees),
    }
    with transaction.atomic():
        return _store(actor, workspace, TemplateKind.TASK, name, description, visibility, body)


def save_from_project(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    name: str,
    description: str,
    visibility: str,
    include: list[str],
    include_assignees: bool,
) -> TemplateView:
    """``include`` picks from ``content.INCLUDES``; automations need ``automation.manage``."""
    unknown = sorted(set(include) - set(content.INCLUDES))
    if unknown:
        raise ApiError(f"Unknown parts to include: {', '.join(unknown)}.")
    access.require(actor, CREATE, workspace)
    access.require(actor, VIEW, workspace)
    project = projects.load(actor, workspace, project_id)
    body: dict[str, Any] = {"schema": content.SCHEMA, "tasks": []}
    if "features" in include:
        body["features"] = sorted(projects.enabled_features(project))
    if "workflow" in include:
        body["workflow"] = snapshot.workflow_of(project)
    if "fields" in include:
        body["fields"] = snapshot.fields_of(project)
    if "automations" in include:
        access.require(actor, "automation.manage", workspace)
        body["automations"] = snapshot.automations_of(project)
    if "tasks" in include:
        body["tasks"] = snapshot.tasks_of(project, [], assignees=include_assignees)
        if "fields" not in include:
            body["tasks"] = [{**t, "fields": []} for t in body["tasks"]]
    with transaction.atomic():
        return _store(actor, workspace, TemplateKind.PROJECT, name, description, visibility, body)
