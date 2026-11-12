import io
from collections.abc import Iterator
from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.imports import services
from infrastructure.imports.models import ImportJob
from infrastructure.projects import services as project_services
from infrastructure.projects.models import ProjectMember
from infrastructure.sync.actor import set_actor
from infrastructure.workspaces import access, invitations
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.models import WorkspaceMember


class World:
    """An Owner (admin rights), a Member and a Viewer in one workspace, and an open project Web."""

    def __init__(self) -> None:
        users = get_user_model().objects
        self.owner = users.create_user("owner", "owner@x.test", "pw-123456-x")
        self.alice = users.create_user("alice", "alice@acme.test", "pw-123456-x")
        self.viewer = users.create_user("viewer", "v@x.test", "pw-123456-x")
        self.ws = workspace_services.create(self.owner, "Acme", "acme")
        invitations.accept(invitations.create_link(self.ws, self.owner).token, self.alice)
        WorkspaceMember.objects.create(
            workspace=self.ws, user=self.viewer, role=access.builtin_role("Viewer")
        )
        set_actor(self.owner)
        self.web = project_services.create(self.owner, self.ws, "Web", "WEB").project
        self.sec = project_services.create(
            self.owner, self.ws, "Sec", "SEC", visibility="private"
        ).project
        ProjectMember.objects.get_or_create(project=self.sec, user=self.owner)

    def upload(self, text: str | bytes, name: str = "issues.csv", **kw: Any) -> ImportJob:
        raw = text.encode() if isinstance(text, str) else text
        return services.upload(self.owner, self.ws, io.BytesIO(raw), name, **kw)

    def analyzed(self, text: str | bytes, name: str = "issues.csv", **kw: Any) -> ImportJob:
        job = self.upload(text, name, **kw)
        return services.analyze(self.owner, self.ws, str(job.pk)).job

    def run(self, text: str | bytes, name: str = "issues.csv", **changes: Any) -> ImportJob:
        """Upload, analyze, apply ``changes`` to the proposed mapping, start (runs on the spot)."""
        job = self.analyzed(text, name)
        mapping = {**job.mapping, **changes}
        return services.start(self.owner, self.ws, str(job.pk), mapping)

    def into_web(self, **changes: Any) -> dict[str, Any]:
        return {"target": {"project_id": str(self.web.pk)}, **changes}


@pytest.fixture
def world(db: None, settings: Any, tmp_path: Any) -> Iterator[World]:
    settings.MEDIA_ROOT = str(tmp_path)
    yield World()
