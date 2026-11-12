"""Writing a project (or a workspace) as a zip of open formats.

A project's folder holds ``tasks.json`` (everything, in the shape the importer reads back),
``tasks.csv`` (one flat row per task, for a spreadsheet), ``comments.json`` (plain text of every
comment), ``attachments.json`` (a manifest: which task, name, size, hash; the bytes are not
copied) and ``README.md`` (the schema). A workspace export is one such folder per project plus
``workspace.json``. Everything is written as a stream, a batch of tasks at a time.
"""

import csv
import io
import json
import shutil
import tempfile
import zipfile
from collections import defaultdict
from collections.abc import Iterator
from typing import IO, Any, Final

from infrastructure.attachments.models import Attachment
from infrastructure.comments.models import Comment
from infrastructure.customfields import values as custom
from infrastructure.customfields.models import FieldDefinition
from infrastructure.imports.parsers import taskforge
from infrastructure.projects.models import Project
from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Task, TaskAssignee, TaskLink
from infrastructure.workflows.models import Status

BATCH: Final = 500
CSV_COLUMNS: Final = (
    "key", "title", "status", "priority", "assignees", "reporter", "created_at", "updated_at",
    "start_date", "due_date", "estimate_sec", "points", "sprint", "parent", "description",
)  # fmt: skip
README: Final = """# TaskForge export

Each project folder holds:

- `tasks.json` - everything about the project, as a stream-friendly JSON object:
  `format` (`taskforge-export`), `version`, `project`, `statuses`, `fields`, `sprints`, then
  `tasks`. A task has `id`, `key`, `title`, `description` (a rich-text document), `status`,
  `priority`, `assignees`, `reporter`, `created_at`, `updated_at`, `start_date`, `due_date`,
  `due_time`, `estimate_sec`, `points`, `sprint`, `parent_id`, `fields` (custom field name to
  value), `comments`, `links` (`kind`: blocks, blocked_by or relates; `target`: a task id) and
  `attachments`. TaskForge can import this file again (Import, source "TaskForge export").
- `tasks.csv` - one row per task for a spreadsheet; `description` is plain text.
- `comments.json` - every comment as plain text, with the task key, author and time.
- `attachments.json` - a manifest of the files attached to tasks (the files are not included).

Dates are ISO 8601 in UTC. Ids are TaskForge's own and are only used to tie records together.
"""


def _who(user: Any) -> dict[str, str] | None:
    return {"name": user.username, "email": user.email or ""} if user else None


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def _text_of(document: Any) -> str:
    from infrastructure.imports import richtext

    return richtext.plain_of(document.get("content", [])) if isinstance(document, dict) else ""


def _batches(project: Project) -> Iterator[list[Task]]:
    rows = (
        Task.objects.filter(project=project, deleted_at__isnull=True)
        .select_related("status", "created_by", "sprint")
        .order_by("tree_key")
    )
    batch: list[Task] = []
    for task in rows.iterator(chunk_size=BATCH):
        batch.append(task)
        if len(batch) == BATCH:
            yield batch
            batch = []
    if batch:
        yield batch


def _details(batch: list[Task]) -> dict[str, dict[str, Any]]:
    ids = [t.pk for t in batch]
    people: dict[Any, list[Any]] = defaultdict(list)
    for row in TaskAssignee.objects.filter(task_id__in=ids).select_related("user").order_by("pk"):
        people[row.task_id].append(row.user)
    comments: dict[Any, list[Comment]] = defaultdict(list)
    rows = Comment.objects.filter(task_id__in=ids, deleted_at__isnull=True)
    for c in rows.select_related("author").order_by("created_at"):
        comments[c.task_id].append(c)
    links: dict[Any, list[dict[str, str]]] = defaultdict(list)
    for link in TaskLink.objects.filter(from_task_id__in=ids):
        kind = "blocks" if link.type == "blocks" else "relates"
        links[link.from_task_id].append({"kind": kind, "target": str(link.to_task_id)})
    for link in TaskLink.objects.filter(to_task_id__in=ids, type="blocks"):
        links[link.to_task_id].append({"kind": "blocked_by", "target": str(link.from_task_id)})
    files: dict[Any, list[Attachment]] = defaultdict(list)
    for a in Attachment.objects.filter(task_id__in=ids, deleted_at__isnull=True).select_related(
        "uploader"
    ):
        files[a.task_id].append(a)
    custom.attach(batch)
    return {"people": people, "comments": comments, "links": links, "files": files}


