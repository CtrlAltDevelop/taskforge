"""CSV files: Jira's export, ClickUp's export, and any other CSV with the columns mapped by hand.

One parser serves all three. A *profile* says which header names each tool uses for each field
(case-insensitive, first match wins) and how its text is written; ``propose`` turns the header of
a file into the column mapping the wizard shows, and the person may change any of it. A column may
repeat in the header (Jira repeats ``Labels``, ``Sprint``, ``Comment`` once per value): every cell
under a mapped name is read.
"""

import hashlib
import re
from collections.abc import Iterator
from dataclasses import dataclass
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

FIELDS = (
    "id",
    "key",
    "title",
    "description",
    "status",
    "priority",
    "type",
    "assignee",
    "reporter",
    "created",
    "updated",
    "start",
    "due",
    "labels",
    "sprint",
    "parent",
    "points",
    "estimate",
    "comment",
)
REQUIRED = ("title",)
GENERIC = {
    "id": ("id", "task id", "issue id", "issue key"),
    "key": ("key", "issue key"),
    "title": ("title", "name", "summary", "task name", "subject"),
    "description": ("description", "task content", "content", "details", "body"),
    "status": ("status", "state"),
    "priority": ("priority",),
    "type": ("issue type", "type"),
    "assignee": ("assignee", "assignees", "assigned to", "owner"),
    "reporter": ("reporter", "creator", "created by"),
    "created": ("created", "date created", "created at", "created on"),
    "updated": ("updated", "date updated", "updated at"),
    "start": ("start date", "start"),
    "due": ("due date", "due", "deadline"),
    "labels": ("labels", "tags", "label"),
    "sprint": ("sprint",),
    "parent": ("parent id", "parent", "parent task", "parent key"),
    "points": ("story points", "points", "story point estimate", "custom field (story points)"),
    "estimate": ("original estimate", "time estimate", "estimate", "time estimated"),
    "comment": ("comment", "comments"),
}


@dataclass(frozen=True, slots=True)
class Profile:
    source: str
    body_format: str
    aliases: dict[str, tuple[str, ...]]
    estimate_unit: str  # of the estimate column: s | ms | h
    jira: bool = False


PROFILES = {
    "csv": Profile("csv", "text", GENERIC, "h"),
    "jira_csv": Profile(
        "jira_csv",
        "jira",
        {
            **GENERIC,
            "id": ("issue id",),
            "key": ("issue key",),
            "parent": ("parent id", "parent"),
            "points": (
                "custom field (story point estimate)",
                "custom field (story points)",
                "story point estimate",
            ),
            "estimate": ("original estimate",),
        },
        "s",
        jira=True,
    ),
    "clickup_csv": Profile(
        "clickup_csv",
        "md",
        {
            **GENERIC,
            "id": ("task id",),
            "key": (),
            "estimate": ("time estimated",),
        },
        "ms",
    ),
}
_LINK_HEADER = re.compile(r"^(outward|inward) issue link \((.+)\)$", re.I)
_BLOCKS_NAMES = {"blocks", "blocked"}


def propose(source: str, header: list[str]) -> dict[str, str]:
    """The header name each field would be read from, by the tool's own names."""
    lowered = {h.lower(): h for h in header}
    found: dict[str, str] = {}
    for field, names in PROFILES[source].aliases.items():
        for name in names:
            if name in lowered:
                found[field] = lowered[name]
                break
    return found


def _index(header: list[str], columns: dict[str, str]) -> dict[str, list[int]]:
    out: dict[str, list[int]] = {}
    for field in FIELDS:
        name = columns.get(field, "")
        out[field] = [i for i, h in enumerate(header) if name and h == name]
    return out


def _cells(row: list[str], where: list[int]) -> list[str]:
    return [row[i].strip() for i in where if i < len(row) and row[i].strip()]


def _comment(text: str, number: int, fmt: str, jira: bool) -> RComment:
    author = created = None
    body = text
    if jira:
        parts = text.split(";", 2)
        if len(parts) == 3 and (stamp := common.when(parts[0])):
            created, author, body = stamp, common.person(parts[1]), parts[2]
    return RComment(
        source_id=f"c{number}", body=body, body_format=fmt, author=author, created=created
    )


