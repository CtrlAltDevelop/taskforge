"""TaskForge's own export (``tasks.json``), read back by the importer: the round trip."""

import json
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
    RSprint,
)

FORMAT = "taskforge-export"
VERSION = 1


def _who(value: Any) -> Any:
    return common.person(value.get("name"), value.get("email")) if isinstance(value, dict) else None


def header(binary: IO[bytes]) -> dict[str, Any]:
    """The project, statuses, fields and sprints that come before the tasks."""
    found = streams.json_members_before(streams.text_of(binary), "tasks")
    if found.get("format") != FORMAT:
        raise streams.refused("This is not a TaskForge export (tasks.json).")
    if found.get("version") != VERSION:
        raise streams.refused(f"Export version {found.get('version')} is not supported here.")
    return found


def _sprints(head: dict[str, Any]) -> dict[str, RSprint]:
    return {
        str(s["name"]): RSprint(
            str(s["name"]),
            str(s.get("state", "")),
            common.day(s.get("start_date")),
            common.day(s.get("end_date")),
        )
        for s in head.get("sprints") or []
        if isinstance(s, dict) and s.get("name")
    }


def _one(item: Any, position: int, sprints: dict[str, RSprint]) -> RIssue | Problem:
    if not isinstance(item, dict):
        return Problem(position, "Entry is not an object.")
    own, title = str(item.get("id") or ""), str(item.get("title") or "").strip()
    if not own or not title:
        return Problem(position, f"Task {own or position} has no id or title.")
    description = item.get("description")
    sprint = str(item.get("sprint") or "")
    return RIssue(
        source_id=own,
        key=str(item.get("key") or ""),
        title=title,
        body=json.dumps(description) if isinstance(description, dict) and description else "",
        body_format="doc",
        status=str(item.get("status") or ""),
        priority=str(item.get("priority") or ""),
        assignees=tuple(p for p in (_who(a) for a in item.get("assignees") or []) if p),
        reporter=_who(item.get("reporter")),
        created=common.when(item.get("created_at")),
        updated=common.when(item.get("updated_at")),
        start=common.day(item.get("start_date")),
        due=common.day(item.get("due_date")),
        labels=(),
        sprints=(sprints.get(sprint) or RSprint(sprint),) if sprint else (),
        parent_id=str(item.get("parent_id") or ""),
        points=common.number(item.get("points")),
        estimate_sec=item.get("estimate_sec")
        if isinstance(item.get("estimate_sec"), int)
        else None,
        comments=tuple(
            RComment(
                str(c.get("id") or f"c{n}"),
                json.dumps(c.get("body") or {}),
                "doc",
                _who(c.get("author")),
                common.when(c.get("created_at")),
            )
            for n, c in enumerate(item.get("comments") or [], 1)
            if isinstance(c, dict)
        ),
        links=tuple(
            RLink(str(k.get("kind")), str(k.get("target")))
            for k in item.get("links") or []
            if isinstance(k, dict) and k.get("kind") and k.get("target")
        ),
        attachments=tuple(
            RAttachment(str(a.get("filename", "")), int(a.get("size") or 0))
            for a in item.get("attachments") or []
            if isinstance(a, dict)
        ),
        extra={str(k): str(v) for k, v in (item.get("fields") or {}).items()},
        line=position,
    )


def parse(binary: IO[bytes], head: dict[str, Any] | None = None) -> Iterator[RIssue | Problem]:
    sprints = _sprints(head or {})
    for position, item in enumerate(streams.json_items(streams.text_of(binary), "tasks"), 1):
        yield _one(item, position, sprints)