def _task_item(task: Task, key: str, d: dict[str, Any], names: dict[str, str]) -> dict[str, Any]:
    return {
        "id": str(task.pk),
        "key": task.display_id,
        "title": task.title,
        "description": task.description or {},
        "status": task.status.name,
        "priority": task.priority,
        "assignees": [_who(u) for u in d["people"].get(task.pk, [])],
        "reporter": _who(task.created_by),
        "created_at": _iso(task.created_at),
        "updated_at": _iso(task.updated_at),
        "start_date": _iso(task.start_date),
        "due_date": _iso(task.due_date),
        "due_time": task.due_time.strftime("%H:%M") if task.due_time else "",
        "estimate_sec": task.estimate_sec,
        "points": str(task.points) if task.points is not None else "",
        "sprint": task.sprint.name if task.sprint else "",
        "parent_id": str(task.parent_id or ""),
        "fields": {names[fid]: wire for fid, wire in task.custom_values.items() if fid in names},
        "comments": [
            {
                "id": str(c.pk),
                "author": _who(c.author),
                "created_at": _iso(c.created_at),
                "body": c.body,
            }
            for c in d["comments"].get(task.pk, [])
        ],
        "links": d["links"].get(task.pk, []),
        "attachments": [
            {"filename": a.filename, "size": a.size} for a in d["files"].get(task.pk, [])
        ],
    }


def _write_json_stream(
    out: IO[bytes], head: dict[str, Any], items: Iterator[dict[str, Any]]
) -> None:
    """``head`` members, then ``"tasks": [ item, item ... ]``, one item at a time."""
    out.write(b"{")
    for name, value in head.items():
        out.write(json.dumps(name).encode() + b":" + json.dumps(value).encode() + b",")
    out.write(b'"tasks":[')
    for n, item in enumerate(items):
        out.write((b"," if n else b"") + json.dumps(item).encode())
    out.write(b"]}")


