"""``project_changed`` fires after commit only, once per mutation."""

from typing import Any

import pytest
from django.db import transaction

from infrastructure.projects import members, services
from infrastructure.projects.signals import project_changed

from .conftest import Team


@pytest.fixture(autouse=True)
def _commit_hooks_run_now() -> None:
    """Override the conftest shim: these tests need real on_commit semantics."""


@pytest.fixture
def received() -> Any:
    events: list[dict[str, Any]] = []

    def receiver(sender: Any, **kwargs: Any) -> None:
        events.append({k: v for k, v in kwargs.items() if k != "signal"})

    project_changed.connect(receiver)
    yield events
    project_changed.disconnect(receiver)


def test_nothing_is_sent_until_commit_then_one_event(
    team: Team, received: Any, django_capture_on_commit_callbacks: Any
) -> None:
    with django_capture_on_commit_callbacks(execute=False) as callbacks:
        view = services.create(team.owner, team.ws, "Web", "WEB")
    assert received == [] and len(callbacks) == 1

    for callback in callbacks:
        callback()

    assert received == [
        {
            "project_id": str(view.project.pk),
            "workspace_id": str(team.ws.pk),
            "version": 1,
            "action": "created",
        }
    ]


def test_a_rolled_back_mutation_sends_nothing(
    team: Team, received: Any, django_capture_on_commit_callbacks: Any
) -> None:
    p = team.create(team.owner, "WEB")
    received.clear()

    with (
        django_capture_on_commit_callbacks(execute=True),
        pytest.raises(RuntimeError, match="boom"),
        transaction.atomic(),
    ):
        services.update(team.owner, team.ws, str(p.pk), 1, name="New")
        raise RuntimeError("boom")

    assert received == []


def test_every_mutation_names_its_action(
    team: Team, received: Any, django_capture_on_commit_callbacks: Any
) -> None:
    pid = str(team.create(team.owner, "WEB", "private").pk)
    received.clear()

    with django_capture_on_commit_callbacks(execute=True):
        services.update(team.owner, team.ws, pid, 1, name="N")
        services.set_features(team.owner, team.ws, pid, ["sprints"], 2)
        members.add_member(team.owner, team.ws, pid, str(team.viewer.pk))
        members.remove_member(team.owner, team.ws, pid, str(team.viewer.pk))
        services.archive(team.owner, team.ws, pid, 3)
        services.restore(team.owner, team.ws, pid, 4)
        services.favorite(team.owner, team.ws, pid, True)  # per-user: silent

    assert [(e["action"], e["version"]) for e in received] == [
        ("updated", 2),
        ("features", 3),
        ("member_added", 3),
        ("member_removed", 3),
        ("archived", 4),
        ("restored", 5),
    ]
