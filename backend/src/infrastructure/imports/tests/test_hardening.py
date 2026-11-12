"""What a careful reviewer would try: a second run on a live job, a private project, deep chains,
parents from another project, loops across runs, undo of work people added, and big inputs."""

import io
import json
from datetime import timedelta
from typing import Any

import pytest
from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.imports import engine, exports, services, streams
from infrastructure.imports.models import ImportJob
from infrastructure.imports.tests.conftest import World
from infrastructure.imports.tests.samples import JIRA_CSV
from infrastructure.projects import services as project_services
from infrastructure.sprints.models import EventKind, ScopeEvent, Sprint, State
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task, TaskLink
from infrastructure.workspaces import access, roles
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember


def _generic(rows: list[tuple[str, str, str]]) -> str:
    """A CSV of ``(id, title, parent)`` rows."""
    out = io.StringIO()
    out.write("id,title,parent\n")
    for source_id, title, parent in rows:
        out.write(f"{source_id},{title},{parent}\n")
    return out.getvalue()


def _go(world: World, text: str, project: Any = None, name: str = "f.csv") -> ImportJob:
    job = world.analyzed(text, name)
    target = {"project_id": str((project or world.web).pk)}
    return services.start(world.owner, world.ws, str(job.pk), {**job.mapping, "target": target})


