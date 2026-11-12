"""Offline changes sent more than once: applied once, answered the same, owned by who sent them."""

import json
import uuid
from datetime import timedelta
from typing import Any

import grpc
from django.utils import timezone

from infrastructure.comments.grpc import comments_pb2 as cpb
from infrastructure.comments.grpc import comments_pb2_grpc as cstubs
from infrastructure.comments.models import Comment
from infrastructure.sync import mutations
from infrastructure.sync.models import AppliedMutation
from infrastructure.tasks.grpc import tasks_pb2 as pb
from infrastructure.tasks.grpc import tasks_pb2_grpc as tstubs
from infrastructure.tasks.models import Task
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _refused

T = tstubs.TaskControllerStub
C = cstubs.CommentControllerStub
team = base.team  # the fixture, registered here by name
DOC = json.dumps(
    {"type": "doc", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "hi"}]}]}
)


def _new() -> str:
    return str(uuid.uuid4())


def _make(call: GrpcCall, team: dict[str, Any], who: str = "max", **fields: Any) -> Any:
    request = pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], **{"title": "Fix", **fields}
    )
    return call(T, "Create", request, token=team["tokens"][who])


def test_a_task_made_offline_keeps_the_id_the_client_chose(team: Any, grpc_call: GrpcCall) -> None:
    chosen = _new()
    made = _make(grpc_call, team, client_id=chosen, client_mutation_id=_new())
    assert made.id == chosen and made.number == 1
    assert Task.objects.get(pk=chosen).title == "Fix"


def test_sending_a_create_twice_makes_one_task_and_answers_the_same(
    team: Any, grpc_call: GrpcCall
) -> None:
    mutation, chosen = _new(), _new()
    first = _make(grpc_call, team, client_id=chosen, client_mutation_id=mutation)
    again = _make(grpc_call, team, client_id=chosen, client_mutation_id=mutation, title="Other")
    assert again.id == first.id and again.title == "Fix"  # as it is now, not as re-sent
    assert Task.objects.count() == 1 and AppliedMutation.objects.count() == 1


def test_a_task_id_already_used_is_refused_without_a_mutation_id(
    team: Any, grpc_call: GrpcCall
) -> None:
    chosen = _new()
    _make(grpc_call, team, client_id=chosen)
    refusal = _refused(grpc_call, T, "Create", pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], title="x", client_id=chosen,
    ), token=team["tokens"]["max"])  # fmt: skip
    assert refusal.code() is grpc.StatusCode.ALREADY_EXISTS
    bad = _refused(grpc_call, T, "Create", pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], title="x", client_id="nope",
    ), token=team["tokens"]["max"])  # fmt: skip
    assert bad.code() is grpc.StatusCode.INVALID_ARGUMENT


def test_an_update_sent_twice_changes_the_task_once(team: Any, grpc_call: GrpcCall) -> None:
    made = _make(grpc_call, team)
    mutation = _new()

    def send() -> Any:
        return grpc_call(
            T,
            "Update",
            pb.TaskUpdateRequest(
                workspace_id=team["ws"], project_id=team["project"], id=made.id,
                expected_version=1, title="Renamed", client_mutation_id=mutation,
            ),
            token=team["tokens"]["max"],
        )  # fmt: skip

    first, again = send(), send()
    assert (first.version, again.version) == (2, 2)  # the repeat did not bump it, nor conflict
    assert Task.objects.get(pk=made.id).version == 2


def test_an_update_without_an_id_still_conflicts_when_repeated(
    team: Any, grpc_call: GrpcCall
) -> None:
    made = _make(grpc_call, team)
    request = pb.TaskUpdateRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id,
        expected_version=1, title="Renamed",
    )  # fmt: skip
    grpc_call(T, "Update", request, token=team["tokens"]["max"])
    refusal = _refused(grpc_call, T, "Update", request, token=team["tokens"]["max"])
    assert refusal.code() is grpc.StatusCode.ABORTED


def test_a_refused_change_is_not_remembered_so_it_can_be_sent_again(
    team: Any, grpc_call: GrpcCall
) -> None:
    made = _make(grpc_call, team)
    mutation = _new()
    stale = pb.TaskUpdateRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id,
        expected_version=1, title="A", client_mutation_id=mutation,
    )  # fmt: skip
    grpc_call(T, "Update", pb.TaskUpdateRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id,
        expected_version=1, title="Theirs",
    ), token=team["tokens"]["max"])  # fmt: skip
    assert _refused(grpc_call, T, "Update", stale, token=team["tokens"]["max"]).code() is (
        grpc.StatusCode.ABORTED
    )
    assert not AppliedMutation.objects.exists()
    fixed = pb.TaskUpdateRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id,
        expected_version=2, title="A", client_mutation_id=mutation,
    )  # fmt: skip
    assert grpc_call(T, "Update", fixed, token=team["tokens"]["max"]).version == 3


def test_a_delete_sent_twice_answers_with_the_deleted_task(team: Any, grpc_call: GrpcCall) -> None:
    made = _make(grpc_call, team, who="zoe")
    mutation = _new()
    request = pb.TaskDeleteRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id, client_mutation_id=mutation
    )
    first = grpc_call(T, "Delete", request, token=team["tokens"]["zoe"])
    again = grpc_call(T, "Delete", request, token=team["tokens"]["zoe"])
    assert first.deleted_at and again.deleted_at == first.deleted_at


