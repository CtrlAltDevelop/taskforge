"""Re-running, undoing, resuming, cancelling, dry-running, and who may do any of it."""

from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.utils import timezone

from infrastructure.comments.models import Comment
from infrastructure.common.errors import ApiError
from infrastructure.imports import engine, placeholders, queue, services
from infrastructure.imports.models import (
    ImportedRef,
    ImportJob,
    PlaceholderAssignment,
    PlaceholderUser,
)
from infrastructure.imports.tests.conftest import World
from infrastructure.imports.tests.samples import GENERIC_CSV, JIRA_CSV
from infrastructure.projects import services as project_services
from infrastructure.projects.models import ProjectMember
from infrastructure.sprints.models import Sprint
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task, TaskAssignee, TaskLink
from infrastructure.workspaces import services as workspace_services


def _start(world: World, text: str = JIRA_CSV, name: str = "a.csv") -> ImportJob:
    job = world.analyzed(text, name)
    return services.start(
        world.owner,
        world.ws,
        str(job.pk),
        world.into_web(**{k: v for k, v in job.mapping.items() if k != "target"}),
    )


def _counts() -> dict[str, int]:
    from infrastructure.customfields.models import FieldDefinition
    from infrastructure.projects.models import Project
    from infrastructure.workflows.models import Status

    return {
        "tasks": Task.objects.count(),
        "comments": Comment.objects.count(),
        "links": TaskLink.objects.count(),
        "sprints": Sprint.objects.count(),
        "fields": FieldDefinition.objects.count(),
        "statuses": Status.objects.count(),
        "projects": Project.objects.count(),
        "placeholders": PlaceholderUser.objects.count(),
        "assignees": TaskAssignee.objects.count(),
    }


def test_running_the_same_import_again_makes_no_duplicates(world: World) -> None:
    first = _start(world)
    before = _counts()
    second = _start(world)
    assert (first.status, second.status) == ("done", "done")
    assert _counts() == before
    assert second.done == second.total == 4  # all four were already there
    assert second.stats.get("tasks", 0) == 0 and ImportedRef.objects.filter(job=second).count() == 0


def test_a_file_with_the_same_issue_twice_keeps_the_first(world: World) -> None:
    text = JIRA_CSV + JIRA_CSV.split("\n", 1)[1]
    job = _start(world, text)
    assert Task.objects.count() == 4
    assert any("twice" in p["message"] for p in job.error_report)


def test_undo_removes_exactly_the_imported_set(world: World) -> None:
    mine = world.owner
    own = task_services.create(mine, world.ws, str(world.web.pk), "My own task")
    before = _counts()
    job = _start(world)
    assert _counts() != before
    undone, gone = services.undo(world.owner, world.ws, str(job.pk))
    assert undone.status == "undone"
    assert _counts() == before
    assert list(Task.objects.values_list("pk", flat=True)) == [own.pk]
    assert gone["tasks"] == 4 and gone["comments"] == 2 and gone["links"] == 1
    assert ImportedRef.objects.count() == 0  # so it can be imported again
    again = _start(world)
    assert again.status == "done" and Task.objects.count() == 5


def test_undo_keeps_a_task_someone_added_a_subtask_to(world: World) -> None:
    job = _start(world)
    story = Task.objects.get(title="Card form")
    mine = task_services.create(
        world.owner, world.ws, str(world.web.pk), "Added later", parent_id=str(story.pk)
    )
    _, gone = services.undo(world.owner, world.ws, str(job.pk))
    assert gone["kept"] == 2  # the story and the epic above it
    assert set(Task.objects.values_list("title", flat=True)) == {
        "Card form", "Checkout epic", "Added later",
    }  # fmt: skip
    assert Task.objects.get(pk=mine.pk).parent_id == story.pk


def test_undo_of_a_new_project_removes_the_project_too(world: World) -> None:
    from infrastructure.projects.models import Project

    job = world.analyzed(JIRA_CSV)
    done = services.start(
        world.owner,
        world.ws,
        str(job.pk),
        {**job.mapping, "target": {"name": "Shop", "key": "SHP"}},
    )
    assert Project.objects.filter(key="SHP").exists()
    services.undo(world.owner, world.ws, str(done.pk))
    assert not Project.objects.filter(key="SHP").exists()


