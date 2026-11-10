"""Task links: blocks / blocked by, relates to, duplicates / duplicated by. gRPC renders the answer.

A link is stored once (``TaskLink``) and read from both ends: ``list_for_task`` turns the stored
direction into the ``kind`` the asked-about task sees. Both ends must be tasks the caller can open
(an invisible one is a 404, like a missing one); when a LATER reader cannot open the far end the
link still shows, with ``other`` ``None`` ("Restricted task"), so a title or id never leaks.

Blocking rules: a chain of ``blocks`` links may never loop (``LINK_CYCLE`` with the readable
path), and a task with an open blocker cannot move into a Done status (``TASK_BLOCKED``) unless
someone who manages the project overrides it, which is recorded (``BlockOverride``).
"""

import re
import uuid
from collections.abc import Iterable
from dataclasses import dataclass
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.tasks.models import BlockOverride, LinkType, Task, TaskLink
from infrastructure.tasks.signals import announce
from infrastructure.tasks.tree import FINAL
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
CHANGE = "task.update"
OVERRIDE = "project.update"
RESTRICTED: Final = "Restricted task"
# kind as the caller names it -> (stored type, stored the other way round)
KINDS: Final = {
    "blocks": (LinkType.BLOCKS, False),
    "blocked_by": (LinkType.BLOCKS, True),
    "relates": (LinkType.RELATES, False),
    "duplicates": (LinkType.DUPLICATES, False),
    "duplicated_by": (LinkType.DUPLICATES, True),
}
KIND_ORDER: Final = {kind: n for n, kind in enumerate(KINDS)}
__all__ = [
    "BlockOverride",
    "LinkView",
    "add",
    "blocked_ids",
    "blocking_pairs",
    "list_for_task",
    "remove",
    "search_tasks",
]


@dataclass(frozen=True, slots=True)
class LinkView:
    link: TaskLink
    kind: str  # from the asked-about task's side, one of ``KINDS``
    other: Task | None  # None: the caller may not open it

    @property
    def other_is_restricted(self) -> bool:
        return self.other is None


def _not_found() -> ApiError:
    return ApiError("No such task.", status=404)


def visible_projects(actor: Any, workspace: Workspace) -> set[Any]:
    return set(Project.objects.visible_to(actor, workspace).values_list("pk", flat=True))


def _task(actor: Any, workspace: Workspace, task_id: str, *, lock: bool = False) -> Task:
    """A live task of ``workspace`` in a project ``actor`` can open, else 404."""
    try:
        pk = uuid.UUID(str(task_id))
    except ValueError:
        raise _not_found() from None
    rows = Task.objects.filter(
        pk=pk,
        workspace=workspace,
        deleted_at__isnull=True,
        project__in=Project.objects.visible_to(actor, workspace),
    ).select_related("project", "status")
    task = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if task is None:
        raise _not_found()
    return task


def _label(task: Task, visible: set[Any]) -> str:
    return task.display_id if task.project_id in visible else RESTRICTED


def _cycle_path(actor: Any, workspace: Workspace, start: Task, end: Task) -> str:
    """The loop ``start -> end -> ... -> start`` that a new ``start blocks end`` link would close,
    named for ``actor`` ('' when there is none). Breadth first, iterative (a chain can be long), one
    query per hop. # ponytail: per-hop queries; one recursive CTE if chains of thousands matter."""
    came_from: dict[Any, Any] = {end.pk: None}
    frontier = [end.pk]
    while frontier and start.pk not in came_from:
        edges = TaskLink.objects.filter(
            workspace=workspace,
            type=LinkType.BLOCKS,
            from_task_id__in=frontier,
            from_task__deleted_at__isnull=True,  # a deleted task blocks nothing (see blocked_ids)
            to_task__deleted_at__isnull=True,
        ).values_list("from_task_id", "to_task_id")
        frontier = []
        for source, target in edges:
            if target not in came_from:
                came_from[target] = source
                frontier.append(target)
    if start.pk not in came_from:
        return ""
    chain = [start.pk]
    while chain[-1] != end.pk:
        chain.append(came_from[chain[-1]])
    ordered = [start.pk, *reversed(chain[1:])]  # start, end, ..., (last before start)
    ids = [*ordered, start.pk]
    tasks = {t.pk: t for t in Task.objects.filter(pk__in=ids).select_related("project")}
    visible = visible_projects(actor, workspace)
    return " → ".join(_label(tasks[i], visible) for i in ids)


