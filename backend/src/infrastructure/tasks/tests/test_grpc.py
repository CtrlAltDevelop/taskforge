"""TaskController over a real gRPC server. Rules are tested on the services; this checks the
contract: field names, status codes, titles, the stream, the payload."""

import json
from collections.abc import Callable
from typing import Any

import grpc
import pytest
from django.contrib.auth import get_user_model

from infrastructure.projects import services as projects
from infrastructure.tasks.grpc import tasks_pb2 as pb
from infrastructure.tasks.grpc import tasks_pb2_grpc as stubs
from infrastructure.workflows.models import Status
from infrastructure.workspaces import services as workspace_services
from infrastructure.workspaces.tests.test_grpc import _token

T = stubs.TaskControllerStub
GrpcCall = Callable[..., Any]
NAMES = ("zoe", "max", "vic", "eve")  # owner, member, viewer, outsider
DOC = json.dumps({"type": "doc", "content": [{"type": "paragraph"}]})


@pytest.fixture
def team(transactional_db: None, add_member: Any) -> dict[str, Any]:
    tokens = {n: _token(n) for n in NAMES}
    users = {n: get_user_model().objects.get(username=n) for n in NAMES}
    workspace = workspace_services.create(users["zoe"], "Acme", "acme")
    workspace_services.create(users["eve"], "Other", "other")
    add_member(workspace, users["max"], "Member")
    add_member(workspace, users["vic"], "Viewer")
    project = projects.create(users["zoe"], workspace, "Web", "WEB").project
    return {"ws": str(workspace.id), "project": str(project.pk), "tokens": tokens, "users": users}


def _refused(call: GrpcCall, *args: Any, **kwargs: Any) -> grpc.aio.AioRpcError:
    with pytest.raises(grpc.aio.AioRpcError) as refusal:
        call(*args, **kwargs)
    return refusal.value


def _create(call: GrpcCall, team: dict[str, Any], who: str = "max", **fields: Any) -> Any:
    request = pb.TaskCreateRequest(
        workspace_id=team["ws"], project_id=team["project"], **{"title": "Fix", **fields}
    )
    return call(T, "Create", request, token=team["tokens"][who])


def test_create_and_get_round_trip_with_the_full_payload(team: Any, grpc_call: GrpcCall) -> None:
    assignee = str(team["users"]["max"].pk)
    created = _create(
        grpc_call,
        team,
        description=DOC,
        priority="high",
        start_date="2026-03-01",
        due_date="2026-03-05",
        assignee_ids=[assignee],
    )

    got = grpc_call(
        T,
        "Get",
        pb.TaskGetRequest(workspace_id=team["ws"], project_id=team["project"], id=created.id),
        token=team["tokens"]["vic"],
    )

    assert got == created
    assert (got.display_id, got.number, got.version) == ("WEB-1", 1, 1)
    assert (got.status_name, got.status_category) == ("To do", "not_started")
    assert got.status == str(Status.objects.get(project_id=team["project"], name="To do").pk)
    assert got.priority == "high" and got.due_date == "2026-03-05"
    assert list(got.assignee_ids) == [assignee]
    assert json.loads(got.description) == json.loads(DOC)
    assert got.deleted_at == "" and got.position and got.created_by == assignee


def test_update_sends_only_the_fields_in_the_mask(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, priority="low", due_date="2026-03-05")
    request = pb.TaskUpdateRequest(
        workspace_id=team["ws"],
        project_id=team["project"],
        id=created.id,
        expected_version=1,
        title="New",
        due_date="",  # present and empty: clears the date
    )

    updated = grpc_call(T, "Update", request, token=team["tokens"]["max"])

    assert (updated.title, updated.priority, updated.due_date, updated.version) == (
        "New",
        "low",
        "",
        2,
    )


def test_update_can_replace_and_clear_assignees(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team, assignee_ids=[str(team["users"]["max"].pk)])
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}

    cleared = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, set_assignees=True),
        token=team["tokens"]["max"],
    )
    untouched = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=2, title="Again"),
        token=team["tokens"]["max"],
    )

    assert list(cleared.assignee_ids) == [] and list(untouched.assignee_ids) == []


