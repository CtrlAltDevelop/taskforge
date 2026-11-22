"""The core demo seed builds every area it promises, and ``--reset`` rebuilds it cleanly."""

from io import StringIO
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.core.management import call_command

from infrastructure.common.demo import core
from infrastructure.common.demo.base import Ctx
from infrastructure.customfields.models import FieldDefinition, FieldType
from infrastructure.filters.models import SavedFilter
from infrastructure.projects.models import Project
from infrastructure.savedviews.models import SavedView
from infrastructure.tasks.models import LinkType, Task, TaskLink
from infrastructure.workspaces.models import Invitation, Role, Workspace, WorkspaceMember

pytestmark = pytest.mark.django_db(transaction=True)


@pytest.fixture(autouse=True)
def _debug(settings: Any) -> None:
    settings.DEBUG = True


def _counts() -> dict[str, int]:
    live = Task.objects.filter(deleted_at__isnull=True)
    return {
        "users": get_user_model().objects.count(),
        "workspaces": Workspace.objects.count(),
        "projects": Project.objects.count(),
        "tasks": live.count(),
        "trashed": Task.objects.filter(deleted_at__isnull=False).count(),
        "views": SavedView.objects.count(),
        "filters": SavedFilter.objects.count(),
    }


def test_seed_creates_every_core_area() -> None:
    ctx = Ctx()
    core.seed(ctx)

    assert set(ctx.users) == {
        "owner",
        "admin",
        "member",
        "dev",
        "designer",
        "viewer",
        "guest",
        "demo",
    }
    assert set(ctx.projects) == {"web", "mobile", "bugs", "marketing", "private", "archived"}
    assert ctx.ws.slug == "acme" and ctx.workspaces["side"].slug == "side-project"
    assert ctx.projects["archived"].pk and Project.objects.get(key="OLD").archived_at
    assert Project.objects.get(key="PRV").visibility == "private"

    roles = {m.user.username: m.role.name for m in WorkspaceMember.objects.filter(workspace=ctx.ws)}
    assert roles["owner"] == "Owner" and roles["admin"] == "Admin"
    assert roles["viewer"] == "Viewer" and roles["guest"] == "Support"
    assert Role.objects.filter(workspace=ctx.ws, name="Support").exists()
    assert Invitation.objects.filter(workspace=ctx.ws, accepted_at=None).count() == 2

    live = Task.objects.filter(workspace=ctx.ws, deleted_at__isnull=True)
    assert live.count() >= 70
    assert Task.objects.filter(workspace=ctx.ws, deleted_at__isnull=False).count() == 3
    assert max(live.values_list("depth", flat=True)) == 3
    assert live.filter(assignees__isnull=True).exists()
    assert {"web-1", "chk", "login", "bug-a"} <= set(ctx.tasks)
    parent = Task.objects.get(pk=ctx.tasks["chk"].pk)
    assert parent.progress_total >= 3 and parent.progress_done >= 1

    assert {LinkType.BLOCKS, LinkType.RELATES, LinkType.DUPLICATES} <= set(
        TaskLink.objects.values_list("type", flat=True)
    )
    assert set(FieldDefinition.objects.values_list("type", flat=True)) == set(FieldType.values)
    assert SavedView.objects.filter(pinned_as_tab=True).exists()
    assert SavedFilter.objects.filter(project__isnull=True).exists()


def test_reset_rebuilds_the_same_dataset() -> None:
    out = StringIO()
    call_command("seed_demo", stdout=out)
    first = _counts()
    call_command("seed_demo", stdout=out)  # no --reset: leaves it alone
    assert _counts() == first
    call_command("seed_demo", "--reset", stdout=out)
    assert _counts() == first
