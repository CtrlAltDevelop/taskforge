"""What a saved list layout may hold. Unknown keys and values are refused, not dropped, so a
client bug shows up at once instead of as a layout that quietly forgets things."""

import uuid
from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.tasks import listing

COLUMNS: Final = (
    "status",
    "assignee",
    "priority",
    "start_date",
    "due_date",
    "created_at",
    "updated_at",
)
FIXED_WIDTHS: Final = ("title",)  # always shown, so it has a width but is not a choice
MAX_COLUMNS: Final = 60
MIN_WIDTH, MAX_WIDTH = 40, 1200
KEYS: Final = ("columns", "widths", "sort", "group_by")

BOARD_KEYS: Final = ("group_by", "swimlane", "card_fields", "limits")
CARD_FIELDS: Final = ("assignee", "due_date", "priority", "progress")  # title and id always show
DEFAULT_CARD_FIELDS: Final = list(CARD_FIELDS)
SWIMLANES: Final = ("", "assignee")
MAX_LIMITS: Final = 200
MAX_LIMIT: Final = 9999


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.VIEW_INVALID)


def _field_ref(value: Any) -> bool:
    if not isinstance(value, str) or not value.startswith(listing.FIELD_PREFIX):
        return False
    try:
        uuid.UUID(value.removeprefix(listing.FIELD_PREFIX))
    except ValueError:
        return False
    return True


def _column(value: Any) -> str:
    if value in COLUMNS or _field_ref(value):
        return str(value)
    raise invalid(f"{value!r} is not a column.")


def _sort_key(value: Any) -> str:
    if value in listing.SORT_KEYS or _field_ref(value):
        return str(value)
    raise invalid(f"Cannot sort by {value!r}.")


def clean(raw: Any) -> dict[str, Any]:
    """The layout with every key present, or ``VIEW_INVALID``."""
    if not isinstance(raw, dict):
        raise invalid("A layout is an object.")
    unknown = set(raw) - set(KEYS)
    if unknown:
        raise invalid(f"Unknown layout key: {sorted(unknown)[0]}.")
    columns = raw.get("columns", [])
    if not isinstance(columns, list) or len(columns) > MAX_COLUMNS:
        raise invalid("columns is a list of at most 60 columns.")
    cleaned_columns = [_column(c) for c in columns]
    if len(set(cleaned_columns)) != len(cleaned_columns):
        raise invalid("A column is listed once.")
    widths = raw.get("widths", {})
    if not isinstance(widths, dict) or len(widths) > MAX_COLUMNS + len(FIXED_WIDTHS):
        raise invalid("widths maps columns to pixel widths.")
    cleaned_widths = {}
    for key, width in widths.items():
        if key not in FIXED_WIDTHS:
            _column(key)
        if isinstance(width, bool) or not isinstance(width, int | float):
            raise invalid("A width is a number.")
        if not MIN_WIDTH <= width <= MAX_WIDTH:
            raise invalid(f"A width is between {MIN_WIDTH} and {MAX_WIDTH}.")
        cleaned_widths[key] = int(width)
    sort = raw.get("sort", [])
    if not isinstance(sort, list) or len(sort) > listing.MAX_SORT:
        raise invalid(f"sort is a list of at most {listing.MAX_SORT} keys.")
    cleaned_sort = []
    for item in sort:
        if not isinstance(item, dict) or set(item) - {"key", "desc"}:
            raise invalid("A sort key is {key, desc}.")
        desc = item.get("desc", False)
        if not isinstance(desc, bool):
            raise invalid("desc is true or false.")
        cleaned_sort.append({"key": _sort_key(item.get("key")), "desc": desc})
    if len({s["key"] for s in cleaned_sort}) != len(cleaned_sort):
        raise invalid("Sort by each column once.")
    group_by = raw.get("group_by", "")
    if group_by and not (group_by in listing.GROUP_KEYS or _field_ref(group_by)):
        raise invalid(f"Cannot group by {group_by!r}.")
    return {
        "columns": cleaned_columns,
        "widths": cleaned_widths,
        "sort": cleaned_sort,
        "group_by": group_by,
    }


