from datetime import UTC, date, datetime
from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.common.errors import ApiError
from infrastructure.projects import services as project_services
from infrastructure.projects.models import ProjectMember
from infrastructure.recurrence import services
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workflows.models import Category, Status
from infrastructure.workspaces import access, invitations
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.models import WorkspaceMember


def at(day: str, hour: int = 12) -> datetime:
    """A moment on ``day`` (UTC)."""
    start = date.fromisoformat(day)
    return datetime(start.year, start.month, start.day, hour, tzinfo=UTC)


class World:
    """An Owner, a Member, a read-only Viewer, and two projects: Web (open) and Sec (private)."""

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
        ProjectMember.objects.get_or_create(project=self.sec, user=self.owner)

    def task(self, project: Any = None, title: str = "Weekly report", **kw: Any) -> Task:
        made = task_services.create(self.owner, self.ws, str((project or self.web).pk), title, **kw)
        return Task.objects.get(pk=made.pk)

    def repeat(self, task: Task, rrule: str = "FREQ=WEEKLY", **kw: Any) -> services.View:
        kw.setdefault("mode", "schedule")
        return services.set_rule(
            self.owner, self.ws, str(task.project_id), str(task.pk), rrule=rrule, **kw
        )

    def finish(self, task: Task) -> None:
        done = Status.objects.filter(project=task.project, category=Category.DONE).first()
        fresh = Task.objects.get(pk=task.pk)
        task_services.update(
            self.owner, self.ws, str(fresh.project_id), str(fresh.pk), fresh.version,
            {"status": str(done.pk)},
        )  # fmt: skip

    def refused(self, call: Any, *args: Any, **kw: Any) -> ApiError:
        with pytest.raises(ApiError) as error:
            call(*args, **kw)
        return error.value


@pytest.fixture
def world(db: None) -> World:
    return World()
