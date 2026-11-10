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
from infrastructure.tasks import fields, tree
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.tasks.signals import announce
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Category, Status
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
    parent_id: str = "",
) -> Task:
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.create")
        parent = _live_parent(project, parent_id) if parent_id else None
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
        task_id = uuid.uuid4()
        position = tree.next_position(project.pk, parent.pk if parent else None)
        depth, path, tree_key = tree.placement(parent, task_id, position)
        tree.check_depth(depth)
        task = Task.objects.create(
            id=task_id,
            workspace=workspace,
            project=project,
            number=number,
            created_by=actor,
            position=position,
            parent=parent,
            depth=depth,
            path=path,
            tree_key=tree_key,
            **cleaned,
        )
        _set_assignees(task, users)
        tree.refresh_above(task)
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
    elif name == "parent":
        current = str(task.parent_id or "")
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
    *,
    subtasks_taken: bool = False,
) -> Task:
    """``subtasks_taken``: the caller moves the open subtasks along in the same transaction; when
    the target is a done status that satisfies a "subtasks done" condition on this move (``move``
    with subtasks), otherwise they would not be done and the condition is checked as usual."""
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
                open_subtasks=(
                    (lambda: 0)
                    if subtasks_taken and cleaned["status"].category == Category.DONE
                    else (lambda: tree.open_subtasks(task))
                ),
            )
        task.version += 1
        for name, value in cleaned.items():
            setattr(task, name, value)
        task.field_versions = {**seen, **{name: task.version for name in changes}}
        task.updated_at = timezone.now()
        task.save()
        if users is not None:
            _set_assignees(task, users)
        if "status" in cleaned:
            tree.refresh_above(task)
        announce(task, "updated")
    return _reload(task)


def move(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    expected_version: int,
    status_id: str,
    *,
    with_subtasks: bool = False,
) -> Task:
    """Change only the status of a task: ``update`` with the workflow's rules applied.

    ``with_subtasks`` also moves every open subtask to that status in the same transaction (a
    subtask already done is left alone when the target is a done status). Each of them must be
    allowed to make that move, or nothing at all is moved.
    """
    if not with_subtasks:
        return update(
            actor, workspace, project_id, task_id, expected_version, {"status": status_id}
        )
    with transaction.atomic():
        task = update(
            actor,
            workspace,
            project_id,
            task_id,
            expected_version,
            {"status": status_id},
            subtasks_taken=True,
        )
        _move_open_subtasks(actor, workspace, task.project, task, task.status)
    return _reload(task)


def _move_open_subtasks(
    actor: Any, workspace: Workspace, project: Project, task: Task, target: Status
) -> None:
    now = timezone.now()
    moved: list[Task] = []
    rows = (
        tree.descendants(task)
        .exclude(status__category__in=tree.FINAL)  # finished ones (done, cancelled) are left alone
        .select_related("status")
        .select_for_update(of=("self",))
    )
    for sub in rows.order_by("depth", "tree_key"):
        if sub.status_id == target.pk:
            continue
        workflows.check_move(
            actor, workspace, project, sub.status, target, assignee_count=sub.assignees.count()
        )
        sub.status = target
        sub.version += 1
        sub.field_versions = {**sub.field_versions, "status": sub.version}
        sub.updated_at = now
        moved.append(sub)
    if not moved:
        return
    Task.objects.bulk_update(moved, ["status", "version", "field_versions", "updated_at"])
    for sub in moved:
        announce(sub, "updated")
    with_children = tree.descendants(task).filter(progress_total__gt=0)
    tree.refresh_progress(
        [task.pk, *tree.ancestor_ids(task), *with_children.values_list("pk", flat=True)]
    )


def _live_parent(project: Project, parent_id: str) -> Task:
    """The live task ``parent_id`` of ``project``, else a 400 (a foreign id is just unknown)."""
    try:
        pk = uuid.UUID(str(parent_id))
    except ValueError:
        raise ApiError("That parent task does not exist in this project.") from None
    parent = (
        Task.objects.filter(project=project, pk=pk, deleted_at__isnull=True)
        .select_related("project")
        .first()
    )
    if parent is None:
        raise ApiError("That parent task does not exist in this project.")
    return parent


def _bump(rows: list[Task], now: Any, **changes: Any) -> None:
    """Count one edit on each of ``rows`` (and set ``changes``), saved in one batch."""
    for row in rows:
        row.version += 1
        row.updated_at = now
        for name, value in changes.items():
            setattr(row, name, value)
    Task.objects.bulk_update(rows, ["version", "updated_at", *changes], batch_size=500)


def set_parent(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    expected_version: int,
    parent_id: str,
) -> Task:
    """Make ``task_id`` a subtask of ``parent_id`` (``""``: a top-level task), with everything
    under it. Never under itself or one of its own subtasks; same project; at most
    ``tree.MAX_DEPTH`` levels. Conflicts like any other field (``parent``)."""
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.update")
        task = _load_task(project, task_id, lock=True)
        if not 1 <= expected_version <= task.version:
            raise ApiError("expected_version must be between 1 and the task's current version.")
        if task.field_versions.get("parent", 1) > expected_version:
            raise _conflict(task, "parent")
        new_parent = _live_parent(project, parent_id) if parent_id else None
        if (new_parent.pk if new_parent else None) == task.parent_id:
            return _reload(task)
        if new_parent is not None and new_parent.path.startswith(task.path):
            raise ApiError(
                "A task cannot become a subtask of itself or of one of its own subtasks.",
                title=ResponseTitle.SUBTASK_CYCLE,
            )
        base_depth = new_parent.depth + 1 if new_parent else 0
        tree.check_depth(base_depth + tree.subtree_depth(task))
        touched = tree.move_subtree(task, new_parent)
        task.version += 1
        task.field_versions = {**task.field_versions, "parent": task.version}
        task.save(update_fields=["version", "field_versions"])
        tree.refresh_progress(touched)
        announce(task, "reparented")
    return _reload(task)


