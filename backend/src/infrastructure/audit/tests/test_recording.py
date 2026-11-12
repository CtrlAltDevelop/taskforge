"""Recording: same transaction, diffs, redaction, immutability, batches."""

from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.db import transaction

from infrastructure.audit import context, recorder
from infrastructure.audit.models import AuditEntry, ImmutableError
from infrastructure.projects import services as project_services
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workspaces import services as workspace_services


@pytest.fixture
def world(db: None) -> dict[str, Any]:
    owner = get_user_model().objects.create_user("owner", "o@x.test", "pw-123456-x")
    ws = workspace_services.create(owner, "Acme", "acme")
    project = project_services.create(owner, ws, "Web", "WEB").project
    set_actor(owner)  # what the gRPC adapter does for every authenticated call
    return {"owner": owner, "ws": ws, "project": project}


def _actions(ws: Any) -> list[str]:
    return list(
        AuditEntry.objects.filter(workspace=ws.pk).order_by("id").values_list("action", flat=True)
    )


def test_creating_and_renaming_a_task_leaves_entries_with_before_and_after(world: Any) -> None:
    w = world
    made = task_services.create(w["owner"], w["ws"], str(w["project"].pk), "Alpha")
    task_services.update(
        w["owner"], w["ws"], str(w["project"].pk), str(made.pk), made.version, {"title": "Beta"}
    )
    entry = AuditEntry.objects.filter(action="task.updated", target_id=str(made.pk)).get()
    assert entry.changes["title"] == ["Alpha", "Beta"]
    assert entry.actor == str(w["owner"].pk)
    assert entry.actor_type == "user"
    assert entry.project == w["project"].pk
    assert "task.created" in _actions(w["ws"])


def test_a_rolled_back_change_leaves_no_entry(world: Any) -> None:
    w = world
    before = AuditEntry.objects.count()
    with pytest.raises(RuntimeError), transaction.atomic():
        task_services.create(w["owner"], w["ws"], str(w["project"].pk), "Doomed")
        raise RuntimeError("boom")
    assert AuditEntry.objects.count() == before


def test_entries_cannot_be_changed_or_deleted(world: Any) -> None:
    entry = recorder.record(
        workspace_id=world["ws"].pk, action="x.y", target_type="x", target_id="1"
    )
    entry.action = "other"
    with pytest.raises(ImmutableError):
        entry.save()
    with pytest.raises(ImmutableError):
        entry.delete()
    with pytest.raises(ImmutableError):
        AuditEntry.objects.all().update(action="z")
    with pytest.raises(ImmutableError):
        AuditEntry.objects.all().delete()


def test_secrets_and_bodies_are_not_stored(world: Any) -> None:
    entry = recorder.record(
        workspace_id=world["ws"].pk,
        action="automation.updated",
        target_type="automation",
        target_id="1",
        changes={
            "password": ["old", "new"],
            "actions": [[{"type": "webhook", "headers": {"Authorization": "Bearer abc"}}], []],
            "body": ["x" * 5000, "short"],
        },
    )
    assert entry.changes["password"] == "[redacted]"
    assert "Bearer abc" not in str(entry.changes)
    assert entry.changes["body"][0] == {"size": 5000, "start": "x" * 80}


def test_a_batch_shares_one_id_and_gets_one_entry_per_row(world: Any) -> None:
    with context.batch() as batch_id:
        for name in ("a", "b"):
            recorder.record(
                workspace_id=world["ws"].pk,
                action="task.updated",
                target_type="task",
                target_id=name,
            )
    assert set(
        AuditEntry.objects.filter(target_id__in=["a", "b"]).values_list("batch_id", flat=True)
    ) == {batch_id}


def test_automation_changes_say_so(world: Any) -> None:
    with context.as_automation():
        entry = recorder.record(
            workspace_id=world["ws"].pk, action="task.updated", target_type="task", target_id="1"
        )
    assert entry.actor_type == "automation"
