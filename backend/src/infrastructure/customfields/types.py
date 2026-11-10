"""What each field type accepts and how it is stored. Pure: no database, no transport.

A value travels as one string (its *wire form*): text and url as typed, number and money as
decimal strings (never floats; money is ``"12.50 USD"``), select as an option id, multiselect as
option ids joined by commas, date as ``YYYY-MM-DD``, checkbox as ``true`` / ``false``, user as a
user id. ``""`` means "no value".
"""

import re
import uuid
from collections.abc import Callable, Iterable
from dataclasses import dataclass
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Any, Final
from urllib.parse import urlsplit

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields.models import FieldType

NAME_MAX: Final = 60
OPTION_LABEL_MAX: Final = 60
OPTIONS_MAX: Final = 100
TEXT_MAX: Final = 500  # kept short so the value stays inside an index entry
URL_MAX: Final = 2000  # ASCII only (percent-encoded), for the same reason
NUMBER_PLACES: Final = 6
MONEY_PLACES: Final = 4
MAX_INTEGER_DIGITS: Final = 18
SELECT_TYPES: Final = frozenset({FieldType.SELECT, FieldType.MULTISELECT})
HIDEABLE_VIEWS: Final = frozenset({"list", "board", "calendar", "timeline"})
COMPATIBLE_CHANGES: Final = frozenset(
    {(FieldType.TEXT, FieldType.URL), (FieldType.URL, FieldType.TEXT)}
)
OPTION_ID_PATTERN: Final = re.compile(r"[0-9a-f]{32}")  # the form the server hands out
COLOR_PATTERN: Final = re.compile(r"#[0-9A-Fa-f]{6}")
CURRENCY_PATTERN: Final = re.compile(r"[A-Z]{3}")


@dataclass(frozen=True, slots=True)
class Stored:
    """A value as the typed columns hold it. ``Stored()`` is the empty value."""

    text: str = ""
    number: Decimal | None = None
    day: date | None = None
    json: Any = None

    @property
    def is_empty(self) -> bool:
        return not self.text and self.number is None and self.day is None and self.json is None


EMPTY: Final = Stored()
UserCheck = Callable[[str], str]


def invalid(message: str) -> ApiError:
    return ApiError(message, title=ResponseTitle.FIELD_INVALID)


def clean_name(value: str) -> str:
    cleaned = value.strip()
    if not cleaned or len(cleaned) > NAME_MAX:
        raise invalid(f"The field name must be 1-{NAME_MAX} characters.")
    return cleaned


def clean_type(value: str) -> str:
    if value not in FieldType.values:
        raise invalid(f"The field type must be one of: {', '.join(FieldType.values)}.")
    return value


def clean_hidden_views(values: Iterable[str]) -> list[str]:
    seen = list(dict.fromkeys(values))
    unknown = [v for v in seen if v not in HIDEABLE_VIEWS]
    if unknown:
        raise invalid(f"Unknown view: {unknown[0]}.")
    return seen


def clean_options(field_type: str, raw: Iterable[dict[str, str]]) -> list[dict[str, str]]:
    """Validate the options of a field of ``field_type``; an option without an id gets one."""
    items = list(raw)
    if field_type not in SELECT_TYPES:
        if items:
            raise invalid("Only select fields have options.")
        return []
    if not 1 <= len(items) <= OPTIONS_MAX:
        raise invalid(f"A select field needs 1-{OPTIONS_MAX} options.")
    cleaned: list[dict[str, str]] = []
    for item in items:
        label = item.get("label", "").strip()
        color = item.get("color", "").strip()
        if not label or len(label) > OPTION_LABEL_MAX:
            raise invalid(f"An option label must be 1-{OPTION_LABEL_MAX} characters.")
        if color and not COLOR_PATTERN.fullmatch(color):
            raise invalid("An option color must look like #RRGGBB.")
        option_id = item.get("id", "").strip() or uuid.uuid4().hex
        if not OPTION_ID_PATTERN.fullmatch(option_id):
            raise invalid("An option id is not one this server issued.")
        cleaned.append({"id": option_id, "label": label, "color": color.upper()})
    if len({o["id"] for o in cleaned}) != len(cleaned):
        raise invalid("Two options share an id.")
    if len({o["label"].casefold() for o in cleaned}) != len(cleaned):
        raise invalid("Two options share a label.")
    return cleaned


