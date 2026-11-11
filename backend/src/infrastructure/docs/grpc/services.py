"""Docs over gRPC: ``DocController``. Rules are in ``infrastructure.docs``.

``Tree`` lists the pages the caller may open (of the workspace, or of ``project_id``), in tree
order, archived ones only when asked. ``Get`` / ``Create`` / ``Update`` / ``Move`` / ``Archive`` /
``Restore`` / ``SetAccess`` / ``RevisionRestore`` answer with a ``DocAnswer``: the page, its body
(``blocks_json``, absent for Move/Archive/Restore/SetAccess), the ``cards`` its task cards resolve
to for *this* caller (``hidden`` ones are kept in the body), who is ``editing`` now and what the
caller may do (``can_edit``, ``can_manage``). ``Update`` names what it changes in ``fields``
(title, icon, blocks) and carries the ``expected_version`` the editor loaded: a stale one is
ABORTED (VERSION_CONFLICT) with trailers ``x-error-version-bin`` and, when the body is small,
``x-error-blocks-bin`` (else ``x-error-blocks_omitted-bin``) for the merge dialog; saving the same
content again is not a save. INVALID_ARGUMENT for a bad body or value (DOC_INVALID), a stale parent
or archived page is ALREADY_EXISTS (DOC_ARCHIVED / DOC_CYCLE). ``RevisionList`` / ``RevisionGet``
read the history, ``Backlinks`` the pages mentioning one, ``ExportMarkdown`` gives Markdown,
``ForTask`` / ``LinkTask`` / ``UnlinkTask`` the "Related docs" of a task, ``TaskCards`` resolves
cards, ``Presence`` (state viewing | editing | left; repeat every ~20 s) is the "editing now" hint.
A page the caller may not open is NOT_FOUND, never PERMISSION_DENIED.
"""

import json
from collections.abc import Callable
from typing import Any

from asgiref.sync import sync_to_async
from django_socio_grpc import generics
from django_socio_grpc.decorators import grpc_action

from infrastructure.common.errors import ApiError
from infrastructure.common.grpc.errors import action, require_caller
from infrastructure.common.identity import grpc_caller
from infrastructure.docs import markdown, services
from infrastructure.docs.grpc.serializers import (
    DocNode,
    Editor,
    RelatedDoc,
    RevisionInfo,
    TaskCard,
)
from infrastructure.workspaces.scoping import require_workspace

WS = {"name": "workspace_id", "type": "string"}
DOC = [WS, {"name": "doc_id", "type": "string"}]
TASK = [
    WS,
    {"name": "project_id", "type": "string"},
    {"name": "task_id", "type": "string"},
    {"name": "doc_id", "type": "string"},
]
ANSWER = [
    {"name": "doc", "type": DocNode},
    {"name": "version", "type": "int32"},
    {"name": "schema_version", "type": "int32"},
    {"name": "blocks_json", "type": "string"},
    {"name": "updated_by", "type": "string"},
    {"name": "editing", "cardinality": "repeated", "type": Editor},
    {"name": "cards", "cardinality": "repeated", "type": TaskCard},
    {"name": "can_edit", "type": "bool"},
    {"name": "can_manage", "type": "bool"},
    {"name": "access_user_ids", "cardinality": "repeated", "type": "string"},
]
TREE = [{"name": "docs", "cardinality": "repeated", "type": DocNode}]
RELATED = [{"name": "docs", "cardinality": "repeated", "type": RelatedDoc}]


def _pb() -> Any:
    from infrastructure.docs.grpc import wikidocs_pb2

    return wikidocs_pb2


def _iso(value: Any) -> str:
    return value.isoformat() if value else ""


def node(doc: Any) -> Any:
    return _pb().DocNode(
        id=str(doc.pk),
        workspace_id=str(doc.workspace_id),
        project_id=str(doc.project_id or ""),
        parent_id=str(doc.parent_id or ""),
        title=doc.title,
        icon=doc.icon,
        position=doc.position,
        restricted=doc.restricted,
        archived=doc.archived_at is not None,
        created_by=str(doc.created_by_id),
        created_at=_iso(doc.created_at),
        updated_at=_iso(doc.updated_at),
    )


def card(c: services.Card) -> Any:
    return _pb().TaskCard(
        task_id=c.task_id,
        hidden=c.hidden,
        project_id=c.project_id,
        key=c.key,
        title=c.title,
        status_name=c.status_name,
        status_category=c.status_category,
        priority=c.priority,
    )


def editors(rows: list[dict[str, Any]]) -> list[Any]:
    return [_pb().Editor(user_id=r["id"], editing=r["editing"]) for r in rows]


