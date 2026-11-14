"""Device info for sessions (phase 40): parse ``X-Device-Info``, name the session, fingerprint it.

The app sends one header on sign-in, sign-up and refresh. While the server's *Collect device
info* setting is on, it is validated here, turned into a display label ("Pixel 8 · Android 14")
and a keyed fingerprint, and then thrown away: raw header values are never stored or logged.

The fingerprint is a label, not a credential. The client reports the facts, so it can be faked;
what protects a session is the DPoP key of phase 39. This module is about clarity and control.

REST and gRPC adapters share it: a REST request carries the header as ``HTTP_X_DEVICE_INFO``, a
gRPC call as the metadata key ``x-device-info`` (see ``common.identity.grpc_caller``).
"""

import hashlib
import hmac
import logging
import re
from dataclasses import dataclass, field
from datetime import timedelta
from typing import Any, Final

from django.conf import settings
from django.core.cache import cache
from django.db import transaction
from django.dispatch import Signal
from django.http import HttpRequest
from django.utils import timezone

from infrastructure.auth.core.models import KnownDevice

logger = logging.getLogger(__name__)

REST_META_KEY: Final = "HTTP_X_DEVICE_INFO"
GRPC_META_KEY: Final = "x-device-info"

MAX_HEADER_LENGTH: Final = 512
MAX_NAME_LENGTH: Final = 80
UNKNOWN_DEVICE: Final = "Unknown device"
FINGERPRINT_BYTES: Final = 16
SHORT_FINGERPRINT_LENGTH: Final = 8
PRUNE_AFTER: Final = timedelta(days=365)
_PRUNE_INTERVAL_SECONDS: Final = 24 * 60 * 60

# One pattern per key, matched against the whole value. Bad optional values are dropped.
_PATTERNS: Final[dict[str, re.Pattern[str]]] = {
    key: re.compile(pattern, re.ASCII)
    for key, pattern in {
        "model": r"[A-Za-z0-9](?:[A-Za-z0-9 ._+,/()\-]{0,62}[A-Za-z0-9)])?",
        "os": r"[a-z][a-z0-9]{1,15}",
        "osVersion": r"[0-9A-Za-z][0-9A-Za-z._\-]{0,23}",
        "build": r"[0-9A-Za-z][0-9A-Za-z._\-]{0,31}",
        "screen": r"\d{3,5}x\d{3,5}@\d(?:\.\d{1,2})?",
        "locale": r"[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8}){0,3}",
        "tz": r"(?:UTC|[A-Za-z]+(?:/[A-Za-z0-9_+\-]+){1,2})",
        "abi": r"[A-Za-z0-9][A-Za-z0-9_\-]{1,23}",
    }.items()
}
_REQUIRED: Final = ("model", "os")
_OS_NAMES: Final = {
    "android": "Android",
    "ios": "iOS",
    "ipados": "iPadOS",
    "macos": "macOS",
    "windows": "Windows",
    "linux": "Linux",
    "web": "Web",
}
_REJECTED_CACHE_PREFIX: Final = "device_info:rejected:"
REJECTION_REASONS: Final = ("header", "key")

new_device_signin = Signal()
"""Sent (after commit) when a sign-in arrives with a fingerprint the account has not used before.

Receivers get ``user``, ``label``, ``fingerprint``, ``session_name`` and ``first_device`` (True for
the account's very first device, which a notification would usually skip). Phase 19 listens here;
nothing in this phase sends anything."""


@dataclass(frozen=True)
class DeviceInfo:
    """The validated facts of one header. Never stored: only ``label`` and a fingerprint are."""

    model: str
    os: str
    os_version: str = ""
    build: str = ""
    screen: str = ""
    locale: str = ""
    tz: str = ""
    abi: str = ""

    @property
    def label(self) -> str:
        os_name = _OS_NAMES.get(self.os, self.os.capitalize())
        return f"{self.model} · {os_name} {self.os_version}".strip()

    def fingerprint_message(self) -> str:
        return "|".join((self.model, self.os, self.screen, self.locale, self.tz, self.abi))