def _links(header: list[str], row: list[str]) -> tuple[RLink, ...]:
    out = []
    for i, name in enumerate(header):
        found = _LINK_HEADER.match(name)
        if not found or i >= len(row) or not row[i].strip():
            continue
        outward = found.group(1).lower() == "outward"
        if found.group(2).strip().lower() in _BLOCKS_NAMES:
            kind = "blocks" if outward else "blocked_by"
        else:
            kind = "relates"
        out.append(RLink(kind, row[i].strip()))
    return tuple(out)


def _attachments(header: list[str], row: list[str]) -> tuple[RAttachment, ...]:
    out = []
    for i, name in enumerate(header):
        if name.lower() == "attachment" and i < len(row) and row[i].strip():
            parts = row[i].split(";", 3)
            out.append(
                RAttachment(
                    filename=parts[2] if len(parts) > 2 else parts[-1],
                    url=parts[3] if len(parts) > 3 else "",
                )
            )
    return tuple(out)


def _row_id(row: list[str], seen: dict[str, int]) -> str:
    digest = hashlib.sha1("\x1f".join(row).encode(), usedforsecurity=False).hexdigest()[:16]
    seen[digest] = seen.get(digest, 0) + 1
    return f"row-{digest}" + (f"-{seen[digest]}" if seen[digest] > 1 else "")


def read_header(binary: IO[bytes]) -> tuple[list[str], list[dict[str, str]]]:
    """The header and the first few rows, to show in the mapping step."""
    header, rows = streams.csv_rows(streams.text_of(binary))
    sample = []
    for _, cells in rows:
        sample.append({h: cells[i] if i < len(cells) else "" for i, h in enumerate(header)})
        if len(sample) == 5:
            break
    return header, sample


def parse(
    source: str, binary: IO[bytes], columns: dict[str, str] | None = None
) -> Iterator[RIssue | Problem]:
    profile = PROFILES[source]
    header, rows = streams.csv_rows(streams.text_of(binary))
    cols = columns if columns is not None else propose(source, header)
    where = _index(header, cols)
    if not where["title"]:
        raise streams.refused("Map a column to the title first.")
    seen: dict[str, int] = {}
    for line, row in rows:
        if row and row[0].startswith("\x00"):
            yield Problem(line, f"Row could not be read: {row[0][1:]}")
            continue
        yield _issue(profile, header, where, row, line, seen)


def _issue(
    profile: Profile,
    header: list[str],
    where: dict[str, list[int]],
    row: list[str],
    line: int,
    seen: dict[str, int],
) -> RIssue | Problem:
    def one(field: str) -> str:
        cells = _cells(row, where[field])
        return cells[0] if cells else ""

    title = one("title")
    if not title:
        return Problem(line, "The row has no title.")
    sprints = tuple(
        RSprint(name=s) for cell in _cells(row, where["sprint"]) for s in common.listing(cell, ";")
    )
    issue_id = one("id") or _row_id(row, seen)
    return RIssue(
        source_id=issue_id,
        key=one("key"),
        title=title,
        body=one("description"),
        body_format=profile.body_format,
        status=one("status"),
        priority=one("priority"),
        issue_type=one("type"),
        assignees=tuple(p for c in _cells(row, where["assignee"]) for p in common.people_text(c)),
        reporter=common.person(one("reporter")),
        created=common.when(one("created")),
        updated=common.when(one("updated")),
        start=common.day(one("start")),
        due=common.day(one("due")),
        labels=tuple(
            dict.fromkeys(x for c in _cells(row, where["labels"]) for x in common.listing(c))
        ),
        sprints=sprints,
        parent_id=one("parent"),
        points=common.number(one("points")),
        estimate_sec=common.seconds(one("estimate"), profile.estimate_unit)
        if one("estimate")
        else None,
        comments=tuple(
            _comment(c, n, profile.body_format, profile.jira)
            for n, c in enumerate(_cells(row, where["comment"]), 1)
        ),
        links=_links(header, row) if profile.jira else (),
        attachments=_attachments(header, row) if profile.jira else (),
        line=line,
    )


def column_names(source: str) -> dict[str, Any]:
    """For the wizard: which fields can be mapped, and which are required."""
    return {"fields": list(FIELDS), "required": list(REQUIRED), "source": source}
