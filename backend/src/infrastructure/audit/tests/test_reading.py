"""The admin list, a task's activity, and the CSV export."""

import csv
import io
from datetime import timedelta
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone

from infrastructure.audit import recorder, services
from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.projects import services as project_services
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.workspaces import access, invitations
from infrastructure.workspaces import services as workspace_services


@pytest.fixture
def w(db: None) -> Any:
    users = get_user_model().objects
    owner = users.create_user("owner", "o@x.test", "pw-123456-x")
    member = users.create_user("member", "m@x.test", "pw-123456-x")
    ws = workspace_services.create(owner, "Acme", "acme")
    invitations.accept(invitations.create_link(ws, owner).token, member)
    project = project_services.create(owner, ws, "Web", "WEB").project
    set_actor(owner)
    return type("W", (), {"owner": owner, "member": member, "ws": ws, "project": project})


def _noise(w: Any, n: int, action: str = "x.y") -> None:
    for i in range(n):
        recorder.record(workspace_id=w.ws.pk, action=action, target_type="x", target_id=str(i))


def test_only_those_with_audit_view_may_read(w: Any) -> None:
    services.list_entries(w.owner, w.ws, services.Filters())
    with pytest.raises(ApiError):
        services.list_entries(w.member, w.ws, services.Filters())
    with pytest.raises(ApiError):
        services.export_csv(w.member, w.ws, services.Filters())


def test_a_page_is_stable_while_new_entries_arrive(w: Any) -> None:
    _noise(w, 7, "page.test")
    f = services.Filters(action="page.test")
    first = services.list_entries(w.owner, w.ws, f, limit=3)
    _noise(w, 5, "page.test")  # arrive between two page reads
    second = services.list_entries(w.owner, w.ws, f, before=first.next_before, limit=3)
    third = services.list_entries(w.owner, w.ws, f, before=second.next_before, limit=3)
    seen = [e.target_id for p in (first, second) for e in p.entries]
    assert len(seen) == len(set(seen)) == 6
    assert first.entries[0].pk > first.entries[-1].pk > second.entries[0].pk
    assert len(third.entries) == 1 and third.next_before == 0


def test_filters_narrow_by_actor_action_prefix_and_time(w: Any) -> None:
    t = task_services.create(w.owner, w.ws, str(w.project.pk), "A")
    task_services.update(w.owner, w.ws, str(w.project.pk), str(t.pk), t.version, {"title": "B"})
    everything = services.list_entries(w.owner, w.ws, services.Filters(), limit=200).entries
    assert {e.action for e in everything} >= {"task.created", "task.updated", "project.created"}
    only_task = services.list_entries(w.owner, w.ws, services.Filters(action="task."), limit=200)
    assert {e.action for e in only_task.entries} == {"task.created", "task.updated"}
    mine = services.list_entries(w.owner, w.ws, services.Filters(actor=str(w.member.pk)))
    assert mine.entries == []
    future = (timezone.now() + timedelta(days=1)).isoformat()
    assert services.list_entries(w.owner, w.ws, services.Filters(since=future)).entries == []
    with pytest.raises(ApiError):
        services.list_entries(w.owner, w.ws, services.Filters(since="yesterday-ish"))


def test_one_workspace_never_reads_anothers_log(w: Any) -> None:
    other = workspace_services.create(w.member, "Beta", "beta")
    _noise(w, 1, "mine.only")
    rows = services.list_entries(w.member, other, services.Filters(action="mine.only"))
    assert rows.entries == []
    with pytest.raises(ApiError):
        services.list_entries(w.member, w.ws, services.Filters())


def test_a_tasks_activity_is_for_anyone_who_can_open_it(w: Any) -> None:
    pid = str(w.project.pk)
    t = task_services.create(w.owner, w.ws, pid, "A")
    task_services.update(w.owner, w.ws, pid, str(t.pk), t.version, {"priority": "high"})
    page = services.activity_for_task(w.member, w.ws, pid, str(t.pk))
    assert [e.action for e in page.entries] == ["task.updated", "task.created"]
    assert all(e.target_id == str(t.pk) for e in page.entries)
    other = project_services.create(w.owner, w.ws, "Sec", "SEC", visibility="private").project
    secret = task_services.create(w.owner, w.ws, str(other.pk), "Hidden")
    with pytest.raises(ApiError):
        services.activity_for_task(w.member, w.ws, str(other.pk), str(secret.pk))


def test_export_streams_csv_in_chunks_and_records_itself(w: Any, monkeypatch: Any) -> None:
    monkeypatch.setattr(services, "EXPORT_CHUNK", 5)
    recorder.record(
        workspace_id=w.ws.pk, action="evil.cell", target_type="x", target_id="=HYPERLINK(1)"
    )
    stream = services.export_csv(w.owner, w.ws, services.Filters())
    assert iter(stream) is stream  # a generator, not a list
    text = "".join(stream)
    rows = list(csv.reader(io.StringIO(text)))
    assert rows[0][:5] == ["id", "at", "actor", "actor_type", "action"]
    assert any(r[4] == "evil.cell" and r[6] == "'=HYPERLINK(1)" for r in rows)
    assert AuditEntry.objects.filter(workspace=w.ws.pk, action="audit.exported").count() == 1
    assert access.can(w.member, "audit.view", w.ws).allowed is False


@pytest.mark.parametrize("lead", ["=", "+", "-", "@", "\t", "\r"])
def test_every_formula_prefix_is_quoted(lead: str) -> None:
    assert services._safe(f"{lead}cmd").startswith("'")
    assert services._safe("plain") == "plain"
