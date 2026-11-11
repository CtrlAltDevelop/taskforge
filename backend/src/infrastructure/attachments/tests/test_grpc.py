"""AttachmentController over a real gRPC server: the contract. Rules are tested on the services."""

from typing import Any

import grpc

from infrastructure.attachments import services
from infrastructure.attachments.grpc import attachments_pb2 as pb
from infrastructure.attachments.grpc import attachments_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused
from infrastructure.workspaces.models import Workspace

A = stubs.AttachmentControllerStub
team = base.team  # the fixture, registered here by name


def _attach(team: dict[str, Any], task: Any, data: bytes = b"hello", who: str = "max") -> Any:
    user = team["users"][who]
    workspace = Workspace.objects.get(pk=team["ws"])
    session = services.start_upload(user, workspace, team["project"], task.id, "a.txt", len(data))
    services.put_chunk(user, str(session.pk), 0, data)
    return services.complete(user, str(session.pk))


def test_the_list_and_usage_round_trip(
    team: Any, grpc_call: GrpcCall, tmp_path: Any, settings: Any
) -> None:
    settings.MEDIA_ROOT = str(tmp_path)
    settings.ATTACHMENT_WORKSPACE_QUOTA_BYTES = 1000
    task = _create(grpc_call, team, title="T")
    made = _attach(team, task, b"hello world")

    listed = grpc_call(
        A,
        "List",
        pb.AttachmentListRequest(
            workspace_id=team["ws"], project_id=team["project"], task_id=task.id
        ),
        token=team["tokens"]["vic"],
    )
    usage = grpc_call(
        A, "Usage", pb.UsageRequest(workspace_id=team["ws"]), token=team["tokens"]["vic"]
    )

    [got] = listed.attachments
    assert (got.id, got.filename, got.mime, got.size, got.has_thumb) == (
        str(made.pk),
        "a.txt",
        "text/plain",
        11,
        False,
    )
    assert got.uploader_id == str(team["users"]["max"].pk) and got.created_at
    assert (usage.used_bytes, usage.quota_bytes, usage.file_count) == (11, 1000, 1)
    assert usage.max_file_bytes > 0


def test_delete_is_the_uploaders_or_a_managers(
    team: Any, grpc_call: GrpcCall, tmp_path: Any, settings: Any
) -> None:
    settings.MEDIA_ROOT = str(tmp_path)
    task = _create(grpc_call, team, title="T")
    made = _attach(team, task)
    request = pb.AttachmentDeleteRequest(
        workspace_id=team["ws"], project_id=team["project"], id=str(made.pk)
    )

    denied = _refused(grpc_call, A, "Delete", request, token=team["tokens"]["vic"])
    assert denied.code() is grpc.StatusCode.PERMISSION_DENIED

    gone = grpc_call(A, "Delete", request, token=team["tokens"]["max"])
    assert gone.id == str(made.pk)
    listed = grpc_call(
        A,
        "List",
        pb.AttachmentListRequest(
            workspace_id=team["ws"], project_id=team["project"], task_id=task.id
        ),
        token=team["tokens"]["max"],
    )
    assert list(listed.attachments) == []


def test_a_stranger_is_refused_and_an_unknown_file_is_not_found(
    team: Any, grpc_call: GrpcCall
) -> None:
    refused = _refused(
        grpc_call, A, "Usage", pb.UsageRequest(workspace_id=team["ws"]), token=team["tokens"]["eve"]
    )
    missing = _refused(
        grpc_call,
        A,
        "Delete",
        pb.AttachmentDeleteRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            id="00000000-0000-0000-0000-000000000000",
        ),
        token=team["tokens"]["max"],
    )

    assert refused.code() is grpc.StatusCode.PERMISSION_DENIED
    assert missing.code() is grpc.StatusCode.NOT_FOUND