def answer(view: services.DocView) -> Any:
    content = view.content
    return _pb().DocAnswer(
        doc=node(view.doc),
        version=content.version if content else 0,
        schema_version=content.schema_version if content else 0,
        blocks_json=json.dumps(content.blocks, separators=(",", ":")) if content else "",
        updated_by=str(content.updated_by_id or "") if content else "",
        editing=editors(view.editing),
        cards=[card(c) for c in view.cards],
        can_edit=view.can_edit,
        can_manage=view.can_manage,
        access_user_ids=view.access_user_ids,
    )


def revision_info(row: Any) -> Any:
    return _pb().RevisionInfo(
        id=row.pk,
        version=row.version,
        title=row.title,
        author_id=str(row.author_id or ""),
        at=_iso(row.at),
        saved_at=_iso(row.saved_at),
    )


def related(rows: list[services.Related]) -> Any:
    pb = _pb()
    return pb.RelatedDocs(docs=[pb.RelatedDoc(doc=node(r.doc), kind=r.kind) for r in rows])


async def _run(request: Any, context: Any, work: Callable[[Any, Any], Any]) -> Any:
    user = require_caller(await grpc_caller(context))
    workspace = await sync_to_async(require_workspace)(user, request.workspace_id)
    return await sync_to_async(lambda: work(user, workspace))()


