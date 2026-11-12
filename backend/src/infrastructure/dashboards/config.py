"""What a widget may ask for, checked once when it is saved."""

import uuid
from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle

MAX_WIDGETS: Final = 20
GRID_COLUMNS: Final = 12

NUMBER, BAR, LINE, PIE, TABLE, BURNDOWN, WORKLOAD = (
    "number", "bar", "line", "pie", "table", "burndown", "workload"
)  # fmt: skip
TYPES: Final = (NUMBER, BAR, LINE, PIE, TABLE, BURNDOWN, WORKLOAD)

COUNT, POINTS, ESTIMATE_HOURS, LOGGED_HOURS, CYCLE_DAYS = (
    "count", "points", "estimate_hours", "logged_hours", "cycle_days"
)  # fmt: skip
MEASURES: Final = (COUNT, POINTS, ESTIMATE_HOURS, LOGGED_HOURS, CYCLE_DAYS)

GROUPS: Final = (
    "", "status", "category", "assignee", "priority", "project", "sprint",
    "created_day", "created_week", "due_week",
)  # fmt: skip
TIME_GROUPS: Final = ("created_day", "created_week", "due_week")
SCOPES: Final = ("all", "open", "done")

DEFAULT_LIMIT: Final = 12
MAX_LIMIT: Final = 50
DEFAULT_RANGE_DAYS: Final = 90
MAX_RANGE_DAYS: Final = 730


def invalid(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.DASHBOARD_INVALID)


def _choice(value: Any, allowed: tuple[str, ...], what: str) -> str:
    text = str(value or "")
    if text not in allowed:
        raise invalid(f"{what} must be one of: {', '.join(a or 'none' for a in allowed)}.")
    return text


def _id(value: Any, what: str) -> str:
    text = str(value or "")
    if not text:
        return ""
    try:
        return str(uuid.UUID(text))
    except ValueError:
        raise invalid(f"{what} is not an id.") from None


MAX_TFQL: Final = 2000


def _tfql(value: Any) -> str:
    """The filter text as sent: too long is refused (cutting it could change what it means)."""
    text = str(value or "").strip()
    if len(text) > MAX_TFQL:
        raise invalid(f"A filter is at most {MAX_TFQL} characters.")
    return text


def _int(value: Any, default: int, low: int, high: int, what: str) -> int:
    try:
        number = int(value) if value not in (None, "") else default
    except (TypeError, ValueError):
        raise invalid(f"{what} must be a whole number.") from None
    if not low <= number <= high:
        raise invalid(f"{what} must be between {low} and {high}.")
    return number


def normalise(kind: str, raw: Any) -> dict[str, Any]:
    """The config of a ``kind`` widget with every key present and valid; anything else is a 400."""
    if kind not in TYPES:
        raise invalid(f"A widget is one of: {', '.join(TYPES)}.")
    if not isinstance(raw, dict):
        raise invalid("A widget's config is an object.")
    source = raw.get("source") or {}
    if not isinstance(source, dict):
        raise invalid("A widget's source is an object.")
    cfg: dict[str, Any] = {
        "source": {
            "filter_id": _id(source.get("filter_id"), "The filter"),
            "tfql": _tfql(source.get("tfql")),
        },
        "measure": _choice(raw.get("measure") or COUNT, MEASURES, "The measure"),
        "group_by": _choice(raw.get("group_by"), GROUPS, "The grouping"),
        "scope": _choice(raw.get("scope") or "all", SCOPES, "The scope"),
        "sprint_id": _id(raw.get("sprint_id"), "The sprint"),
        "project_id": _id(raw.get("project_id"), "The project"),
        "limit": _int(raw.get("limit"), DEFAULT_LIMIT, 1, MAX_LIMIT, "The limit"),
        "range_days": _int(
            raw.get("range_days"), DEFAULT_RANGE_DAYS, 7, MAX_RANGE_DAYS, "The range"
        ),
    }
    _fit(kind, cfg)
    return cfg


def _fit(kind: str, cfg: dict[str, Any]) -> None:
    """The combinations that make sense; the rest are refused rather than guessed."""
    group, measure = cfg["group_by"], cfg["measure"]
    if kind == NUMBER:
        cfg["group_by"] = ""
    elif kind in (BAR, PIE, TABLE) and not group:
        raise invalid(f"A {kind} widget needs a grouping.")
    elif kind == LINE:
        cfg["group_by"] = group or "created_week"
        if cfg["group_by"] not in TIME_GROUPS:
            raise invalid("A line widget groups by created_day, created_week or due_week.")
    elif kind == WORKLOAD:
        cfg["group_by"], cfg["scope"] = "assignee", "open"
    elif kind == BURNDOWN:
        if not cfg["sprint_id"]:
            raise invalid("A burndown widget needs a sprint.")
        cfg["group_by"], cfg["measure"] = "", POINTS
    if measure == CYCLE_DAYS and cfg["group_by"] == "assignee":
        raise invalid("Cycle time cannot be grouped by person.")
    if measure == CYCLE_DAYS:
        cfg["scope"] = "done"  # only finished work has a cycle time