def test_same_field_conflict_is_aborted_with_the_current_value(
    team: Any, grpc_call: GrpcCall
) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}
    grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, title="Theirs"),
        token=team["tokens"]["zoe"],
    )

    merged = grpc_call(
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, priority="urgent"),
        token=team["tokens"]["max"],
    )
    refusal = _refused(
        grpc_call,
        T,
        "Update",
        pb.TaskUpdateRequest(**base, expected_version=1, title="Mine"),
        token=team["tokens"]["max"],
    )

    assert merged.title == "Theirs" and merged.priority == "urgent"
    assert refusal.code() == grpc.StatusCode.ABORTED
    assert refusal.details().startswith("VERSION_CONFLICT")
    trailers = {k: v for k, v in refusal.trailing_metadata()}
    assert trailers["x-error-field-bin"] == b"title"
    assert trailers["x-error-current-bin"] == b"Theirs"


def test_delete_and_restore(team: Any, grpc_call: GrpcCall) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"], "id": created.id}

    gone = grpc_call(T, "Delete", pb.TaskDeleteRequest(**base), token=team["tokens"]["max"])
    missing = _refused(grpc_call, T, "Get", pb.TaskGetRequest(**base), token=team["tokens"]["max"])
    back = grpc_call(T, "Restore", pb.TaskRestoreRequest(**base), token=team["tokens"]["max"])

    assert gone.deleted_at != "" and back.deleted_at == "" and back.version == 3
    assert missing.code() == grpc.StatusCode.NOT_FOUND


def test_list_streams_every_task_in_order_across_pages(team: Any, grpc_call: GrpcCall) -> None:
    for i in range(7):
        _create(grpc_call, team, title=f"t{i}")

    streamed = grpc_call(
        T,
        "List",
        pb.TaskListRequest(workspace_id=team["ws"], project_id=team["project"], page_size=3),
        token=team["tokens"]["vic"],
    )
    done = grpc_call(
        T,
        "List",
        pb.TaskListRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            status=str(Status.objects.get(project_id=team["project"], name="Done").pk),
        ),
        token=team["tokens"]["vic"],
    )

    assert [t.title for t in streamed] == [f"t{i}" for i in range(7)]
    assert [t.number for t in streamed] == list(range(1, 8))
    assert done == []


def test_refusals_map_to_the_usual_statuses(team: Any, grpc_call: GrpcCall) -> None:
    request = pb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title="x")
    viewer = _refused(grpc_call, T, "Create", request, token=team["tokens"]["vic"])
    stranger = _refused(grpc_call, T, "Create", request, token=team["tokens"]["eve"])
    anonymous = _refused(grpc_call, T, "Create", request)
    invalid = _refused(
        grpc_call,
        T,
        "Create",
        pb.TaskCreateRequest(workspace_id=team["ws"], project_id=team["project"], title=" "),
        token=team["tokens"]["max"],
    )
    stream = _refused(
        grpc_call,
        T,
        "List",
        pb.TaskListRequest(workspace_id=team["ws"], project_id="nope"),
        token=team["tokens"]["vic"],
    )

    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED
    assert dict(viewer.trailing_metadata())["x-error-permission-bin"] == b"task.create"
    assert stranger.code() == grpc.StatusCode.PERMISSION_DENIED
    assert anonymous.code() == grpc.StatusCode.UNAUTHENTICATED
    assert invalid.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert stream.code() == grpc.StatusCode.NOT_FOUND


def test_list_trash_returns_deleted_tasks_and_needs_the_delete_permission(
    team: Any, grpc_call: GrpcCall
) -> None:
    created = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"]}
    grpc_call(T, "Delete", pb.TaskDeleteRequest(**base, id=created.id), token=team["tokens"]["max"])

    trash = grpc_call(T, "ListTrash", pb.TaskListTrashRequest(**base), token=team["tokens"]["max"])
    refused = _refused(
        grpc_call, T, "ListTrash", pb.TaskListTrashRequest(**base), token=team["tokens"]["vic"]
    )

    assert [t.id for t in trash.tasks] == [created.id]
    assert trash.tasks[0].deleted_at != ""
    assert refused.code() == grpc.StatusCode.PERMISSION_DENIED


def _sub(
    call: GrpcCall, team: dict[str, Any], title: str, parent: Any = None, who: str = "max"
) -> Any:
    return _create(call, team, who, title=title, parent_id=parent.id if parent else "")


def _base(team: dict[str, Any], task: Any) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "project_id": team["project"], "id": task.id}


