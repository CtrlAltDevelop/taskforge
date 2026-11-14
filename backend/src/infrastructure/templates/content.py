"""The snapshot a template stores, and the pure operations on it (no database).

Shape (``SCHEMA`` 1)::

    {"schema": 1,
     "tasks": [{"ref", "parent", "title", "description", "priority", "status",
                "start_offset", "due_offset", "due_time", "assignee_ids",
                "fields": [{"name", "type", "value"}]}],       # parents come before children
     # project templates only; a missing key means "not included":
     "features": ["subtasks", ...],
     "workflow": {"restrict", "restrict_creation",
                  "statuses": [{"key", "name", "color", "category", "is_default"}],
                  "transitions": [{"from", "to", "require_assignee", "require_subtasks_done"}]},
     "fields": [{"key", "name", "type", "options": [{"id", "label", "color"}], "required",
                 "default", "hidden_views"}],
     "automations": [{"name", "enabled", "trigger", "condition", "actions"}]}

Dates are offsets in days from the start date chosen when the template is applied. Statuses are
named by name, select values by option label. ``{{name}}`` anywhere in a string is a variable.
"""

import copy
import json
import re
from collections.abc import Callable, Mapping
from typing import Any, Final

from infrastructure.common.errors import ApiError

SCHEMA: Final = 1
MAX_TASKS: Final = 2000
MAX_BYTES: Final = 6_000_000
MAX_OFFSET: Final = 36_500
VARIABLE: Final = re.compile(r"\{\{\s*([A-Za-z_][A-Za-z0-9_]{0,39})\s*\}\}")
INCLUDES: Final = ("workflow", "fields", "automations", "features", "tasks")

Json = dict[str, Any]


def bad(message: str) -> ApiError:
    return ApiError(message)


def _walk(value: Any, visit: Callable[[str], str]) -> Any:
    if isinstance(value, str):
        return visit(value)
    if isinstance(value, list):
        return [_walk(v, visit) for v in value]
    if isinstance(value, dict):
        return {k: _walk(v, visit) for k, v in value.items()}
    return value


def variables(content: Any) -> list[str]:
    """Every ``{{name}}`` in the snapshot, in order of first appearance."""
    found: dict[str, None] = {}

    def visit(text: str) -> str:
        for match in VARIABLE.finditer(text):
            found.setdefault(match.group(1))
        return text

    _walk(content, visit)
    return list(found)


def substitute(content: Any, values: Mapping[str, str]) -> Any:
    """A copy of ``content`` with every variable replaced (an unknown one is left as typed)."""

    def visit(text: str) -> str:
        return VARIABLE.sub(lambda m: values.get(m.group(1), m.group(0)), text)

    return _walk(copy.deepcopy(content), visit)


def remap_ids(content: Any, mapping: Mapping[str, str]) -> Any:
    """Replace every old id (status, field, option) found inside any string by its new one."""

    def visit(text: str) -> str:
        for old, new in mapping.items():
            if old in text:
                text = text.replace(old, new)
        return text

    return _walk(copy.deepcopy(content), visit)


def includes(content: Mapping[str, Any]) -> list[str]:
    """Which of ``INCLUDES`` the snapshot holds."""
    return [key for key in INCLUDES if content.get(key)]


def status_names(content: Mapping[str, Any]) -> list[str]:
    workflow = content.get("workflow") or {}
    return [str(s.get("name", "")) for s in workflow.get("statuses", [])]


def _text(raw: Any, name: str, limit: int, *, required: bool = False) -> str:
    if raw is None:
        raw = ""
    if not isinstance(raw, str):
        raise bad(f"{name} must be text.")
    text = raw.strip()
    if (required and not text) or len(text) > limit:
        raise bad(f"{name} must be {1 if required else 0}-{limit} characters.")
    return text


def _offset(raw: Any, name: str) -> int | None:
    if raw is None or raw == "":
        return None
    if isinstance(raw, bool) or not isinstance(raw, int) or abs(raw) > MAX_OFFSET:
        raise bad(f"{name} must be a whole number of days.")
    return raw


def _task(raw: Any, seen: set[str]) -> Json:
    if not isinstance(raw, dict):
        raise bad("A task in the template is malformed.")
    ref = _text(raw.get("ref"), "A task reference", 40, required=True)
    if ref in seen:
        raise bad(f"Two tasks share the reference {ref}.")
    parent = _text(raw.get("parent"), "A parent reference", 40)
    if parent and parent not in seen:
        raise bad(f"The parent of {ref} must come before it.")
    start = _offset(raw.get("start_offset"), "A start")
    due = _offset(raw.get("due_offset"), "A due")
    if start is not None and due is not None and due < start:
        raise bad(f"{ref} is due before it starts.")
    description = raw.get("description") or {}
    if not isinstance(description, dict):
        raise bad("A task description is malformed.")
    assignees = raw.get("assignee_ids") or []
    fields = raw.get("fields") or []
    if not isinstance(assignees, list) or not isinstance(fields, list):
        raise bad("A task in the template is malformed.")
    return {
        "ref": ref,
        "parent": parent,
        "title": _text(raw.get("title"), "A task title", 500, required=True),
        "description": description,
        "priority": _text(raw.get("priority") or "none", "A priority", 8),
        "status": _text(raw.get("status"), "A status", 40),
        "start_offset": start,
        "due_offset": due,
        "due_time": _text(raw.get("due_time"), "A due time", 8),
        "assignee_ids": [str(a) for a in assignees][:50],
        "fields": [_field_value(f) for f in fields][:100],
    }