def _decimal(raw: str, places: int) -> Decimal:
    try:
        value = Decimal(raw.strip())
    except InvalidOperation:
        raise invalid(f"{raw!r} is not a number.") from None
    if not value.is_finite():
        raise invalid(f"{raw!r} is not a number.")
    exponent = value.as_tuple().exponent
    # Trailing zeros beyond the precision are harmless; anything else would be rounded.
    if (
        isinstance(exponent, int)
        and -exponent > places
        and value != value.quantize(Decimal(1).scaleb(-places))
    ):
        raise invalid(f"At most {places} decimal places are allowed.")
    if value.adjusted() >= MAX_INTEGER_DIGITS:
        raise invalid("That number is too large.")
    return value.quantize(Decimal(1).scaleb(-places))


def plain(value: Decimal, min_places: int = 0) -> str:
    """The decimal without exponent or trailing zeros (but at least ``min_places`` places)."""
    text = format(value.normalize(), "f")
    if min_places:
        whole, _, fraction = text.partition(".")
        text = f"{whole}.{fraction.ljust(min_places, '0')}"
    return text


def _url(raw: str) -> str:
    value = raw.strip()
    parts = urlsplit(value)
    if (
        len(value) > URL_MAX
        or not value.isascii()
        or parts.scheme not in ("http", "https")
        or not parts.netloc
        or any(c.isspace() for c in value)
    ):
        raise invalid("A URL must start with http:// or https:// (no spaces, percent-encoded).")
    return value


def _text(raw: str) -> str:
    value = raw.strip()
    if len(value) > TEXT_MAX:
        raise invalid(f"Text can be at most {TEXT_MAX} characters.")
    return value


def option_ids(options: Iterable[dict[str, str]]) -> list[str]:
    return [o["id"] for o in options]


def clean_value(
    field_type: str, options: list[dict[str, str]], raw: str, user_check: UserCheck
) -> Stored:
    """The stored form of ``raw`` for a field, or ``FIELD_INVALID``. ``user_check`` returns the
    canonical user id of a user who may be chosen, else raises."""
    if not raw.strip():
        return EMPTY
    match field_type:
        case FieldType.TEXT:
            return Stored(text=_text(raw))
        case FieldType.URL:
            return Stored(text=_url(raw))
        case FieldType.NUMBER:
            return Stored(number=_decimal(raw, NUMBER_PLACES))
        case FieldType.MONEY:
            amount, _, currency = raw.strip().partition(" ")
            code = currency.strip().upper()
            if not CURRENCY_PATTERN.fullmatch(code):
                raise invalid('Money looks like "12.50 USD".')
            return Stored(text=code, number=_decimal(amount, MONEY_PLACES))
        case FieldType.DATE:
            try:
                return Stored(day=date.fromisoformat(raw.strip()))
            except ValueError:
                raise invalid("Dates must be YYYY-MM-DD.") from None
        case FieldType.CHECKBOX:
            word = raw.strip().lower()
            if word not in ("true", "false"):
                raise invalid("A checkbox is true or false.")
            return Stored(number=Decimal(int(word == "true")))
        case FieldType.SELECT:
            chosen = raw.strip()
            if chosen not in option_ids(options):
                raise invalid("That option does not exist on this field.")
            return Stored(text=chosen)
        case FieldType.MULTISELECT:
            wanted = list(dict.fromkeys(p.strip() for p in raw.split(",") if p.strip()))
            known = option_ids(options)
            if any(w not in known for w in wanted):
                raise invalid("An option does not exist on this field.")
            return Stored(json=[k for k in known if k in wanted])
        case FieldType.USER:
            return Stored(text=user_check(raw.strip()))
    raise invalid("Unknown field type.")


def render(field_type: str, stored: Stored) -> str:
    """The wire form of a stored value (``""`` when empty)."""
    if stored.is_empty:
        return ""
    match field_type:
        case FieldType.NUMBER:
            return plain(stored.number) if stored.number is not None else ""
        case FieldType.MONEY:
            amount = plain(stored.number, 2) if stored.number is not None else ""
            return f"{amount} {stored.text}"
        case FieldType.DATE:
            return stored.day.isoformat() if stored.day else ""
        case FieldType.CHECKBOX:
            return "true" if stored.number else "false"
        case FieldType.MULTISELECT:
            return ",".join(stored.json or [])
        case _:
            return stored.text
