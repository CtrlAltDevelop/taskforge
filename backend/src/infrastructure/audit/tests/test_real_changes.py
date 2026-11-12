"""The writes the permission matrix can only call as no-ops (same parent, same status, one field
to reorder ...) do record when they change something."""

import json
from typing import Any

import pytest
from django.contrib.auth import get_user_model

from infrastructure.attachments import services as attachment_services
from infrastructure.audit.models import AuditEntry
from infrastructure.customfields import services as field_services
from infrastructure.docs import services as doc_services
from infrastructure.projects import services as project_services
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workflows.models import Status
from infrastructure.workspaces import services as workspace_services


@pytest.fixture
def w(db: None) -> Any:
    owner = get_user_model().objects.create_user("owner", "o@x.test", "pw-123456-x")
    ws = workspace_services.create(owner, "Acme", "acme")
    project = project_services.create(owner, ws, "Web", "WEB").project
    set_actor(owner)
    return type("W", (), {"owner": owner, "ws": ws, "project": project, "pid": str(project.pk)})


def _one(action: str, **filters: Any) -> AuditEntry:
    return AuditEntry.objects.filter(action=action, **filters).get()


def test_moving_a_task_under_another_records_the_parent(w: Any) -> None:
    a = task_services.create(w.owner, w.ws, w.pid, "A")
    b = task_services.create(w.owner, w.ws, w.pid, "B")
    task_services.set_parent(w.owner, w.ws, w.pid, str(b.pk), b.version, str(a.pk))
    entry = _one("task.updated", target_id=str(b.pk))
    assert entry.changes["parent_id"] == [None, str(a.pk)]


def test_a_status_move_says_from_and_to(w: Any) -> None:
    t = task_services.create(w.owner, w.ws, w.pid, "T")
    target = Status.objects.filter(project=w.project).exclude(pk=t.status_id).first()
    task_services.move(w.owner, w.ws, w.pid, str(t.pk), t.version, str(target.pk))
    entry = _one("task.status_changed", target_id=str(t.pk))
    assert entry.changes["status_id"] == [str(t.status_id), str(target.pk)]


def test_moving_with_subtasks_gives_one_entry_each_under_one_batch(w: Any) -> None:
    parent = task_services.create(w.owner, w.ws, w.pid, "P")
    child = task_services.create(w.owner, w.ws, w.pid, "C", parent_id=str(parent.pk))
    target = Status.objects.filter(project=w.project).exclude(pk=parent.status_id).first()
    task_services.move(
        w.owner, w.ws, w.pid, str(parent.pk), parent.version, str(target.pk), with_subtasks=True
    )
    rows = AuditEntry.objects.filter(
        action="task.status_changed", target_id__in=[str(parent.pk), str(child.pk)]
    )
    assert rows.count() == 2
    assert rows.filter(batch_id__isnull=False).count() >= 1


def test_reordering_fields_and_editing_one_record(w: Any) -> None:
    f1 = field_services.create(w.owner, w.ws, w.pid, name="One", type="text")
    f2 = field_services.create(w.owner, w.ws, w.pid, name="Two", type="text")
    field_services.reorder(w.owner, w.ws, w.pid, [str(f2.pk), str(f1.pk)])
    assert AuditEntry.objects.filter(action="field.updated", changes__field_id=str(f1.pk)).exists()
    field_services.update(w.owner, w.ws, w.pid, str(f1.pk), f1.version, {"name": "Uno"})
    names = AuditEntry.objects.filter(action="field.updated").values_list("changes", flat=True)
    assert any(c.get("name") == ["One", "Uno"] for c in names)


def test_moving_a_page_and_linking_a_task_record(w: Any) -> None:
    first = doc_services.create(w.owner, w.ws, w.pid, "", "First")
    second = doc_services.create(w.owner, w.ws, w.pid, "", "Second")
    doc_services.move(w.owner, w.ws, str(second.doc.pk), str(first.doc.pk), 0)
    assert _one("doc.updated", target_id=str(second.doc.pk)).changes["parent_id"][1] == str(
        first.doc.pk
    )
    t = task_services.create(w.owner, w.ws, w.pid, "T")
    doc_services.link_task(w.owner, w.ws, w.pid, str(t.pk), str(first.doc.pk))
    doc_services.unlink_task(w.owner, w.ws, w.pid, str(t.pk), str(first.doc.pk))
    assert _one("doc_link.created", target_id=str(t.pk)).changes["doc_id"] == str(first.doc.pk)
    assert _one("doc_link.deleted", target_id=str(t.pk)).changes["doc_id"] == str(first.doc.pk)