def write_project(archive: zipfile.ZipFile, project: Project, folder: str = "") -> dict[str, int]:
    """Add one project's files to ``archive`` under ``folder``; returns counts."""
    prefix = f"{folder}/" if folder else ""
    fields = list(
        FieldDefinition.objects.filter(project=project, archived_at__isnull=True).order_by(
            "position"
        )
    )
    names = {str(f.pk): f.name for f in fields}
    head = {
        "format": taskforge.FORMAT,
        "version": taskforge.VERSION,
        "project": {"name": project.name, "key": project.key, "description": project.description,
                    "color": project.color, "icon": project.icon},
        "statuses": [
            {"name": s.name, "category": s.category, "color": s.color, "position": s.position,
             "is_default": s.is_default}
            for s in Status.objects.filter(project=project).order_by("position")
        ],
        "fields": [
            {"name": f.name, "type": f.type, "options": f.options, "required": f.required}
            for f in fields
        ],
        "sprints": [
            {"name": s.name, "goal": s.goal, "state": s.state, "start_date": _iso(s.start_date),
             "end_date": _iso(s.end_date)}
            for s in Sprint.objects.filter(project=project).order_by("start_date")
        ],
    }  # fmt: skip
    counts = {"tasks": 0, "comments": 0, "attachments": 0}
    keys: dict[Any, str] = {}
    # The side files grow with the project: each goes to a temporary file as it is made and is
    # copied into the zip afterwards (a zip can have one entry open at a time).
    with _Spool() as sheet, _Spool() as comments_out, _Spool() as manifest:
        writer = csv.writer(sheet.text, lineterminator="\n")
        writer.writerow(CSV_COLUMNS)
        comment_list, file_list = _JsonList(comments_out.text), _JsonList(manifest.text)

        def items() -> Iterator[dict[str, Any]]:
            for batch in _batches(project):
                d = _details(batch)
                for task in batch:
                    keys[task.pk] = task.display_id
                    item = _task_item(task, task.display_id, d, names)
                    counts["tasks"] += 1
                    counts["comments"] += len(item["comments"])
                    counts["attachments"] += len(item["attachments"])
                    writer.writerow(_csv_row(task, item, keys))
                    for c in item["comments"]:
                        comment_list.add(
                            {"task": item["key"], "author": (c["author"] or {}).get("name", ""),
                             "created_at": c["created_at"], "text": _text_of(c["body"])}
                        )  # fmt: skip
                    for a in d["files"].get(task.pk, []):
                        file_list.add(
                            {"task": item["key"], "filename": a.filename, "mime": a.mime,
                             "size": a.size, "sha256": a.sha256, "uploaded_by": a.uploader.username,
                             "created_at": _iso(a.created_at)}
                        )  # fmt: skip
                    yield item

        with archive.open(f"{prefix}tasks.json", "w", force_zip64=True) as out:
            _write_json_stream(out, head, items())
        comment_list.close()
        file_list.close()
        for name, spool in (
            ("tasks.csv", sheet),
            ("comments.json", comments_out),
            ("attachments.json", manifest),
        ):
            spool.copy_to(archive, f"{prefix}{name}")
    archive.writestr(f"{prefix}README.md", README)
    return counts


class _Spool:
    """A temporary file written as text and read back as bytes."""

    def __init__(self) -> None:
        self._raw = tempfile.TemporaryFile()  # noqa: SIM115 -- closed in __exit__
        self.text = io.TextIOWrapper(self._raw, encoding="utf-8", newline="", write_through=True)

    def __enter__(self) -> "_Spool":
        return self

    def __exit__(self, *_: object) -> None:
        self._raw.close()

    def copy_to(self, archive: zipfile.ZipFile, name: str) -> None:
        self.text.flush()
        self._raw.seek(0)
        with archive.open(name, "w", force_zip64=True) as out:
            shutil.copyfileobj(self._raw, out)


class _JsonList:
    """A JSON array written one element at a time."""

    def __init__(self, out: IO[str]) -> None:
        self._out, self._first = out, True
        out.write("[")

    def add(self, item: dict[str, Any]) -> None:
        self._out.write(("" if self._first else ",\n") + json.dumps(item))
        self._first = False

    def close(self) -> None:
        self._out.write("]")


def _csv_row(task: Task, item: dict[str, Any], keys: dict[Any, str]) -> list[str]:
    return [
        _csv_safe(item["key"]),
        _csv_safe(task.title),
        _csv_safe(item["status"]),
        item["priority"],
        _csv_safe("; ".join(a["email"] or a["name"] for a in item["assignees"] if a)),
        _csv_safe(
            (item["reporter"] or {}).get("email") or (item["reporter"] or {}).get("name", "")
        ),
        item["created_at"],
        item["updated_at"],
        item["start_date"],
        item["due_date"],
        "" if item["estimate_sec"] is None else str(item["estimate_sec"]),
        item["points"],
        _csv_safe(item["sprint"]),
        keys.get(task.parent_id, "") if task.parent_id else "",
        _csv_safe(_text_of(item["description"])),
    ]


def _csv_safe(text: str) -> str:
    """A cell that starts like a formula is quoted with a leading apostrophe (spreadsheets)."""
    return "'" + text if text[:1] in ("=", "+", "-", "@", "\t", "\r") else text
