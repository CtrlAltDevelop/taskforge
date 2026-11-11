"""Nothing is recorded or sent for a change that rolled back; both happen once it commits."""

from typing import Any

import pytest
from django.db import transaction

from infrastructure.sync.models import ChangeLog
from infrastructure.tasks import services as tasks

pytestmark = pytest.mark.django_db


@pytest.fixture(autouse=True)
def _commit_hooks_run_now() -> None:
    """Keep Django's real on_commit behaviour (the shared fixture would run hooks at once)."""


def test_a_rollback_records_and_sends_nothing(
    team: Any, project: Any, broker: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with (
        django_capture_on_commit_callbacks(execute=True),
        pytest.raises(RuntimeError),
        transaction.atomic(),
    ):
        tasks.create(team.owner, team.ws, str(project.pk), "gone")
        raise RuntimeError("roll back")

    assert ChangeLog.objects.filter(entity_type="task").count() == 0
    assert broker.sent == []


def test_a_commit_records_and_sends_once(
    team: Any, project: Any, broker: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with django_capture_on_commit_callbacks(execute=True):
        tasks.create(team.owner, team.ws, str(project.pk), "kept")

    assert ChangeLog.objects.filter(entity_type="task").count() == 1
    assert sorted({e["cursor"]: e["type"] for e in broker.events()}.values()) == ["task.created"]