def test_a_mutation_id_belongs_to_whoever_used_it_first(team: Any, grpc_call: GrpcCall) -> None:
    mutation, chosen = _new(), _new()
    _make(grpc_call, team, who="max", client_id=chosen, client_mutation_id=mutation)
    refusal = _refused(grpc_call, T, "Create", pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], title="x",
        client_id=_new(), client_mutation_id=mutation,
    ), token=team["tokens"]["zoe"])  # fmt: skip
    assert refusal.code() is grpc.StatusCode.ALREADY_EXISTS  # 409
    assert Task.objects.count() == 1


def test_a_mutation_id_must_be_a_uuid(team: Any, grpc_call: GrpcCall) -> None:
    refusal = _refused(grpc_call, T, "Create", pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], title="x", client_mutation_id="no",
    ), token=team["tokens"]["max"])  # fmt: skip
    assert refusal.code() is grpc.StatusCode.INVALID_ARGUMENT
    assert not Task.objects.exists()


def test_a_comment_written_offline_is_made_once_with_its_own_id(
    team: Any, grpc_call: GrpcCall
) -> None:
    made = _make(grpc_call, team)
    mutation, chosen = _new(), _new()
    request = cpb.CommentCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], task_id=made.id, body=DOC,
        client_id=chosen, client_mutation_id=mutation,
    )  # fmt: skip
    first = grpc_call(C, "Create", request, token=team["tokens"]["max"])
    again = grpc_call(C, "Create", request, token=team["tokens"]["max"])
    assert first.id == chosen and again.id == chosen
    assert Comment.objects.count() == 1


def test_old_mutations_are_forgotten(team: Any, grpc_call: GrpcCall) -> None:
    _make(grpc_call, team, client_mutation_id=_new())
    assert mutations.purge() == 0
    assert mutations.purge(timezone.now() + timedelta(days=mutations.KEEP_DAYS + 1)) == 1


def test_a_mutation_id_is_only_known_inside_its_workspace(team: Any, grpc_call: GrpcCall) -> None:
    from infrastructure.workspaces.models import Workspace

    mutation = _new()
    _make(grpc_call, team, client_id=_new(), client_mutation_id=mutation)
    other = Workspace.objects.create(
        name="Other", slug="other-ws", created_by=Workspace.objects.get(pk=team["ws"]).created_by
    )
    ran: list[int] = []
    actor = Workspace.objects.get(pk=team["ws"]).created_by

    def apply() -> int:
        ran.append(1)
        return 1

    result = mutations.once(
        actor, other, mutation, "Task.Create", apply,
        entity=lambda r: ("task", uuid.uuid4()), current=lambda f: 0,
    )  # fmt: skip
    assert result == 1 and ran == [1]  # the same id in another workspace is a new change


def test_a_mutation_id_reused_for_a_different_call_is_refused(
    team: Any, grpc_call: GrpcCall
) -> None:
    mutation = _new()
    made = _make(grpc_call, team, client_id=_new(), client_mutation_id=mutation)
    refusal = _refused(grpc_call, T, "Delete", pb.TaskDeleteRequest(
        workspace_id=team["ws"], project_id=team["project"], id=made.id,
        client_mutation_id=mutation,
    ), token=team["tokens"]["max"])  # fmt: skip
    assert refusal.code() is grpc.StatusCode.ALREADY_EXISTS
    assert Task.objects.get(pk=made.id).deleted_at is None


def test_sending_a_create_twice_works_without_a_chosen_task_id(
    team: Any, grpc_call: GrpcCall
) -> None:
    mutation = _new()
    first = _make(grpc_call, team, client_mutation_id=mutation)
    again = _make(grpc_call, team, client_mutation_id=mutation)
    assert again.id == first.id and Task.objects.count() == 1


def test_an_id_held_by_another_workspace_is_refused_like_a_bad_one(
    team: Any, grpc_call: GrpcCall
) -> None:
    from infrastructure.comments import services as comment_services
    from infrastructure.common.errors import ApiError
    from infrastructure.tasks import services as task_services
    from infrastructure.workspaces.models import Workspace

    made = _make(grpc_call, team)
    owner = Workspace.objects.get(pk=team["ws"]).created_by
    other = Workspace.objects.create(name="Other", slug="other-two", created_by=owner)
    mine = Workspace.objects.get(pk=team["ws"])
    for service, held in ((task_services, made.id),):
        with_bad = _error(service._chosen_id, "nope", other)
        across = _error(service._chosen_id, held, other)
        assert (across.status, str(across)) == (with_bad.status, str(with_bad))
        assert _error(service._chosen_id, held, mine).status == 409  # my own: as before
    assert Comment.objects.count() == 0
    bad = _error(comment_services._chosen_id, "nope", other)
    assert bad.status == 400 and isinstance(bad, ApiError)


def _error(call: Any, *args: Any) -> Any:
    from infrastructure.common.errors import ApiError

    try:
        call(*args)
    except ApiError as e:
        return e
    raise AssertionError("expected a refusal")
