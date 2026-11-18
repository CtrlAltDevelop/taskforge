"""What Home remembers per person and workspace: onboarding progress, recent items, pinned
dashboards. Everything here is personal; none of it is shared with other members."""

from django.conf import settings as django_settings
from django.db import models
from django.utils import timezone

from infrastructure.workspaces.models import Workspace


class UserOnboarding(models.Model):
    """One person's first-run checklist in one workspace (a new workspace starts a new one).

    ``checklist`` maps a step name to the ISO time it was ticked. ``dismissed_at`` hides the card
    for good. ``sample_project`` is the project the starter filled with sample tasks (empty for a
    Blank starter or after the project is deleted)."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    checklist = models.JSONField(default=dict, blank=True)
    dismissed_at = models.DateTimeField(null=True, blank=True)
    sample_project = models.ForeignKey(
        "projects.Project", null=True, blank=True, on_delete=models.SET_NULL, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "workspace"], name="user_onboarding_unique")
        ]

    def __str__(self) -> str:
        return f"onboarding of {self.user_id} in {self.workspace_id}"


class RecentItem(models.Model):
    """A task the person opened (newest ``opened_at`` first, trimmed to ``RECENT_KEEP``)."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    task = models.ForeignKey("tasks.Task", on_delete=models.CASCADE, related_name="+")
    opened_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [models.UniqueConstraint(fields=["user", "task"], name="home_recent_unique")]
        indexes = [models.Index(fields=["user", "workspace", "-opened_at"], name="home_recent_idx")]

    def __str__(self) -> str:
        return f"{self.user_id} opened {self.task_id}"


class DashboardPin(models.Model):
    """A dashboard the person pinned to their Home."""

    user = models.ForeignKey(
        django_settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="+"
    )
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="+")
    dashboard = models.ForeignKey(
        "dashboards.Dashboard", on_delete=models.CASCADE, related_name="+"
    )
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["user", "dashboard"], name="home_pin_unique")
        ]
        indexes = [models.Index(fields=["user", "workspace"], name="home_pin_idx")]

    def __str__(self) -> str:
        return f"{self.user_id} pinned {self.dashboard_id}"