class DocService(generics.GenericService):
    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "include_archived", "type": "bool"},
        ],
        request_name="DocTreeRequest",
        response=TREE,
        response_name="DocTree",
    )
    @action
    async def Tree(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.tree(user, ws, request.project_id, request.include_archived)
            return _pb().DocTree(docs=[node(d) for d in rows])

        return await _run(request, context, work)

    @grpc_action(
        request=DOC, request_name="DocGetRequest", response=ANSWER, response_name="DocAnswer"
    )
    @action
    async def Get(self, request: Any, context: Any) -> Any:
        return await _run(request, context, lambda u, w: answer(services.get(u, w, request.doc_id)))

    @grpc_action(
        request=[
            WS,
            {"name": "project_id", "type": "string"},
            {"name": "parent_id", "type": "string"},
            {"name": "title", "type": "string"},
            {"name": "icon", "type": "string"},
            {"name": "blocks_json", "type": "string"},
        ],
        request_name="DocCreateRequest",
        response=ANSWER,
        response_name="DocAnswer",
    )
    @action
    async def Create(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            return answer(
                services.create(
                    user,
                    ws,
                    request.project_id,
                    request.parent_id,
                    request.title,
                    request.icon,
                    request.blocks_json,
                )
            )

        return await _run(request, context, work)

    @grpc_action(
        request=[
            *DOC,
            {"name": "expected_version", "type": "int32"},
            {"name": "fields", "cardinality": "repeated", "type": "string"},
            {"name": "title", "type": "string"},
            {"name": "icon", "type": "string"},
            {"name": "blocks_json", "type": "string"},
            {"name": "schema_version", "type": "int32"},
        ],
        request_name="DocUpdateRequest",
        response=ANSWER,
        response_name="DocAnswer",
    )
    @action
    async def Update(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            changes: dict[str, str] = {}
            for name in request.fields:
                if name not in services.EDITABLE:
                    raise ApiError(f"Cannot change {name}.", status=400)
                changes[name] = request.blocks_json if name == "blocks" else getattr(request, name)
            return answer(
                services.update(
                    user,
                    ws,
                    request.doc_id,
                    request.expected_version,
                    changes,
                    request.schema_version,
                )
            )

        return await _run(request, context, work)

    @grpc_action(
        request=[
            *DOC,
            {"name": "parent_id", "type": "string"},
            {"name": "index", "type": "int32"},
        ],
        request_name="DocMoveRequest",
        response=ANSWER,
        response_name="DocAnswer",
    )
    @action
    async def Move(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            return answer(services.move(user, ws, request.doc_id, request.parent_id, request.index))

        return await _run(request, context, work)

    @grpc_action(
        request=DOC, request_name="DocArchiveRequest", response=ANSWER, response_name="DocAnswer"
    )
    @action
    async def Archive(self, request: Any, context: Any) -> Any:
        return await _run(
            request, context, lambda u, w: answer(services.archive(u, w, request.doc_id))
        )

    @grpc_action(
        request=DOC, request_name="DocRestoreRequest", response=ANSWER, response_name="DocAnswer"
    )
    @action
    async def Restore(self, request: Any, context: Any) -> Any:
        return await _run(
            request, context, lambda u, w: answer(services.restore(u, w, request.doc_id))
        )

    @grpc_action(
        request=[
            *DOC,
            {"name": "restricted", "type": "bool"},
            {"name": "user_ids", "cardinality": "repeated", "type": "string"},
        ],
        request_name="DocSetAccessRequest",
        response=ANSWER,
        response_name="DocAnswer",
    )
    @action
    async def SetAccess(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            return answer(
                services.set_access(user, ws, request.doc_id, request.restricted, request.user_ids)
            )

        return await _run(request, context, work)

    @grpc_action(
        request=DOC,
        request_name="DocRevisionListRequest",
        response=[{"name": "revisions", "cardinality": "repeated", "type": RevisionInfo}],
        response_name="DocRevisionList",
    )
    @action
    async def RevisionList(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.revision_list(user, ws, request.doc_id)
            return _pb().DocRevisionList(revisions=[revision_info(r) for r in rows])

        return await _run(request, context, work)

    @grpc_action(
        request=[*DOC, {"name": "revision_id", "type": "int64"}],
        request_name="DocRevisionGetRequest",
        response=[
            {"name": "revision", "type": RevisionInfo},
            {"name": "blocks_json", "type": "string"},
        ],
        response_name="DocRevisionAnswer",
    )
    @action
    async def RevisionGet(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            row = services.revision_get(user, ws, request.doc_id, request.revision_id)
            return _pb().DocRevisionAnswer(
                revision=revision_info(row),
                blocks_json=json.dumps(row.blocks, separators=(",", ":")),
            )

        return await _run(request, context, work)

    @grpc_action(
        request=[
            *DOC,
            {"name": "revision_id", "type": "int64"},
            {"name": "expected_version", "type": "int32"},
        ],
        request_name="DocRevisionRestoreRequest",
        response=ANSWER,
        response_name="DocAnswer",
    )
    @action
    async def RevisionRestore(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            return answer(
                services.revision_restore(
                    user, ws, request.doc_id, request.revision_id, request.expected_version
                )
            )

        return await _run(request, context, work)

    @grpc_action(
        request=DOC, request_name="DocBacklinksRequest", response=TREE, response_name="DocTree"
    )
    @action
    async def Backlinks(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.backlinks(user, ws, request.doc_id)
            return _pb().DocTree(docs=[node(d) for d in rows])

        return await _run(request, context, work)

    @grpc_action(
        request=DOC,
        request_name="DocExportRequest",
        response=[{"name": "title", "type": "string"}, {"name": "markdown", "type": "string"}],
        response_name="DocMarkdown",
    )
    @action
    async def ExportMarkdown(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            view = services.get(user, ws, request.doc_id)
            body = markdown.to_markdown(view.content.blocks if view.content else [])
            return _pb().DocMarkdown(title=view.doc.title, markdown=body)

        return await _run(request, context, work)

    @grpc_action(
        request=TASK[:3],
        request_name="DocForTaskRequest",
        response=RELATED,
        response_name="RelatedDocs",
    )
    @action
    async def ForTask(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            return related(services.for_task(user, ws, request.project_id, request.task_id))

        return await _run(request, context, work)

    @grpc_action(
        request=TASK,
        request_name="DocLinkTaskRequest",
        response=RELATED,
        response_name="RelatedDocs",
    )
    @action
    async def LinkTask(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.link_task(user, ws, request.project_id, request.task_id, request.doc_id)
            return related(rows)

        return await _run(request, context, work)

    @grpc_action(
        request=TASK,
        request_name="DocLinkTaskRequest",
        response=RELATED,
        response_name="RelatedDocs",
    )
    @action
    async def UnlinkTask(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.unlink_task(
                user, ws, request.project_id, request.task_id, request.doc_id
            )
            return related(rows)

        return await _run(request, context, work)

    @grpc_action(
        request=[WS, {"name": "task_ids", "cardinality": "repeated", "type": "string"}],
        request_name="DocTaskCardsRequest",
        response=[{"name": "cards", "cardinality": "repeated", "type": TaskCard}],
        response_name="DocTaskCards",
    )
    @action
    async def TaskCards(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            rows = services.task_cards(user, ws, list(request.task_ids))
            return _pb().DocTaskCards(cards=[card(c) for c in rows])

        return await _run(request, context, work)

    @grpc_action(
        request=[*DOC, {"name": "state", "type": "string"}],
        request_name="DocPresenceRequest",
        response=[{"name": "editing", "cardinality": "repeated", "type": Editor}],
        response_name="DocPresence",
    )
    @action
    async def Presence(self, request: Any, context: Any) -> Any:
        def work(user: Any, ws: Any) -> Any:
            roster = services.touch_presence(user, ws, request.doc_id, request.state)
            return _pb().DocPresence(editing=editors(roster))

        return await _run(request, context, work)


GRPC_SERVICES = [DocService]