def list_children(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> list[Task]:
    """The direct subtasks of a task, in order."""
    project = _project(actor, workspace, project_id, VIEW, False)
    task = _load_task(project, task_id)
    rows = _scoped(project).filter(parent=task, deleted_at__isnull=True)
    return list(rows.order_by("position", "number").prefetch_related(_with_assignees()))


def _soft(task: Task, deleted: bool) -> Task:
    task.deleted_at = timezone.now() if deleted else None
    task.version += 1
    task.updated_at = timezone.now()
    task.save(update_fields=["deleted_at", "version", "updated_at"])
    announce(task, "deleted" if deleted else "restored")
    return _reload(task)


DELETE_MODES: Final = ("", "subtree", "promote")


def delete(actor: Any, workspace: Workspace, project_id: str, task_id: str, mode: str = "") -> Task:
    """Delete a task. One with subtasks needs a ``mode``: ``subtree`` deletes them with it (all at
    the same moment, so a restore brings the batch back), ``promote`` moves them up to its parent
    first. Without subtasks the mode is ignored."""
    if mode not in DELETE_MODES:
        raise ApiError("The delete mode must be 'subtree' or 'promote'.")
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.delete")
        task = _load_task(project, task_id, lock=True)
        below = tree.descendants(task).count()
        if below and not mode:
            raise ApiError(
                f"This task has {below} subtask(s): delete them with it, or promote them.",
                title=ResponseTitle.HAS_SUBTASKS,
                data={"count": below},
            )
        if below and mode == "promote":
            _promote_children(task)
            result = _soft(task, True)
        elif below:
            stamp = timezone.now()
            subs = list(tree.descendants(task).select_for_update(of=("self",)))
            _bump(subs, stamp, deleted_at=stamp)
            task.deleted_at = stamp
            task.version += 1
            task.updated_at = stamp
            task.save(update_fields=["deleted_at", "version", "updated_at"])
            for sub in subs:
                announce(sub, "deleted")
            announce(task, "deleted")
            result = _reload(task)
        else:
            result = _soft(task, True)
        tree.refresh_above(task)
    return result


def _promote_children(task: Task) -> None:
    """Move each live direct child of ``task`` (with its subtree) up to ``task``'s own parent."""
    grandparent = (
        Task.objects.select_related("project").get(pk=task.parent_id) if task.parent_id else None
    )
    touched: list[Any] = []
    for kid in Task.objects.filter(parent=task, deleted_at__isnull=True).order_by(
        "position", "number"
    ):
        touched += tree.move_subtree(kid, grandparent)
        kid.version += 1
        kid.field_versions = {**kid.field_versions, "parent": kid.version}
        kid.save(update_fields=["version", "field_versions"])
        announce(kid, "reparented")
    tree.refresh_progress(touched)


def restore(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    """Bring a task back, with the subtasks that were deleted in the same batch. One whose parent
    is still deleted comes back as a top-level task."""
    with transaction.atomic():
        project = _writable_project(actor, workspace, project_id, "task.delete")
        task = _load_task(project, task_id, lock=True, trashed=True)
        stamp = task.deleted_at
        batch = list(
            Task.objects.filter(project=project, path__startswith=task.path, deleted_at=stamp)
            .exclude(pk=task.pk)
            .select_for_update(of=("self",))
        )
        _bump(batch, timezone.now(), deleted_at=None)
        parent_gone = (
            task.parent_id is not None
            and Task.objects.filter(pk=task.parent_id, deleted_at__isnull=False).exists()
        )
        restored = _soft(task, False)
        if parent_gone:
            tree.move_subtree(task, None)
            task.field_versions = {**task.field_versions, "parent": task.version}
            task.save(update_fields=["field_versions"])
            announce(task, "reparented")
        inner = tree.descendants(task).filter(progress_total__gt=0).values_list("pk", flat=True)
        tree.refresh_progress([task.pk, *inner, *tree.ancestor_ids(task)])
    return _reload(restored)


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
        key, number = json.loads(base64.urlsafe_b64decode(cursor.encode()))
        return str(key), int(number)
    except (ValueError, TypeError, binascii.Error):
        raise ApiError("That cursor is not valid.") from None


def _encode(task: Task) -> str:
    return base64.urlsafe_b64encode(json.dumps([task.tree_key, task.number]).encode()).decode()


def list_page(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    status: str = "",
    assignee_id: str = "",
    cursor: str = "",
    limit: int = PAGE_DEFAULT,
    include_subtasks: bool = False,
) -> tuple[list[Task], str]:
    """One keyset page in tree order and the cursor of the next ('' at the end). Only top-level
    tasks unless ``include_subtasks``, which returns every task with each parent right before its
    own subtasks."""
    project = _project(actor, workspace, project_id, VIEW, False)
    rows = _scoped(project).filter(deleted_at__isnull=True)
    if not include_subtasks:
        rows = rows.filter(parent__isnull=True)
    if status:
        rows = rows.filter(status=workflows.status_of(project, status))
    if assignee_id:
        rows = rows.filter(assignees__user_id__in=_valid_pks([assignee_id]) or [None])
    after = _decode(cursor)
    if after:
        key, number = after
        rows = rows.filter(Q(tree_key__gt=key) | Q(tree_key=key, number__gt=number))
    size = max(1, min(limit or PAGE_DEFAULT, PAGE_MAX))
    found = list(
        rows.order_by("tree_key", "number").prefetch_related(_with_assignees())[: size + 1]
    )
    page = found[:size]
    return page, _encode(page[-1]) if len(found) > size else ""
