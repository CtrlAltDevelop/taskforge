from typing import Any

import pytest

from infrastructure.projects import services as projects
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as tasks

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


def with_time(team: Any, project: Any) -> Any:
    """The project with *Time tracking* switched on."""
    current = projects.get(team.owner, team.ws, str(project.pk)).project
    projects.set_features(team.owner, team.ws, str(project.pk), {"time_tracking"}, current.version)
    return projects.get(team.owner, team.ws, str(project.pk)).project


@pytest.fixture
def web(team: Any) -> Any:
    return with_time(team, team.create(team.owner, "WEB"))


@pytest.fixture
def task(team: Any, web: Any) -> Any:
    return tasks.create(team.owner, team.ws, str(web.pk), "Fix login")
