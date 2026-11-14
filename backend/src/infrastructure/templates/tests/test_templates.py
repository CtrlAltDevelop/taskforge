"""Templates end to end: the save -> apply round trip, dates, variables, limits and access."""

# ruff: noqa: E501 - fixture data reads better on one line

import json
from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as fields
from infrastructure.customfields import values
from infrastructure.projects.models import Project
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.templates import apply, builtin, content, services
from infrastructure.templates.models import Template
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft, TransitionDraft, WorkflowDraft
from infrastructure.workflows.models import Status

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


def make(
    team: Any, actor: Any, kind: str, body: dict[str, Any], visibility: str = "workspace"
) -> str:
    view = services.create(
        actor, team.ws, kind, "T", "", visibility, json.dumps({"schema": 1, **body})
    )
    return view.id


def task_item(ref: str, title: str, **extra: Any) -> dict[str, Any]:
    return {"ref": ref, "title": title, **extra}


# --- save-project -> apply round trip ------------------------------------------------------


@pytest.fixture
def source(team: Any) -> Project:
    """A project with its own workflow, a text field and a parent/child pair of dated tasks."""
    project = team.create(team.owner, "SRC")
    pid = str(project.pk)
    current = workflows.get(team.owner, team.ws, pid)
    draft = WorkflowDraft(
        statuses=(
            StatusDraft("idea", "Idea", "#111111", "not_started", True),
            StatusDraft("doing", "Doing", "#222222", "active"),
            StatusDraft("shipped", "Shipped", "#333333", "done"),
        ),
        transitions=(TransitionDraft("idea", "doing"), TransitionDraft("doing", "shipped")),
    )
    workflows.update(team.owner, team.ws, pid, current.workflow.version, draft, {})
    note = fields.create(team.owner, team.ws, pid, name="Notes", type="text")
    doing = Status.objects.get(project=project, name="Doing")
    parent = tasks.create(
        team.owner, team.ws, pid, "Parent", status=str(doing.pk), priority="high",
        start_date="2030-03-04", due_date="2030-03-08",
        field_values={str(note.pk): "hello"},
    )  # fmt: skip
    tasks.create(
        team.owner, team.ws, pid, "Child", parent_id=str(parent.pk),
        start_date="2030-03-05", due_date="2030-03-06",
    )  # fmt: skip
    return project


def shape(project: Project) -> dict[str, Any]:
    """Everything a round trip must preserve, free of ids."""
    rows = list(Task.objects.filter(project=project).select_related("status", "parent"))
    defs = values.active_fields(project)
    return {
        "statuses": [
            (s.name, s.color, s.category, s.is_default)
            for s in Status.objects.filter(project=project).order_by("position")
        ],
        "transitions": sorted(
            (t.from_status.name, t.to_status.name) for t in project.transitions.all()
        ),
        "fields": [(f.name, f.type) for f in defs],
        "tasks": sorted(
            (
                t.title, t.priority, t.status.name,
                t.parent.title if t.parent else "",
                t.start_date, t.due_date,
            )
            for t in rows
        ),
    }  # fmt: skip


def test_saving_a_project_and_applying_it_reproduces_workflow_fields_and_tasks(
    team: Any, source: Project
) -> None:
    saved = services.save_from_project(
        team.owner, team.ws, str(source.pk), "Tpl", "", "workspace",
        ["workflow", "fields", "tasks"], False,
    )  # fmt: skip
    assert saved.task_count == 2

    result = apply.apply(
        team.owner, team.ws, saved.id,
        project=apply.ProjectParams(name="Copy", key="CPY"), start_date="2030-03-04",
    )  # fmt: skip

    copy = Project.objects.get(pk=result.project_id)
    assert result.warnings == []
    assert len(result.task_ids) == 2
    assert shape(copy) == shape(source)
    note = next(f for f in values.active_fields(copy) if f.name == "Notes")
    parent = Task.objects.get(project=copy, title="Parent")
    assert values.current(parent, str(note.pk)) == "hello"


