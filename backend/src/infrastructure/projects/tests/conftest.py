from dataclasses import dataclass
from typing import Any

import pytest

from infrastructure.projects import services
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests import conftest as workspace_fixtures

# The workspaces fixtures, registered here by name.
make_user = workspace_fixtures.make_user
add_member = workspace_fixtures.add_member
_commit_hooks_run_now = workspace_fixtures._commit_hooks_run_now


@dataclass
class Team:
    """One workspace with a user per built-in role, a second workspace and a stranger."""

    ws: Any
    other_ws: Any
    owner: Any
    admin: Any
    member: Any
    viewer: Any
    outsider: Any  # a member of ``other_ws`` only
    pm: Any  # a Member-role user: the creator (so member) of private projects in the matrix

    def create(self, actor: Any, key: str, visibility: str = "open", name: str = "Web") -> Any:
        return services.create(actor, self.ws, name, key, visibility=visibility).project


@pytest.fixture
def team(db: None, make_user: Any, add_member: Any) -> Team:
    users = {n: make_user(n) for n in ("owner", "admin", "member", "viewer", "outsider", "pm")}
    ws = workspace_services.create(users["owner"], "Acme", "acme")
    other_ws = workspace_services.create(users["outsider"], "Other", "other")
    for name, role in (
        ("admin", "Admin"),
        ("member", "Member"),
        ("viewer", "Viewer"),
        ("pm", "Member"),
    ):
        add_member(ws, users[name], role)
    return Team(ws, other_ws, **users)
