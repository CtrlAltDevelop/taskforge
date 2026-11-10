"""Migrations 0002-0004 turn the three fixed status words into project statuses and back.

The test makes tasks on the current schema, migrates the database *back* to 0001 (where the
status is a word again, chosen from the status category), then forward again, and checks every
task ends up on the right status of its own project.
"""

from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import connection
from django.db.migrations.executor import MigrationExecutor

from infrastructure.projects import services as projects
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status
from infrastructure.workspaces import services as workspaces

pytestmark = pytest.mark.django_db(transaction=True)

BEFORE = [("tasks", "0001_initial")]
LATEST_TASKS = [("tasks", "0006_subtasks_data")]


def _migrate(targets: list[tuple[str, str]]) -> None:
    executor = MigrationExecutor(connection)
    executor.migrate(targets)


def _words() -> dict[str, str]:
    with connection.cursor() as cursor:
        cursor.execute("SELECT title, status FROM tasks_task")
        return {title: status for title, status in cursor.fetchall()}


def test_status_words_round_trip_through_the_migration() -> None:
    owner = get_user_model().objects.create_user(
        username="zoe", email="zoe@example.com", password="x-y-z-12345"
    )
    workspace = workspaces.create(owner, "Acme", "acme")
    web = projects.create(owner, workspace, "Web", "WEB").project
    app = projects.create(owner, workspace, "App", "APP").project
    made: dict[str, Any] = {}
    for project in (web, app):
        by_name = {
            s.name: str(s.pk) for s in workflows.get(owner, workspace, str(project.pk)).statuses
        }
        for title, name in (("todo", "To do"), ("doing", "In progress"), ("done", "Done")):
            made[f"{project.key}-{title}"] = tasks.create(
                owner, workspace, str(project.pk), f"{project.key}-{title}", status=by_name[name]
            )
    # A custom "Cancelled" status has no phase-06 word: it goes back as "done".
    saved = workflows.get(owner, workspace, str(web.pk))
    cancelled = Status.objects.create(
        project=web, name="Cancelled", category="cancelled", position=9
    )
    stray = tasks.create(owner, workspace, str(web.pk), "WEB-stray", status=str(cancelled.pk))
    assert saved.workflow.version == 1 and stray.status.name == "Cancelled"

    try:
        _migrate(BEFORE)
        words = _words()
    finally:
        _migrate(LATEST_TASKS)

    assert words == {
        "WEB-todo": "todo",
        "WEB-doing": "in_progress",
        "WEB-done": "done",
        "APP-todo": "todo",
        "APP-doing": "in_progress",
        "APP-done": "done",
        "WEB-stray": "done",
    }
    # Forward again: each task is on the status of its own project that its word meant.
    for key, task in made.items():
        task.refresh_from_db()
        project_key, _, word = key.partition("-")
        expected = {"todo": "To do", "doing": "In progress", "done": "Done"}[word]
        assert task.status.name == expected and task.status.project.key == project_key
    stray_row = Task.objects.get(title="WEB-stray")
    assert stray_row.status.name == "Done" and stray_row.status.project_id == web.pk
    assert Status.objects.filter(project=app).count() == 3
