"""Quiet hours and digest times, read in the person's own time zone."""

from datetime import UTC, datetime, time, timedelta
from typing import Any
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


def zone(prefs: Any) -> ZoneInfo:
    try:
        return ZoneInfo(prefs.timezone or "UTC")
    except (ZoneInfoNotFoundError, ValueError):
        return ZoneInfo("UTC")


def _inside(t: time, start: time, end: time) -> bool:
    if start <= end:
        return start <= t < end
    return t >= start or t < end


def in_quiet(now: datetime, prefs: Any) -> bool:
    """Whether ``now`` falls in the person's quiet hours (the start is inside, the end is not)."""
    window = prefs.quiet
    if window is None:
        return False
    return _inside(now.astimezone(zone(prefs)).time(), *window)


def _local(day: datetime, at: time, tz: ZoneInfo) -> datetime:
    return datetime.combine(day.date(), at, tzinfo=tz).astimezone(UTC)


def release_time(now: datetime, prefs: Any) -> datetime:
    """When a push or email may go: ``now``, or the end of the quiet hours it falls in."""
    if not in_quiet(now, prefs):
        return now
    start, end = prefs.quiet
    tz = zone(prefs)
    local = now.astimezone(tz)
    day = local + timedelta(days=1) if start > end and local.time() >= start else local
    return _local(day, end, tz)


def next_digest(now: datetime, prefs: Any) -> datetime:
    """The next time the person's digest hour comes round (strictly after ``now``)."""
    tz = zone(prefs)
    local = now.astimezone(tz)
    at = time(max(0, min(23, prefs.digest_hour)))
    today = _local(local, at, tz)
    return today if today > now else _local(local + timedelta(days=1), at, tz)
