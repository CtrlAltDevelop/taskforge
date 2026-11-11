from datetime import UTC, datetime
from typing import Any

import pytest

from infrastructure.accounts.models import Profile
from infrastructure.projects import services as projects
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.sprints import services
from infrastructure.tasks import services as tasks
from infrastructure.workflows.models import Status

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
base_team = project_fixtures.team


@pytest.fixture
def team(base_team: Any) -> Any:
    Profile.objects.filter(user=base_team.owner).update(timezone="UTC")
    return base_team


def at(day: int, hour: int = 12, minute: int = 0, month: int = 11) -> datetime:
    return datetime(2026, month, day, hour, minute, tzinfo=UTC)


def with_sprints(team: Any, project: Any) -> Any:
    current = projects.get(team.owner, team.ws, str(project.pk)).project
    projects.set_features(team.owner, team.ws, str(project.pk), {"sprints"}, current.version)
    return projects.get(team.owner, team.ws, str(project.pk)).project


@pytest.fixture
def web(team: Any) -> Any:
    return with_sprints(team, team.create(team.owner, "WEB"))


def make_task(team: Any, web: Any, title: str, points: str = "") -> Any:
    task = tasks.create(team.owner, team.ws, str(web.pk), title)
    if points:
        task = services.set_points(team.owner, team.ws, str(web.pk), str(task.pk), points)
    return task


def set_status(team: Any, web: Any, task: Any, category: str) -> Any:
    status = Status.objects.filter(project=web, category=category).first()
    if status is None:
        status = Status.objects.create(project=web, name=category, category=category, position=9)
    current = tasks.get(team.owner, team.ws, str(web.pk), str(task.pk))
    return tasks.update(
        team.owner, team.ws, str(web.pk), str(task.pk), current.version, {"status": str(status.pk)}
    )


def new_sprint(
    team: Any, web: Any, name: str = "S1", start: str = "2026-11-02", end: str = "2026-11-06"
) -> Any:
    return services.create(team.owner, team.ws, str(web.pk), name, "", start, end).sprint
