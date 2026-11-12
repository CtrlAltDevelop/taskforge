"""Docs: the page tree, a page's body and history, who may open it, and what it links to.

Reading needs ``workspace.view`` and the right to open the page (see ``reach``); changing a page
needs ``doc.edit``; restricting a page and choosing who may open it needs ``doc.manage``. A project
page also needs the project to be visible, and an archived project is read-only. Saving is
optimistic: ``expected_version`` must be the version the editor loaded, or the save is refused with
``VERSION_CONFLICT`` carrying the server's version (and its blocks when small) so the client can
offer a merge. Every save re-checks and rebuilds the body (``blocks.clean``), keeps one revision per
burst of editing, rebuilds the page's links, tells the live sync and the search index.
"""

import json
from collections.abc import Sequence
from dataclasses import dataclass, field
from typing import Any, Final

from django.db import transaction
from django.db.models import Max
from django.utils import timezone

from infrastructure.audit import changes as audit_changes
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.docs import blocks as block_schema
from infrastructure.docs import links, reach, revisions
from infrastructure.docs.models import (
    Doc,
    DocAccess,
    DocContent,
    DocLink,
    DocRevision,
    LinkKind,
)
from infrastructure.docs.signals import announce
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.sync import presence
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

VIEW: Final = reach.VIEW
EDIT: Final = reach.EDIT
MANAGE: Final = reach.MANAGE
TITLE_MAX: Final = 200
ICON_MAX: Final = 32
EDITABLE: Final = ("title", "icon", "blocks")
CARDS_MAX: Final = 200
ACCESS_MAX: Final = 500
CONFLICT_BLOCKS_MAX: Final = 4000  # bytes of blocks a conflict may carry (it rides in trailers)
STATES: Final = ("viewing", "editing", "left")
CONN: Final = "rpc"


def _bad(message: str) -> ApiError:
    return ApiError(message, status=400, title=ResponseTitle.DOC_INVALID)


def _archived() -> ApiError:
    return ApiError(
        "That page is archived. Restore it first.", status=409, title=ResponseTitle.DOC_ARCHIVED
    )


@dataclass(frozen=True, slots=True)
class Card:
    """A task card as one viewer may see it; ``hidden`` when they may not open the task (or it is
    gone): nothing else is filled in then."""

    task_id: str
    hidden: bool
    project_id: str = ""
    key: str = ""
    title: str = ""
    status_name: str = ""
    status_category: str = ""
    priority: str = ""


@dataclass(slots=True)
class DocView:
    doc: Doc
    content: DocContent | None
    editing: list[dict[str, Any]] = field(default_factory=list)
    cards: list[Card] = field(default_factory=list)
    can_edit: bool = False
    can_manage: bool = False
    access_user_ids: list[str] = field(default_factory=list)

    def body(self) -> DocContent:
        """The content, for a view made with its body."""
        if self.content is None:
            raise ValueError("this view was made without its body")
        return self.content


@dataclass(frozen=True, slots=True)
class Related:
    doc: Doc
    kind: str  # "embedded" (a task card in it) or "related" (linked by hand)


def _title(value: str) -> str:
    title = value.strip()
    if len(title) > TITLE_MAX:
        raise _bad(f"A title is at most {TITLE_MAX} characters.")
    return title


def _icon(value: str) -> str:
    icon = value.strip()
    if len(icon) > ICON_MAX:
        raise _bad(f"An icon is at most {ICON_MAX} characters.")
    return icon


def _scope_project(actor: Any, workspace: Workspace, project_id: str, *, write: bool) -> Any:
    if not project_id:
        return None
    project = projects.load(actor, workspace, project_id)
    if write:
        projects.writable(project)
    return project


def _writable(doc: Doc) -> None:
    if doc.archived_at is not None:
        raise _archived()
    if doc.project_id is not None:
        projects.writable(Project.objects.get(pk=doc.project_id))


def _conflict(content: DocContent) -> ApiError:
    data: dict[str, Any] = {
        "version": content.version,
        "updated_by": str(content.updated_by_id or ""),
    }
    encoded = json.dumps(content.blocks, separators=(",", ":"))
    if len(encoded.encode()) <= CONFLICT_BLOCKS_MAX:
        data["blocks"] = encoded
    else:
        data["blocks_omitted"] = "1"
    return ApiError(
        "Someone else changed this page first.",
        status=409,
        title=ResponseTitle.VERSION_CONFLICT,
        data=data,
    )