def _stored(task: Task, other: Task, kind: str) -> tuple[Task, Task, str]:
    if kind not in KINDS:
        raise ApiError(f"Unknown link kind: {kind or '(none)'}.")
    link_type, reverse = KINDS[kind]
    source, target = (other, task) if reverse else (task, other)
    if link_type == LinkType.RELATES and str(source.pk) > str(target.pk):
        source, target = target, source  # one row per pair, whichever end it was added from
    return source, target, link_type


def _exists() -> ApiError:
    return ApiError(
        "These tasks are already linked that way.", status=409, title=ResponseTitle.LINK_EXISTS
    )


def add(
    actor: Any,
    workspace: Workspace,
    task_id: str,
    other_id: str,
    kind: str,
    *,
    close_duplicate: bool = False,
) -> TaskLink:
    """Link ``task_id`` to ``other_id`` as ``kind`` (seen from ``task_id``). ``close_duplicate``
    (only with ``duplicates`` / ``duplicated_by``) also moves the duplicate to a Done status."""
    access.require(actor, CHANGE, workspace)
    if close_duplicate and kind not in ("duplicates", "duplicated_by"):
        raise ApiError("close_duplicate only applies to a duplicates link.")
    with transaction.atomic():
        task = _task(actor, workspace, task_id)
        other = _task(actor, workspace, other_id)
        projects.writable(task.project)
        projects.writable(other.project)
        if task.pk == other.pk:
            raise ApiError("A task cannot be linked to itself.")
        source, target, link_type = _stored(task, other, kind)
        if TaskLink.objects.filter(from_task=source, to_task=target, type=link_type).exists():
            raise _exists()
        if link_type == LinkType.BLOCKS:
            # Two opposite links added at once would each pass the check below and then both be
            # inserted; one blocking-link insert per workspace at a time rules that out.
            access.lock(workspace)
        if link_type == LinkType.BLOCKS and (path := _cycle_path(actor, workspace, source, target)):
            raise ApiError(
                f"That link would make tasks block each other in a loop: {path}.",
                status=409,
                title=ResponseTitle.LINK_CYCLE,
                data={"path": path},
            )
        try:
            with transaction.atomic():
                link = TaskLink.objects.create(
                    workspace=workspace,
                    from_task=source,
                    to_task=target,
                    type=link_type,
                    created_by=actor,
                )
        except IntegrityError:
            raise _exists() from None
        announce(source, "linked")
        announce(target, "linked")
        if close_duplicate:
            _close(actor, workspace, source)
    return link


def _close(actor: Any, workspace: Workspace, duplicate: Task) -> None:
    from infrastructure.tasks import services

    statuses = list(
        Status.objects.filter(
            project=duplicate.project, category__in=(Category.CANCELLED, Category.DONE)
        ).order_by("position")
    )
    target = next((s for s in statuses if s.category == Category.CANCELLED), None) or next(
        iter(statuses), None
    )
    if target is None:
        raise ApiError("The duplicate's project has no Done or Cancelled status to close it with.")
    if duplicate.status.category in FINAL:
        return
    services.update(
        actor,
        workspace,
        str(duplicate.project_id),
        str(duplicate.pk),
        duplicate.version,
        {"status": str(target.pk)},
    )


def remove(actor: Any, workspace: Workspace, link_id: str) -> None:
    """Delete a link. The caller must be able to open one of its two tasks."""
    access.require(actor, CHANGE, workspace)
    try:
        pk = uuid.UUID(str(link_id))
    except ValueError:
        raise _not_found() from None
    with transaction.atomic():
        link = (
            TaskLink.objects.select_for_update(of=("self",))
            .select_related("from_task__project", "to_task__project")
            .filter(pk=pk, workspace=workspace)
            .first()
        )
        visible = visible_projects(actor, workspace)
        if link is None or not {link.from_task.project_id, link.to_task.project_id} & visible:
            raise _not_found()
        near = link.from_task if link.from_task.project_id in visible else link.to_task
        projects.writable(near.project)
        link.delete()
        announce(link.from_task, "unlinked")
        announce(link.to_task, "unlinked")


