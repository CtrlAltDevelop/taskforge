"""The audit RPCs end to end: names in the reply, paging, filters, and what an outsider sees."""

import csv
import io
import json
from typing import Any

import grpc
import pytest

from infrastructure.audit import services
from infrastructure.audit.grpc import audit_pb2 as pb
from infrastructure.audit.grpc import audit_pb2_grpc as stubs
from infrastructure.audit.models import AuditEntry
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

AUDIT = stubs.AuditControllerStub
ACTIVITY = stubs.ActivityControllerStub


def _task(world: Any, title: str = "Alpha") -> Any:
    owner = world.workspace.created_by
    set_actor(owner)  # what the gRPC adapter does for an authenticated call
    return task_services.create(owner, world.workspace, world.project_id, title)


def test_the_list_names_people_statuses_and_pages_by_id(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    t = _task(world)
    for n in range(4):
        task_services.update(
            world.workspace.created_by,
            world.workspace,
            world.project_id,
            str(t.pk),
            t.version + n,
            {"title": f"T{n}"},
        )
    token = world.tokens["Owner"]
    first = grpc_call(
        AUDIT,
        "List",
        pb.AuditListRequest(workspace_id=world.ws, action="task.", limit=2),
        token=token,
    )
    assert len(first.entries) == 2 and first.next_before
    assert first.entries[0].id > first.entries[1].id
    owner_id = str(world.workspace.created_by.pk)
    assert {label.id for label in first.labels} >= {owner_id}
    assert first.entries[0].actor_name
    nxt = grpc_call(
        AUDIT,
        "List",
        pb.AuditListRequest(
            workspace_id=world.ws, action="task.", limit=50, before=first.next_before
        ),
        token=token,
    )
    seen = {e.id for e in first.entries} | {e.id for e in nxt.entries}
    assert len(seen) == len(first.entries) + len(nxt.entries) and nxt.next_before == 0
    changed = next(e for e in [*nxt.entries, *first.entries] if e.action == "task.updated")
    assert json.loads(changed.changes_json)["title"][0].startswith(("Alpha", "T"))


def test_filters_by_target_type_target_id_and_until(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    t = _task(world)
    token = world.tokens["Owner"]

    def ask(**kw: Any) -> Any:
        return grpc_call(
            AUDIT, "List", pb.AuditListRequest(workspace_id=world.ws, **kw), token=token
        )

    assert {e.target_id for e in ask(target_type="task", target_id=str(t.pk)).entries} == {
        str(t.pk)
    }
    assert ask(until="2000-01-01T00:00:00+00:00").entries == []
    with pytest.raises(grpc.aio.AioRpcError) as bad:
        ask(project_id="not-an-id")
    assert bad.value.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_export_streams_csv_text_and_records_who_exported(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    _task(world)
    chunks = grpc_call(
        AUDIT, "Export", pb.AuditExportRequest(workspace_id=world.ws), token=world.tokens["Owner"]
    )
    rows = list(csv.reader(io.StringIO("".join(c.csv for c in chunks))))
    assert rows[0][4] == "action" and any(r[4] == "task.created" for r in rows)
    exported = AuditEntry.objects.get(workspace=world.ws, action="audit.exported")
    assert exported.actor == str(world.workspace.created_by.pk)


def test_activity_for_a_task_names_the_statuses(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    from infrastructure.workflows.models import Status

    world = _world(people, 0)
    t = _task(world)
    target = Status.objects.filter(project_id=world.project_id).exclude(pk=t.status_id).first()
    task_services.move(
        world.workspace.created_by,
        world.workspace,
        world.project_id,
        str(t.pk),
        t.version,
        str(target.pk),
    )
    page = grpc_call(
        ACTIVITY,
        "ForTask",
        pb.ActivityForTaskRequest(
            workspace_id=world.ws, project_id=world.project_id, task_id=str(t.pk)
        ),
        token=world.tokens["Viewer"],
    )
    assert [e.action for e in page.entries][:2] == ["task.status_changed", "task.created"]
    names = {label.id: label.name for label in page.labels}
    assert names[str(target.pk)] == target.name
    assert names[str(t.status_id)] == t.status.name


def test_another_workspaces_task_is_not_found_and_its_entries_stay_private(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    a = _world(people, 0)
    b = _world(people, 1)
    secret = _task(b, "Secret")
    with pytest.raises(grpc.aio.AioRpcError) as refused:
        grpc_call(
            ACTIVITY,
            "ForTask",
            pb.ActivityForTaskRequest(
                workspace_id=a.ws, project_id=a.project_id, task_id=str(secret.pk)
            ),
            token=a.tokens["Owner"],
        )
    assert refused.value.code() in (grpc.StatusCode.NOT_FOUND, grpc.StatusCode.PERMISSION_DENIED)
    # An Owner of A filtering for B's task id reads A's log only: nothing of B's.
    mine = grpc_call(
        AUDIT,
        "List",
        pb.AuditListRequest(workspace_id=a.ws, target_id=str(secret.pk)),
        token=a.tokens["Owner"],
    )
    assert mine.entries == []
    assert not [
        e
        for e in services.list_entries(
            a.workspace.created_by, a.workspace, services.Filters(), limit=200
        ).entries
        if e.workspace != a.workspace.pk
    ]


def test_configured_redact_keys_are_blanked(settings: Any, db: None) -> None:
    import uuid

    from infrastructure.audit import recorder

    settings.AUDIT_REDACT_KEYS = ("internal_note",)
    entry = recorder.record(
        workspace_id=uuid.uuid4(),
        action="x.y",
        target_type="x",
        target_id="1",
        changes={"internal_note": ["a", "b"], "config": [{"internal_note": "hush"}, {}]},
    )
    assert entry.changes["internal_note"] == "[redacted]"
    assert "hush" not in str(entry.changes)


def test_a_tasks_history_hides_addresses_and_unreachable_task_names(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    from infrastructure.audit import context
    from infrastructure.projects import services as project_services
    from infrastructure.tasks import links

    world = _world(people, 0)
    owner = world.workspace.created_by
    context.set_client({"REMOTE_ADDR": "203.0.113.5", "user-agent": "secret-agent"})
    public = _task(world, "Public")
    private_project = project_services.create(
        owner, world.workspace, "Sec", "SECX", visibility="private"
    ).project
    hidden = task_services.create(owner, world.workspace, str(private_project.pk), "Acquire Acme")
    links.add(
        owner,
        world.workspace,
        str(public.pk),
        str(hidden.pk),
        "blocks",
    )

    def history(role: str) -> Any:
        return grpc_call(
            ACTIVITY,
            "ForTask",
            pb.ActivityForTaskRequest(
                workspace_id=world.ws, project_id=world.project_id, task_id=str(public.pk)
            ),
            token=world.tokens[role],
        )

    for role in ("Owner", "Member"):
        page = history(role)
        assert all(e.ip == "" and e.user_agent == "" for e in page.entries)
    member_names = {label.name for label in history("Member").labels}
    assert "Acquire Acme" not in member_names
    admin_log = grpc_call(
        AUDIT,
        "List",
        pb.AuditListRequest(workspace_id=world.ws, target_id=str(public.pk)),
        token=world.tokens["Owner"],
    )
    assert any(e.ip == "203.0.113.5" for e in admin_log.entries)


def test_purging_a_workspace_is_one_entry_not_one_per_row(
    people: dict[str, Any],  # noqa: F811
) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.workspaces import services as workspace_services
    from infrastructure.workspaces.models import Workspace

    world = _world(people, 0)  # members, roles, two projects with their statuses cascade away
    Workspace.objects.filter(pk=world.workspace.pk).update(
        deleted_at=timezone.now() - timedelta(days=30)
    )
    before = AuditEntry.objects.filter(workspace=world.workspace.pk).count()
    assert workspace_services.purge_expired() == 1
    rows = AuditEntry.objects.filter(workspace=world.workspace.pk).order_by("pk")
    assert rows.count() == before + 1
    assert rows.last().action == "workspace.purged"