def clean_board(raw: Any) -> dict[str, Any]:
    """A board layout with every key present, or ``VIEW_INVALID``. ``limits`` maps a column's key
    (a status id, a priority, a user id, an option id; ``""`` for the column of tasks with none)
    to its work-in-progress limit."""
    if not isinstance(raw, dict):
        raise invalid("A layout is an object.")
    unknown = set(raw) - set(BOARD_KEYS)
    if unknown:
        raise invalid(f"Unknown layout key: {sorted(unknown)[0]}.")
    group_by = raw.get("group_by", "status")
    if not (group_by in listing.GROUP_KEYS or _field_ref(group_by)):
        raise invalid(f"Cannot group a board by {group_by!r}.")
    swimlane = raw.get("swimlane", "")
    if swimlane not in SWIMLANES:
        raise invalid(f"Cannot split a board into lanes by {swimlane!r}.")
    fields = raw.get("card_fields", DEFAULT_CARD_FIELDS)
    if not isinstance(fields, list) or len(fields) > MAX_COLUMNS:
        raise invalid("card_fields is a list of card fields.")
    for name in fields:
        if name not in CARD_FIELDS and not _field_ref(name):
            raise invalid(f"{name!r} is not a card field.")
    if len(set(fields)) != len(fields):
        raise invalid("A card field is listed once.")
    limits = raw.get("limits", {})
    if not isinstance(limits, dict) or len(limits) > MAX_LIMITS:
        raise invalid("limits maps column keys to limits.")
    for key, limit in limits.items():
        if not isinstance(key, str) or isinstance(limit, bool) or not isinstance(limit, int):
            raise invalid("A limit is a whole number.")
        if not 1 <= limit <= MAX_LIMIT:
            raise invalid(f"A limit is between 1 and {MAX_LIMIT}.")
    return {
        "group_by": group_by,
        "swimlane": swimlane,
        "card_fields": list(fields),
        "limits": dict(limits),
    }


CALENDAR_KEYS: Final = ("mode", "color_by", "week_start", "hide_done")
CALENDAR_MODES: Final = ("month", "week", "day")
CALENDAR_COLORS: Final = ("status", "priority")


def clean_calendar(raw: Any) -> dict[str, Any]:
    """A calendar layout with every key present, or ``VIEW_INVALID``. ``week_start`` is the ISO
    weekday the week begins on (1 Monday ... 7 Sunday; 0: the viewer's locale decides)."""
    if not isinstance(raw, dict):
        raise invalid("A layout is an object.")
    unknown = set(raw) - set(CALENDAR_KEYS)
    if unknown:
        raise invalid(f"Unknown layout key: {sorted(unknown)[0]}.")
    mode = raw.get("mode", "month")
    if mode not in CALENDAR_MODES:
        raise invalid(f"{mode!r} is not a calendar mode.")
    color_by = raw.get("color_by", "status")
    if color_by not in CALENDAR_COLORS:
        raise invalid(f"Cannot colour a calendar by {color_by!r}.")
    week_start = raw.get("week_start", 0)
    if isinstance(week_start, bool) or not isinstance(week_start, int) or not 0 <= week_start <= 7:
        raise invalid("week_start is a weekday from 1 (Monday) to 7 (Sunday), or 0.")
    hide_done = raw.get("hide_done", False)
    if not isinstance(hide_done, bool):
        raise invalid("hide_done is true or false.")
    return {"mode": mode, "color_by": color_by, "week_start": week_start, "hide_done": hide_done}


def clean_for(kind: str, raw: Any) -> dict[str, Any]:
    if kind == "board":
        return clean_board(raw)
    return clean_calendar(raw) if kind == "calendar" else clean(raw)