def _content(doc: Doc, *, lock: bool = False) -> DocContent:
    rows = DocContent.objects.filter(doc=doc)
    row = (rows.select_for_update() if lock else rows).first()
    if row is None:  # a page always has a body; heal rather than fail if one went missing
        row = DocContent.objects.create(doc=doc)
    return row


# -- tree ------------------------------------------------------------------------------------


def tree(
    actor: Any, workspace: Workspace, project_id: str = "", include_archived: bool = False
) -> list[Doc]:
    """The pages of the workspace (or of one project) the caller may open, in tree order (every
    page after its parent, siblings by position). Archived pages only when asked for."""
    access.require(actor, VIEW, workspace)
    project = _scope_project(actor, workspace, project_id, write=False)
    rows = reach.readable(actor, workspace).filter(project=project)
    if not include_archived:
        rows = rows.filter(archived_at__isnull=True)
    by_parent: dict[Any, list[Doc]] = {}
    for doc in rows.order_by("position", "created_at", "id"):
        by_parent.setdefault(doc.parent_id, []).append(doc)
    ordered: list[Doc] = []
    stack = list(reversed(by_parent.pop(None, [])))
    while stack:
        doc = stack.pop()
        ordered.append(doc)
        stack.extend(reversed(by_parent.pop(doc.pk, [])))
    return ordered


# -- reading ---------------------------------------------------------------------------------


def task_cards(actor: Any, workspace: Workspace, task_ids: Sequence[str]) -> list[Card]:
    """One card per id asked for, in order: filled in when the caller may open the task, else
    ``hidden``. Never says which of the two (missing, deleted or private) it was."""
    access.require(actor, VIEW, workspace)
    wanted = tasks.valid_uuids(list(task_ids)[:CARDS_MAX])
    visible = Project.objects.visible_to(actor, workspace).values("pk")
    found = {
        t.pk: t
        for t in Task.objects.filter(
            workspace=workspace, pk__in=wanted, deleted_at__isnull=True, project_id__in=visible
        ).select_related("project", "status")
    }
    cards = []
    for pk in wanted:
        task = found.get(pk)
        cards.append(
            Card(str(pk), True)
            if task is None
            else Card(
                str(pk),
                False,
                str(task.project_id),
                f"{task.project.key}-{task.number}",
                task.title,
                task.status.name,
                task.status.category,
                task.priority,
            )
        )
    return cards


def _room(doc: Doc) -> str:
    return f"doc:{doc.pk}"


def _view(actor: Any, workspace: Workspace, doc: Doc, *, body: bool) -> DocView:
    manage = access.can(actor, MANAGE, workspace).allowed
    view = DocView(
        doc,
        None,
        can_edit=access.can(actor, EDIT, workspace).allowed and doc.archived_at is None,
        can_manage=manage,
    )
    if manage or doc.created_by_id == actor.pk:
        view.access_user_ids = [
            str(u) for u in DocAccess.objects.filter(doc=doc).values_list("user_id", flat=True)
        ]
    if body:
        view.content = _content(doc)
        _, task_ids = block_schema.references(view.content.blocks)
        view.cards = task_cards(actor, workspace, [str(t) for t in task_ids])
        view.editing = presence.store().who(_room(doc))
    return view


def get(actor: Any, workspace: Workspace, doc_id: str) -> DocView:
    access.require(actor, VIEW, workspace)
    return _view(actor, workspace, reach.load(actor, workspace, doc_id), body=True)


# -- writing ---------------------------------------------------------------------------------


def _next_position(workspace: Workspace, project: Any, parent: Doc | None) -> int:
    top = Doc.objects.filter(workspace=workspace, project=project, parent=parent).aggregate(
        m=Max("position")
    )["m"]
    return 0 if top is None else int(top) + 1


def _parent(actor: Any, workspace: Workspace, parent_id: str, project: Any) -> Doc | None:
    if not parent_id:
        return None
    parent = reach.load(actor, workspace, parent_id)
    if parent.archived_at is not None:
        raise _archived()
    if parent.project_id != (project.pk if project else None):
        raise _bad("A page and its parent must be in the same place (workspace or project).")
    return parent


def _store(doc: Doc, content: DocContent, actor: Any, cleaned: block_schema.Cleaned) -> None:
    """Write the body, then everything that follows from a changed body."""
    content.blocks = cleaned.blocks
    content.schema_version = block_schema.SCHEMA_VERSION
    content.updated_by = actor
    content.updated_at = timezone.now()
    content.save()
    links.sync(doc, cleaned.doc_ids, cleaned.task_ids)


