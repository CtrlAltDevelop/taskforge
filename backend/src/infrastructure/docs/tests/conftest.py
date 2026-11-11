import json
from typing import Any

import pytest

from infrastructure.docs import services
from infrastructure.projects import members as project_members
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as tasks

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


def para(text: str) -> dict[str, Any]:
    return {"type": "paragraph", "content": [{"type": "text", "text": text}]}


def body(*blocks: dict[str, Any]) -> str:
    return json.dumps(list(blocks))


def card(task: Any) -> dict[str, Any]:
    return {"type": "task_card", "attrs": {"task_id": str(task.pk)}}


def mention(doc_id: Any, label: str = "Page") -> dict[str, Any]:
    return {
        "type": "paragraph",
        "content": [{"type": "mention", "attrs": {"doc_id": str(doc_id), "label": label}}],
    }


def page(
    team: Any,
    title: str = "Page",
    parent: Any = None,
    project: Any = None,
    actor: Any = None,
    blocks: str = "",
) -> Any:
    """A page made by the owner (or ``actor``); returns the ``Doc``."""
    view = services.create(
        actor or team.owner,
        team.ws,
        str(project.pk) if project else "",
        str(parent.pk) if parent else "",
        title,
        "",
        blocks,
    )
    return view.doc


@pytest.fixture
def web(team: Any) -> Any:
    return team.create(team.owner, "WEB")


@pytest.fixture
def secret(team: Any) -> Any:
    """A private project only ``pm`` (its creator) and the owner are in."""
    project = team.create(team.pm, "SEC", visibility="private")
    project_members.add_member(team.owner, team.ws, str(project.pk), str(team.owner.pk))
    return project


def make_task(team: Any, project: Any, title: str = "Task") -> Any:
    return tasks.create(team.owner, team.ws, str(project.pk), title)
