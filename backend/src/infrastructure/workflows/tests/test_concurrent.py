"""A project's default workflow is made exactly once however many callers open it first. Only
PostgreSQL has real concurrent writers: run ``make test-postgres`` from ``backend/``."""

from concurrent.futures import ThreadPoolExecutor
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections

from infrastructure.projects import services as projects
from infrastructure.workflows import services
from infrastructure.workflows.models import Status, Workflow
from infrastructure.workspaces import services as workspace_services

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL"),
    pytest.mark.django_db(transaction=True),
]

CALLERS = 12


def _open(args: tuple[Any, Any, str]) -> int:
    user, workspace, project_id = args
    try:
        return len(services.get(user, workspace, project_id).statuses)
    finally:
        connections.close_all()


def test_many_first_openers_make_one_default_workflow() -> None:
    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspace_services.create(owner, "Acme", "acme")
    project = projects.create(owner, workspace, "Web", "WEB").project

    with ThreadPoolExecutor(CALLERS) as pool:
        counts = list(pool.map(_open, [(owner, workspace, str(project.pk))] * CALLERS))

    assert counts == [3] * CALLERS
    assert Workflow.objects.filter(project=project).count() == 1
    assert Status.objects.filter(project=project).count() == 3
    assert Status.objects.filter(project=project, is_default=True).count() == 1