def test_a_run_that_lost_its_job_to_another_run_stops_instead_of_writing(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    ImportJob.objects.filter(pk=job.pk).update(status="running", run_token=None)
    old = ImportJob.objects.get(pk=job.pk)
    old.run_token = __import__("uuid").uuid4()  # the first run's token
    ImportJob.objects.filter(pk=job.pk).update(
        run_token=old.run_token, heartbeat_at=timezone.now() - timedelta(minutes=10)
    )
    assert engine.resume_stalled() == 1  # a tick thought it was dead and ran it again
    assert ImportJob.objects.get(pk=job.pk).status in ("failed", "done", "queued")
    with pytest.raises((engine.Superseded, engine.Cancelled)):
        engine._heartbeat(old)  # the first run notices on its next beat
    assert Task.objects.count() <= 4  # and nothing was made twice


def test_a_live_run_cannot_be_started_a_second_time(world: World) -> None:
    job = world.analyzed(JIRA_CSV)
    ImportJob.objects.filter(pk=job.pk).update(status="running")
    with pytest.raises(ApiError) as busy:
        services.start(
            world.owner,
            world.ws,
            str(job.pk),
            {**job.mapping, "target": {"name": "A", "key": "AA"}},
        )
    assert busy.value.status == 409
    engine.run_job(job.pk)  # not queued: nothing happens
    assert Task.objects.count() == 0


def test_the_importer_cannot_target_a_private_project_they_cannot_open(world: World) -> None:
    data_role = roles.create_role(world.ws, world.owner, "Data", ["workspace.view", "data.manage"])
    clerk = get_user_model().objects.create_user("clerk", "c@x.test", "pw-123456-x")
    WorkspaceMember.objects.create(workspace=world.ws, user=clerk, role=data_role.role)
    job = services.upload(clerk, world.ws, io.BytesIO(b"title\nA\n"), "a.csv")
    proposal = services.analyze(clerk, world.ws, str(job.pk)).job
    for project in (world.sec, world.web):
        mapping = {**proposal.mapping, "target": {"project_id": str(project.pk)}}
        if project is world.sec:  # private, and the clerk is not in it
            with pytest.raises(ApiError):
                services.start(clerk, world.ws, str(job.pk), mapping)
            with pytest.raises(ApiError):
                services.dry_run(clerk, world.ws, str(job.pk), mapping)
        else:
            assert services.start(clerk, world.ws, str(job.pk), mapping).status == "done"
    assert not Task.objects.filter(project=world.sec).exists()


def test_a_chain_of_thousands_of_parents_does_not_crash(world: World) -> None:
    rows = [("r0", "root", "")] + [(f"r{n}", f"task {n}", f"r{n - 1}") for n in range(1, 3000)]
    job = _go(world, _generic(rows))
    assert job.status == "done", job.error
    assert Task.objects.count() == 3000
    assert max(Task.objects.values_list("depth", flat=True)) <= 24
    assert any("nested deeper" in p["message"] for p in job.error_report)


def test_a_loop_of_parents_is_broken_not_followed_forever(world: World) -> None:
    job = _go(world, _generic([("a", "A", "c"), ("b", "B", "a"), ("c", "C", "b")]))
    assert job.status == "done" and Task.objects.count() == 3
    assert Task.objects.filter(parent__isnull=True).count() == 1
    assert any("own ancestor" in p["message"] for p in job.error_report)


def test_a_parent_made_into_another_project_is_not_used_as_a_parent(world: World) -> None:
    other = project_services.create(world.owner, world.ws, "Other", "OTH").project
    _go(world, _generic([("p1", "Parent", "")]), world.web)
    job = _go(world, _generic([("p1", "Parent", ""), ("c1", "Child", "p1")]), other)
    child = Task.objects.get(title="Child")
    assert child.project_id == other.pk and child.parent_id is None and child.depth == 0
    assert child.path.startswith(str(child.pk))  # its own tree, not the other project's
    assert any("parent not in this project" in p["message"] for p in job.error_report)


def test_a_resume_cannot_move_a_half_made_import_to_another_project(
    world: World, monkeypatch: pytest.MonkeyPatch
) -> None:
    other = project_services.create(world.owner, world.ws, "Other", "OTH").project
    real = engine._chunk
    calls: list[int] = []

    def die_second(run: Any, nodes: Any, issues: list[Any], structure: Any) -> None:
        calls.append(1)
        if len(calls) == 2:
            raise ApiError("boom")
        real(run, nodes, issues, structure)

    monkeypatch.setattr(engine, "_chunk", die_second)
    job = _go(world, JIRA_CSV, world.web, "j.csv")
    assert job.status == "failed"
    with pytest.raises(ApiError) as moved:
        services.start(
            world.owner,
            world.ws,
            str(job.pk),
            {**job.mapping, "target": {"project_id": str(other.pk)}},
        )
    assert moved.value.status == 409


def test_a_spreadsheet_formula_is_neutralised_in_every_text_cell(world: World) -> None:
    import zipfile

    from django.core.files.storage import default_storage

    first = task_services.create(
        world.owner, world.ws, str(world.web.pk), '=HYPERLINK("x")', assignee_ids=[]
    )
    Task.objects.filter(pk=first.pk).update(title="=cmd|' /C calc'!A0")
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    archive = zipfile.ZipFile(io.BytesIO(default_storage.open(job.file_key, "rb").read()))
    cells = archive.read("tasks.csv").decode().splitlines()[1]
    assert "'=cmd" in cells and "\n=" not in cells and not cells.startswith("=")


def test_undo_keeps_the_work_people_added_to_imported_things(world: World) -> None:
    from infrastructure.comments import services as comment_services

    sprint = Sprint.objects.create(
        workspace=world.ws, project=world.web, name="Sprint 1", start_date="2024-11-01",
        end_date="2024-11-14", state=State.PLANNED,
    )  # fmt: skip
    del sprint
    job = _go(world, JIRA_CSV)
    story = Task.objects.get(title="Card form")
    mine = task_services.create(world.owner, world.ws, str(world.web.pk), "Mine")
    Task.objects.filter(pk=mine.pk).update(sprint=Sprint.objects.get(name="Sprint 2"))
    body = json.dumps(
        {
            "type": "doc",
            "content": [{"type": "paragraph", "content": [{"type": "text", "text": "ok"}]}],
        }
    )
    comment_services.create(world.owner, world.ws, str(world.web.pk), str(story.pk), body)
    _, gone = services.undo(world.owner, world.ws, str(job.pk))
    assert Task.objects.filter(pk=story.pk).exists()  # it has a comment of a person
    assert gone["kept"] >= 2  # the story and the epic above it
    assert Sprint.objects.filter(name="Sprint 2").exists()  # somebody put a task in it
    assert Task.objects.get(pk=mine.pk).sprint.name == "Sprint 2"
    from infrastructure.search.models import Kind, SearchEntry

    assert not SearchEntry.objects.filter(kind=Kind.COMMENT).exists()  # the import's are gone


def test_the_labels_field_stays_when_people_used_it_on_their_own_tasks(world: World) -> None:
    from infrastructure.customfields.models import FieldValue

    job = _go(world, JIRA_CSV)
    field = world.web.custom_fields.get(name="Labels")
    mine = task_services.create(world.owner, world.ws, str(world.web.pk), "Mine")
    FieldValue.objects.create(task_id=mine.pk, field=field, value_json=[field.options[0]["id"]])
    services.undo(world.owner, world.ws, str(job.pk))
    assert world.web.custom_fields.filter(name="Labels").exists()
    assert FieldValue.objects.filter(task_id=mine.pk).exists()


def test_which_loop_edge_is_dropped_does_not_depend_on_order_or_on_earlier_runs(
    world: World,
) -> None:
    import random
    import uuid

    from infrastructure.imports.prepare import Run

    ids = [uuid.uuid4() for _ in range(4)]
    edges = {(ids[i], ids[(i + 1) % 4], "blocks") for i in range(4)}  # a ring of four
    run = Run(None, world.ws, world.owner, "x", {})  # type: ignore[arg-type]
    results = []
    for seed in range(5):
        shuffled = list(edges)
        random.Random(seed).shuffle(shuffled)
        results.append(engine._without_cycles(run, set(shuffled)))
    assert all(r == results[0] for r in results) and len(results[0]) == 3


def _status(world: World) -> Any:
    from infrastructure.workflows import services as workflows

    return workflows.default_status(world.web)


def test_a_link_stored_by_an_earlier_run_closes_the_loop_for_this_one(world: World) -> None:
    from infrastructure.imports.prepare import Run

    one = task_services.create(world.owner, world.ws, str(world.web.pk), "one")
    two = task_services.create(world.owner, world.ws, str(world.web.pk), "two")
    TaskLink.objects.create(
        workspace=world.ws,
        from_task_id=one.pk,
        to_task_id=two.pk,
        type="blocks",
        created_by=world.owner,
    )
    run = Run(None, world.ws, world.owner, "x", {})  # type: ignore[arg-type]
    kept = engine._without_cycles(run, {(two.pk, one.pk, "blocks")})
    assert kept == set()  # two blocks one would close the loop with the stored one blocks two


def test_tasks_made_into_a_running_sprint_are_a_scope_change(world: World) -> None:
    Sprint.objects.create(
        workspace=world.ws, project=world.web, name="Sprint 2", start_date="2024-11-01",
        end_date="2024-11-30", state=State.ACTIVE, started_at=timezone.now(),
    )  # fmt: skip
    _go(world, JIRA_CSV)
    events = ScopeEvent.objects.filter(kind=EventKind.ADDED)
    assert events.count() == 1 and events.get().after_start and events.get().delta_tasks == 1
    assert events.get().delta_points == 5  # the story's points


def test_a_download_link_dies_with_the_right_to_export(world: World) -> None:
    job = exports.start(world.owner, world.ws, str(world.web.pk))
    token = exports.link_token(world.owner, world.ws, str(job.pk))
    assert exports.resolve_token(token).pk == job.pk
    world.ws.created_by = world.owner
    admin = get_user_model().objects.create_user("adm", "adm@x.test", "pw-123456-x")
    WorkspaceMember.objects.create(
        workspace=world.ws, user=admin, role=access.builtin_role("Admin")
    )
    mine = exports.start(admin, world.ws, str(world.web.pk))
    link = exports.link_token(admin, world.ws, str(mine.pk))
    WorkspaceMember.objects.filter(user=admin).update(status=MemberStatus.REMOVED)
    with pytest.raises(ApiError) as gone:
        exports.resolve_token(link)
    assert gone.value.status == 404


def test_a_file_with_no_line_breaks_is_refused_before_it_fills_memory() -> None:
    raw = b"a" * (streams.MAX_LINE + 10)
    with pytest.raises(ApiError, match="longer than 2 MB"):
        streams.csv_rows(streams.text_of(io.BytesIO(raw)))
    rest = b"h\n" + b"x," * 5 + b"\n" + b"y" * (streams.MAX_LINE + 10)
    _, rows = streams.csv_rows(streams.text_of(io.BytesIO(rest)))
    with pytest.raises(ApiError, match="longer than 2 MB"):
        list(rows)


def test_a_json_entry_of_several_megabytes_is_read_in_a_few_steps() -> None:
    big = {"id": "1", "text": "x" * 3_000_000}
    raw = json.dumps({"issues": [big, {"id": "2"}]}).encode()
    reads = 0
    reader_fill = streams._Reader._fill

    def counting(self: Any, size: int = 0) -> bool:
        nonlocal reads
        reads += 1
        return reader_fill(self, size)

    streams._Reader._fill = counting  # type: ignore[method-assign]
    try:
        items = list(streams.json_items(streams.text_of(io.BytesIO(raw)), "issues"))
    finally:
        streams._Reader._fill = reader_fill  # type: ignore[method-assign]
    assert [i["id"] for i in items] == ["1", "2"]
    assert reads < 60  # about log2(3 MB / 64 KB) refills for the big entry, not 46


def test_the_tick_and_purge_commands_are_idempotent(world: World) -> None:
    out = io.StringIO()
    call_command("imports_tick", stdout=out)
    call_command("purge_exports", stdout=out)
    assert "resumed 0" in out.getvalue()
