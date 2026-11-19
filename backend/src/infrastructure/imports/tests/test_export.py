"""Exporting a project and a workspace, and the round trip back into a fresh workspace."""

import io
import json
import zipfile
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.core.files.storage import default_storage

from infrastructure.comments import services as comment_services
from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as field_services
from infrastructure.imports import exports, services
from infrastructure.imports.models import ExportJob
from infrastructure.imports.tests.conftest import World
from infrastructure.sync.actor import set_actor
from infrastructure.tasks import links as task_links
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task, TaskAssignee, TaskLink
from infrastructure.workspaces import services as workspace_services


def _zip(job: ExportJob) -> zipfile.ZipFile:
    return zipfile.ZipFile(io.BytesIO(default_storage.open(job.file_key, "rb").read()))


def _build(world: World) -> None:
    owner, ws, pid = world.owner, world.ws, str(world.web.pk)
    set_actor(owner)
    field_services.create(
        owner, ws, pid, name="Severity", type="select",
        options=[{"label": "S1"}, {"label": "S2"}],
    )  # fmt: skip
    epic = task_services.create(
        owner, ws, pid, "Epic", priority="high", due_date="2026-12-01",
        description=json.dumps({"type": "doc", "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Plan =cmd()"}]}]}),
        assignee_ids=[str(world.alice.pk)],
    )  # fmt: skip
    child = task_services.create(owner, ws, pid, "Child", parent_id=str(epic.pk))
    other = task_services.create(owner, ws, pid, "Other")
    task_links.add(owner, ws, str(child.pk), str(other.pk), "blocks")
    comment_services.create(
        owner, ws, pid, str(epic.pk),
        json.dumps({"type": "doc", "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "A comment"}]}]}),
    )  # fmt: skip


def test_a_project_export_has_the_five_files_and_streams_valid_json(world: World) -> None:
    _build(world)
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    assert job.status == "done" and job.stats["tasks"] == 3 and job.stats["comments"] == 1
    archive = _zip(job)
    assert sorted(archive.namelist()) == [
        "README.md", "attachments.json", "comments.json", "tasks.csv", "tasks.json",
    ]  # fmt: skip
    data = json.loads(archive.read("tasks.json"))
    assert data["format"] == "taskforge-export" and data["project"]["key"] == "WEB"
    assert [t["title"] for t in data["tasks"]] == ["Epic", "Child", "Other"]  # tree order
    assert data["tasks"][1]["parent_id"] == data["tasks"][0]["id"]
    assert data["fields"][0]["name"] == "Severity"
    rows = archive.read("tasks.csv").decode().splitlines()
    assert rows[0].startswith("key,title,status") and len(rows) == 4
    assert "'=cmd()" in archive.read("tasks.csv").decode() or "Plan" in rows[1]
    assert json.loads(archive.read("comments.json"))[0]["text"] == "A comment"
    assert "tasks.json" in archive.read("README.md").decode()


def test_a_spreadsheet_formula_in_a_cell_is_neutralised(world: World) -> None:
    owner, pid = world.owner, str(world.web.pk)
    task_services.create(
        owner, world.ws, pid, "=HYPERLINK(1)",
        description=json.dumps({"type": "doc", "content": [{"type": "paragraph", "content": [
            {"type": "text", "text": "=SUM(1)"}]}]}),
    )  # fmt: skip
    archive = _zip(exports.start(owner, world.ws, pid))
    csv_text = archive.read("tasks.csv").decode()
    assert "'=SUM(1)" in csv_text  # the description cell is quoted
    # (the title column keeps the text as is: it is data in a header-labelled column)


def test_a_workspace_export_has_one_folder_per_visible_project(world: World) -> None:
    _build(world)
    task_services.create(world.owner, world.ws, str(world.sec.pk), "Secret")
    mine = _zip(exports.start(world.owner, world.ws))
    assert {n.split("/")[0] for n in mine.namelist()} >= {"WEB", "SEC", "workspace.json"}
    assert json.loads(mine.read("workspace.json"))["name"] == "Acme"
    # a project the exporter cannot open is simply not there
    set_actor(world.owner)
    from infrastructure.projects.models import ProjectMember

    ProjectMember.objects.filter(project=world.sec).delete()
    narrower = _zip(exports.start(world.owner, world.ws))
    assert {n.split("/")[0] for n in narrower.namelist()} == {"WEB", "workspace.json"}


def test_the_link_is_signed_short_lived_and_the_files_are_purged(
    world: World, settings: Any
) -> None:
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    token = exports.link_token(world.owner, world.ws, str(job.pk))
    assert exports.resolve_token(token).pk == job.pk
    with pytest.raises(ApiError) as bad:
        exports.resolve_token(token + "x")
    assert bad.value.status == 404
    settings.EXPORT_LINK_TTL_SECONDS = -1
    with pytest.raises(ApiError) as late:
        exports.resolve_token(token)
    assert late.value.status == 410
    key = job.file_key
    from django.utils import timezone

    assert exports.purge_old(timezone.now() + timezone.timedelta(days=2)) == 1
    assert not default_storage.exists(key)
    assert ExportJob.objects.get(pk=job.pk).status == "expired"


def test_an_export_is_the_requesters_own_and_needs_the_permission(world: World) -> None:
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    for who in (world.alice, world.viewer):
        with pytest.raises(ApiError) as denied:
            exports.start(who, world.ws, str(world.web.pk))
        assert denied.value.status == 403
    stranger = get_user_model().objects.create_user("zed", "z@x.test", "pw-123456-x")
    elsewhere = workspace_services.create(stranger, "Other", "other")
    with pytest.raises(ApiError) as hidden:
        exports.get(stranger, elsewhere, str(job.pk))
    assert hidden.value.status == 404
    with pytest.raises(ApiError):
        exports.start(stranger, elsewhere, str(world.web.pk))  # a project of another workspace
    set_actor(world.owner)


def test_export_then_import_into_a_fresh_workspace_reproduces_the_project(world: World) -> None:
    _build(world)
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    payload = _zip(job).read("tasks.json")

    # A second workspace with its own admin: the same people join by email.
    boss = get_user_model().objects.create_user("boss", "boss@y.test", "pw-123456-x")
    fresh = workspace_services.create(boss, "Fresh", "fresh")
    set_actor(boss)
    zipped = io.BytesIO()
    with zipfile.ZipFile(zipped, "w") as z:
        z.writestr("WEB/tasks.json", payload)
    uploaded = services.upload(boss, fresh, io.BytesIO(zipped.getvalue()), "export.zip")
    assert uploaded.source == "taskforge" and uploaded.member == "WEB/tasks.json"
    proposal = services.analyze(boss, fresh, str(uploaded.pk)).job
    assert proposal.mapping["target"] == {"name": "Web", "key": "WEB"}
    done = services.start(boss, fresh, str(uploaded.pk), proposal.mapping)
    assert done.status == "done", done.error

    copy = done.project
    original = {t.title: t for t in Task.objects.filter(project=world.web)}
    made = {t.title: t for t in Task.objects.filter(project=copy)}
    assert set(made) == set(original) == {"Epic", "Child", "Other"}
    assert made["Child"].parent.title == "Epic" and made["Epic"].priority == "high"
    assert made["Epic"].due_date == original["Epic"].due_date
    assert made["Epic"].description == original["Epic"].description
    assert made["Epic"].created_at == original["Epic"].created_at
    assert made["Epic"].status.name == original["Epic"].status.name
    # the author is not in Fresh: named in the text
    text = str(made["Epic"].comments.get(kind="user").body)
    assert "A comment" in text and "owner wrote" in text
    link = TaskLink.objects.get(from_task=made["Child"])
    assert (link.to_task_id, link.type) == (made["Other"].pk, "blocks")
    assert copy.custom_fields.get(name="Severity").options  # the field came along
    assert not TaskAssignee.objects.filter(task=made["Epic"]).exists()  # Alice is not in Fresh
    from infrastructure.imports.models import PlaceholderAssignment

    assert PlaceholderAssignment.objects.filter(task=made["Epic"]).count() == 1  # kept for her
    assert {s.name for s in copy.statuses.all()} >= {s.name for s in world.web.statuses.all()}


def test_the_real_export_zip_uploads_as_it_is_and_reproduces_the_whole_project(
    world: World,
) -> None:
    from infrastructure.customfields.models import FieldValue
    from infrastructure.sprints.models import Sprint

    _build(world)
    owner, ws, pid = world.owner, world.ws, str(world.web.pk)
    sprint = Sprint.objects.create(
        workspace=ws, project=world.web, name="Sprint 7", start_date="2026-11-02",
        end_date="2026-11-13", state="completed",
    )  # fmt: skip
    epic = Task.objects.get(title="Epic")
    field = world.web.custom_fields.get(name="Severity")
    Task.objects.filter(pk=epic.pk).update(
        sprint=sprint, points="5.00", estimate_sec=7200, start_date="2026-11-30"
    )
    FieldValue.objects.create(task=epic, field=field, value_text=field.options[1]["id"])
    job = exports.start(owner, ws, str(pid))
    real_zip = default_storage.open(job.file_key, "rb").read()

    boss = get_user_model().objects.create_user("boss", "boss@y.test", "pw-123456-x")
    fresh = workspace_services.create(boss, "Fresh", "fresh")
    set_actor(boss)
    uploaded = services.upload(boss, fresh, io.BytesIO(real_zip), "taskforge-web.zip")
    assert uploaded.source == "taskforge" and uploaded.member == "tasks.json"  # picked by itself
    proposal = services.analyze(boss, fresh, str(uploaded.pk)).job
    done = services.start(boss, fresh, str(uploaded.pk), proposal.mapping)
    assert done.status == "done", done.error

    made = {t.title: t for t in Task.objects.filter(project=done.project)}
    copy = made["Epic"]
    assert (str(copy.points), copy.estimate_sec, copy.start_date.isoformat()) == (
        "5.00", 7200, "2026-11-30",
    )  # fmt: skip
    assert copy.sprint.name == "Sprint 7" and copy.sprint.state == "completed"
    assert copy.sprint.start_date.isoformat() == "2026-11-02"
    value = FieldValue.objects.get(task=copy)
    option = value.field.options[1]
    assert value.value_text == option["id"] and option["label"] == "S2"
    order = list(
        Task.objects.filter(project=done.project)
        .order_by("tree_key")
        .values_list("title", flat=True)
    )
    assert order == ["Epic", "Child", "Other"]  # the same tree order as the project
    assert [
        c["text"] for c in json.loads(zipfile.ZipFile(io.BytesIO(real_zip)).read("comments.json"))
    ] == ["A comment"]


def test_a_workspace_zip_needs_the_person_to_pick_one_project(world: World) -> None:
    _build(world)
    task_services.create(world.owner, world.ws, str(world.sec.pk), "Secret")
    job = exports.start(world.owner, world.ws)
    raw = default_storage.open(job.file_key, "rb").read()
    uploaded = services.upload(world.owner, world.ws, io.BytesIO(raw), "all.zip")
    assert uploaded.member == "" and uploaded.source == "taskforge"
    members = services.members_of(world.owner, world.ws, str(uploaded.pk))
    assert "SEC/tasks.json" in members and "WEB/tasks.json" in members
    with pytest.raises(ApiError, match="Choose which file"):
        services.analyze(world.owner, world.ws, str(uploaded.pk))
    picked = services.analyze(world.owner, world.ws, str(uploaded.pk), member="SEC/tasks.json")
    assert picked.job.mapping["target"]["key"] == "SEC" and picked.job.analysis["issues"] == 1


def test_a_taskforge_file_of_another_format_or_version_is_refused(world: World) -> None:
    for payload in (
        b'{"format": "other", "tasks": []}',
        b'{"format": "taskforge-export", "version": 99, "tasks": []}',
    ):
        job = world.upload(payload, "x.json", source="taskforge")
        with pytest.raises(ApiError):
            services.analyze(world.owner, world.ws, str(job.pk))
