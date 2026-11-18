from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as project_services
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces import access, invitations
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.models import WorkspaceMember


class World:
    """An Owner, a Member, a Viewer, and two projects: Web (open) and Sec (private, owner only)."""

    def __init__(self) -> None:
        users = get_user_model().objects
        self.owner = users.create_user("owner", "o@x.test", "pw-123456-x")
        self.member = users.create_user("member", "m@x.test", "pw-123456-x")
        self.viewer = users.create_user("viewer", "v@x.test", "pw-123456-x")
        self.ws = workspace_services.create(self.owner, "Acme", "acme")
        invitations.accept(invitations.create_link(self.ws, self.owner).token, self.member)
        WorkspaceMember.objects.create(
            workspace=self.ws, user=self.viewer, role=access.builtin_role("Viewer")
        )
        set_actor(self.owner)
        self.web = project_services.create(self.owner, self.ws, "Web", "WEB").project
        self.sec = project_services.create(
            self.owner, self.ws, "Sec", "SEC", visibility="private"
        ).project

    def task(self, project: Any, title: str, *assignees: Any, **kw: Any) -> Task:
        made = task_services.create(self.owner, self.ws, str(project.pk), title, **kw)
        for user in assignees:  # directly: a private project's assignee list is not what is tested
            TaskAssignee.objects.get_or_create(task_id=made.pk, user=user)
        return Task.objects.get(pk=made.pk)

    def task_in(self, workspace: Any, project: Any, title: str, *assignees: Any, **kw: Any) -> Task:
        made = task_services.create(self.owner, workspace, str(project.pk), title, **kw)
        for user in assignees:
            TaskAssignee.objects.get_or_create(task_id=made.pk, user=user)
        return Task.objects.get(pk=made.pk)

    def move(self, task: Task, category: str) -> None:
        status = Status.objects.filter(project=task.project, category=category).first()
        Task.objects.filter(pk=task.pk).update(status=status)


@pytest.fixture
def world(db: None) -> World:
    return World()


__all__ = ["Category", "World", "world"]
