"""A Jira CSV export, end to end: parse, map, import, and what the tasks look like."""

from infrastructure.comments.models import Comment
from infrastructure.imports import services
from infrastructure.imports.models import (
    ImportedRef,
    ImportJob,
    PlaceholderAssignment,
    PlaceholderUser,
)
from infrastructure.imports.tests.conftest import World
from infrastructure.imports.tests.samples import JIRA_CSV
from infrastructure.sprints.models import Sprint
from infrastructure.tasks.models import Task, TaskAssignee, TaskLink


def _run(world: World) -> ImportJob:
    job = world.analyzed(JIRA_CSV)
    return services.start(
        world.owner,
        world.ws,
        str(job.pk),
        world.into_web(**{k: v for k, v in job.mapping.items() if k != "target"}),
    )


def test_a_file_is_recognised_and_its_choices_are_proposed(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    assert job.source == "jira_csv" and job.status == "analyzed"
    assert job.analysis["issues"] == 4 and job.analysis["subtasks"] == 3
    assert set(job.mapping["statuses"]) == {"To Do", "In Progress", "Done", "Closed"}
    assert job.mapping["priorities"]["High"] == "high"
    assert job.mapping["users"]["alice@acme.test"] == str(world.alice.pk)  # matched by email
    assert job.mapping["users"]["bob@old.test"] == "placeholder"
    assert job.mapping["columns"]["title"] == "Summary"
    assert job.mapping["columns"]["points"] == "Custom field (Story point estimate)"
    assert job.analysis["sprints"] == ["Sprint 1", "Sprint 2"]


def test_the_import_makes_tasks_with_their_tree_dates_and_authors(world: World) -> None:
    job = _run(world)
    assert job.status == "done", job.error
    assert (job.total, job.done) == (4, 4)
    tasks = {t.title: t for t in Task.objects.filter(project=world.web)}
    assert set(tasks) == {"Checkout epic", "Card form", "Validate the card", "Dangling"}
    epic, story, sub = tasks["Checkout epic"], tasks["Card form"], tasks["Validate the card"]
    assert story.parent_id == epic.pk and sub.parent_id == story.pk
    assert (epic.depth, story.depth, sub.depth) == (0, 1, 2)
    assert tasks["Dangling"].parent_id is None  # its parent is not in the file
    assert epic.created_at.date().isoformat() == "2024-11-12"  # the source's own date
    assert epic.due_date.isoformat() == "2024-11-30"
    assert (
        epic.priority == "high"
        and story.priority == "normal"
        and tasks["Dangling"].priority == "low"
    )
    assert str(story.points) == "5.00" and story.estimate_sec == 7200
    assert tasks["Validate the card"].status.category == "done"
    assert tasks["Dangling"].status.category == "done"  # "Closed" became a done status
    assert sorted(t.number for t in tasks.values()) == [1, 2, 3, 4]  # numbered level by level
    assert epic.created_by_id == world.owner.pk  # the reporter is not a member: the importer
    assert story.created_by_id == world.alice.pk  # a member reporter is kept


def test_text_becomes_our_rich_text_and_labels_a_field(world: World) -> None:
    _run(world)
    story = Task.objects.get(title="Card form")
    kinds = {n["type"] for n in story.description["content"]}
    assert kinds == {"paragraph"}
    marks = [
        m["type"] for n in story.description["content"][0]["content"] for m in n.get("marks", [])
    ]
    assert "bold" in marks and "link" in marks
    epic = Task.objects.get(title="Checkout epic")
    assert [n["type"] for n in epic.description["content"]] == ["heading", "bullet_list"]
    from infrastructure.customfields import values

    field = world.web.custom_fields.get(name="Labels")
    assert [o["label"] for o in field.options] == ["payments", "ui"]
    assert values.current(story, str(field.pk)) != ""


def test_people_assignees_and_placeholders(world: World) -> None:
    _run(world)
    epic = Task.objects.get(title="Checkout epic")
    assert [a.user_id for a in TaskAssignee.objects.filter(task=epic)] == [world.alice.pk]
    story = Task.objects.get(title="Card form")
    assert not TaskAssignee.objects.filter(task=story).exists()  # Bob is not a member
    holder = PlaceholderUser.objects.get(workspace=world.ws, key="bob@old.test")
    assert PlaceholderAssignment.objects.filter(task=story, placeholder=holder).exists()


def test_comments_sprints_and_links(world: World) -> None:
    _run(world)
    story = Task.objects.get(title="Card form")
    comments = list(Comment.objects.filter(task=story).order_by("created_at"))
    assert len(comments) == 2 and comments[0].created_at.date().isoformat() == "2024-11-15"
    assert "wrote on 2024-11-15" in str(comments[0].body)  # an unmatched author is named
    assert [s.name for s in Sprint.objects.filter(project=world.web).order_by("name")] == [
        "Sprint 1", "Sprint 2",
    ]  # fmt: skip
    assert story.sprint.name == "Sprint 2"  # the latest
    epic = Task.objects.get(title="Checkout epic")
    link = TaskLink.objects.get()
    assert (link.from_task_id, link.to_task_id, link.type) == (epic.pk, story.pk, "blocks")


def test_the_job_remembers_what_it_made_and_the_attachments_manifest(world: World) -> None:
    job = _run(world)
    refs = ImportedRef.objects.filter(job=job)
    assert refs.filter(entity_type="task").count() == 4
    meta = refs.get(entity_type="task", source_id="10002").meta
    assert meta["key"] == "WEB-2" and meta["attachments"][0]["filename"] == "spec.pdf"
    assert job.stats["tasks"] == 4 and job.stats["comments"] == 2 and job.stats["links"] == 1