def create(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    parent_id: str,
    title: str,
    icon: str = "",
    blocks_json: str = "",
) -> DocView:
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    project = _scope_project(actor, workspace, project_id, write=True)
    parent = _parent(actor, workspace, parent_id, project)
    if reach.depth_of(parent) >= reach.MAX_DEPTH:
        raise _bad(f"Pages can be nested at most {reach.MAX_DEPTH} levels deep.")
    cleaned = block_schema.clean(blocks_json)
    with transaction.atomic():
        now = timezone.now()
        doc = Doc.objects.create(
            workspace=workspace,
            project=project,
            parent=parent,
            title=_title(title),
            icon=_icon(icon),
            position=_next_position(workspace, project, parent),
            created_by=actor,
            created_at=now,
            updated_at=now,
        )
        content = DocContent(doc=doc, version=1)
        _store(doc, content, actor, cleaned)
        revisions.record(doc, content, actor, new=True)
        announce(doc, "created", content.version)
    return _view(actor, workspace, doc, body=True)


def update(
    actor: Any,
    workspace: Workspace,
    doc_id: str,
    expected_version: int,
    changes: dict[str, str],
    schema_version: int = 0,
) -> DocView:
    """Change ``title``, ``icon`` and/or ``blocks`` (the JSON text) of the page. Changing nothing
    (the same title, icon and blocks) is not a save: no version, no revision."""
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    unknown = [name for name in changes if name not in EDITABLE]
    if unknown:
        raise _bad(f"Cannot change {unknown[0]}.")
    title = _title(changes["title"]) if "title" in changes else None
    icon = _icon(changes["icon"]) if "icon" in changes else None
    cleaned = block_schema.clean(changes["blocks"], schema_version) if "blocks" in changes else None
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        _writable(doc)
        content = _content(doc, lock=True)
        same = (
            (title is None or title == doc.title)
            and (icon is None or icon == doc.icon)
            and (cleaned is None or cleaned.blocks == content.blocks)
        )
        if same:
            return _view(actor, workspace, doc, body=True)
        if expected_version != content.version:
            raise _conflict(content)
        _apply(doc, content, actor, title, icon, cleaned)
        announce(doc, "updated", content.version)
    return _view(actor, workspace, doc, body=True)


def _apply(
    doc: Doc,
    content: DocContent,
    actor: Any,
    title: str | None,
    icon: str | None,
    cleaned: block_schema.Cleaned | None,
    *,
    new_revision: bool = False,
) -> None:
    if title is not None:
        doc.title = title
    if icon is not None:
        doc.icon = icon
    doc.updated_at = timezone.now()
    doc.save(update_fields=["title", "icon", "updated_at"])
    content.version += 1
    if cleaned is not None:
        _store(doc, content, actor, cleaned)
    else:
        content.updated_by = actor
        content.updated_at = doc.updated_at
        content.save()
    revisions.record(doc, content, actor, new=new_revision)


def _height(doc: Doc) -> int:
    """Levels of the subtree under ``doc``, itself included."""
    levels, frontier = 1, [doc.pk]
    while True:
        frontier = list(Doc.objects.filter(parent_id__in=frontier).values_list("pk", flat=True))
        if not frontier:
            return levels
        levels += 1


def move(actor: Any, workspace: Workspace, doc_id: str, parent_id: str, index: int) -> DocView:
    """Put the page under ``parent_id`` (empty: at the top) at position ``index`` among its new
    siblings. Never under itself or a page below it, never across workspace/project, never past
    ``MAX_DEPTH`` levels."""
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        _writable(doc)
        # One lock for the whole tree of this place, so two moves cannot each look safe and
        # together make a loop.
        list(
            Doc.objects.select_for_update()
            .filter(workspace=workspace, project_id=doc.project_id)
            .values_list("pk", flat=True)
        )
        doc = Doc.objects.get(pk=doc.pk)
        project = Project.objects.filter(pk=doc.project_id).first()
        parent = _parent(actor, workspace, parent_id, project)
        if parent is not None and parent.pk in reach.subtree_ids(doc):
            raise ApiError(
                "A page cannot be put under itself or one of its own subpages.",
                status=409,
                title=ResponseTitle.DOC_CYCLE,
            )
        if reach.depth_of(parent) + _height(doc) > reach.MAX_DEPTH:
            raise _bad(f"Pages can be nested at most {reach.MAX_DEPTH} levels deep.")
        siblings = list(
            Doc.objects.filter(workspace=workspace, project_id=doc.project_id, parent=parent)
            .exclude(pk=doc.pk)
            .order_by("position", "created_at", "id")
        )
        siblings.insert(min(max(index, 0), len(siblings)), doc)
        for position, sibling in enumerate(siblings):
            sibling.position = position
        Doc.objects.bulk_update([s for s in siblings if s.pk != doc.pk], ["position"])
        doc.parent = parent
        doc.updated_at = timezone.now()
        doc.save(update_fields=["parent", "position", "updated_at"])
        announce(doc, "moved", _content(doc).version)
    return _view(actor, workspace, doc, body=False)


