"""The other sources: Jira JSON, ClickUp CSV and JSON, and a CSV mapped by hand."""

import pytest

from infrastructure.comments.models import Comment
from infrastructure.imports import services
from infrastructure.imports.models import (
    ImportedRef,
    ImportJob,
    PlaceholderAssignment,
    PlaceholderUser,
)
from infrastructure.imports.tests.conftest import World
from infrastructure.imports.tests.samples import (
    CLICKUP_CSV,
    CLICKUP_JSON,
    GENERIC_CSV,
    JIRA_JSON,
)
from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Task, TaskAssignee, TaskLink


def _go(world: World, text: str, name: str, **changes: object) -> ImportJob:
    job = world.analyzed(text, name)
    mapping = {**job.mapping, **changes, "target": {"project_id": str(world.web.pk)}}
    return services.start(world.owner, world.ws, str(job.pk), mapping)


def test_jira_json_with_adf_comments_sprints_and_links(world: World) -> None:
    job = _go(world, JIRA_JSON, "export.json")
    assert job.source == "jira_json" and job.status == "done", job.error
    first = Task.objects.get(title="Design the API")
    assert first.priority == "urgent" and str(first.points) == "8.00"
    assert first.description["content"][0]["content"][1]["marks"] == [{"type": "bold"}]
    assert first.sprint.name == "Sprint 9" and first.sprint.state == "completed"
    assert first.sprint.start_date.isoformat() == "2024-11-01"
    assert [a.user_id for a in TaskAssignee.objects.filter(task=first)] == [world.alice.pk]
    assert "good" in str(Comment.objects.get(task=first).body)
    second = Task.objects.get(title="Implement the API")
    assert second.parent_id == first.pk
    assert TaskLink.objects.count() == 1  # both ends name the same pair: once
    assert TaskLink.objects.get().from_task_id == first.pk
    problems = [p["message"] for p in job.error_report]
    assert any("no title" in m or "no summary" in m for m in problems)  # the third entry
    assert Task.objects.filter(project=world.web).count() == 2


def test_clickup_csv_markdown_tags_assignees_and_a_tree(world: World) -> None:
    job = _go(world, CLICKUP_CSV, "tasks.csv")
    assert job.source == "clickup_csv" and job.status == "done", job.error
    plan = Task.objects.get(title="Plan launch")
    assert plan.priority == "high" and plan.estimate_sec == 7200
    assert [n["type"] for n in plan.description["content"]] == ["heading", "bullet_list"]
    assert plan.created_at.year == 2024
    copy = Task.objects.get(title="Write copy")
    assert copy.parent_id == plan.pk and copy.priority == "urgent"
    assert Task.objects.get(title="Ship it").status.category == "done"
    assert world.web.custom_fields.get(name="Labels").options  # launch, q4
    assert PlaceholderUser.objects.filter(workspace=world.ws, name="Dave D").exists()
    assert "Looks fine" in str(Comment.objects.get(task=plan).body)


def test_clickup_json_dependencies_and_manifest(world: World) -> None:
    job = _go(world, CLICKUP_JSON, "tasks.json")
    assert job.source == "clickup_json" and job.status == "done", job.error
    one, two = Task.objects.get(title="Plan launch"), Task.objects.get(title="Write copy")
    link = TaskLink.objects.get()
    assert (link.from_task_id, link.to_task_id) == (one.pk, two.pk)  # t2 depends on t1
    assert ImportedRef.objects.get(source_id="t1").meta["attachments"][0]["filename"] == "plan.pdf"
    assert one.estimate_sec == 3600


def test_a_generic_csv_is_mapped_by_hand(world: World) -> None:
    job = world.analyzed(GENERIC_CSV, "stuff.csv")
    assert job.source == "csv"
    assert job.mapping["columns"] == {
        "title": "Name",
        "description": "Details",
        "status": "State",
        "assignee": "Owner",
        "due": "Due",
    }
    chosen = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    done = services.start(world.owner, world.ws, str(job.pk), chosen)
    assert done.status == "done", done.error
    assert (
        Task.objects.filter(project=world.web).count() == 2
    )  # the row without a title is a problem
    assert any("no title" in p["message"] for p in done.error_report)
    login = Task.objects.get(title="Fix login")
    assert login.due_date.isoformat() == "2024-12-01"
    assert [a.user_id for a in TaskAssignee.objects.filter(task=login)] == [world.alice.pk]
    assert PlaceholderAssignment.objects.filter(placeholder__key="nobody@x.test").count() == 1


def test_the_columns_can_be_changed_and_must_exist(world: World) -> None:
    job = world.analyzed(GENERIC_CSV, "stuff.csv")
    base = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    swapped = {**base, "columns": {"title": "Details"}}
    done = services.start(world.owner, world.ws, str(job.pk), swapped)
    assert sorted(Task.objects.values_list("title", flat=True)) == [
        "It breaks", "no title here",
    ]  # fmt: skip
    assert done.status == "done"
    job2 = world.analyzed(GENERIC_CSV, "again.csv")
    for bad in ({"title": "Nope"}, {"id": "Name"}, {}, {"bogus": "Name", "title": "Name"}):
        with pytest.raises(Exception, match=r"column|title|field"):
            services.start(world.owner, world.ws, str(job2.pk), {**base, "columns": bad})


def test_a_new_project_is_made_from_a_name_and_key(world: World) -> None:
    job = world.analyzed(CLICKUP_CSV, "tasks.csv")
    mapping = {**job.mapping, "target": {"name": "Launch", "key": "LCH"}}
    done = services.start(world.owner, world.ws, str(job.pk), mapping)
    assert done.status == "done" and done.project.key == "LCH"
    assert Task.objects.filter(project=done.project).count() == 3
    assert {s.name.lower() for s in done.project.statuses.all()} >= {
        "open",
        "in progress",
        "complete",
    }
    assert Sprint.objects.count() == 0


def test_a_clickup_import_is_dry_run_first_and_names_comment_authors(world: World) -> None:
    from infrastructure.imports.tests.samples import CLICKUP_JSON

    job = world.analyzed(CLICKUP_JSON, "tasks.json")
    mapping = {**job.mapping, "target": {"project_id": str(world.web.pk)}}
    report = services.dry_run(world.owner, world.ws, str(job.pk), mapping)
    assert (report.counts["tasks"], report.counts["subtasks"], report.counts["links"]) == (2, 1, 1)
    assert Task.objects.count() == 0  # a dry run changes nothing
    done = services.start(world.owner, world.ws, str(job.pk), mapping)
    comment = Comment.objects.get(task__title="Plan launch")
    assert "Dave wrote on 2024-11-12" in str(comment.body) and done.status == "done"


def test_a_jira_sprint_that_is_not_closed_is_imported_as_planned(world: World) -> None:
    job = _go(world, JIRA_JSON.replace('"state": "closed"', '"state": "active"'), "export.json")
    assert job.status == "done", job.error
    assert Task.objects.get(title="Design the API").sprint.state == "planned"