def test_subtasks_carry_parent_depth_and_progress_over_the_wire(
    team: Any, grpc_call: GrpcCall
) -> None:
    parent = _sub(grpc_call, team, "P")
    child = _sub(grpc_call, team, "C", parent)
    _sub(grpc_call, team, "G", child)

    got = grpc_call(T, "Get", pb.TaskGetRequest(**_base(team, parent)), token=team["tokens"]["vic"])
    kid = grpc_call(T, "Get", pb.TaskGetRequest(**_base(team, child)), token=team["tokens"]["vic"])

    assert (parent.parent_id, parent.depth) == ("", 0)
    assert (child.parent_id, child.depth) == (parent.id, 1)
    assert (got.progress_done, got.progress_total) == (0, 2)
    assert (kid.progress_done, kid.progress_total) == (0, 1)


def test_list_streams_the_tree_only_when_asked(team: Any, grpc_call: GrpcCall) -> None:
    a = _sub(grpc_call, team, "A")
    a1 = _sub(grpc_call, team, "A1", a)
    b = _sub(grpc_call, team, "B")
    request = dict(workspace_id=team["ws"], project_id=team["project"])

    top = grpc_call(T, "List", pb.TaskListRequest(**request), token=team["tokens"]["vic"])
    every = grpc_call(
        T,
        "List",
        pb.TaskListRequest(**request, include_subtasks=True, page_size=2),
        token=team["tokens"]["vic"],
    )

    assert [t.id for t in top] == [a.id, b.id]
    assert [t.id for t in every] == [a.id, a1.id, b.id]


def test_set_parent_and_list_children(team: Any, grpc_call: GrpcCall) -> None:
    a, b = _sub(grpc_call, team, "A"), _sub(grpc_call, team, "B")

    moved = grpc_call(
        T,
        "SetParent",
        pb.TaskSetParentRequest(**_base(team, b), expected_version=1, parent_id=a.id),
        token=team["tokens"]["max"],
    )
    kids = grpc_call(
        T, "ListChildren", pb.TaskListChildrenRequest(**_base(team, a)), token=team["tokens"]["vic"]
    )
    cycle = _refused(
        grpc_call,
        T,
        "SetParent",
        pb.TaskSetParentRequest(**_base(team, a), expected_version=1, parent_id=b.id),
        token=team["tokens"]["max"],
    )
    stale = _refused(
        grpc_call,
        T,
        "SetParent",
        pb.TaskSetParentRequest(**_base(team, b), expected_version=1, parent_id=""),
        token=team["tokens"]["max"],
    )
    viewer = _refused(
        grpc_call,
        T,
        "SetParent",
        pb.TaskSetParentRequest(**_base(team, a), expected_version=1, parent_id=""),
        token=team["tokens"]["vic"],
    )

    assert (moved.parent_id, moved.depth, moved.version) == (a.id, 1, 2)
    assert [t.id for t in kids.tasks] == [b.id]
    assert cycle.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert cycle.details().startswith("SUBTASK_CYCLE")
    assert stale.code() == grpc.StatusCode.ABORTED
    assert dict(stale.trailing_metadata())["x-error-field-bin"] == b"parent"
    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED


def test_deleting_a_parent_needs_a_mode(team: Any, grpc_call: GrpcCall) -> None:
    parent = _sub(grpc_call, team, "P")
    kid = _sub(grpc_call, team, "K", parent)
    token = team["tokens"]["max"]

    refused = _refused(
        grpc_call, T, "Delete", pb.TaskDeleteRequest(**_base(team, parent)), token=token
    )
    promoted = grpc_call(
        T, "Delete", pb.TaskDeleteRequest(**_base(team, parent), mode="promote"), token=token
    )
    after = grpc_call(T, "Get", pb.TaskGetRequest(**_base(team, kid)), token=token)

    assert refused.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert refused.details().startswith("HAS_SUBTASKS")
    assert dict(refused.trailing_metadata())["x-error-count-bin"] == b"1"
    assert promoted.deleted_at != "" and (after.parent_id, after.depth) == ("", 0)


def test_move_can_take_the_open_subtasks_along(team: Any, grpc_call: GrpcCall) -> None:
    parent = _sub(grpc_call, team, "P")
    kid = _sub(grpc_call, team, "K", parent)
    done = str(Status.objects.get(project_id=team["project"], name="Done").pk)
    token = team["tokens"]["max"]

    moved = grpc_call(
        T,
        "Move",
        pb.TaskMoveRequest(
            **_base(team, parent), expected_version=1, status=done, include_subtasks=True
        ),
        token=token,
    )
    sub = grpc_call(T, "Get", pb.TaskGetRequest(**_base(team, kid)), token=token)

    assert moved.status_name == "Done" and sub.status_name == "Done"
    assert (moved.progress_done, moved.progress_total) == (1, 1)


