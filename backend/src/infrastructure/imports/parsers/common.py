"""Small readers shared by the parsers: dates, numbers, people, lists. None of them raises on bad
input: a value that cannot be read is ``None`` and the parser records a warning."""

import re
from datetime import UTC, date, datetime
from decimal import Decimal, InvalidOperation
from typing import Any

from dateutil import parser as dateparser

from infrastructure.imports.records import Person

MAX_POINTS = Decimal("9999.99")


def when(value: Any) -> datetime | None:
    """A moment from ISO text, a Jira/ClickUp date text, or epoch seconds or milliseconds."""
    if value is None or value == "":
        return None
    text = str(value).strip()
    if not text:
        return None
    try:
        if re.fullmatch(r"\d{9,14}", text):
            number = int(text)
            seconds = number / 1000 if number > 99_999_999_999 else number
            return datetime.fromtimestamp(seconds, tz=UTC)
        parsed = dateparser.parse(text)
    except (ValueError, OverflowError, OSError, dateparser.ParserError):
        return None
    if parsed is None:
        return None
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=UTC)


def day(value: Any) -> date | None:
    moment = when(value)
    return moment.date() if moment else None


def number(value: Any) -> Decimal | None:
    if value in (None, ""):
        return None
    try:
        out = Decimal(str(value).strip().replace(",", "."))
    except InvalidOperation:
        return None
    if not out.is_finite() or out < 0 or out > MAX_POINTS:
        return None
    return out.quantize(Decimal("0.01"))


def seconds(value: Any, unit: str = "s") -> int | None:
    """A duration as seconds from a number of ``s`` seconds, ``ms`` milliseconds or ``h`` hours."""
    n = number(value) if unit != "ms" else number(Decimal(str(value or 0)) / 1000)
    if n is None:
        return None
    factor = 3600 if unit == "h" else 1
    return int(n * factor)


def listing(value: Any, separators: str = ",;") -> tuple[str, ...]:
    """``"[a, b]"``, ``"a;b"`` or ``["a", "b"]`` as a tuple of non-empty strings."""
    if isinstance(value, (list, tuple)):
        parts = [str(v) for v in value]
    else:
        text = str(value or "").strip()
        if text.startswith("[") and text.endswith("]"):
            text = text[1:-1]
        parts = re.split("[" + re.escape(separators) + "]", text) if text else []
    return tuple(dict.fromkeys(p.strip().strip("'\"") for p in parts if p.strip().strip("'\"")))


def person(name: Any = "", email: Any = "") -> Person | None:
    n, e = str(name or "").strip(), str(email or "").strip()
    if not n and not e:
        return None
    return Person(name=n or e, email=e.lower() if "@" in e else "")


def people_text(value: Any) -> tuple[Person, ...]:
    """People written as a list of names or emails ("Ann <ann@x.com>" is split)."""
    out = []
    for item in listing(value):
        found = re.fullmatch(r"(.*?)\s*<([^>]+@[^>]+)>", item)
        made = (
            person(found.group(1), found.group(2))
            if found
            else person(item, item if "@" in item else "")
        )
        if made:
            out.append(made)
    return tuple(out)
