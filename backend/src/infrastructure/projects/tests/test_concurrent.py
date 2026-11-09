"""Task numbers stay unique under concurrent writers. Only PostgreSQL has real row locks:
run ``make test-postgres`` from ``backend/`` with the venv's ``bin`` on PATH.
(Sequential correctness is in test_services.py, on every database.)"""

from concurrent.futures import ThreadPoolExecutor
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection, connections

from infrastructure.projects import services
from infrastructure.workspaces import services as workspace_services

pytestmark = [
    pytest.mark.skipif(connection.vendor != "postgresql", reason="needs PostgreSQL row locks"),
    pytest.mark.django_db(transaction=True),
]

WORKERS = 8
PER_WORKER = 10


def _take(project: Any) -> list[int]:
    try:
        return [services.next_task_number(project) for _ in range(PER_WORKER)]
    finally:
        connections.close_all()


def test_concurrent_numbering_hands_out_each_number_once() -> None:
    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspace_services.create(owner, "Acme", "acme")
    project = services.create(owner, workspace, "Web", "WEB").project

    with ThreadPoolExecutor(WORKERS) as pool:
        taken = [n for batch in pool.map(_take, [project] * WORKERS) for n in batch]

    assert sorted(taken) == list(range(1, WORKERS * PER_WORKER + 1))
    project.refresh_from_db()
    assert project.task_counter == WORKERS * PER_WORKER
