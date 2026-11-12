"""Make a changed value safe and small before it is stored: plain JSON, no secrets, no bodies."""

import datetime as dt
import json
import uuid
from decimal import Decimal
from typing import Any, Final

from django.conf import settings

MAX_TEXT: Final = 300
MAX_JSON: Final = 600
REDACTED: Final = "[redacted]"
DEFAULT_REDACT_KEYS: Final = frozenset(
    {
        "password",
        "secret",
        "token",
        "token_hash",
        "authorization",
        "api_key",
        "headers",
        "url",  # a webhook address is a bearer secret (Slack, Teams ...)
    }
)


def redact_keys() -> frozenset[str]:
    return DEFAULT_REDACT_KEYS | frozenset(
        k.lower() for k in getattr(settings, "AUDIT_REDACT_KEYS", ())
    )


def _scrub(value: Any, keys: frozenset[str]) -> Any:
    if isinstance(value, dict):
        return {
            k: REDACTED if str(k).lower() in keys else _scrub(v, keys) for k, v in value.items()
        }
    if isinstance(value, list):
        return [_scrub(v, keys) for v in value]
    return value


def plain(value: Any) -> Any:
    """One field value as something JSON stores and a reader can show."""
    if value is None or isinstance(value, bool | int | float):
        return value
    if isinstance(value, uuid.UUID | Decimal):
        return str(value)
    if isinstance(value, dt.datetime | dt.date | dt.time):
        return value.isoformat()
    if isinstance(value, dict | list):
        text = json.dumps(_scrub(value, redact_keys()), default=str, sort_keys=True)
        # A body (a page, a description) is not copied: its size says enough.
        return json.loads(text) if len(text) <= MAX_JSON else {"size": len(text)}
    text = str(value)
    return text if len(text) <= MAX_TEXT else {"size": len(text), "start": text[:80]}


def clean(changes: dict[str, Any]) -> dict[str, Any]:
    """Every value (or before/after pair) made plain; a key that names a secret is blanked."""
    keys = redact_keys()
    out: dict[str, Any] = {}
    for name, change in changes.items():
        if name.lower() in keys:
            out[name] = REDACTED
        elif isinstance(change, list | tuple):
            out[name] = [plain(v) for v in change]
        else:
            out[name] = plain(change)
    return out