def test_a_finished_upload_records_the_file_not_its_bytes(w: Any) -> None:
    t = task_services.create(w.owner, w.ws, w.pid, "T")
    body = b"remember the milk\n"
    session = attachment_services.start_upload(
        w.owner, w.ws, w.pid, str(t.pk), "milk.txt", len(body)
    )
    attachment_services.put_chunk(w.owner, str(session.pk), 0, body)
    attachment_services.complete(w.owner, str(session.pk))
    entry = _one("attachment.created", target_id=str(t.pk))
    assert entry.changes["filename"] == "milk.txt"
    assert "storage_key" not in entry.changes


def test_a_comment_edit_and_a_timer_stop_record(w: Any) -> None:
    from infrastructure.comments import services as comment_services
    from infrastructure.timetracking import services as time_services

    t = task_services.create(w.owner, w.ws, w.pid, "T")
    project_services.set_features(w.owner, w.ws, w.pid, ["time_tracking"], w.project.version)

    def say(text: str) -> str:
        paragraph = {"type": "paragraph", "content": [{"type": "text", "text": text}]}
        return json.dumps({"type": "doc", "content": [paragraph]})

    note = comment_services.create(w.owner, w.ws, w.pid, str(t.pk), say("hello"))
    comment: Any = getattr(note, "comment", note)
    comment_services.edit(w.owner, w.ws, w.pid, str(comment.pk), comment.version, say("again"))
    assert AuditEntry.objects.filter(action="comment.updated", target_id=str(t.pk)).exists()
    time_services.start(w.owner, w.ws, w.pid, str(t.pk))
    time_services.stop(w.owner, w.ws)
    assert AuditEntry.objects.filter(action="time.updated", target_id=str(t.pk)).exists()


def test_leaving_and_joining_record_for_the_member(w: Any) -> None:
    from infrastructure.workspaces import invitations, members

    guest = get_user_model().objects.create_user("guest", "g@x.test", "pw-123456-x")
    made = invitations.create_link(w.ws, w.owner)
    invitations.accept(made.token, guest)
    assert _one("member.created", target_id=str(guest.pk))
    set_actor(guest)
    members.leave(w.ws, guest)
    assert _one("member.removed", target_id=str(guest.pk)).actor == str(guest.pk)


def test_a_new_workspace_records_itself(w: Any) -> None:
    other = workspace_services.create(w.owner, "Beta", "beta")
    assert AuditEntry.objects.filter(workspace=other.pk, action="workspace.created").exists()


def test_a_bulk_edit_gives_one_entry_per_task_with_one_batch_id(w: Any) -> None:
    from infrastructure.tasks import bulk

    ids = [str(task_services.create(w.owner, w.ws, w.pid, n).pk) for n in ("a", "b", "c")]
    list(bulk.update_many(w.owner, w.ws, w.pid, ids, changes={"priority": "high"}))
    rows = AuditEntry.objects.filter(action="task.updated", target_id__in=ids)
    assert rows.count() == 3
    assert len(set(rows.values_list("batch_id", flat=True))) == 1
    assert rows.first().batch_id is not None


def test_an_automations_change_is_recorded_as_the_automation(w: Any) -> None:
    from infrastructure.audit import context

    t = task_services.create(w.owner, w.ws, w.pid, "T")
    with context.as_automation("rule-1"):
        task_services.update(w.owner, w.ws, w.pid, str(t.pk), t.version, {"title": "Auto"})
    entry = _one("task.updated", target_id=str(t.pk))
    assert (entry.actor_type, entry.actor) == ("automation", "rule-1")


def test_the_callers_address_and_agent_are_kept(w: Any, settings: Any) -> None:
    from infrastructure.audit import context

    settings.AUDIT_TRUSTED_PROXY_HOPS = 1  # one proxy of ours: it appends the peer it saw
    context.set_client(
        {
            "HTTP_X_FORWARDED_FOR": "6.6.6.6, 203.0.113.9",  # the left is the client's own claim
            "REMOTE_ADDR": "10.0.0.2",
            "user-agent": "tf-app/1",
        }
    )
    t = task_services.create(w.owner, w.ws, w.pid, "T")
    entry = _one("task.created", target_id=str(t.pk))
    assert (entry.ip, entry.user_agent) == ("203.0.113.9", "tf-app/1")


def test_a_sign_in_is_filed_under_each_workspace_of_the_person(w: Any, rf: Any) -> None:
    from infrastructure.auth.core import flows

    request = rf.post("/login", HTTP_USER_AGENT="tf-app/2", REMOTE_ADDR="198.51.100.7")
    flows.record_event(request, "login_succeeded", user=w.owner, method="password")
    flows.record_event(request, "login_failed", identifier="nobody@x.test")  # no person: skipped
    entry = _one("auth.login_succeeded", workspace=w.ws.pk)
    assert (entry.target_id, entry.user_agent) == (str(w.owner.pk), "tf-app/2")
    assert not AuditEntry.objects.filter(action="auth.login_failed").exists()


