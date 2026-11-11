"""A workspace's days. A workspace has no time zone of its own yet, so its days are the ones its
creator lives in (their profile's zone, else ``ACCOUNTS_DEFAULT_TIMEZONE``, else UTC): sprint days
and the midnight snapshot both follow it."""

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from django.conf import settings

from infrastructure.workspaces.models import Workspace


def _zone(name: str) -> ZoneInfo | None:
    try:
        return ZoneInfo(name) if name else None
    except (ZoneInfoNotFoundError, ValueError):
        return None


def zone_of(workspace: Workspace) -> ZoneInfo:
    owner = workspace.created_by
    profile = getattr(owner, "profile", None)
    return (
        _zone(getattr(profile, "timezone", ""))
        or _zone(getattr(settings, "ACCOUNTS_DEFAULT_TIMEZONE", ""))
        or ZoneInfo("UTC")
    )


def local_date(zone: ZoneInfo, moment: datetime) -> date:
    return moment.astimezone(zone).date()


def day_end(zone: ZoneInfo, day: date) -> datetime:
    """The midnight that closes ``day`` there."""
    return datetime.combine(day + timedelta(days=1), time.min, tzinfo=zone)
