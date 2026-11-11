import json
from typing import Any

import pytest

from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture
def project(team: Any) -> Any:
    return team.create(team.owner, "WEB")


@pytest.fixture
def task(team: Any, project: Any) -> Any:
    from infrastructure.tasks import services as tasks

    return tasks.create(team.owner, team.ws, str(project.pk), "Fix login")


def say(*parts: Any) -> str:
    """A body: a paragraph of text and mention nodes."""
    nodes = [{"type": "text", "text": p} if isinstance(p, str) else p for p in parts]
    return json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": nodes}]})


def ping(user: Any, label: str = "x") -> dict[str, Any]:
    return {"type": "mention", "attrs": {"id": str(user.pk), "label": label}}