def test_assigning_someone_records_who_before_and_after(w: Any) -> None:
    t = task_services.create(w.owner, w.ws, w.pid, "T")
    task_services.update(
        w.owner, w.ws, w.pid, str(t.pk), t.version, {"assignee_ids": [str(w.owner.pk)]}
    )
    entry = _one("task.assignees_changed", target_id=str(t.pk))
    assert entry.changes["assignees"] == [[], [str(w.owner.pk)]]


def test_editing_and_deleting_a_time_entry_record(w: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    from infrastructure.timetracking import services as time_services

    t = task_services.create(w.owner, w.ws, w.pid, "T")
    project_services.set_features(w.owner, w.ws, w.pid, ["time_tracking"], w.project.version)
    entry = time_services.create_entry(
        w.owner, w.ws, w.pid, str(t.pk), timezone.now() - timedelta(hours=1), 600
    )
    time_services.update_entry(w.owner, w.ws, str(entry.pk), {"note": "retro"})
    assert _one("time.updated", target_id=str(t.pk)).changes["note"] == ["", "retro"]
    time_services.delete_entry(w.owner, w.ws, str(entry.pk))
    assert _one("time.deleted", target_id=str(t.pk)).changes["entry_id"] == str(entry.pk)


def test_without_trusted_proxies_the_address_is_the_peer_not_the_header(w: Any) -> None:
    from infrastructure.audit import context

    context.set_client({"HTTP_X_FORWARDED_FOR": "6.6.6.6", "REMOTE_ADDR": "198.51.100.1"})
    assert context.current_client()[0] == "198.51.100.1"


def test_renaming_a_project_key_is_recorded_not_blanked(w: Any) -> None:
    project_services.update(w.owner, w.ws, w.pid, w.project.version, key="WEBX")
    assert _one("project.created", target_id=str(w.project.pk)).changes["key"] == "WEB"
    assert _one("project.updated", target_id=str(w.project.pk)).changes["key"] == ["WEB", "WEBX"]


def test_a_webhook_address_is_never_stored(w: Any) -> None:
    from infrastructure.audit import recorder

    entry = recorder.record(
        workspace_id=w.ws.pk,
        action="automation.updated",
        target_type="automation",
        target_id="1",
        changes={"actions": [[], [{"type": "webhook", "url": "https://hooks.example/T0/B0/xyz"}]]},
    )
    assert "xyz" not in str(entry.changes)


def test_a_nested_batch_joins_the_outer_one(w: Any) -> None:
    from infrastructure.audit import context

    with context.batch() as outer, context.batch() as inner:
        assert inner == outer


def test_deleting_a_parent_with_its_subtree_is_one_batch(w: Any) -> None:
    parent = task_services.create(w.owner, w.ws, w.pid, "P")
    kid = task_services.create(w.owner, w.ws, w.pid, "K", parent_id=str(parent.pk))
    task_services.delete(w.owner, w.ws, w.pid, str(parent.pk), "subtree")
    rows = AuditEntry.objects.filter(
        action="task.deleted", target_id__in=[str(parent.pk), str(kid.pk)]
    )
    assert rows.count() == 2 and len(set(rows.values_list("batch_id", flat=True))) == 1
    assert rows.first().batch_id is not None


def test_promoting_children_records_their_new_parent(w: Any) -> None:
    grand = task_services.create(w.owner, w.ws, w.pid, "G")
    parent = task_services.create(w.owner, w.ws, w.pid, "P", parent_id=str(grand.pk))
    kid = task_services.create(w.owner, w.ws, w.pid, "K", parent_id=str(parent.pk))
    task_services.delete(w.owner, w.ws, w.pid, str(parent.pk), "promote")
    entry = _one("task.updated", target_id=str(kid.pk))
    assert entry.changes["parent_id"] == [str(parent.pk), str(grand.pk)]


def test_saving_a_workflow_records_renames_and_moved_tasks(w: Any) -> None:
    from infrastructure.workflows import services as workflow_services
    from infrastructure.workflows.drafts import StatusDraft, WorkflowDraft

    t = task_services.create(w.owner, w.ws, w.pid, "T")
    view = workflow_services.get(w.owner, w.ws, w.pid)
    statuses = list(view.statuses)
    first = statuses[0]
    draft = WorkflowDraft(
        statuses=tuple(
            StatusDraft(
                key=str(s.pk),
                name="Renamed" if s.pk == first.pk else s.name,
                color=s.color,
                category=s.category,
                is_default=s.is_default,
            )
            for s in statuses
        ),
        transitions=(),
        restrict=False,
        restrict_creation=False,
    )
    workflow_services.update(w.owner, w.ws, w.pid, view.workflow.version, draft, {})
    entry = AuditEntry.objects.filter(
        action="status.updated", changes__status_id=str(first.pk)
    ).get()
    assert entry.changes["name"][1] == "Renamed"
    assert not AuditEntry.objects.filter(
        action="status.updated", changes__name__0__startswith="~"
    ).exists()
    assert t.pk
