"""The templates every workspace has without saving anything: defined here, listed in the gallery
beside the saved ones, applied exactly like them. They cannot be edited or deleted."""

from dataclasses import dataclass
from typing import Any, Final

from infrastructure.templates import content

PREFIX: Final = "builtin:"
Json = dict[str, Any]


@dataclass(frozen=True, slots=True)
class Builtin:
    key: str
    name: str
    description: str
    content: Json

    @property
    def id(self) -> str:
        return PREFIX + self.key


def _statuses(*rows: tuple[str, str, str]) -> list[Json]:
    return [
        {
            "key": name,
            "name": name,
            "color": color,
            "category": category,
            "is_default": index == 0,
        }
        for index, (name, color, category) in enumerate(rows)
    ]


def _options(*labels: tuple[str, str]) -> list[Json]:
    return [{"id": "", "label": label, "color": color} for label, color in labels]


def _task(
    ref: str,
    title: str,
    status: str,
    *,
    parent: str = "",
    priority: str = "none",
    start: int | None = None,
    due: int | None = None,
    fields: list[Json] | None = None,
) -> Json:
    return {
        "ref": ref,
        "parent": parent,
        "title": title,
        "description": {},
        "priority": priority,
        "status": status,
        "start_offset": start,
        "due_offset": due,
        "due_time": "",
        "assignee_ids": [],
        "fields": fields or [],
    }


def _software() -> Json:
    todo = "To do"
    return {
        "schema": content.SCHEMA,
        "features": ["subtasks", "dependencies", "custom_fields", "time_tracking", "sprints"],
        "workflow": {
            "restrict": False,
            "restrict_creation": False,
            "statuses": _statuses(
                ("Backlog", "#9E9E9E", "not_started"),
                (todo, "#607D8B", "not_started"),
                ("In progress", "#1E88E5", "active"),
                ("In review", "#8E24AA", "active"),
                ("Done", "#43A047", "done"),
                ("Cancelled", "#E53935", "cancelled"),
            ),
            "transitions": [],
        },
        "fields": [
            {
                "key": "Type",
                "name": "Type",
                "type": "select",
                "options": _options(
                    ("Feature", "#1E88E5"), ("Bug", "#E53935"), ("Chore", "#757575")
                ),
                "required": False,
                "default": "",
                "hidden_views": [],
            },
        ],
        "automations": [],
        "tasks": [
            _task("t1", "Sprint {{sprint_name}}", todo, start=0, due=13, priority="high"),
            _task("t2", "Plan the sprint", todo, parent="t1", start=0, due=0),
            _task("t3", "Build the work", "Backlog", parent="t1", start=1, due=10),
            _task("t4", "Review and test", "Backlog", parent="t1", start=10, due=12),
            _task("t5", "Release and retrospective", "Backlog", parent="t1", start=13, due=13),
        ],
    }


def _marketing() -> Json:
    return {
        "schema": content.SCHEMA,
        "features": ["subtasks", "custom_fields"],
        "workflow": {
            "restrict": False,
            "restrict_creation": False,
            "statuses": _statuses(
                ("Idea", "#9E9E9E", "not_started"),
                ("Planned", "#607D8B", "not_started"),
                ("In progress", "#1E88E5", "active"),
                ("In review", "#8E24AA", "active"),
                ("Published", "#43A047", "done"),
            ),
            "transitions": [],
        },
        "fields": [
            {
                "key": "Channel",
                "name": "Channel",
                "type": "select",
                "options": _options(
                    ("Email", "#1E88E5"),
                    ("Social", "#8E24AA"),
                    ("Blog", "#43A047"),
                    ("Ads", "#FB8C00"),
                ),
                "required": False,
                "default": "",
                "hidden_views": [],
            },
        ],
        "tasks": [
            _task("t1", "{{campaign_name}} campaign", "Planned", start=0, due=28, priority="high"),
            _task("t2", "Define audience and message", "Planned", parent="t1", start=0, due=4),
            _task("t3", "Write the copy", "Idea", parent="t1", start=3, due=10),
            _task("t4", "Design the assets", "Idea", parent="t1", start=5, due=14),
            _task("t5", "Launch", "Idea", parent="t1", start=21, due=21, priority="urgent"),
            _task("t6", "Report on results", "Idea", parent="t1", start=28, due=28),
        ],
    }


def _bugs() -> Json:
    return {
        "schema": content.SCHEMA,
        "features": ["dependencies", "custom_fields"],
        "workflow": {
            "restrict": False,
            "restrict_creation": False,
            "statuses": _statuses(
                ("New", "#9E9E9E", "not_started"),
                ("Triaged", "#607D8B", "not_started"),
                ("In progress", "#1E88E5", "active"),
                ("Fixed", "#00ACC1", "active"),
                ("Verified", "#43A047", "done"),
                ("Won't fix", "#E53935", "cancelled"),
            ),
            "transitions": [],
        },
        "fields": [
            {
                "key": "Severity",
                "name": "Severity",
                "type": "select",
                "options": _options(
                    ("Critical", "#E53935"),
                    ("Major", "#FB8C00"),
                    ("Minor", "#FDD835"),
                    ("Cosmetic", "#9E9E9E"),
                ),
                "required": False,
                "default": "",
                "hidden_views": [],
            },
            {
                "key": "Environment",
                "name": "Environment",
                "type": "text",
                "options": [],
                "required": False,
                "default": "",
                "hidden_views": [],
            },
        ],
        "tasks": [
            _task("t1", "Example: login fails with a valid password", "New", priority="high"),
        ],
    }


BUILTINS: Final = (
    Builtin(
        "software-team",
        "Software team",
        "Backlog to done with review, a type field, sprints and a sample sprint plan.",
        _software(),
    ),
    Builtin(
        "marketing",
        "Marketing",
        "Idea to published, a channel field and a campaign plan with relative dates.",
        _marketing(),
    ),
    Builtin(
        "bug-tracker",
        "Bug tracker",
        "Triage workflow with severity and environment fields.",
        _bugs(),
    ),
)
BY_ID: Final = {b.id: b for b in BUILTINS}
