"""ClickUp's JSON: the API's task list (``{"tasks": [...]}``) or a bare list of tasks."""

from collections.abc import Iterator
from typing import IO, Any

from infrastructure.imports import streams
from infrastructure.imports.parsers import common
from infrastructure.imports.records import (
    Problem,
    RAttachment,
    RComment,
    RIssue,
    RLink,
)


def _who(value: Any) -> Any:
    if not isinstance(value, dict):
        return None
    return common.person(
        value.get("username") or value.get("name") or value.get("id"), value.get("email")
    )


def _links(task: dict[str, Any], own: str) -> tuple[RLink, ...]:
    out = []
    for dep in task.get("dependencies") or []:
        if not isinstance(dep, dict):
            continue
        before, after = str(dep.get("depends_on", "")), str(dep.get("task_id", ""))
        if after == own and before:
            out.append(RLink("blocked_by", before))
        elif before == own and after:
            out.append(RLink("blocks", after))
    for link in task.get("linked_tasks") or []:
        if isinstance(link, dict):
            other = str(
                link.get("link_id") if link.get("task_id") == own else link.get("task_id") or ""
            )
            if other:
                out.append(RLink("relates", other))
    return tuple(out)


def _one(task: Any, position: int) -> RIssue | Problem:
    if not isinstance(task, dict):
        return Problem(position, "Entry is not an object.")
    own, title = str(task.get("id") or ""), str(task.get("name") or "").strip()
    if not own or not title:
        return Problem(position, f"Task {own or position} has no id or name.")
    description = (
        task.get("markdown_description")
        or task.get("text_content")
        or task.get("description")
        or ""
    )
    priority = task.get("priority")
    comments = tuple(
        RComment(
            str(c.get("id") or f"c{n}"),
            str(c.get("comment_text") or c.get("text") or ""),
            "text",
            _who(c.get("user")),
            common.when(c.get("date")),
        )
        for n, c in enumerate(task.get("comments") or [], 1)
        if isinstance(c, dict)
    )
    estimate = task.get("time_estimate")
    return RIssue(
        source_id=own,
        title=title,
        body=str(description),
        body_format="md" if task.get("markdown_description") else "text",
        status=str((task.get("status") or {}).get("status", "")),
        priority=str(
            priority.get("priority", "") if isinstance(priority, dict) else priority or ""
        ),
        assignees=tuple(p for p in (_who(a) for a in task.get("assignees") or []) if p),
        reporter=_who(task.get("creator")),
        created=common.when(task.get("date_created")),
        updated=common.when(task.get("date_updated")),
        start=common.day(task.get("start_date")),
        due=common.day(task.get("due_date")),
        labels=common.listing(
            [t.get("name", "") if isinstance(t, dict) else t for t in task.get("tags") or []]
        ),
        parent_id=str(task.get("parent") or ""),
        points=common.number(task.get("points")),
        estimate_sec=common.seconds(estimate, "ms") if estimate else None,
        comments=comments,
        links=_links(task, own),
        attachments=tuple(
            RAttachment(
                str(a.get("title") or a.get("name") or ""),
                int(a.get("size") or 0),
                str(a.get("url", "")),
            )
            for a in task.get("attachments") or []
            if isinstance(a, dict)
        ),
        line=position,
    )


def parse(binary: IO[bytes]) -> Iterator[RIssue | Problem]:
    for position, item in enumerate(streams.json_items(streams.text_of(binary), "tasks"), 1):
        yield _one(item, position)