def test_list_sorts_groups_and_pages_by_the_request(team: Any, grpc_call: GrpcCall) -> None:
    for title, due in (("c", "2026-03-03"), ("a", ""), ("b", "2026-03-01")):
        _create(grpc_call, team, title=title, due_date=due)

    def titles(**kw: Any) -> list[str]:
        request = pb.TaskListRequest(
            workspace_id=team["ws"], project_id=team["project"], page_size=1, **kw
        )
        return [t.title for t in grpc_call(T, "List", request, token=team["tokens"]["vic"])]

    assert titles(sort=[pb.SortKey(key="due_date")]) == ["b", "c", "a"]
    assert titles(sort=[pb.SortKey(key="title", desc=True)]) == ["c", "b", "a"]
    assert titles(group_by="priority") == ["c", "a", "b"]


def test_a_bad_sort_is_invalid_argument(team: Any, grpc_call: GrpcCall) -> None:
    refused = _refused(
        grpc_call,
        T,
        "List",
        pb.TaskListRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            sort=[pb.SortKey(key="nope")],
        ),
        token=team["tokens"]["vic"],
    )

    assert refused.code() == grpc.StatusCode.INVALID_ARGUMENT


def test_group_counts(team: Any, grpc_call: GrpcCall) -> None:
    for priority in ("high", "high", "low"):
        _create(grpc_call, team, priority=priority)

    counts = grpc_call(
        T,
        "GroupCounts",
        pb.TaskGroupCountsRequest(
            workspace_id=team["ws"], project_id=team["project"], group_by="priority"
        ),
        token=team["tokens"]["vic"],
    )

    assert [(g.key, g.count) for g in counts.groups] == [("high", 2), ("low", 1)]


def test_bulk_update_streams_one_result_per_task(team: Any, grpc_call: GrpcCall) -> None:
    ids = [_create(grpc_call, team, title=f"t{i}").id for i in range(3)]

    results = grpc_call(
        T,
        "BulkUpdate",
        pb.TaskBulkUpdateRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            ids=[*ids, "not-a-task"],
            priority="urgent",
        ),
        token=team["tokens"]["max"],
    )

    assert [r.id for r in results] == [*ids, "not-a-task"]
    assert [r.ok for r in results] == [True, True, True, False]
    assert results[0].task.priority == "urgent" and results[0].task.version == 2
    assert results[3].code == "NOT_FOUND" and results[3].task.id == ""


def test_bulk_update_can_clear_the_assignees_and_delete(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team, assignee_ids=[str(team["users"]["max"].pk)])
    base = {"workspace_id": team["ws"], "project_id": team["project"], "ids": [task.id]}

    [cleared] = grpc_call(
        T,
        "BulkUpdate",
        pb.TaskBulkUpdateRequest(**base, set_assignees=True),
        token=team["tokens"]["max"],
    )
    [gone] = grpc_call(
        T,
        "BulkUpdate",
        pb.TaskBulkUpdateRequest(**base, delete=True),
        token=team["tokens"]["max"],
    )

    assert cleared.ok and list(cleared.task.assignee_ids) == []
    assert gone.ok and gone.task.deleted_at != ""


def test_a_bulk_call_is_refused_whole_when_it_is_malformed_or_not_allowed(
    team: Any, grpc_call: GrpcCall
) -> None:
    task = _create(grpc_call, team)
    base = {"workspace_id": team["ws"], "project_id": team["project"], "ids": [task.id]}

    nothing = _refused(
        grpc_call, T, "BulkUpdate", pb.TaskBulkUpdateRequest(**base), token=team["tokens"]["max"]
    )
    viewer = _refused(
        grpc_call,
        T,
        "BulkUpdate",
        pb.TaskBulkUpdateRequest(**base, priority="low"),
        token=team["tokens"]["vic"],
    )

    assert nothing.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED


B = stubs.BoardControllerStub


def _board(call: GrpcCall, team: dict[str, Any], who: str = "vic", **fields: Any) -> Any:
    request = pb.BoardGetRequest(workspace_id=team["ws"], project_id=team["project"], **fields)
    return call(B, "Get", request, token=team["tokens"][who])