def _field_value(raw: Any) -> Json:
    if not isinstance(raw, dict):
        raise bad("A field value in the template is malformed.")
    return {
        "name": _text(raw.get("name"), "A field name", 60, required=True),
        "type": _text(raw.get("type"), "A field type", 12, required=True),
        "value": _text(raw.get("value"), "A field value", 3400),
    }


def _workflow(raw: Any) -> Json:
    if not isinstance(raw, dict):
        raise bad("The workflow in the template is malformed.")
    statuses = raw.get("statuses") or []
    transitions = raw.get("transitions") or []
    if not isinstance(statuses, list) or not isinstance(transitions, list):
        raise bad("The workflow in the template is malformed.")
    return {
        "restrict": bool(raw.get("restrict")),
        "restrict_creation": bool(raw.get("restrict_creation")),
        "statuses": [
            {
                "key": _text(s.get("key") or s.get("name"), "A status key", 80, required=True),
                "name": _text(s.get("name"), "A status name", 40, required=True),
                "color": _text(s.get("color"), "A status color", 7),
                "category": _text(s.get("category"), "A status category", 12, required=True),
                "is_default": bool(s.get("is_default")),
            }
            for s in statuses
            if isinstance(s, dict)
        ][:50],
        "transitions": [
            {
                "from": _text(t.get("from"), "A transition", 80, required=True),
                "to": _text(t.get("to"), "A transition", 80, required=True),
                "require_assignee": bool(t.get("require_assignee")),
                "require_subtasks_done": bool(t.get("require_subtasks_done")),
            }
            for t in transitions
            if isinstance(t, dict)
        ][:500],
    }


def _field_definition(raw: Any) -> Json:
    if not isinstance(raw, dict):
        raise bad("A field in the template is malformed.")
    options = raw.get("options") or []
    hidden = raw.get("hidden_views") or []
    if not isinstance(options, list) or not isinstance(hidden, list):
        raise bad("A field in the template is malformed.")
    return {
        "key": _text(raw.get("key") or raw.get("name"), "A field key", 80, required=True),
        "name": _text(raw.get("name"), "A field name", 60, required=True),
        "type": _text(raw.get("type"), "A field type", 12, required=True),
        "options": [
            {
                "id": str(o.get("id", "")),
                "label": str(o.get("label", "")),
                "color": str(o.get("color", "")),
            }
            for o in options
            if isinstance(o, dict)
        ][:50],
        "required": bool(raw.get("required")),
        "default": _text(raw.get("default"), "A field default", 3400),
        "hidden_views": [str(v) for v in hidden][:20],
    }


def _automation(raw: Any) -> Json:
    if not isinstance(raw, dict):
        raise bad("An automation in the template is malformed.")
    condition = raw.get("condition") or {}
    actions = raw.get("actions") or []
    trigger = raw.get("trigger")
    if not isinstance(condition, dict) or not isinstance(actions, list):
        raise bad("An automation in the template is malformed.")
    if not isinstance(trigger, dict):
        raise bad("An automation in the template is malformed.")
    return {
        "name": _text(raw.get("name"), "An automation name", 80, required=True),
        "enabled": bool(raw.get("enabled", True)),
        "trigger": trigger,
        "condition": condition,
        "actions": actions,
    }


def clean(kind: str, raw: Any) -> Json:
    """The snapshot ``raw`` as it will be stored, or a 400 saying what is wrong. Unknown keys
    are dropped; a task template holds tasks only."""
    if not isinstance(raw, dict):
        raise bad("The template content must be an object.")
    if len(json.dumps(raw)) > MAX_BYTES:
        raise bad("The template is too large.")
    raw_tasks = raw.get("tasks") or []
    if not isinstance(raw_tasks, list):
        raise bad("The tasks of the template must be a list.")
    if len(raw_tasks) > MAX_TASKS:
        raise bad(f"A template can hold at most {MAX_TASKS} tasks.")
    seen: set[str] = set()
    tasks: list[Json] = []
    for item in raw_tasks:
        task = _task(item, seen)
        seen.add(task["ref"])
        tasks.append(task)
    if kind == "task" and not tasks:
        raise bad("A task template needs at least one task.")
    out: Json = {"schema": SCHEMA, "tasks": tasks}
    if kind != "project":
        return out
    if isinstance(raw.get("features"), list):
        out["features"] = [str(k) for k in raw["features"]][:20]
    if raw.get("workflow") is not None:
        out["workflow"] = _workflow(raw["workflow"])
    if raw.get("fields") is not None:
        out["fields"] = [_field_definition(f) for f in raw["fields"]][:50]
    if raw.get("automations") is not None:
        out["automations"] = [_automation(a) for a in raw["automations"]][:50]
    return out
