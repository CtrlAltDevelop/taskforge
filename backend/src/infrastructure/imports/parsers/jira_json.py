"""Jira's JSON: the REST search result (``{"issues": [...]}``) or a bare list of issues."""

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

POINT_FIELDS = ("customfield_10016", "customfield_10026", "storyPoints", "story_points")
EPIC_FIELDS = ("customfield_10014",)


def _text(value: Any) -> tuple[str, str]:
    """A description or comment body and its format: wiki text (v2) or a document (v3)."""
    if isinstance(value, dict):
        return json.dumps(value), "adf"
    return str(value or ""), "jira"


def _who(value: Any) -> Any:
    if not isinstance(value, dict):
        return None
    return common.person(
        value.get("displayName") or value.get("name") or value.get("accountId"),
        value.get("emailAddress"),
    )


def _sprints(fields: dict[str, Any]) -> tuple[RSprint, ...]:
    found: list[dict[str, Any]] = []
    for name, value in fields.items():
        if name in ("sprint", "closedSprints") or name.startswith("customfield_"):
            items = value if isinstance(value, list) else [value]
            found += [
                i
                for i in items
                if isinstance(i, dict) and "name" in i and ("state" in i or "boardId" in i)
            ]
    return tuple(
        RSprint(
            str(s["name"]),
            str(s.get("state", "")),
            common.day(s.get("startDate")),
            common.day(s.get("endDate")),
        )
        for s in found
    )


def _links(fields: dict[str, Any]) -> tuple[RLink, ...]:
    out = []
    for link in fields.get("issuelinks") or []:
        kind = str((link.get("type") or {}).get("name", "")).lower()
        for side, target in (("outwardIssue", "outward"), ("inwardIssue", "inward")):
            other = link.get(side)
            if isinstance(other, dict) and (other.get("id") or other.get("key")):
                mapped = "relates"
                if kind == "blocks":
                    mapped = "blocks" if target == "outward" else "blocked_by"
                out.append(RLink(mapped, str(other.get("id") or other.get("key"))))
    return tuple(out)


def _one(item: Any, position: int) -> RIssue | Problem:
    if not isinstance(item, dict):
        return Problem(position, "Entry is not an object.")
    fields = item.get("fields")
    if not isinstance(fields, dict):
        return Problem(position, f"Issue {item.get('key', '')} has no fields.")
    title = str(fields.get("summary") or "").strip()
    source_id = str(item.get("id") or item.get("key") or "")
    if not title or not source_id:
        return Problem(position, f"Issue {item.get('key', '')} has no title or id.")
    body, fmt = _text(fields.get("description"))
    parent = fields.get("parent") or {}
    parent_id = str(parent.get("id") or parent.get("key") or "") if isinstance(parent, dict) else ""
    for name in EPIC_FIELDS:
        parent_id = parent_id or str(fields.get(name) or "")
    comments = []
    for n, c in enumerate((fields.get("comment") or {}).get("comments") or [], 1):
        cbody, cfmt = _text(c.get("body"))
        comments.append(
            RComment(
                str(c.get("id") or f"c{n}"),
                cbody,
                cfmt,
                _who(c.get("author")),
                common.when(c.get("created")),
            )
        )
    points = next(
        (common.number(fields.get(f)) for f in POINT_FIELDS if fields.get(f) is not None), None
    )
    assignee = _who(fields.get("assignee"))
    return RIssue(
        source_id=source_id,
        key=str(item.get("key") or ""),
        title=title,
        body=body,
        body_format=fmt,
        status=str((fields.get("status") or {}).get("name", "")),
        priority=str((fields.get("priority") or {}).get("name", "")),
        issue_type=str((fields.get("issuetype") or {}).get("name", "")),
        assignees=(assignee,) if assignee else (),
        reporter=_who(fields.get("reporter") or fields.get("creator")),
        created=common.when(fields.get("created")),
        updated=common.when(fields.get("updated")),
        due=common.day(fields.get("duedate")),
        labels=common.listing(fields.get("labels") or []),
        sprints=_sprints(fields),
        parent_id=parent_id,
        points=points,
        estimate_sec=common.seconds(fields.get("timeoriginalestimate"))
        if fields.get("timeoriginalestimate")
        else None,
        comments=tuple(comments),
        links=_links(fields),
        attachments=tuple(
            RAttachment(
                str(a.get("filename", "")), int(a.get("size") or 0), str(a.get("content", ""))
            )
            for a in fields.get("attachment") or []
            if isinstance(a, dict)
        ),
        line=position,
    )


def parse(binary: IO[bytes]) -> Iterator[RIssue | Problem]:
    for position, item in enumerate(streams.json_items(streams.text_of(binary), "issues"), 1):
        yield _one(item, position)
