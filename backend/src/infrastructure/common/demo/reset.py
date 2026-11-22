"""Remove the demo: its workspaces (hard delete, cascades) and its users."""

from django.contrib.auth import get_user_model

from infrastructure.projects.models import Project
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Status
from infrastructure.workspaces.models import Workspace

DEMO_USERNAMES = ("owner", "admin", "member", "dev", "designer", "viewer", "guest", "demo")


def wipe() -> None:
    """Delete every workspace the demo owner created, then the demo users.

    There is no service for hard-deleting a workspace (the product only soft-deletes it for
    seven days), so this is the one place that uses the ORM directly; deleting is cascading
    and is for local development only.
    """
    users = get_user_model().objects.filter(username__in=DEMO_USERNAMES)
    owned = Workspace.objects.filter(created_by__in=users)
    # Task -> Status -> Project -> Workspace are PROTECT links: delete from the leaves up.
    Task.objects.filter(workspace__in=owned).delete()
    Status.objects.filter(project__workspace__in=owned).delete()
    Project.objects.filter(workspace__in=owned).delete()
    # Service accounts (the "Release bot") get a generated ``sa-…`` user inside those workspaces.
    bots = get_user_model().objects.filter(
        username__startswith="sa-", workspace_memberships__workspace__in=owned
    )
    bot_ids = list(bots.values_list("pk", flat=True))
    owned.delete()
    get_user_model().objects.filter(pk__in=bot_ids).delete()
    users.delete()