def test_the_board_answers_columns_with_counts_and_cards(team: Any, grpc_call: GrpcCall) -> None:
    _create(grpc_call, team, title="a")
    _create(grpc_call, team, title="b", priority="high")

    [lane] = _board(grpc_call, team).lanes

    assert [(c.name, c.count) for c in lane.columns] == [
        ("To do", 2),
        ("In progress", 0),
        ("Done", 0),
    ]
    assert [t.title for t in lane.columns[0].tasks] == ["a", "b"]


def test_list_column_pages_and_move_places_the_card(team: Any, grpc_call: GrpcCall) -> None:
    ids = [_create(grpc_call, team, title=f"t{i}").id for i in range(4)]
    [lane] = _board(grpc_call, team, page_size=2).lanes
    todo = lane.columns[0]
    assert len(todo.tasks) == 2 and todo.cursor

    rest = grpc_call(
        B,
        "ListColumn",
        pb.BoardListColumnRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            column=todo.key,
            cursor=todo.cursor,
            page_size=5,
        ),
        token=team["tokens"]["vic"],
    )
    assert [t.title for t in rest.tasks] == ["t2", "t3"] and rest.cursor == ""

    moved = grpc_call(
        B,
        "Move",
        pb.BoardMoveRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            id=ids[3],
            expected_version=1,
            column=todo.key,
            before_id=ids[0],
        ),
        token=team["tokens"]["max"],
    )

    assert moved.id == ids[3] and moved.version == 2
    [after] = _board(grpc_call, team).lanes
    assert [t.title for t in after.columns[0].tasks] == ["t3", "t0", "t1", "t2"]


def test_board_refusals_map_to_the_usual_statuses(team: Any, grpc_call: GrpcCall) -> None:
    task = _create(grpc_call, team)
    move = pb.BoardMoveRequest(
        workspace_id=team["ws"], project_id=team["project"], id=task.id, expected_version=1
    )

    assert _refused(grpc_call, B, "Move", move, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.PERMISSION_DENIED
    )
    assert _refused(
        grpc_call,
        B,
        "Get",
        pb.BoardGetRequest(workspace_id=team["ws"], project_id=team["project"], group_by="title"),
        token=team["tokens"]["vic"],
    ).code() is (grpc.StatusCode.INVALID_ARGUMENT)
    assert _refused(
        grpc_call,
        B,
        "Get",
        pb.BoardGetRequest(workspace_id=team["ws"], project_id=team["project"]),
        token=team["tokens"]["eve"],
    ).code() in (grpc.StatusCode.PERMISSION_DENIED, grpc.StatusCode.NOT_FOUND)


CAL = stubs.CalendarControllerStub


def test_the_calendar_streams_the_tasks_of_a_range(team: Any, grpc_call: GrpcCall) -> None:
    _create(grpc_call, team, title="in", due_date="2026-11-05")
    _create(grpc_call, team, title="out", due_date="2026-12-25")

    tasks = grpc_call(
        CAL,
        "ListRange",
        pb.CalendarRangeRequest(
            workspace_id=team["ws"],
            project_id=team["project"],
            range_start="2026-11-01",
            range_end="2026-11-30",
            include_done=True,
        ),
        token=team["tokens"]["vic"],
    )

    assert [(t.title, t.due_date) for t in tasks] == [("in", "2026-11-05")]


def test_the_tray_pages_and_a_bad_range_is_invalid_argument(team: Any, grpc_call: GrpcCall) -> None:
    for n in range(3):
        _create(grpc_call, team, title=f"t{n}")
    request = pb.CalendarTrayRequest(
        workspace_id=team["ws"], project_id=team["project"], page_size=2
    )

    first = grpc_call(CAL, "ListUnscheduled", request, token=team["tokens"]["vic"])
    request.cursor = first.cursor
    second = grpc_call(CAL, "ListUnscheduled", request, token=team["tokens"]["vic"])

    assert [t.title for t in first.tasks] == ["t0", "t1"] and first.cursor
    assert [t.title for t in second.tasks] == ["t2"] and second.cursor == ""
    bad = pb.CalendarRangeRequest(
        workspace_id=team["ws"], project_id=team["project"], range_start="x", range_end="y"
    )
    assert _refused(grpc_call, CAL, "ListRange", bad, token=team["tokens"]["vic"]).code() is (
        grpc.StatusCode.INVALID_ARGUMENT
    )