@dataclass(frozen=True)
class DeviceRecord:
    """What a new session row stores about its device."""

    name: str
    device_label: str = ""
    device_fingerprint: str = ""
    flags: dict[str, bool] = field(default_factory=dict)
    """``new_device`` / ``key_changed``, present only when true; merged into the row's metadata."""

    @property
    def row_fields(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "device_label": self.device_label,
            "device_fingerprint": self.device_fingerprint,
        }


def count_rejection(reason: str) -> None:
    """Count a dropped header or key; ``/metrics`` reads the totals."""
    key = _REJECTED_CACHE_PREFIX + reason
    try:
        cache.incr(key)
    except ValueError:
        cache.add(key, 0, None)
        cache.incr(key)


def rejection_counts() -> dict[str, int]:
    return {
        reason: int(cache.get(_REJECTED_CACHE_PREFIX + reason, 0)) for reason in REJECTION_REASONS
    }


def parse(raw: str) -> DeviceInfo | None:
    """Validate a header value. ``None`` means "ignore it": it never raises, never fails a login."""
    if len(raw) > MAX_HEADER_LENGTH:
        count_rejection("header")
        return None
    if not raw.isascii() or any(ord(ch) < 32 or ord(ch) == 127 for ch in raw):
        count_rejection("header")
        return None
    pairs: dict[str, str] = {}
    for part in raw.split(";"):
        key, separator, value = part.partition("=")
        if not separator or not key or key in pairs:
            count_rejection("header")  # malformed pair or duplicate key
            return None
        pairs[key] = value
    accepted: dict[str, str] = {}
    for key, pattern in _PATTERNS.items():
        if key not in pairs:
            continue
        if pattern.fullmatch(pairs[key]) is None:  # also rejects `=` in a value
            if key in _REQUIRED:
                count_rejection("header")
                return None
            count_rejection("key")
            continue
        accepted[key] = pairs[key]
    if any(key not in accepted for key in _REQUIRED):
        count_rejection("header")
        return None
    return DeviceInfo(
        model=accepted["model"],
        os=accepted["os"],
        os_version=accepted.get("osVersion", ""),
        build=accepted.get("build", ""),
        screen=accepted.get("screen", ""),
        locale=accepted.get("locale", ""),
        tz=accepted.get("tz", ""),
        abi=accepted.get("abi", ""),
    )


def fingerprint(user_id: Any, info: DeviceInfo) -> str:
    """``HMAC-SHA256(pepper ‖ user_id, model|os|screen|locale|tz|abi)`` cut to 16 bytes, in hex.

    The user id is in the key, so one phone under two accounts gives two unrelated values, and a
    database leak reveals no raw value. ``osVersion`` and ``build`` are left out: they change with
    every update and would make a returning device look new.
    """
    key = settings.DEVICE_FINGERPRINT_PEPPER.encode() + str(user_id).encode()
    digest = hmac.new(key, info.fingerprint_message().encode(), hashlib.sha256).digest()
    return digest[:FINGERPRINT_BYTES].hex()


def short_fingerprint(value: str) -> str:
    return value[:SHORT_FINGERPRINT_LENGTH]


def collection_enabled() -> bool:
    """Whether the header is read at all: the admin toggle (else the env default) and a pepper."""
    if not settings.DEVICE_FINGERPRINT_PEPPER:
        return False
    from infrastructure.common.app_labels import app_installed

    if not app_installed("system"):
        return bool(settings.COLLECT_DEVICE_INFO)
    from infrastructure.system import toggles

    return toggles.is_enabled(toggles.COLLECT_DEVICE_INFO, default=settings.COLLECT_DEVICE_INFO)


def from_request(request: HttpRequest) -> DeviceInfo | None:
    """The request's validated device facts, or ``None`` (setting off, no header, or bad header)."""
    if not collection_enabled():
        return None
    raw = request.META.get(REST_META_KEY) or request.META.get(GRPC_META_KEY) or ""
    return parse(str(raw)) if raw else None


# --- names -----------------------------------------------------------------------------------

_BROWSERS: Final = (
    ("Edg/", "Edge"),
    ("OPR/", "Opera"),
    ("Firefox/", "Firefox"),
    ("Chrome/", "Chrome"),
    ("Safari/", "Safari"),
)
_SYSTEMS: Final = (
    ("Android", "Android"),
    ("iPhone", "iOS"),
    ("iPad", "iPadOS"),
    ("Windows", "Windows"),
    ("Macintosh", "macOS"),
    ("Linux", "Linux"),
)


