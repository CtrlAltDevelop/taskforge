"""The import and export RPCs and the two REST routes, over the wire."""

import io
import json
import zipfile
from typing import Any

import grpc
import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.core.management import call_command
from django.test import Client

from infrastructure.imports.grpc import imports_pb2 as pb
from infrastructure.imports.grpc import imports_pb2_grpc as stubs
from infrastructure.imports.tests.samples import GENERIC_CSV
from infrastructure.workspaces.tests.conftest import make_user  # noqa: F401
from infrastructure.workspaces.tests.test_rbac_matrix import (
    _world,
    people,  # noqa: F401
)

IM = stubs.ImportControllerStub
EX = stubs.ExportControllerStub


def _upload(world: Any, role: str = "Owner", name: str = "t.csv", data: bytes = b"") -> Any:
    return Client().post(
        "/api/v1/imports/upload",
        {
            "workspace_id": world.ws,
            "file": SimpleUploadedFile(name, data or GENERIC_CSV.encode(), content_type="text/csv"),
        },
        HTTP_AUTHORIZATION=f"Bearer {world.tokens[role]}",
    )


def _job_id(world: Any) -> str:
    body = _upload(world).json()
    return str(body.get("data", body)["id"])


def test_upload_analyze_dry_run_start_progress_and_undo_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    token = world.tokens["Owner"]
    sent = _upload(world)
    assert sent.status_code == 200
    body = sent.json()
    data = body.get("data", body)
    job_id = data["id"]
    assert data["source"] == "csv" and data["members"] == []
    ref = {"workspace_id": world.ws, "job_id": job_id}

    proposal = grpc_call(IM, "Analyze", pb.ImportAnalyzeRequest(**ref), token=token)
    assert proposal.job.status == "analyzed"
    mapping = json.loads(proposal.mapping_json)
    assert json.loads(proposal.analysis_json)["issues"] == 2
    mapping["target"] = {"project_id": world.project_id}

    report = grpc_call(
        IM, "DryRun", pb.ImportDryRunRequest(**ref, mapping_json=json.dumps(mapping)), token=token
    )
    assert json.loads(report.counts_json)["tasks"] == 2 and report.errors == 1  # the untitled row

    started = grpc_call(
        IM, "Start", pb.ImportStartRequest(**ref, mapping_json=json.dumps(mapping)), token=token
    )
    assert started.job.status == "done" and started.job.done == 2
    stream = grpc_call(IM, "Progress", pb.ImportProgressRequest(**ref), token=token)
    assert [m.job.status for m in stream] == ["done"]  # a finished job ends the stream at once
    detail = grpc_call(IM, "Get", pb.ImportGetRequest(**ref), token=token)
    assert detail.job.problem_count == 1 and detail.problems[0].message
    assert [
        j.id
        for j in grpc_call(
            IM, "List", pb.ImportListRequest(workspace_id=world.ws), token=token
        ).jobs
    ] == [job_id]

    undone = grpc_call(IM, "Undo", pb.ImportUndoRequest(**ref), token=token)
    assert undone.job.status == "undone" and json.loads(undone.removed_json)["tasks"] == 2