def test_a_run_that_stops_halfway_resumes_without_duplicates(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    real = engine._chunk
    calls: list[int] = []

    def dies_on_the_second_chunk(run: Any, nodes: Any, issues: list[Any], structure: Any) -> None:
        calls.append(len(issues))
        if len(calls) == 2:
            raise ApiError("The database went away.")
        real(run, nodes, issues, structure)

    monkeypatch.setattr(engine, "_chunk", dies_on_the_second_chunk)
    job = _start(world)
    assert job.status == "failed" and "database" in job.error
    assert 0 < Task.objects.count() < 4 and job.done < 4
    monkeypatch.setattr(engine, "_chunk", real)
    job = services.start(world.owner, world.ws, str(job.pk), job.mapping)
    assert job.status == "done" and Task.objects.count() == 4
    assert TaskLink.objects.count() == 1 and Comment.objects.count() == 2
    assert Task.objects.get(title="Validate the card").parent.title == "Card form"


def test_a_stalled_run_is_resumed_by_the_tick(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    job = world.analyzed(JIRA_CSV)
    mapping = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    monkeypatch.setattr(queue, "run_later", lambda *a: None)  # the worker never starts
    queued = services.start(world.owner, world.ws, str(job.pk), mapping)
    assert queued.status == "queued"
    ImportJob.objects.filter(pk=job.pk).update(
        status="running", heartbeat_at="2000-01-01T00:00:00Z"
    )
    monkeypatch.undo()
    assert engine.resume_stalled() == 1
    assert ImportJob.objects.get(pk=job.pk).status == "done"


def test_cancelling_stops_the_run_and_starting_again_finishes_it(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    real = engine._chunk

    def cancel_after_first(run: Any, nodes: Any, issues: list[Any], structure: Any) -> None:
        real(run, nodes, issues, structure)
        services.cancel(world.owner, world.ws, str(run.job.pk))

    monkeypatch.setattr(engine, "_chunk", cancel_after_first)
    job = _start(world)
    assert job.status == "cancelled" and 0 < Task.objects.count() < 4
    monkeypatch.setattr(engine, "_chunk", real)
    job = services.start(world.owner, world.ws, str(job.pk), job.mapping)
    assert job.status == "done" and Task.objects.count() == 4


def test_the_dry_run_counts_and_warns_and_changes_nothing(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    before = _counts()
    report = services.dry_run(
        world.owner,
        world.ws,
        str(job.pk),
        world.into_web(**{k: v for k, v in job.mapping.items() if k != "target"}),
    )
    assert _counts() == before
    assert (report.counts["tasks"], report.counts["subtasks"]) == (4, 3)
    assert report.counts["comments"] == 2 and report.counts["links"] == 2
    assert report.counts["placeholders"] == 3  # Bob and the two comment authors
    assert report.counts["sprints"] == 2
    text = " ".join(w["message"] for w in report.warnings)
    assert "not in the file" in text  # the dangling parent
    assert "linked issue" in text  # and the dangling link
    assert report.already_imported == 0
    _start(world)
    assert (
        services.dry_run(
            world.owner,
            world.ws,
            str(job.pk),
            {**job.mapping, "target": {"project_id": str(world.web.pk)}},
        ).already_imported
        == 4
    )


def test_a_blocking_loop_in_the_file_is_broken_not_imported(world: World) -> None:
    from infrastructure.imports.tests.samples import JIRA_HEADER, _csv

    text = _csv(
        JIRA_HEADER,
        {"Summary": "A", "Issue key": "L-1", "Issue id": "1", "Outward issue link (Blocks)": "L-2"},
        {"Summary": "B", "Issue key": "L-2", "Issue id": "2", "Outward issue link (Blocks)": "L-1"},
    )
    job = _start(world, text)
    assert job.status == "done" and TaskLink.objects.count() == 1
    assert any("loop" in p["message"] for p in job.error_report)


def test_placeholders_are_claimed_when_the_person_joins(world: World) -> None:
    _start(world)
    story = Task.objects.get(title="Card form")
    bob = get_user_model().objects.create_user("bob", "Bob@Old.Test", "pw-123456-x")
    from infrastructure.workspaces import invitations

    invitations.accept(invitations.create_link(world.ws, world.owner).token, bob)
    assert TaskAssignee.objects.filter(task=story, user=bob).exists()
    assert not PlaceholderAssignment.objects.filter(task=story).exists()
    assert PlaceholderUser.objects.get(key="bob@old.test").claimed_by_id == bob.pk


def test_a_removed_member_invited_back_takes_over_the_placeholder(world: World) -> None:
    from django.utils import timezone

    from infrastructure.workspaces import access, invitations
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    _start(world)
    story = Task.objects.get(title="Card form")
    bob = get_user_model().objects.create_user("bob", "Bob@Old.Test", "pw-123456-x")
    WorkspaceMember.objects.create(
        workspace=world.ws,
        user=bob,
        role=access.builtin_role("Member"),
        status=MemberStatus.REMOVED,
        removed_at=timezone.now() - timezone.timedelta(days=1),
    )
    invitations.accept(invitations.create_link(world.ws, world.owner).token, bob)
    assert TaskAssignee.objects.filter(task=story, user=bob).exists()
    assert PlaceholderUser.objects.get(key="bob@old.test").claimed_by_id == bob.pk


def test_a_task_in_a_private_project_keeps_waiting_until_they_can_open_it(world: World) -> None:
    holder = PlaceholderUser.objects.create(workspace=world.ws, key="dan@x.test", name="Dan")
    open_task = task_services.create(world.owner, world.ws, str(world.web.pk), "Open").pk
    secret = task_services.create(world.owner, world.ws, str(world.sec.pk), "Secret").pk
    gone = task_services.create(world.owner, world.ws, str(world.web.pk), "Gone")
    for pk in (open_task, secret, gone.pk):
        PlaceholderAssignment.objects.create(task_id=pk, placeholder=holder)
    Task.objects.filter(pk=gone.pk).update(deleted_at=timezone.now())

    assert placeholders.claim(world.owner, world.ws, str(holder.pk), str(world.alice.pk)) == 1
    assert TaskAssignee.objects.filter(task_id=open_task, user=world.alice).exists()
    left = PlaceholderAssignment.objects.filter(placeholder=holder)
    assert [a.task_id for a in left] == [secret]  # kept; the deleted one is dropped
    holder.refresh_from_db()
    assert holder.claimed_by_id is None  # still open, so it can be claimed again

    ProjectMember.objects.create(project=world.sec, user=world.alice)
    assert placeholders.claim(world.owner, world.ws, str(holder.pk), str(world.alice.pk)) == 1
    assert TaskAssignee.objects.filter(task_id=secret, user=world.alice).exists()
    holder.refresh_from_db()
    assert holder.claimed_by_id == world.alice.pk
    assert not PlaceholderAssignment.objects.filter(placeholder=holder).exists()


def test_an_admin_can_claim_a_placeholder_for_a_member(world: World) -> None:
    _start(world)
    holder = PlaceholderUser.objects.get(key="bob@old.test")
    keys = [h.key for h in placeholders.list_unclaimed(world.owner, world.ws)]
    assert keys == ["acc-77", "acc-78", "bob@old.test"]
    assert placeholders.claim(world.owner, world.ws, str(holder.pk), str(world.alice.pk)) == 1
    assert "bob@old.test" not in [h.key for h in placeholders.list_unclaimed(world.owner, world.ws)]
    with pytest.raises(ApiError) as gone:
        placeholders.claim(world.owner, world.ws, str(holder.pk), str(world.alice.pk))
    assert gone.value.status == 404


def test_only_an_admin_may_import_and_each_job_is_its_workspaces(world: World) -> None:
    job = world.analyzed(GENERIC_CSV, "g.csv")
    for who in (world.alice, world.viewer):
        with pytest.raises(ApiError) as denied:
            services.analyze(who, world.ws, str(job.pk))
        assert denied.value.status == 403
        with pytest.raises(ApiError):
            services.list_jobs(who, world.ws)
    stranger = get_user_model().objects.create_user("zed", "z@x.test", "pw-123456-x")
    elsewhere = workspace_services.create(stranger, "Other", "other")
    set_actor(stranger)
    project_services.create(stranger, elsewhere, "Theirs", "THR")
    with pytest.raises(ApiError) as hidden:
        services.get(stranger, elsewhere, str(job.pk))
    assert hidden.value.status == 404
    with pytest.raises(ApiError) as hidden_undo:
        services.undo(stranger, elsewhere, str(job.pk))
    assert hidden_undo.value.status == 404
    set_actor(world.owner)


def test_a_mapping_that_names_a_foreign_project_or_status_is_refused(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    base = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    from infrastructure.workflows import services as workflows

    other = world.sec
    workflows.ensure(other)
    bad_status = {**base, "statuses": {"To Do": f"id:{other.statuses.first().pk}"}}
    with pytest.raises(ApiError):
        services.start(world.owner, world.ws, str(job.pk), bad_status)
    with pytest.raises(ApiError):
        services.start(
            world.owner, world.ws, str(job.pk), {**base, "users": {"x": str(world.viewer.pk) + "0"}}
        )
    stranger = get_user_model().objects.create_user("zed", "z@x.test", "pw-123456-x")
    foreign = {**base, "users": {"alice@acme.test": str(stranger.pk)}}
    with pytest.raises(ApiError):
        services.start(world.owner, world.ws, str(job.pk), foreign)
    with pytest.raises(ApiError):
        services.start(world.owner, world.ws, str(job.pk), {**base, "target": {}})
    assert ImportJob.objects.get(pk=job.pk).status == "analyzed"


def test_a_private_project_does_not_get_assignees_who_cannot_open_it(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    mapping = {**job.mapping, "target": {"project_id": str(world.sec.pk)}}
    done = services.start(world.owner, world.ws, str(job.pk), mapping)
    assert done.status == "done"
    assert not TaskAssignee.objects.filter(user=world.alice).exists()
    assert any("private project" in p["message"] for p in done.error_report)


def test_an_unmapped_job_cannot_start_twice_or_undo_before_it_ran(world: World) -> None:
    job = world.analyzed(GENERIC_CSV, "g.csv")
    mapping = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    with pytest.raises(ApiError) as early:
        services.undo(world.owner, world.ws, str(job.pk))
    assert early.value.status == 409
    services.start(world.owner, world.ws, str(job.pk), mapping)
    with pytest.raises(ApiError) as twice:
        services.start(world.owner, world.ws, str(job.pk), mapping)
    assert twice.value.status == 409


def test_discarding_a_job_that_made_nothing_removes_its_file(world: World) -> None:
    from django.core.files.storage import default_storage

    job = world.upload(GENERIC_CSV, "g.csv")
    key = job.file_key
    assert default_storage.exists(key)
    services.discard(world.owner, world.ws, str(job.pk))
    assert not default_storage.exists(key) and not ImportJob.objects.exists()
    made = _start(world)
    with pytest.raises(ApiError):
        services.discard(world.owner, world.ws, str(made.pk))


def test_one_audit_entry_records_the_import_and_one_its_undo(world: World) -> None:
    from infrastructure.audit.models import AuditEntry

    job = _start(world)
    entry = AuditEntry.objects.get(action="import.completed")
    assert entry.target_id == str(job.pk) and entry.actor_type == "system"
    assert not AuditEntry.objects.filter(action="task.created").exists()  # no per-row noise
    services.undo(world.owner, world.ws, str(job.pk))
    assert AuditEntry.objects.filter(action="import.undone").count() == 1


def test_imported_tasks_and_comments_are_searchable_and_undo_unindexes_them(world: World) -> None:
    from infrastructure.search.models import Kind, SearchEntry

    job = _start(world)
    assert SearchEntry.objects.filter(kind=Kind.TASK).count() == 4
    assert SearchEntry.objects.filter(kind=Kind.COMMENT).count() == 2
    hit = SearchEntry.objects.get(kind=Kind.TASK, title="card form")
    assert hit.task.title == "Card form"
    services.undo(world.owner, world.ws, str(job.pk))
    assert SearchEntry.objects.count() == 0


def test_open_clients_are_told_to_read_the_project_again(world: World) -> None:
    from infrastructure.sync.models import ChangeLog

    job = _start(world)
    seen = ChangeLog.objects.filter(entity_type="project", entity_id=world.web.pk).order_by("-pk")
    assert seen.first().action == "updated" and seen.first().project == world.web.pk
    before = ChangeLog.objects.count()
    services.undo(world.owner, world.ws, str(job.pk))
    assert ChangeLog.objects.count() == before + 1


def test_every_imported_task_carries_a_history_line_saying_where_it_came_from(
    world: World,
) -> None:
    from infrastructure.audit.models import AuditEntry

    job = _start(world)
    lines = AuditEntry.objects.filter(action="task.imported")
    assert lines.count() == 4
    story = Task.objects.get(title="Card form")
    line = lines.get(target_id=str(story.pk))
    assert line.actor_type == "system" and line.project == world.web.pk
    assert line.changes["source"] == "jira" and line.changes["key"] == "WEB-2"
    assert line.changes["author"] == "alice@acme.test"
    assert line.changes["created_at"].startswith("2024-11-14")
    assert line.changes["job"] == str(job.pk)
    # a reporter who is not a member keeps no author on the task: the history names them
    epic = Task.objects.get(title="Checkout epic")
    assert epic.created_by_id == world.owner.pk
    assert lines.get(target_id=str(epic.pk)).changes["author"] == "bob@old.test"