def test_dates_are_offsets_from_the_chosen_start(team: Any, source: Project) -> None:
    saved = services.save_from_project(
        team.owner, team.ws, str(source.pk), "Tpl", "", "workspace", ["workflow", "tasks"], False
    )
    body = services.get(team.owner, team.ws, saved.id).content
    offsets = {t["title"]: (t["start_offset"], t["due_offset"]) for t in body["tasks"]}
    assert offsets == {"Parent": (0, 4), "Child": (1, 2)}

    result = apply.apply(
        team.owner, team.ws, saved.id,
        project=apply.ProjectParams(name="Later", key="LTR"), start_date="2030-04-01",
    )  # fmt: skip
    rows = {
        t.title: (str(t.start_date), str(t.due_date))
        for t in Task.objects.filter(project_id=result.project_id)
    }
    assert rows == {
        "Parent": ("2030-04-01", "2030-04-05"),
        "Child": ("2030-04-02", "2030-04-03"),
    }


def test_variables_are_substituted_in_every_string(team: Any) -> None:
    body = {
        "workflow": {
            "restrict": False,
            "restrict_creation": False,
            "statuses": [
                {"key": "a", "name": "Open {{team}}", "color": "#111111", "category": "not_started", "is_default": True},
                {"key": "b", "name": "Closed", "color": "#222222", "category": "done", "is_default": False},
            ],
            "transitions": [],
        },
        "fields": [
            {"key": "n", "name": "{{team}} notes", "type": "text", "options": [], "required": False, "default": "", "hidden_views": []}
        ],
        "tasks": [
            task_item(
                "t1", "{{team}} kickoff", status="Open {{team}}",
                description={"type": "doc", "content": [{"type": "text", "text": "for {{team}}"}]},
                fields=[{"name": "{{team}} notes", "type": "text", "value": "owned by {{team}}"}],
            )
        ],
    }  # fmt: skip
    template_id = make(team, team.owner, "project", body)
    assert services.get(team.owner, team.ws, template_id).variables == ["team"]

    result = apply.apply(
        team.owner, team.ws, template_id,
        project=apply.ProjectParams(name="{{team}} project", key="PLT", description="About {{team}}"),
        variables={"team": "Platform"},
    )  # fmt: skip

    project = Project.objects.get(pk=result.project_id)
    assert project.name == "Platform project"
    assert project.description == "About Platform"
    assert Status.objects.filter(project=project, name="Open Platform").exists()
    assert [f.name for f in values.active_fields(project)] == ["Platform notes"]
    task = Task.objects.get(project=project)
    assert task.title == "Platform kickoff"
    assert task.status.name == "Open Platform"
    assert "for Platform" in json.dumps(task.description)
    assert "{{" not in json.dumps([task.title, task.description, project.name, project.description])


def test_a_blank_variable_is_refused(team: Any) -> None:
    template_id = make(team, team.owner, "project", {"tasks": [task_item("t1", "{{a}} and {{b}}")]})
    with pytest.raises(ApiError, match="a, b"):
        apply.apply(
            team.owner,
            team.ws,
            template_id,
            project=apply.ProjectParams(name="P", key="PP"),
            variables={"a": " "},
        )


# --- limits --------------------------------------------------------------------------------


def many(count: int) -> list[dict[str, Any]]:
    return [task_item(f"r{i}", f"t{i}") for i in range(count)]


def test_2000_tasks_is_the_limit(team: Any) -> None:
    assert len(content.clean("project", {"tasks": many(2000)})["tasks"]) == 2000
    with pytest.raises(ApiError, match="2000"):
        content.clean("project", {"tasks": many(2001)})
    with pytest.raises(ApiError):
        services.create(
            team.owner, team.ws, "project", "Big", "", "workspace",
            json.dumps({"tasks": many(2001)}),
        )  # fmt: skip