def name_from_user_agent(user_agent: str) -> str:
    """A browser-and-OS name ("Chrome on macOS") from the User-Agent, or "Unknown device"."""
    browser = next((name for token, name in _BROWSERS if token in user_agent), "")
    system = next((name for token, name in _SYSTEMS if token in user_agent), "")
    if browser and system:
        return f"{browser} on {system}"
    return browser or system or UNKNOWN_DEVICE


def clean_name(value: str) -> str:
    """A user-chosen session name: plain text, trimmed, 1-80 characters. ``ValueError`` if not."""
    name = " ".join(value.split())
    if not name or len(name) > MAX_NAME_LENGTH or any(ord(ch) < 32 for ch in name):
        raise ValueError("A name is 1 to 80 characters.")
    return name


# --- sign-in and refresh -------------------------------------------------------------------


def for_signin(request: HttpRequest, user: Any, jkt: str = "") -> DeviceRecord:
    """Name the session being created and register its device. Call inside the sign-in transaction.

    With collection off, or without a usable header, the name falls back to the User-Agent and no
    fingerprint is computed and no ``KnownDevice`` row is touched.
    """
    info = from_request(request)
    if info is None:
        agent = str(request.META.get("HTTP_USER_AGENT", ""))
        return DeviceRecord(name=name_from_user_agent(agent))
    value = fingerprint(user.pk, info)
    had_devices = KnownDevice.objects.filter(user=user).exists()
    known, created = KnownDevice.objects.get_or_create(user=user, fingerprint=value)
    flags: dict[str, bool] = {}
    if created:
        flags["new_device"] = True
    elif known.dpop_jkt and jkt and known.dpop_jkt != jkt:
        flags["key_changed"] = True
    if not created:
        known.last_seen_at = timezone.now()
    if jkt:
        known.dpop_jkt = jkt
    known.save(update_fields=["last_seen_at", "dpop_jkt"])
    record = DeviceRecord(
        name=info.label[:MAX_NAME_LENGTH],
        device_label=info.label,
        device_fingerprint=value,
        flags=flags,
    )
    if created:
        transaction.on_commit(
            lambda: new_device_signin.send(
                sender=KnownDevice,
                user=user,
                label=record.device_label,
                fingerprint=value,
                session_name=record.name,
                first_device=not had_devices,
            )
        )
    return record


def on_refresh(request: HttpRequest, session: Any) -> None:
    """Keep a session's label and fingerprint current when a refresh carries the header.

    A name the user edited is never touched. A fingerprint seen for the first time here (collection
    was switched on after sign-in) is registered quietly: no ``new_device`` flag, no signal.
    """
    info = from_request(request)
    if info is None:
        return
    value = fingerprint(session.user_id, info)
    update = ["device_label", "device_fingerprint"]
    session.device_label = info.label
    session.device_fingerprint = value
    if not session.name_edited:
        session.name = info.label[:MAX_NAME_LENGTH]
        update.append("name")
    session.save(update_fields=update)
    known, _ = KnownDevice.objects.get_or_create(user_id=session.user_id, fingerprint=value)
    known.last_seen_at = timezone.now()
    known.save(update_fields=["last_seen_at"])


def view_fields(session: Any, *, current: bool) -> dict[str, Any]:
    """The device columns of a Sessions list row. Flags are quiet while collection is off."""
    live = collection_enabled()
    flags = session.metadata.get("device_flags", {}) if live else {}
    return {
        "name": session.name or UNKNOWN_DEVICE,
        "device_label": session.device_label,
        "fingerprint_short": short_fingerprint(session.device_fingerprint),
        "current": current,
        "new_device": bool(flags.get("new_device")),
        "key_changed": bool(flags.get("key_changed")),
    }


def prune_known_devices() -> int:
    """Delete devices unused for 12 months. A due worker; the work itself runs once a day."""
    if not cache.add("device_info:pruned", 1, _PRUNE_INTERVAL_SECONDS):
        return 0
    deleted, _ = KnownDevice.objects.filter(last_seen_at__lt=timezone.now() - PRUNE_AFTER).delete()
    return deleted
