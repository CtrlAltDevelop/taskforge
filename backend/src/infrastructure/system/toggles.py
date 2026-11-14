"""Read and change the runtime toggles stored in :class:`ServerToggle`."""

from typing import Any

from django.utils import timezone

from infrastructure.system.models import ServerToggle

COLLECT_DEVICE_INFO = "collect_device_info"


def is_enabled(key: str, *, default: bool) -> bool:
    """The toggle's stored value, or ``default`` (the environment's) when nobody has set it."""
    row = ServerToggle.objects.filter(key=key).only("enabled").first()
    return default if row is None else row.enabled


def set_enabled(key: str, enabled: bool, *, by: Any = None) -> None:
    ServerToggle.objects.update_or_create(
        key=key,
        defaults={"enabled": enabled, "updated_by": by, "updated_at": timezone.now()},
    )
