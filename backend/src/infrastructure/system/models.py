"""Settings an operator changes while the server runs (phase 40).

Environment variables give the default; a row here overrides it, so the admin System page can
flip a toggle without a redeploy. Only boolean toggles for now.
"""

from django.conf import settings
from django.db import models
from django.utils import timezone


class ServerToggle(models.Model):
    key = models.CharField(max_length=64, primary_key=True)
    enabled = models.BooleanField(default=False)
    updated_at = models.DateTimeField(default=timezone.now)
    updated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="+",
    )

    def __str__(self) -> str:
        return f"{self.key}={self.enabled}"
