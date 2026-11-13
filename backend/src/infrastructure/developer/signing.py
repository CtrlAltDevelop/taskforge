"""Signing a webhook delivery, and the check a receiver runs.

The signed text is ``"<timestamp>.<raw body>"`` and the header is ``X-TaskForge-Signature:
t=<timestamp>,v1=<hex HMAC-SHA256>`` (the timestamp is also sent as ``X-TaskForge-Timestamp``).
Signing the timestamp with the body stops a captured delivery being replayed later: a receiver
rejects a timestamp more than a few minutes old. ``verify`` is the sample receivers can copy.
"""

import hashlib
import hmac
import time
from typing import Final

SIGNATURE_HEADER: Final = "X-TaskForge-Signature"
TIMESTAMP_HEADER: Final = "X-TaskForge-Timestamp"
TOLERANCE_SECONDS: Final = 300


def sign(secret: str, timestamp: int, body: bytes) -> str:
    mac = hmac.new(secret.encode(), f"{timestamp}.".encode() + body, hashlib.sha256)
    return f"t={timestamp},v1={mac.hexdigest()}"


def verify(secret: str, header: str, body: bytes, *, now: float | None = None) -> bool:
    """Whether ``header`` is a fresh, correct signature of ``body`` under ``secret``."""
    parts = dict(item.split("=", 1) for item in header.split(",") if "=" in item)
    try:
        timestamp = int(parts["t"])
        given = parts["v1"]
    except (KeyError, ValueError):
        return False
    if abs((time.time() if now is None else now) - timestamp) > TOLERANCE_SECONDS:
        return False
    expected = sign(secret, timestamp, body).split("v1=", 1)[1]
    return hmac.compare_digest(expected, given)