def archive(actor: Any, workspace: Workspace, doc_id: str) -> DocView:
    """Archive the page and every page below it (one stamp, so a restore brings back exactly
    them)."""
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        _writable(doc)
        now = timezone.now()
        audit_changes.update_rows(
            Doc.objects.filter(pk__in=reach.subtree_ids(doc), archived_at__isnull=True),
            archived_at=now,
            updated_at=now,
        )
        doc.refresh_from_db()
        announce(doc, "archived", _content(doc).version)
    return _view(actor, workspace, doc, body=False)


def restore(actor: Any, workspace: Workspace, doc_id: str) -> DocView:
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        if doc.project_id is not None:
            projects.writable(Project.objects.get(pk=doc.project_id))
        if doc.archived_at is None:
            return _view(actor, workspace, doc, body=False)
        if doc.parent_id and Doc.objects.get(pk=doc.parent_id).archived_at is not None:
            raise _bad("Restore the parent page first.")
        stamp = doc.archived_at
        audit_changes.update_rows(
            Doc.objects.filter(pk__in=reach.subtree_ids(doc), archived_at=stamp),
            archived_at=None,
            updated_at=timezone.now(),
        )
        doc.refresh_from_db()
        announce(doc, "restored", _content(doc).version)
    return _view(actor, workspace, doc, body=False)


def set_access(
    actor: Any, workspace: Workspace, doc_id: str, restricted: bool, user_ids: Sequence[str]
) -> DocView:
    """Restrict the page to its creator, ``user_ids`` and holders of ``doc.manage`` (or open it
    again to whoever can open its parent; the list is kept for a later restriction). The people
    must be active members of the workspace."""
    access.require(actor, VIEW, workspace)
    access.require(actor, MANAGE, workspace)
    wanted = {str(u) for u in user_ids}
    if len(wanted) > ACCESS_MAX:
        raise _bad(f"A page can list at most {ACCESS_MAX} people.")
    valid = tasks.valid_uuids(list(wanted))
    members = set(
        WorkspaceMember.objects.filter(
            workspace=workspace, status=MemberStatus.ACTIVE, user_id__in=valid
        ).values_list("user_id", flat=True)
    )
    if len(members) != len(wanted):
        raise _bad("Everyone listed must be an active member of the workspace.")
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        _writable(doc)
        doc.restricted = restricted
        doc.updated_at = timezone.now()
        doc.save(update_fields=["restricted", "updated_at"])
        DocAccess.objects.filter(doc=doc).exclude(user_id__in=members).delete()
        have = set(DocAccess.objects.filter(doc=doc).values_list("user_id", flat=True))
        for given in DocAccess.objects.bulk_create(
            [DocAccess(doc=doc, user_id=u) for u in members - have]
        ):
            audit_changes.created(given)
        announce(doc, "access", _content(doc).version)
    return _view(actor, workspace, doc, body=False)


# -- history ---------------------------------------------------------------------------------


def revision_list(actor: Any, workspace: Workspace, doc_id: str) -> list[DocRevision]:
    """The retained revisions, newest first (without bodies: see ``revision_get``)."""
    access.require(actor, VIEW, workspace)
    doc = reach.load(actor, workspace, doc_id)
    return list(
        DocRevision.objects.filter(doc=doc)
        .select_related("author")
        .defer("blocks")
        .order_by("-id")[: revisions.keep()]
    )


def _revision(doc: Doc, revision_id: int) -> DocRevision:
    row = DocRevision.objects.filter(doc=doc, pk=revision_id).first() if revision_id else None
    if row is None:
        raise ApiError("No such revision.", status=404)
    return row


def revision_get(actor: Any, workspace: Workspace, doc_id: str, revision_id: int) -> DocRevision:
    access.require(actor, VIEW, workspace)
    return _revision(reach.load(actor, workspace, doc_id), revision_id)


