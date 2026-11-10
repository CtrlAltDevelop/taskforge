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