def test_an_unknown_or_bad_upload_and_the_wrong_role_are_refused(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    assert _upload(world, "Viewer").status_code == 403
    assert _upload(world, "Member").status_code == 403
    empty = Client().post(
        "/api/v1/imports/upload",
        {
            "workspace_id": world.ws,
            "file": SimpleUploadedFile("e.csv", b"", content_type="text/csv"),
        },
        HTTP_AUTHORIZATION=f"Bearer {world.tokens['Owner']}",
    )
    assert empty.status_code == 422
    with pytest.raises(grpc.aio.AioRpcError) as bad:
        grpc_call(
            IM,
            "Start",
            pb.ImportStartRequest(workspace_id=world.ws, job_id="nope", mapping_json="{}"),
            token=world.tokens["Owner"],
        )
    assert bad.value.code() is grpc.StatusCode.NOT_FOUND
    with pytest.raises(grpc.aio.AioRpcError) as notjson:
        grpc_call(
            IM,
            "Start",
            pb.ImportStartRequest(workspace_id=world.ws, job_id=_job_id(world), mapping_json="x"),
            token=world.tokens["Owner"],
        )
    assert notjson.value.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_an_export_is_started_polled_and_downloaded_with_its_signed_path(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    world = _world(people, 0)
    token = world.tokens["Owner"]
    started = grpc_call(
        EX,
        "Start",
        pb.ExportStartRequest(workspace_id=world.ws, project_id=world.project_id),
        token=token,
    ).export
    status = grpc_call(
        EX,
        "Status",
        pb.ExportStatusRequest(workspace_id=world.ws, export_id=started.id),
        token=token,
    ).export
    assert status.status == "done" and status.filename.endswith(".zip")
    assert status.download_path.startswith("/exports/download?token=")
    response = Client().get("/api/v1" + status.download_path)
    assert response.status_code == 200 and response["Content-Type"] == "application/zip"
    assert "attachment" in response["Content-Disposition"]
    archive = zipfile.ZipFile(io.BytesIO(b"".join(response.streaming_content)))
    assert "tasks.json" in archive.namelist()
    assert Client().get("/api/v1/exports/download?token=nope").status_code == 404


@pytest.mark.django_db
def test_the_tick_and_purge_commands_run() -> None:
    out = io.StringIO()
    call_command("imports_tick", stdout=out)
    call_command("purge_exports", stdout=out)
    assert "Stalled imports resumed 0" in out.getvalue() and "removed 0" in out.getvalue()


def test_cancel_discard_and_the_placeholder_calls_over_the_wire(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
) -> None:
    from infrastructure.imports import services as import_services
    from infrastructure.imports.models import ImportJob, PlaceholderAssignment, PlaceholderUser
    from infrastructure.tasks import services as task_services

    world = _world(people, 0)
    owner, token = world.workspace.created_by, world.tokens["Owner"]
    job = import_services.upload(owner, world.workspace, io.BytesIO(b"title\nA\n"), "a.csv")
    ref = {"workspace_id": world.ws, "job_id": str(job.pk)}
    ImportJob.objects.filter(pk=job.pk).update(status="running")
    stopped = grpc_call(IM, "Cancel", pb.ImportCancelRequest(**ref), token=token)
    assert stopped.job.status == "cancelled"
    ImportJob.objects.filter(pk=job.pk).update(status="uploaded")
    gone = grpc_call(IM, "Discard", pb.ImportDiscardRequest(**ref), token=token)
    assert gone.job_id == str(job.pk) and not ImportJob.objects.exists()

    holder = PlaceholderUser.objects.create(
        workspace=world.workspace, key="x@old.test", name="X", source_email="x@old.test"
    )
    made = task_services.create(owner, world.workspace, world.project_id, "Waiting")
    PlaceholderAssignment.objects.create(task_id=made.pk, placeholder=holder)
    listed = grpc_call(
        IM, "ListPlaceholders", pb.PlaceholderListRequest(workspace_id=world.ws), token=token
    )
    assert [(p.name, p.tasks) for p in listed.placeholders] == [("X", 1)]
    claim = pb.PlaceholderClaimRequest(
        workspace_id=world.ws, placeholder_id=str(holder.pk), user_id=str(world.target.pk)
    )
    assert grpc_call(IM, "ClaimPlaceholder", claim, token=token).assigned == 1


def test_progress_streams_a_running_job_until_it_stops(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from infrastructure.imports import services as import_services
    from infrastructure.imports.grpc import services as grpc_services

    world = _world(people, 0)
    owner, token = world.workspace.created_by, world.tokens["Owner"]
    job = import_services.upload(owner, world.workspace, io.BytesIO(b"title\nA\n"), "a.csv")
    real = import_services.get
    steps = iter(
        [("running", 1), ("running", 1), ("running", 3), ("done", 4)]
    )  # (status, done): a repeat is not sent twice

    def scripted(user: Any, workspace: Any, job_id: str) -> Any:
        row = real(user, workspace, job_id)
        row.status, row.done = next(steps)
        row.total = 4
        return row

    monkeypatch.setattr(import_services, "get", scripted)
    monkeypatch.setattr(grpc_services, "POLL_SECONDS", 0.01)
    messages = grpc_call(
        IM,
        "Progress",
        pb.ImportProgressRequest(workspace_id=world.ws, job_id=str(job.pk)),
        token=token,
    )
    assert [(m.job.status, m.job.done) for m in messages] == [
        ("running", 1),
        ("running", 3),
        ("done", 4),
    ]


def test_a_file_larger_than_the_server_accepts_is_refused_with_413(
    people: dict[str, Any],  # noqa: F811
    grpc_call: Any,
    settings: Any,
) -> None:
    world = _world(people, 0)
    settings.IMPORTS_MAX_BYTES = 5
    assert _upload(world, data=b"title\nabcdefghij\n").status_code == 413


@pytest.mark.parametrize(
    ("path", "extra"), [("lists", {}), ("fetch", {"list_ids": ["L1"]})]
)
def test_the_clickup_routes_need_data_manage(
    people: dict[str, Any],  # noqa: F811
    path: str,
    extra: dict[str, Any],
) -> None:
    world = _world(people, 0)
    for role in ("Viewer", "Member"):
        response = Client().post(
            f"/api/v1/imports/clickup/{path}",
            {"workspace_id": world.ws, "token": "pk_x", **extra},
            content_type="application/json",
            HTTP_AUTHORIZATION=f"Bearer {world.tokens[role]}",
        )
        assert response.status_code == 403
        assert "pk_x" not in response.content.decode()