def list_for_task(actor: Any, workspace: Workspace, task_id: str) -> list[LinkView]:
    """Every link of the task, as the task sees it; far ends the caller cannot open are ``None``."""
    access.require(actor, VIEW, workspace)
    task = _task(actor, workspace, task_id)
    visible = visible_projects(actor, workspace)
    rows = (
        TaskLink.objects.filter(Q(from_task=task) | Q(to_task=task), workspace=workspace)
        .select_related("from_task__project", "from_task__status")
        .select_related("to_task__project", "to_task__status")
        .exclude(Q(from_task__deleted_at__isnull=False) | Q(to_task__deleted_at__isnull=False))
    )
    views: list[LinkView] = []
    for link in rows:
        outgoing = link.from_task_id == task.pk
        far = link.to_task if outgoing else link.from_task
        kind = {
            (LinkType.BLOCKS, True): "blocks",
            (LinkType.BLOCKS, False): "blocked_by",
            (LinkType.DUPLICATES, True): "duplicates",
            (LinkType.DUPLICATES, False): "duplicated_by",
        }.get((link.type, outgoing), "relates")
        views.append(LinkView(link, kind, far if far.project_id in visible else None))
    views.sort(key=lambda v: (KIND_ORDER[v.kind], v.other.number if v.other else 0))
    return views


def _open_blockers(task_ids: Iterable[Any]) -> Any:
    """Links whose blocker is alive and not finished, for the given blocked tasks."""
    return (
        TaskLink.objects.filter(type=LinkType.BLOCKS, to_task_id__in=list(task_ids))
        .filter(from_task__deleted_at__isnull=True)
        .exclude(from_task__status__category__in=FINAL)
    )


def blocked_ids(tasks: Iterable[Task]) -> set[Any]:
    """The ids, among ``tasks``, that still have an open blocker (one query)."""
    return set(_open_blockers(t.pk for t in tasks).values_list("to_task_id", flat=True))


def mark_blocked(tasks: list[Task], actor: Any, workspace: Workspace) -> list[Task]:
    """Set ``is_blocked`` and ``blockers`` (what ``actor`` may see of them) on each task, for
    display; returns the same list. One query, two more when something on the page is blocked."""
    flagged = blocked_ids(tasks)
    names: dict[Any, list[str]] = {}
    if flagged:
        visible = visible_projects(actor, workspace)
        rows = (
            _open_blockers(flagged)
            .select_related("from_task__project", "from_task__status")
            .order_by("from_task__project__key", "from_task__number")
        )
        for link in rows:
            blocker = link.from_task
            label = (
                f"{blocker.display_id} ({blocker.status.name})"
                if blocker.project_id in visible
                else RESTRICTED
            )
            names.setdefault(link.to_task_id, []).append(label)
    for task in tasks:
        task.is_blocked = task.pk in flagged
        task.blockers = tuple(names.get(task.pk, ()))
    return tasks


def mark_schedule(tasks: list[Task], actor: Any, workspace: Workspace) -> list[Task]:
    """Set ``blockers_due`` (the latest due date among a task's open blockers) and ``blocks_due``
    (the earliest due date among the open tasks it blocks) on each task, counting only tasks in
    projects ``actor`` can open, so a client can tell whether a new date would break a link. Two
    queries."""
    if not tasks:
        return tasks
    ids = [t.pk for t in tasks]
    visible = visible_projects(actor, workspace)
    latest: dict[Any, str] = {}
    for to_id, due in (
        _open_blockers(ids)
        .filter(from_task__due_date__isnull=False, from_task__project__in=visible)
        .values_list("to_task_id", "from_task__due_date")
    ):
        latest[to_id] = max(latest.get(to_id, ""), due.isoformat())
    earliest: dict[Any, str] = {}
    blocked = (
        TaskLink.objects.filter(type=LinkType.BLOCKS, from_task_id__in=ids)
        .filter(to_task__deleted_at__isnull=True, to_task__due_date__isnull=False)
        .filter(to_task__project__in=visible)
        .exclude(to_task__status__category__in=FINAL)
        .values_list("from_task_id", "to_task__due_date")
    )
    for from_id, due in blocked:
        earliest[from_id] = min(earliest.get(from_id, "9999-12-31"), due.isoformat())
    for task in tasks:
        task.blockers_due = latest.get(task.pk, "")
        task.blocks_due = earliest.get(task.pk, "")
    return tasks


