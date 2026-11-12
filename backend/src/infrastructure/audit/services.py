"""Reading the log: the admin list, the export, and a task's activity."""

import csv
import io
import json
import uuid
from collections.abc import Iterator
from dataclasses import asdict, dataclass
from datetime import datetime
from typing import Any, Final

from django.db.models import QuerySet
from django.utils.dateparse import parse_datetime

from infrastructure.audit import recorder
from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "audit.view"
DEFAULT_PAGE: Final = 50
MAX_PAGE: Final = 200
EXPORT_CHUNK: Final = 2000
CSV_HEADER: Final = (
    "id", "at", "actor", "actor_type", "action", "target_type", "target_id", "project",
    "batch_id", "ip", "user_agent", "changes",
)  # fmt: skip


@dataclass(frozen=True, slots=True)
class Filters:
    actor: str = ""
    action: str = ""  # exact ("task.deleted") or a prefix ending in "." ("task.")
    target_type: str = ""
    target_id: str = ""
    project_id: str = ""
    since: str = ""  # ISO-8601
    until: str = ""


@dataclass(frozen=True, slots=True)
class Page:
    entries: list[AuditEntry]
    next_before: int  # pass as ``before`` for the next page; 0 when this was the last


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400)


def _moment(raw: str, what: str) -> datetime:
    parsed = parse_datetime(raw)
    if parsed is None:
        raise _bad(f"{what} must be an ISO-8601 date and time.")
    return parsed


def _uuid(raw: str, what: str) -> uuid.UUID:
    try:
        return uuid.UUID(raw)
    except ValueError:
        raise _bad(f"{what} is not an id.") from None


def _filtered(workspace: Workspace, f: Filters) -> QuerySet[AuditEntry]:
    rows = AuditEntry.objects.filter(workspace=workspace.pk)
    if f.actor:
        rows = rows.filter(actor=f.actor)
    if f.action:
        rows = (
            rows.filter(action__startswith=f.action)
            if f.action.endswith(".")
            else rows.filter(action=f.action)
        )
    if f.target_type:
        rows = rows.filter(target_type=f.target_type)
    if f.target_id:
        rows = rows.filter(target_id=f.target_id)
    if f.project_id:
        rows = rows.filter(project=_uuid(f.project_id, "The project"))
    if f.since:
        rows = rows.filter(at__gte=_moment(f.since, "since"))
    if f.until:
        rows = rows.filter(at__lt=_moment(f.until, "until"))
    return rows


def list_entries(
    actor: Any, workspace: Workspace, f: Filters, *, before: int = 0, limit: int = 0
) -> Page:
    """Newest first. ``before`` is an entry id: only older ones are returned, so a page never
    shifts while new entries arrive."""
    access.require(actor, VIEW, workspace)
    return _page(_filtered(workspace, f), before, limit)


def _page(rows: QuerySet[AuditEntry], before: int, limit: int) -> Page:
    if before:
        rows = rows.filter(pk__lt=before)
    size = min(limit or DEFAULT_PAGE, MAX_PAGE)
    found = list(rows.order_by("-pk")[: size + 1])
    more = len(found) > size
    found = found[:size]
    return Page(found, found[-1].pk if more else 0)


def activity_for_task(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    task_id: str,
    *,
    before: int = 0,
    limit: int = 0,
) -> Page:
    """A task's history, for anyone who can open the task (a task they cannot see is a 404)."""
    from infrastructure.tasks import services as tasks

    task = tasks.get(actor, workspace, project_id, task_id)
    rows = AuditEntry.objects.filter(
        workspace=workspace.pk, target_type="task", target_id=str(task.pk)
    )
    return _page(rows, before, limit)


def _line(row: AuditEntry) -> list[str]:
    return [
        str(row.pk),
        row.at.isoformat(),
        row.actor,
        row.actor_type,
        row.action,
        row.target_type,
        row.target_id,
        str(row.project or ""),
        str(row.batch_id or ""),
        str(row.ip or ""),
        row.user_agent,
        json.dumps(row.changes, sort_keys=True),
    ]


def _csv(cells: list[str]) -> str:
    out = io.StringIO()
    csv.writer(out).writerow(_safe(c) for c in cells)
    return out.getvalue()


def _safe(cell: str) -> str:
    """A spreadsheet runs a cell that starts with = + - @ as a formula: quote it."""
    return "'" + cell if cell[:1] in ("=", "+", "-", "@", "\t", "\r") else cell


def export_csv(actor: Any, workspace: Workspace, f: Filters) -> Iterator[str]:
    """The filtered log as CSV, a chunk of rows at a time (never all in memory). Exporting is
    itself recorded, once, before the first row."""
    access.require(actor, VIEW, workspace)
    rows = _filtered(workspace, f).order_by("pk")  # validates the filters before anything is sent
    recorder.record(
        workspace_id=workspace.pk,
        action="audit.exported",
        target_type="workspace",
        target_id=workspace.pk,
        changes={k: v for k, v in asdict(f).items() if v},
    )
    return _stream(rows)


def _stream(rows: QuerySet[AuditEntry]) -> Iterator[str]:
    yield _csv(list(CSV_HEADER))
    for row in rows.iterator(chunk_size=EXPORT_CHUNK):
        yield _csv(_line(row))
