"""One person's key binding for one action."""

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone


class UserShortcut(models.Model):
    """One person's key chord for one registry action; an empty chord means unbound on purpose.

    ``action_id`` names an entry of the client's action registry (the registry is client code, so
    the server keeps the name as an opaque string). ``keys`` is a normalised chord (see
    ``shortcuts.keys``). Personal to the user, not to a workspace: the same keys follow them into
    every workspace and onto every device."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    action_id = models.CharField(max_length=80)
    keys = models.CharField(max_length=40, blank=True)
    updated_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "action_id"], name="user_shortcut_unique"),
        ]

    def __str__(self) -> str:
        return f"{self.action_id}={self.keys}"