def test_an_oversized_stored_template_is_refused_on_apply(team: Any) -> None:
    row = Template.objects.create(
        workspace=team.ws, kind="project", name="Raw", created_by=team.owner,
        content={"schema": 1, "tasks": many(2001)}, task_count=2001,
    )  # fmt: skip
    before = Project.objects.count()
    with pytest.raises(ApiError):
        apply.apply(
            team.owner, team.ws, str(row.pk), project=apply.ProjectParams(name="P", key="PP")
        )
    assert Project.objects.count() == before


# --- access --------------------------------------------------------------------------------


def test_a_private_template_is_a_404_for_everybody_else(team: Any) -> None:
    template_id = make(team, team.member, "project", {"tasks": [task_item("t1", "x")]}, "private")
    assert services.get(team.member, team.ws, template_id).visibility == "private"
    for other in (team.owner, team.admin, team.viewer):
        with pytest.raises(ApiError) as caught:
            services.get(other, team.ws, template_id)
        assert caught.value.status == 404
        assert template_id not in [t.id for t in services.list_templates(other, team.ws)]
        with pytest.raises(ApiError) as applied:
            apply.apply(
                other, team.ws, template_id, project=apply.ProjectParams(name="P", key="PP")
            )
        assert applied.value.status == 404
    with pytest.raises(ApiError) as edited:
        services.update(team.owner, team.ws, template_id, 1, name="Mine now")
    assert edited.value.status == 404
    with pytest.raises(ApiError) as deleted:
        services.delete(team.admin, team.ws, template_id)
    assert deleted.value.status == 404


def test_saving_needs_the_create_permission(team: Any, source: Project) -> None:
    body = json.dumps({"tasks": [task_item("t1", "x")]})
    with pytest.raises(ApiError) as caught:
        services.create(team.viewer, team.ws, "project", "T", "", "workspace", body)
    assert caught.value.status == 403
    with pytest.raises(ApiError):
        services.save_from_project(
            team.viewer, team.ws, str(source.pk), "T", "", "workspace", ["tasks"], False
        )
    assert services.create(team.member, team.ws, "project", "T", "", "workspace", body)


def test_only_the_creator_or_a_manager_edits_a_shared_template(team: Any) -> None:
    template_id = make(team, team.member, "project", {"tasks": [task_item("t1", "x")]})
    with pytest.raises(ApiError) as caught:
        services.update(team.pm, team.ws, template_id, 1, name="Hijack")
    assert caught.value.status == 403
    with pytest.raises(ApiError):
        services.delete(team.pm, team.ws, template_id)
    assert services.update(team.member, team.ws, template_id, 1, name="Mine").name == "Mine"
    assert services.update(team.admin, team.ws, template_id, 2, name="Admin's").version == 3
    with pytest.raises(ApiError) as stale:
        services.update(team.member, team.ws, template_id, 1, name="Old")
    assert stale.value.status == 409
    services.delete(team.admin, team.ws, template_id)


def test_nobody_outside_the_workspace_can_list_or_apply(team: Any) -> None:
    template_id = make(team, team.owner, "project", {"tasks": [task_item("t1", "x")]})
    with pytest.raises(ApiError):
        services.list_templates(team.outsider, team.ws)
    with pytest.raises(ApiError):
        apply.apply(
            team.outsider, team.ws, template_id, project=apply.ProjectParams(name="P", key="PP")
        )


def test_built_ins_are_listed_but_read_only(team: Any) -> None:
    listed = [t for t in services.list_templates(team.member, team.ws) if t.is_builtin]
    assert listed and not any(t.can_edit for t in listed)
    builtin_id = builtin.BUILTINS[0].id
    for attempt in (
        lambda: services.update(team.owner, team.ws, builtin_id, 1, name="x"),
        lambda: services.delete(team.owner, team.ws, builtin_id),
    ):
        with pytest.raises(ApiError) as caught:
            attempt()
        assert caught.value.status == 403
    assert Template.objects.filter(workspace=team.ws).count() == 0
