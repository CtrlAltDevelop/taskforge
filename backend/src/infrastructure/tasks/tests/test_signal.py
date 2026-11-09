from typing import Any

import pytest

from infrastructure.tasks import services
from infrastructure.tasks.signals import task_changed

pytestmark = pytest.mark.django_db


def test_each_mutation_announces_once_after_commit(team: Any, project: Any) -> None:
    seen: list[dict[str, Any]] = []

    def listen(sender: Any, **payload: Any) -> None:
        seen.append(payload)

    task_changed.connect(listen)
    try:
        pid = str(project.pk)
        task = services.create(team.member, team.ws, pid, "T")
        services.update(team.member, team.ws, pid, str(task.pk), 1, {"title": "U"})
        services.delete(team.member, team.ws, pid, str(task.pk))
        services.restore(team.member, team.ws, pid, str(task.pk))
    finally:
        task_changed.disconnect(listen)

    assert [p["action"] for p in seen] == ["created", "updated", "deleted", "restored"]
    assert seen[1]["version"] == 2 and seen[0]["task_id"] == str(task.pk)
    assert seen[0]["workspace_id"] == str(team.ws.pk) and seen[0]["project_id"] == pid
