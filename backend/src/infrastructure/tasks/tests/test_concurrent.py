"""Display ids stay unique under concurrent creates. Only PostgreSQL has real row locks:
run ``make test-postgres`` from ``backend/`` with the venv's ``bin`` on PATH.
(Sequential numbering is in test_services.py, on every database.)"""

from concurrent.futures import ThreadPoolExecutor
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections

from infrastructure.projects import services as projects
from infrastructure.tasks import services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import services as workspace_services

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL row locks"),
    pytest.mark.django_db(transaction=True),
]

PARALLEL = 50


def _create(args: tuple[Any, Any, str, int]) -> int:
    user, workspace, project_id, i = args
    try:
        return services.create(user, workspace, project_id, f"t{i}").number
    finally:
        connections.close_all()


def test_fifty_parallel_creates_never_share_a_display_id() -> None:
    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspace_services.create(owner, "Acme", "acme")
    project = projects.create(owner, workspace, "Web", "WEB").project

    jobs = [(owner, workspace, str(project.pk), i) for i in range(PARALLEL)]
    with ThreadPoolExecutor(10) as pool:
        numbers = list(pool.map(_create, jobs))

    assert sorted(numbers) == list(range(1, PARALLEL + 1))
    assert Task.objects.filter(project=project).count() == PARALLEL
    positions = list(Task.objects.filter(project=project).values_list("position", flat=True))
    assert len(set(positions)) == PARALLEL  # the rank is taken under the same lock


def _finish(args: tuple[Any, Any, str, str, str]) -> None:
    user, workspace, project_id, task_id, status_id = args
    try:
        task = Task.objects.get(pk=task_id)
        services.move(user, workspace, project_id, task_id, task.version, status_id)
    finally:
        connections.close_all()


def test_progress_stays_exact_while_many_children_finish_at_once() -> None:
    from infrastructure.workflows.models import Status

    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspace_services.create(owner, "Acme", "acme")
    project = projects.create(owner, workspace, "Web", "WEB").project
    pid = str(project.pk)
    parent = services.create(owner, workspace, pid, "P")
    kids = [
        services.create(owner, workspace, pid, f"k{i}", parent_id=str(parent.pk))
        for i in range(PARALLEL)
    ]
    done = str(Status.objects.get(project=project, name="Done").pk)

    with ThreadPoolExecutor(10) as pool:
        list(pool.map(_finish, [(owner, workspace, pid, str(k.pk), done) for k in kids]))

    parent.refresh_from_db()
    assert (parent.progress_done, parent.progress_total) == (PARALLEL, PARALLEL)
