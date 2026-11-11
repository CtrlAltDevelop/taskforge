"""Who may open a page. Every read and write of a page goes through here.

A page is in the workspace (no project) or in a project. The first needs ``workspace.view``; the
second needs the project to be visible to the caller. On top of that a page may be *restricted*:
only its creator, the people listed in ``DocAccess`` and holders of ``doc.manage`` may open it.
Restriction is cumulative down the tree: a page under a restricted page is open only to those who
may open every restricted page above it (and itself, if it is restricted too). Anything the caller
may not open is the same 404 as a page that does not exist.
"""

import uuid
from typing import Any, Final

from infrastructure.common.errors import ApiError
from infrastructure.docs.models import Doc, DocAccess
from infrastructure.projects.models import Project
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
EDIT: Final = "doc.edit"
MANAGE: Final = "doc.manage"
MAX_DEPTH: Final = 10  # levels of nesting; also bounds every walk up the tree


def not_found() -> ApiError:
    return ApiError("No such page.", status=404)


def _manages(actor: Any, workspace: Workspace) -> bool:
    return access.can(actor, MANAGE, workspace).allowed


def accessible_ids(actor: Any, workspace: Workspace) -> set[uuid.UUID]:
    """The ids of every page of ``workspace`` (archived too) the caller may open."""
    open_projects = set(Project.objects.visible_to(actor, workspace).values_list("pk", flat=True))
    rows = {
        pk: (project, parent, restricted, creator)
        for pk, project, parent, restricted, creator in Doc.objects.filter(
            workspace=workspace
        ).values_list("pk", "project_id", "parent_id", "restricted", "created_by_id")
    }
    listed = set(
        DocAccess.objects.filter(user=actor, doc__workspace=workspace).values_list(
            "doc_id", flat=True
        )
    )
    manage = _manages(actor, workspace)
    verdict: dict[uuid.UUID, bool] = {}
    for start in rows:
        path: list[uuid.UUID] = []
        cursor: uuid.UUID | None = start
        while (
            cursor is not None
            and cursor not in verdict
            and cursor in rows
            and len(path) <= MAX_DEPTH + 2
        ):
            path.append(cursor)
            cursor = rows[cursor][1]
        # Above the walk: a known verdict, the top (open), or something that must not happen (a
        # parent outside the workspace, a loop, a tower too tall): closed.
        ok = cursor is None or verdict.get(cursor, False)
        for node in reversed(path):
            project, _, restricted, creator = rows[node]
            ok = (
                ok
                and (project is None or project in open_projects)
                and (not restricted or manage or creator == actor.pk or node in listed)
            )
            verdict[node] = ok
    return {pk for pk, ok in verdict.items() if ok}


def readable(actor: Any, workspace: Workspace) -> Any:
    """``Doc`` rows of the workspace the caller may open (the queryset to build lists from)."""
    return Doc.objects.filter(workspace=workspace, pk__in=accessible_ids(actor, workspace))


def can_open(actor: Any, workspace: Workspace, doc: Doc) -> bool:
    """The cheap check for one page: a walk up its ancestors, at most ``MAX_DEPTH`` steps."""
    if doc.workspace_id != workspace.pk:
        return False
    manage = _manages(actor, workspace)
    if doc.project_id is not None and not (
        Project.objects.visible_to(actor, workspace).filter(pk=doc.project_id).exists()
    ):
        return False
    cursor: Doc | None = doc
    for _ in range(MAX_DEPTH + 2):
        if cursor is None:
            return True
        if cursor.restricted and not (
            manage
            or cursor.created_by_id == actor.pk
            or DocAccess.objects.filter(doc=cursor, user=actor).exists()
        ):
            return False
        cursor = (
            Doc.objects.filter(pk=cursor.parent_id, workspace=workspace).first()
            if cursor.parent_id
            else None
        )
    return False


def load(actor: Any, workspace: Workspace, doc_id: str, *, lock: bool = False) -> Doc:
    """The page if the caller may open it, else 404 (the same for a page that is not there)."""
    try:
        pk = uuid.UUID(str(doc_id))
    except ValueError:
        raise not_found() from None
    rows = Doc.objects.filter(pk=pk, workspace=workspace)
    doc = (rows.select_for_update() if lock else rows).first()
    if doc is None or not can_open(actor, workspace, doc):
        raise not_found()
    return doc


def depth_of(doc: Doc | None) -> int:
    """How many levels deep ``doc`` sits (a top-level page is 1; no page is 0)."""
    levels = 0
    cursor = doc
    while cursor is not None and levels <= MAX_DEPTH + 1:
        levels += 1
        cursor = Doc.objects.filter(pk=cursor.parent_id).first() if cursor.parent_id else None
    return levels


def subtree_ids(doc: Doc) -> list[uuid.UUID]:
    """``doc`` and every page below it."""
    found = [doc.pk]
    frontier = [doc.pk]
    while frontier:
        frontier = list(Doc.objects.filter(parent_id__in=frontier).values_list("pk", flat=True))
        found.extend(frontier)
    return found
