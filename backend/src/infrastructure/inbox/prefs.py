"""A person's notification choices (per kind), their quiet hours and their push devices."""

from dataclasses import dataclass
from datetime import time
from typing import Any
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from django.db import transaction
from django.utils import timezone as dj_timezone

from infrastructure.common.errors import ApiError
from infrastructure.inbox import kinds
from infrastructure.inbox.models import EmailMode, InboxSettings, NotificationPref, PushDevice

PLATFORMS = ("ios", "android", "web", "desktop")
TOKEN_MAX = 512
DEVICES_MAX = 10  # per person: the oldest is forgotten past this


@dataclass(frozen=True, slots=True)
class Effective:
    inbox: bool
    push: bool
    email_mode: str


def _defaults(kind: kinds.Kind) -> Effective:
    return Effective(kind.inbox, kind.push, kind.email_mode)


def effective(user_id: Any, kind: str) -> Effective:
    """What ``kind`` does for ``user_id``: their choice, else the quiet default."""
    row = NotificationPref.objects.filter(user_id=user_id, event_type=kind).first()
    if row is None:
        return _defaults(kinds.BY_KEY[kind])
    return Effective(row.inbox, row.push, row.email_mode)


def effective_many(user_ids: list[Any], kind: str) -> dict[Any, Effective]:
    rows = {
        r.user_id: Effective(r.inbox, r.push, r.email_mode)
        for r in NotificationPref.objects.filter(user_id__in=user_ids, event_type=kind)
    }
    return {u: rows.get(u, _defaults(kinds.BY_KEY[kind])) for u in user_ids}


def settings_of(user: Any) -> InboxSettings:
    row, _ = InboxSettings.objects.get_or_create(user=user)
    return row


def _clock(value: time | None) -> str:
    return value.strftime("%H:%M") if value else ""


def get(user: Any) -> dict[str, Any]:
    chosen = {r.event_type: r for r in NotificationPref.objects.filter(user=user)}
    rows = []
    for kind in kinds.KINDS:
        row = chosen.get(kind.key)
        have = Effective(row.inbox, row.push, row.email_mode) if row else _defaults(kind)
        rows.append(
            {
                "event_type": kind.key,
                "label": kind.label,
                "inbox": have.inbox,
                "push": have.push,
                "email_mode": have.email_mode,
            }
        )
    s = settings_of(user)
    return {
        "prefs": rows,
        "settings": {
            "timezone": s.timezone,
            "quiet_start": _clock(s.quiet_start),
            "quiet_end": _clock(s.quiet_end),
            "digest_hour": s.digest_hour,
        },
    }


def set_pref(user: Any, event_type: str, *, inbox: bool, push: bool, email_mode: str) -> None:
    if event_type not in kinds.BY_KEY:
        raise ApiError(f"Unknown kind of notification: {event_type!r}.")
    if email_mode not in EmailMode.values:
        raise ApiError("Email is off, instant or digest.")
    NotificationPref.objects.update_or_create(
        user=user,
        event_type=event_type,
        defaults={"inbox": inbox, "push": push, "email_mode": email_mode},
    )


def _time(raw: str, name: str) -> time:
    try:
        value = time.fromisoformat(raw)
    except ValueError:
        raise ApiError(f"{name} must be a time like 22:00.") from None
    if value.tzinfo is not None:
        raise ApiError(f"{name} must be a time like 22:00, without a zone.")
    return value


def set_settings(
    user: Any, *, timezone: str, quiet_start: str, quiet_end: str, digest_hour: int
) -> None:
    try:
        if len(timezone) > 64:
            raise ValueError("too long")
        ZoneInfo(timezone)
    except (ZoneInfoNotFoundError, ValueError, OSError):
        raise ApiError("That is not a time zone (try Europe/Paris).") from None
    if not 0 <= digest_hour <= 23:
        raise ApiError("The digest hour is 0 to 23.")
    if bool(quiet_start) != bool(quiet_end):
        raise ApiError("Quiet hours need a start and an end.")
    start = _time(quiet_start, "The start") if quiet_start else None
    end = _time(quiet_end, "The end") if quiet_end else None
    if start is not None and start == end:
        raise ApiError("Quiet hours cannot start and end at the same time.")
    InboxSettings.objects.update_or_create(
        user=user,
        defaults={
            "timezone": timezone,
            "quiet_start": start,
            "quiet_end": end,
            "digest_hour": digest_hour,
        },
    )


def register_device(user: Any, platform: str, token: str) -> None:
    if platform not in PLATFORMS:
        raise ApiError(f"The platform is one of {', '.join(PLATFORMS)}.")
    if not token or len(token) > TOKEN_MAX:
        raise ApiError("A device needs its push token.")
    with transaction.atomic():
        PushDevice.objects.update_or_create(
            token=token,
            defaults={"user": user, "platform": platform, "last_seen_at": dj_timezone.now()},
        )
        mine = PushDevice.objects.filter(user=user).order_by("-last_seen_at", "-id")
        stale = list(mine.values_list("pk", flat=True)[DEVICES_MAX:])
        if stale:
            PushDevice.objects.filter(pk__in=stale).delete()


def unregister_device(user: Any, token: str) -> None:
    PushDevice.objects.filter(user=user, token=token).delete()


DEVICE_STALE_DAYS = 60


def prune_devices() -> int:
    """Forget devices not seen for a long time (their tokens are certainly stale)."""
    from datetime import timedelta

    cutoff = dj_timezone.now() - timedelta(days=DEVICE_STALE_DAYS)
    count, _ = PushDevice.objects.filter(last_seen_at__lt=cutoff).delete()
    return count
