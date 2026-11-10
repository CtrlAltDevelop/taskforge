"""Parallel edits of the same field value: exactly one wins, the rest are told it changed.
Only PostgreSQL has real row locks (``make test-postgres``)."""

from concurrent.futures import ThreadPoolExecutor
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections

from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as field_services
from infrastructure.customfields.models import FieldValue
from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import services as workspace_services

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL row locks"),
    pytest.mark.django_db(transaction=True),
]

PARALLEL = 10


def _edit(args: tuple[Any, Any, str, str, str, int]) -> str:
    user, workspace, project_id, task_id, field_id, n = args
    try:
        tasks.update(user, workspace, project_id, task_id, 1, {"field_values": {field_id: f"v{n}"}})
        return "won"
    except ApiError as error:
        return str(error.title)
    finally:
        connections.close_all()


def test_parallel_edits_of_one_field_let_exactly_one_win() -> None:
    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspace_services.create(owner, "Acme", "acme")
    project = projects.create(owner, workspace, "Web", "WEB").project
    field = field_services.create(owner, workspace, str(project.pk), name="Env", type="text")
    task = tasks.create(owner, workspace, str(project.pk), "A")

    jobs = [
        (owner, workspace, str(project.pk), str(task.pk), str(field.pk), n) for n in range(PARALLEL)
    ]
    with ThreadPoolExecutor(PARALLEL) as pool:
        outcomes = list(pool.map(_edit, jobs))

    assert outcomes.count("won") == 1
    assert outcomes.count("VERSION_CONFLICT") == PARALLEL - 1
    assert FieldValue.objects.filter(task=task, field=field).count() == 1
