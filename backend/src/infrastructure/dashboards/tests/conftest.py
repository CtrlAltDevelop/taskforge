from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as project_services
from infrastructure.projects.models import ProjectMember
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import invitations
from infrastructure.workspaces import services as workspace_services


class World:
    """An Owner, an ordinary member, and two projects: Web (open) and Sec (private, owner only)."""

    def __init__(self) -> None:
        users = get_user_model().objects
        self.owner = users.create_user("owner", "o@x.test", "pw-123456-x")
        self.member = users.create_user("member", "m@x.test", "pw-123456-x")
        self.ws = workspace_services.create(self.owner, "Acme", "acme")
        invitations.accept(invitations.create_link(self.ws, self.owner).token, self.member)
        set_actor(self.owner)
        self.web = project_services.create(self.owner, self.ws, "Web", "WEB").project
        self.sec = project_services.create(
            self.owner, self.ws, "Sec", "SEC", visibility="private"
        ).project
        ProjectMember.objects.get_or_create(project=self.sec, user=self.owner)

    def task(self, project: Any, title: str, **kw: Any) -> Task:
        points = kw.pop("points", None)
        made = task_services.create(self.owner, self.ws, str(project.pk), title, **kw)
        if points is not None:
            Task.objects.filter(pk=made.pk).update(points=points)
        return Task.objects.get(pk=made.pk)


@pytest.fixture
def world(db: None) -> World:
    return World()
