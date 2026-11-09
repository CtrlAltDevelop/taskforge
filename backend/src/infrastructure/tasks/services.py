"""Every task rule. gRPC renders the answer; nothing here knows a transport.

Order of checks: the workspace-level ``access.require`` first, then the project through
``projects.services.load`` (so an invisible or foreign project is the same 404), then the task
inside that project. Writes refuse an archived project and a trashed task.

A status change is checked against the project's workflow (``workflows.check_move``).

Edits are optimistic: ``update`` takes only the fields that changed plus ``expected_version``.
A field conflicts only if it changed after that version (``Task.field_versions``), so two people
editing different fields merge; the same field answers ``VERSION_CONFLICT`` with its current value.
"""

import base64
import binascii
import json
import uuid
from collections.abc import Callable
from typing import Any, Final

from django.contrib.auth import get_user_model
from django.db import transaction
from django.db.models import Prefetch, Q
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project, ProjectMember, Visibility
from infrastructure.tasks import fields, rank
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.tasks.signals import announce
from infrastructure.workflows import services as workflows
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

VIEW = "workspace.view"
PAGE_DEFAULT: Final = 100
PAGE_MAX: Final = 500
TRASH_MAX: Final = 200
SCALAR_FIELDS: Final[dict[str, Callable[[str], Any]]] = {
    "title": fields.clean_title,
    "description": fields.clean_description,
    "priority": fields.clean_priority,
    "start_date": fields.clean_date,
    "due_date": fields.clean_date,
}
EDITABLE: Final = (*SCALAR_FIELDS, "status", "assignee_ids")


def not_found() -> ApiError:
    return ApiError("No such task.", status=404)


def _with_assignees() -> Prefetch[Any]:
    return Prefetch("assignees", queryset=TaskAssignee.objects.only("task_id", "user_id"))


def _scoped(project: Project) -> Any:
    return Task.objects.filter(project=project).select_related("project", "status")


def _load_task(
    project: Project, task_id: str, *, lock: bool = False, trashed: bool = False
) -> Task:
    try:
        pk = uuid.UUID(str(task_id))
    except ValueError:
        raise not_found() from None
    rows = _scoped(project).filter(pk=pk, deleted_at__isnull=not trashed)
    row = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if row is None:
        raise not_found()
    return row


def _project(actor: Any, workspace: Workspace, project_id: str, key: str, lock: bool) -> Project:
    access.require(actor, key, workspace)
    return projects.load(actor, workspace, project_id, lock=lock)


def _writable_project(actor: Any, workspace: Workspace, project_id: str, key: str) -> Project:
    project = _project(actor, workspace, project_id, key, True)
    projects.writable(project)
    return project


def _assignees(project: Project, raw_ids: Any) -> list[Any]:
    """The users, if each is an active workspace member who can open ``project``."""
    ids: list[Any] = []
    for raw in raw_ids:
        try:
            ids.append(uuid.UUID(str(raw)))
        except ValueError:
            ids.append(str(raw))  # an integer pk or junk: resolved below, junk finds no user
    ids = list(dict.fromkeys(ids))  # the same user in any letter case counts once
    users = list(get_user_model().objects.filter(pk__in=_valid_pks(ids)))
    if len(users) != len(ids):
        raise ApiError("Every assignee must be a member of this project.")
    active = set(
        WorkspaceMember.objects.filter(
            workspace_id=project.workspace_id, user__in=users, status=MemberStatus.ACTIVE
        ).values_list("user_id", flat=True)
    )
    allowed = active
    if project.visibility == Visibility.PRIVATE:
        allowed = active & set(
            ProjectMember.objects.filter(project=project, user__in=users).values_list(
                "user_id", flat=True
            )
        )
    if {u.pk for u in users} - allowed:
        raise ApiError("Every assignee must be a member of this project.")
    return users


def _valid_pks(ids: list[Any]) -> list[Any]:
    pk_field = get_user_model()._meta.pk
    out = []
    for value in ids:
        try:
            out.append(pk_field.to_python(value))
        except Exception:  # noqa: BLE001 - any coercion failure just means "no such user"
            continue
    return out


def _clean(
    project: Project, changes: dict[str, Any], current: Task | None = None
) -> dict[str, Any]:
    """Validate ``changes`` into stored values (``assignee_ids`` becomes a list of users)."""
    unknown = set(changes) - set(EDITABLE)
    if unknown:
        raise ApiError(f"Unknown task field: {sorted(unknown)[0]}.")
    cleaned: dict[str, Any] = {
        name: SCALAR_FIELDS[name](value) for name, value in changes.items() if name in SCALAR_FIELDS
    }
    if "status" in changes:
        cleaned["status"] = workflows.status_of(project, changes["status"])
    if "assignee_ids" in changes:
        cleaned["assignee_ids"] = _assignees(project, changes["assignee_ids"])
    start = (
        cleaned["start_date"] if "start_date" in cleaned else getattr(current, "start_date", None)
    )
    due = cleaned["due_date"] if "due_date" in cleaned else getattr(current, "due_date", None)
    fields.check_range(start, due)
    return cleaned


def _set_assignees(task: Task, users: list[Any]) -> None:
    TaskAssignee.objects.filter(task=task).delete()
    TaskAssignee.objects.bulk_create([TaskAssignee(task=task, user=u) for u in users])