def revision_restore(
    actor: Any, workspace: Workspace, doc_id: str, revision_id: int, expected_version: int
) -> DocView:
    """Make the page what an older revision was (as a new save: the history keeps going)."""
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    with transaction.atomic():
        doc = reach.load(actor, workspace, doc_id, lock=True)
        _writable(doc)
        content = _content(doc, lock=True)
        if expected_version != content.version:
            raise _conflict(content)
        old = _revision(doc, revision_id)
        cleaned = block_schema.clean(json.dumps(old.blocks))
        _apply(doc, content, actor, old.title, None, cleaned, new_revision=True)
        announce(doc, "updated", content.version)
    return _view(actor, workspace, doc, body=True)


# -- links -----------------------------------------------------------------------------------


def backlinks(actor: Any, workspace: Workspace, doc_id: str) -> list[Doc]:
    """The live pages that mention this one with ``[[``, as far as the caller may open them."""
    access.require(actor, VIEW, workspace)
    doc = reach.load(actor, workspace, doc_id)
    sources = DocLink.objects.filter(
        target_doc=doc, kind=LinkKind.MENTION, doc__archived_at__isnull=True
    ).values("doc_id")
    return list(reach.readable(actor, workspace).filter(pk__in=sources).order_by("title", "id"))


def _task(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> Task:
    project = projects.load(actor, workspace, project_id)
    return tasks.load_task(project, task_id)


def for_task(actor: Any, workspace: Workspace, project_id: str, task_id: str) -> list[Related]:
    """The pages that embed this task (a card) or were linked to it by hand, as far as the caller
    may open them: "Related docs" on the task."""
    access.require(actor, VIEW, workspace)
    task = _task(actor, workspace, project_id, task_id)
    kinds: dict[Any, str] = {}
    for link in DocLink.objects.filter(task=task, doc__archived_at__isnull=True):
        if kinds.get(link.doc_id) != "related":
            kinds[link.doc_id] = "related" if link.kind == LinkKind.RELATED else "embedded"
    docs = reach.readable(actor, workspace).filter(pk__in=list(kinds)).order_by("title", "id")
    return [Related(d, kinds[d.pk]) for d in docs]


def link_task(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, doc_id: str
) -> list[Related]:
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    task = _task(actor, workspace, project_id, task_id)
    doc = reach.load(actor, workspace, doc_id)
    DocLink.objects.get_or_create(doc=doc, kind=LinkKind.RELATED, task=task)
    return for_task(actor, workspace, project_id, task_id)


def unlink_task(
    actor: Any, workspace: Workspace, project_id: str, task_id: str, doc_id: str
) -> list[Related]:
    """Remove a hand-made link (a card in the body is removed by editing the page)."""
    access.require(actor, VIEW, workspace)
    access.require(actor, EDIT, workspace)
    task = _task(actor, workspace, project_id, task_id)
    doc = reach.load(actor, workspace, doc_id)
    DocLink.objects.filter(doc=doc, kind=LinkKind.RELATED, task=task).delete()
    return for_task(actor, workspace, project_id, task_id)


# -- "editing now" ---------------------------------------------------------------------------


def touch_presence(
    actor: Any, workspace: Workspace, doc_id: str, state: str
) -> list[dict[str, Any]]:
    """Say the caller is viewing or editing the page (``left`` ends it); renew every ~20 s, the
    entry lapses by itself after 45 s. Returns who is on the page, and tells the others in the
    page's room when that changed."""
    access.require(actor, VIEW, workspace)
    if state not in STATES:
        raise _bad("The state is viewing, editing or left.")
    doc = reach.load(actor, workspace, doc_id)
    store = presence.store()
    uid = str(actor.pk)
    if state == "left":
        changed = store.leave(_room(doc), uid, CONN)
    else:
        changed = store.touch(_room(doc), uid, state == "editing", CONN)
    roster = store.who(_room(doc))
    if changed:
        _publish_presence(doc, roster)
    return roster


def _publish_presence(doc: Doc, roster: list[dict[str, Any]]) -> None:
    from apps.notifications.broadcast import get_broker
    from infrastructure.sync import publish

    audience = reach.audience(doc)
    rooms = (
        [publish.user_room(u) for u in audience]
        if audience is not None
        else [
            publish.project_room(doc.project_id)
            if doc.project_id
            else publish.workspace_room(doc.workspace_id)
        ]
    )
    try:
        for room in rooms:
            message = {
                "room": room,
                "presence": {
                    "project": str(doc.project_id or ""),
                    "doc": str(doc.pk),
                    "users": roster,
                },
            }
            get_broker().publish(publish.channel_of(room), message)
    except Exception:  # the roster is a hint; a broker that is away must not fail the call
        publish.log.exception("Could not publish doc presence")
