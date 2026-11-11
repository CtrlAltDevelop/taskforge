"""The docs controller over a real gRPC server: the contract."""

import json
from typing import Any

import grpc

from infrastructure.docs.grpc import wikidocs_pb2 as pb
from infrastructure.docs.grpc import wikidocs_pb2_grpc as stubs
from infrastructure.tasks.tests import test_grpc as base
from infrastructure.tasks.tests.test_grpc import GrpcCall, _create, _refused

team = base.team
D = stubs.DocControllerStub


def para(text: str) -> str:
    return json.dumps([{"type": "paragraph", "content": [{"type": "text", "text": text}]}])


def make(
    call: GrpcCall, team: dict[str, Any], title: str = "Spec", who: str = "max", **kw: Any
) -> Any:
    request = pb.DocCreateRequest(workspace_id=team["ws"], title=title, **kw)
    return call(D, "Create", request, token=team["tokens"][who])


def ref(team: dict[str, Any], doc: Any) -> dict[str, Any]:
    return {"workspace_id": team["ws"], "doc_id": doc.doc.id}


def test_pages_round_trip_through_every_call(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    root = make(grpc_call, team, "Root", blocks_json=para("hello"))
    child = make(grpc_call, team, "Child", parent_id=root.doc.id)
    other = make(grpc_call, team, "Other")

    got = grpc_call(D, "Get", pb.DocGetRequest(**ref(team, root)), token=team["tokens"]["vic"])
    updated = grpc_call(
        D,
        "Update",
        pb.DocUpdateRequest(
            **ref(team, root),
            expected_version=1,
            fields=["title", "blocks"],
            title="Root 2",
            blocks_json=para("bye"),
        ),
        token=token,
    )
    moved = grpc_call(
        D,
        "Move",
        pb.DocMoveRequest(**ref(team, other), parent_id=child.doc.id, index=0),
        token=token,
    )
    tree = grpc_call(D, "Tree", pb.DocTreeRequest(workspace_id=team["ws"]), token=token)
    exported = grpc_call(
        D, "ExportMarkdown", pb.DocExportRequest(**ref(team, updated)), token=token
    )

    assert got.can_edit is False and json.loads(got.blocks_json)[0]["content"][0]["text"] == "hello"
    assert (updated.version, updated.doc.title) == (2, "Root 2")
    assert moved.doc.parent_id == child.doc.id
    assert [d.title for d in tree.docs] == ["Root 2", "Child", "Other"]
    assert (exported.title, exported.markdown) == ("Root 2", "bye\n")


def test_stale_save_is_aborted_with_the_server_copy_in_the_trailers(
    team: Any, grpc_call: GrpcCall
) -> None:
    token = team["tokens"]["max"]
    doc = make(grpc_call, team)
    grpc_call(
        D,
        "Update",
        pb.DocUpdateRequest(
            **ref(team, doc), expected_version=1, fields=["blocks"], blocks_json=para("new")
        ),
        token=token,
    )

    refusal = _refused(
        grpc_call,
        D,
        "Update",
        pb.DocUpdateRequest(
            **ref(team, doc), expected_version=1, fields=["blocks"], blocks_json=para("mine")
        ),
        token=token,
    )

    assert refusal.code() == grpc.StatusCode.ABORTED
    trailers = {k: v for k, v in refusal.trailing_metadata()}
    assert trailers["x-error-version-bin"] == b"2"
    assert json.loads(trailers["x-error-blocks-bin"])[0]["content"][0]["text"] == "new"


def test_refusals(team: Any, grpc_call: GrpcCall) -> None:
    doc = make(grpc_call, team)
    vic, eve = team["tokens"]["vic"], team["tokens"]["eve"]

    viewer = _refused(grpc_call, D, "Archive", pb.DocArchiveRequest(**ref(team, doc)), token=vic)
    outsider = _refused(grpc_call, D, "Get", pb.DocGetRequest(**ref(team, doc)), token=eve)
    bad = _refused(
        grpc_call,
        D,
        "Create",
        pb.DocCreateRequest(workspace_id=team["ws"], title="x", blocks_json="{"),
        token=team["tokens"]["max"],
    )
    field = _refused(
        grpc_call,
        D,
        "Update",
        pb.DocUpdateRequest(**ref(team, doc), expected_version=1, fields=["restricted"]),
        token=team["tokens"]["max"],
    )
    missing = _refused(
        grpc_call,
        D,
        "Get",
        pb.DocGetRequest(workspace_id=team["ws"], doc_id="00000000-0000-0000-0000-000000000000"),
        token=vic,
    )

    assert viewer.code() == grpc.StatusCode.PERMISSION_DENIED
    assert outsider.code() == grpc.StatusCode.PERMISSION_DENIED
    assert bad.code() == grpc.StatusCode.INVALID_ARGUMENT and "DOC_INVALID" in bad.details()
    assert field.code() == grpc.StatusCode.INVALID_ARGUMENT
    assert missing.code() == grpc.StatusCode.NOT_FOUND


def test_archive_restore_history_and_access(team: Any, grpc_call: GrpcCall) -> None:
    owner, member = team["tokens"]["zoe"], team["tokens"]["max"]
    doc = make(grpc_call, team, blocks_json=para("one"))
    revisions = grpc_call(
        D, "RevisionList", pb.DocRevisionListRequest(**ref(team, doc)), token=member
    )
    peek = grpc_call(
        D,
        "RevisionGet",
        pb.DocRevisionGetRequest(**ref(team, doc), revision_id=revisions.revisions[0].id),
        token=member,
    )
    grpc_call(
        D,
        "Update",
        pb.DocUpdateRequest(
            **ref(team, doc), expected_version=1, fields=["blocks"], blocks_json=para("two")
        ),
        token=owner,
    )
    restored = grpc_call(
        D,
        "RevisionRestore",
        pb.DocRevisionRestoreRequest(
            **ref(team, doc), revision_id=revisions.revisions[0].id, expected_version=2
        ),
        token=member,
    )
    archived = grpc_call(D, "Archive", pb.DocArchiveRequest(**ref(team, doc)), token=member)
    back = grpc_call(D, "Restore", pb.DocRestoreRequest(**ref(team, doc)), token=member)
    restricted = grpc_call(
        D,
        "SetAccess",
        pb.DocSetAccessRequest(**ref(team, doc), restricted=True, user_ids=[]),
        token=owner,
    )
    hidden = _refused(
        grpc_call, D, "Get", pb.DocGetRequest(**ref(team, doc)), token=team["tokens"]["vic"]
    )

    assert (
        len(revisions.revisions) == 1
        and json.loads(peek.blocks_json)[0]["content"][0]["text"] == "one"
    )
    assert (
        json.loads(restored.blocks_json)[0]["content"][0]["text"] == "one" and restored.version == 3
    )
    assert archived.doc.archived and not back.doc.archived
    assert restricted.doc.restricted and restricted.can_manage
    assert hidden.code() == grpc.StatusCode.NOT_FOUND


def test_links_cards_and_presence(team: Any, grpc_call: GrpcCall) -> None:
    token = team["tokens"]["max"]
    task = _create(grpc_call, team, who="zoe", title="Fix")
    target = make(grpc_call, team, "Target")
    blocks = json.dumps(
        [
            {"type": "task_card", "attrs": {"task_id": task.id}},
            {
                "type": "paragraph",
                "content": [{"type": "mention", "attrs": {"doc_id": target.doc.id, "label": "T"}}],
            },
        ]
    )
    source = make(grpc_call, team, "Source", blocks_json=blocks)
    manual = make(grpc_call, team, "Manual")
    task_ref = {"workspace_id": team["ws"], "project_id": team["project"], "task_id": task.id}

    backlinks = grpc_call(D, "Backlinks", pb.DocBacklinksRequest(**ref(team, target)), token=token)
    linked = grpc_call(
        D, "LinkTask", pb.DocLinkTaskRequest(**task_ref, doc_id=manual.doc.id), token=token
    )
    unlinked = grpc_call(
        D, "UnlinkTask", pb.DocLinkTaskRequest(**task_ref, doc_id=manual.doc.id), token=token
    )
    related = grpc_call(D, "ForTask", pb.DocForTaskRequest(**task_ref), token=token)
    cards = grpc_call(
        D,
        "TaskCards",
        pb.DocTaskCardsRequest(
            workspace_id=team["ws"], task_ids=[task.id, "00000000-0000-0000-0000-000000000000"]
        ),
        token=token,
    )
    presence = grpc_call(
        D, "Presence", pb.DocPresenceRequest(**ref(team, source), state="editing"), token=token
    )
    got = grpc_call(D, "Get", pb.DocGetRequest(**ref(team, source)), token=token)

    assert [d.title for d in backlinks.docs] == ["Source"]
    assert {(d.doc.title, d.kind) for d in linked.docs} == {
        ("Source", "embedded"),
        ("Manual", "related"),
    }
    assert [(d.doc.title, d.kind) for d in unlinked.docs] == [("Source", "embedded")]
    assert [d.kind for d in related.docs] == ["embedded"]
    assert [(c.hidden, c.key, c.title) for c in cards.cards] == [
        (False, "WEB-1", "Fix"),
        (True, "", ""),
    ]
    assert [(e.user_id, e.editing) for e in presence.editing] == [
        (str(team["users"]["max"].pk), True)
    ]
    assert got.cards[0].status_name == "To do" and got.editing[0].editing


def test_search_returns_pages_in_the_docs_group(team: Any, grpc_call: GrpcCall) -> None:
    from infrastructure.search.grpc import search_pb2 as spb
    from infrastructure.search.grpc import search_pb2_grpc as sstubs

    make(grpc_call, team, "Quarterly zebra plan")

    found = grpc_call(
        sstubs.SearchControllerStub,
        "Query",
        spb.SearchQueryRequest(workspace_id=team["ws"], text="zebra", types=["doc"]),
        token=team["tokens"]["vic"],
    )

    assert [h.title for h in found.docs] == ["Quarterly zebra plan"]
    assert found.docs[0].kind == "doc" and not found.tasks
