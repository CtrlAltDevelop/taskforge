"""Validation of the editable task fields. Each cleaner returns the stored form or raises."""

import json
from datetime import date, time
from decimal import Decimal, InvalidOperation
from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.tasks.models import Priority

TITLE_MAX: Final = 500
DESCRIPTION_MAX_BYTES: Final = 200 * 1024
BLOCKS: Final = frozenset(
    {
        "paragraph",
        "heading",
        "bullet_list",
        "ordered_list",
        "list_item",
        "checklist",
        "checklist_item",
        "code_block",
        "blockquote",
        "horizontal_rule",
    }
)
INLINE: Final = frozenset({"text", "hard_break", "link"})
MAX_DEPTH: Final = 8


def clean_title(value: str) -> str:
    cleaned = value.strip()
    if not cleaned or len(cleaned) > TITLE_MAX:
        raise ApiError(f"The title must be 1-{TITLE_MAX} characters.")
    return cleaned


def clean_priority(value: str) -> str:
    if value not in Priority.values:
        raise ApiError(f"The priority must be one of: {', '.join(Priority.values)}.")
    return value


def clean_date(value: str) -> date | None:
    if not value:
        return None
    try:
        return date.fromisoformat(value)
    except ValueError:
        raise ApiError("Dates must be YYYY-MM-DD.") from None


def clean_time(value: str) -> time | None:
    """``HH:MM`` (UTC), or empty for none."""
    if not value:
        return None
    try:
        if len(value) != 5 or value[2] != ":":
            raise ValueError(value)
        return time(int(value[:2]), int(value[3:]))
    except ValueError:
        raise ApiError("Times must be HH:MM.") from None


def check_range(start: date | None, due: date | None) -> None:
    if start and due and due < start:
        raise ApiError("The due date cannot be before the start date.")


def _check_node(node: Any, depth: int) -> None:
    if depth > MAX_DEPTH or not isinstance(node, dict):
        raise ApiError("The description is not a valid document.")
    kind = node.get("type")
    if kind not in BLOCKS | INLINE:
        raise ApiError(f"Unknown description node type: {kind!r}.")
    if kind == "text" and not isinstance(node.get("text"), str):
        raise ApiError("A text node needs a text string.")
    children = node.get("content", [])
    if not isinstance(children, list):
        raise ApiError("A node's content must be a list.")
    for child in children:
        _check_node(child, depth + 1)


def clean_description(value: str) -> dict[str, Any]:
    """Parse the rich-text JSON the client sends; ``""`` clears it to ``{}``."""
    if not value.strip():
        return {}
    if len(value.encode()) > DESCRIPTION_MAX_BYTES:
        raise ApiError("The description must be at most 200 KB.")
    try:
        document = json.loads(value)
    except ValueError:
        raise ApiError("The description must be valid JSON.") from None
    if not isinstance(document, dict) or document.get("type") != "doc":
        raise ApiError('The description must be a {"type": "doc"} document.')
    children = document.get("content", [])
    if not isinstance(children, list):
        raise ApiError("The document content must be a list.")
    for child in children:
        _check_node(child, 1)
    return document


ESTIMATE_MAX: Final = 100 * 24 * 3600


def clean_estimate(value: str) -> int | None:
    """Seconds as a whole number, or empty for no estimate."""
    if not value:
        return None
    try:
        seconds = int(value)
    except ValueError:
        raise ApiError("The estimate must be a whole number of seconds.") from None
    if not 0 < seconds <= ESTIMATE_MAX:
        raise ApiError("The estimate must be between a second and 100 days.")
    return seconds


POINTS_MAX: Final = Decimal("9999.99")


def clean_points(value: str) -> Decimal | None:
    """Story points (up to two decimals), or empty for none."""
    if not value:
        return None
    try:
        points = Decimal(value).quantize(Decimal("0.01"))
    except (InvalidOperation, ValueError):
        raise ApiError("The points must be a number.") from None
    if not points.is_finite() or not 0 <= points <= POINTS_MAX:
        raise ApiError("The points must be between 0 and 9999.99.")
    return points