def _reload(task: Task) -> Task:
    return _scoped(task.project).prefetch_related(_with_assignees()).get(pk=task.pk)


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    title: str,
    *,
    description: str = "",
    status: str = "",
    priority: str = "none",
    start_date: str = "",
    due_date: str = "",
    assignee_ids: Any = (),
) -> Task:
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.create")
        cleaned = _clean(
            project,
            {
                "title": title,
                "description": description,
                "status": status or str(workflows.default_status(project).pk),
                "priority": priority,
                "start_date": start_date,
                "due_date": due_date,
                "assignee_ids": list(assignee_ids),
            },
        )
        users = cleaned.pop("assignee_ids")
        workflows.check_create(project, cleaned["status"])
        number = projects.next_task_number(project)
        last = (
            Task.objects.filter(project=project)
            .order_by("-position")
            .values_list("position", flat=True)
        ).first()
        task = Task.objects.create(
            workspace=workspace,
            project=project,
            number=number,
            created_by=actor,
            position=rank.after(last),
            **cleaned,
        )
        _set_assignees(task, users)
        announce(task, "created")
    return _reload(task)


def get(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    project = _project(actor, workspace, project_id, VIEW, False)
    task = _load_task(project, task_id)
    return _reload(task)


def _conflict(task: Task, name: str) -> ApiError:
    if name == "assignee_ids":
        current: Any = ",".join(sorted(str(i) for i in task.assignee_ids()))
    elif name == "status":
        current = str(task.status_id)
    else:
        value = getattr(task, name)
        current = (
            json.dumps(value) if name == "description" else "" if value is None else str(value)
        )
    return ApiError(
        "Someone else changed this first; reload and retry.",
        status=409,
        title=ResponseTitle.VERSION_CONFLICT,
        data={"field": name, "current": current, "version": task.version},
    )


def update(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    expected_version: int,
    changes: dict[str, Any],
) -> Task:
    if not changes:
        raise ApiError("Send at least one field to change.")
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.update")
        task = _load_task(project, task_id, lock=True)
        if not 1 <= expected_version <= task.version:
            raise ApiError("expected_version must be between 1 and the task's current version.")
        cleaned = _clean(project, changes, task)
        seen = task.field_versions
        for name in changes:
            if seen.get(name, 1) > expected_version:
                raise _conflict(task, name)
        users = cleaned.pop("assignee_ids", None)
        if "status" in cleaned:
            workflows.check_move(
                actor,
                workspace,
                project,
                task.status,
                cleaned["status"],
                assignee_count=len(users) if users is not None else task.assignees.count(),
            )
        task.version += 1
        for name, value in cleaned.items():
            setattr(task, name, value)
        task.field_versions = {**seen, **{name: task.version for name in changes}}
        task.updated_at = timezone.now()
        task.save()
        if users is not None:
            _set_assignees(task, users)
        announce(task, "updated")
    return _reload(task)


def move(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    expected_version: int,
    status_id: str,
) -> Task:
    """Change only the status of a task: ``update`` with the workflow's rules applied."""
    return update(actor, workspace, project_id, task_id, expected_version, {"status": status_id})


def _soft(task: Task, deleted: bool) -> Task:
    task.deleted_at = timezone.now() if deleted else None
    task.version += 1
    task.updated_at = timezone.now()
    task.save(update_fields=["deleted_at", "version", "updated_at"])
    announce(task, "deleted" if deleted else "restored")
    return _reload(task)


def delete(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.delete")
        return _soft(_load_task(project, task_id, lock=True), True)


def restore(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.delete")
        return _soft(_load_task(project, task_id, lock=True, trashed=True), False)


def list_trash(
    actor: Any, workspace: Workspace, project_id: str, *, limit: int = TRASH_MAX
) -> list[Task]:
    """The project's deleted tasks, newest deletion first (for whoever may restore them)."""
    project = _project(actor, workspace, project_id, "task.delete", False)
    rows = _scoped(project).filter(deleted_at__isnull=False).order_by("-deleted_at", "-number")
    return list(rows.prefetch_related(_with_assignees())[: max(1, min(limit, TRASH_MAX))])


def _decode(cursor: str) -> tuple[str, int] | None:
    if not cursor:
        return None
    try:
        position, number = json.loads(base64.urlsafe_b64decode(cursor.encode()))
        return str(position), int(number)
    except (ValueError, TypeError, binascii.Error):
        raise ApiError("That cursor is not valid.") from None


def _encode(task: Task) -> str:
    return base64.urlsafe_b64encode(json.dumps([task.position, task.number]).encode()).decode()


def list_page(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    status: str = "",
    assignee_id: str = "",
    cursor: str = "",
    limit: int = PAGE_DEFAULT,
) -> tuple[list[Task], str]:
    """One keyset page in board order and the cursor of the next ('' at the end)."""
    project = _project(actor, workspace, project_id, VIEW, False)
    rows = _scoped(project).filter(deleted_at__isnull=True)
    if status:
        rows = rows.filter(status=workflows.status_of(project, status))
    if assignee_id:
        rows = rows.filter(assignees__user_id__in=_valid_pks([assignee_id]) or [None])
    after = _decode(cursor)
    if after:
        position, number = after
        rows = rows.filter(Q(position__gt=position) | Q(position=position, number__gt=number))
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    found = list(
        rows.order_by("position", "number").prefetch_related(_with_assignees())[: size + 1]
    )
    page = found[:size]
    return page, _encode(page[-1]) if len(found) > size else ""