def blocking_pairs(
    actor: Any, workspace: Workspace, tasks: Iterable[Task]
) -> list[tuple[str, str]]:
    """``(blocker id, dependent id)`` of every blocking link that touches one of ``tasks``, between
    live tasks in projects ``actor`` can open, oldest link first (one query)."""
    ids = [t.pk for t in tasks]
    if not ids:
        return []
    visible = visible_projects(actor, workspace)
    rows = (
        TaskLink.objects.filter(type=LinkType.BLOCKS)
        .filter(Q(from_task_id__in=ids) | Q(to_task_id__in=ids))
        .filter(from_task__deleted_at__isnull=True, to_task__deleted_at__isnull=True)
        .filter(from_task__project__in=visible, to_task__project__in=visible)
        .order_by("created_at", "id")
    )
    return [(str(a), str(b)) for a, b in rows.values_list("from_task_id", "to_task_id")]


def blockers_of(actor: Any, workspace: Workspace, task: Task, *, masked: bool = True) -> list[str]:
    """Display ids of the task's open blockers; with ``masked`` those ``actor`` cannot open read
    'Restricted task' (the answer to a person), without it the real ids (the audit record)."""
    found = (
        _open_blockers([task.pk])
        .select_related("from_task__project")
        .order_by("from_task__project__key", "from_task__number")
    )
    visible = visible_projects(actor, workspace)
    return [
        _label(link.from_task, visible) if masked else link.from_task.display_id for link in found
    ]


def check_unblocked(
    actor: Any, workspace: Workspace, project: Project, task: Task, target: Status, override: bool
) -> None:
    """Refuse moving a blocked task into a Done status (``TASK_BLOCKED``), unless ``override`` and
    ``actor`` manages the project; then the override is recorded."""
    if target.category != Category.DONE or task.status.category == Category.DONE:
        return
    names = blockers_of(actor, workspace, task)
    if not names:
        return
    listed = ", ".join(names)
    if override and access.can(actor, OVERRIDE, project).allowed:
        real = ", ".join(blockers_of(actor, workspace, task, masked=False))
        BlockOverride.objects.create(task=task, actor=actor, blockers=real)
        return
    raise ApiError(
        f"Blocked by {listed}: finish those first.",
        status=409,
        title=ResponseTitle.TASK_BLOCKED,
        data={
            "blockers": listed,
            # so the app offers "complete anyway" to exactly the people the server would allow
            "can_override": str(access.can(actor, OVERRIDE, project).allowed).lower(),
        },
    )


SEARCH_LIMIT: Final = 20
_DISPLAY_ID = re.compile(r"([A-Za-z0-9]+)-(\d+)")


def search_tasks(
    actor: Any, workspace: Workspace, query: str, *, limit: int = SEARCH_LIMIT
) -> list[Task]:
    """Live tasks of every project ``actor`` can open, by title or ``KEY-N`` (newest first), for
    picking the other end of a link. An empty query gives the most recently changed ones."""
    access.require(actor, VIEW, workspace)
    text = query.strip()
    rows = Task.objects.filter(
        workspace=workspace,
        deleted_at__isnull=True,
        project__in=Project.objects.visible_to(actor, workspace),
    ).select_related("project", "status")
    if text:
        match = _DISPLAY_ID.fullmatch(text)
        condition = Q(title__icontains=text)
        if match:
            condition |= Q(project__key__iexact=match[1], number=int(match[2]))
        rows = rows.filter(condition)
    return list(rows.order_by("-updated_at", "-number")[: max(1, min(limit, SEARCH_LIMIT))])
