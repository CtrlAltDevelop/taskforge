"""Saved layouts of a project's views.

Everyone who can open a project keeps personal layouts there (a read-only role included: a layout
is a preference, not an edit, so it survives an archived project too). A layout visible to all
(``shared``) needs ``project.update`` and a project that is not archived; it has no owner, and a
personal layout becomes shared by saving it with ``shared`` (it cannot go back: delete or copy).
A save of an existing layout carries its ``expected_version`` (stale: ``VERSION_CONFLICT`` with the
current ``version``).
"""

import uuid
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.db.models import Count, Q, QuerySet
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.savedviews import config as layout
from infrastructure.savedviews.models import SavedView
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW = "workspace.view"
MANAGE = "project.update"
KINDS: Final = ("list", "board", "calendar")
MAX_PER_SCOPE: Final = 50
MAX_NAME: Final = 60


def not_found() -> ApiError:
    return ApiError("No such view.", status=404)


def _open(actor: Any, workspace: Workspace, project_id: str) -> Project:
    access.require(actor, VIEW, workspace)
    return projects.load(actor, workspace, project_id)


def _manage(actor: Any, workspace: Workspace, project_id: str) -> Project:
    project = projects.authorize(actor, workspace, project_id, MANAGE)
    projects.writable(project)
    return project


def _name(raw: str) -> str:
    name = " ".join(str(raw).split())
    if not 1 <= len(name) <= MAX_NAME:
        raise ApiError(f"A layout's name is 1 to {MAX_NAME} characters.")
    return name


def _kind(raw: str) -> str:
    if raw not in KINDS:
        raise ApiError(f"Unknown view kind {raw!r}.")
    return raw


def _visible(project: Project, actor: Any) -> QuerySet[SavedView]:
    return SavedView.objects.filter(project=project).filter(Q(is_shared=True) | Q(owner=actor))


def list_views(
    actor: Any, workspace: Workspace, project_id: str, kind: str = ""
) -> list[SavedView]:
    """The shared layouts of the project, then the caller's own, each by name."""
    project = _open(actor, workspace, project_id)
    rows = _visible(project, actor)
    if kind:
        rows = rows.filter(kind=_kind(kind))
    return sorted(rows, key=lambda v: (not v.is_shared, v.name.lower()))


def _load(project: Project, actor: Any, view_id: str, *, lock: bool = False) -> SavedView:
    try:
        pk = uuid.UUID(str(view_id))
    except ValueError:
        raise not_found() from None
    rows = _visible(project, actor).filter(pk=pk)
    view = (rows.select_for_update(of=("self",)) if lock else rows).first()
    if view is None:
        raise not_found()
    return view


def _check_room(project: Project, scope: Q, kind: str) -> None:
    taken = SavedView.objects.filter(scope, project=project, kind=kind).aggregate(n=Count("pk"))
    if taken["n"] >= MAX_PER_SCOPE:
        raise ApiError(
            f"A project keeps at most {MAX_PER_SCOPE} layouts of one kind in one place.",
            title=ResponseTitle.VIEW_LIMIT,
        )


def _name_taken() -> ApiError:
    return ApiError(
        "A layout with that name already exists here.",
        status=409,
        title=ResponseTitle.VIEW_NAME_TAKEN,
    )


def save(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    name: str,
    config: Any,
    kind: str = "list",
    view_id: str = "",
    shared: bool = False,
    expected_version: int = 0,
) -> SavedView:
    """Create a layout, or save ``view_id`` (``expected_version`` required then)."""
    cleaned_name, cleaned_kind = _name(name), _kind(kind)
    cleaned = layout.clean_for(cleaned_kind, config)
    try:
        with transaction.atomic():
            return _write(
                actor,
                workspace,
                project_id,
                view_id,
                shared,
                expected_version,
                name=cleaned_name,
                kind=cleaned_kind,
                config=cleaned,
            )
    except IntegrityError:  # two saves of one name raced past the check below
        raise _name_taken() from None


def _write(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    view_id: str,
    shared: bool,
    expected_version: int,
    **values: Any,
) -> SavedView:
    project = (
        _manage(actor, workspace, project_id) if shared else _open(actor, workspace, project_id)
    )
    kind = values["kind"]
    if view_id:
        view = _load(project, actor, view_id, lock=True)
        if view.is_shared and not shared:
            raise ApiError("A shared layout cannot be made personal; delete it or copy it.")
        if expected_version != view.version:
            raise ApiError(
                "Someone else changed this layout first; reload and retry.",
                status=409,
                title=ResponseTitle.VERSION_CONFLICT,
                data={"version": view.version},
            )
        view.version += 1
    else:
        view = SavedView(workspace=workspace, project=project)
    owner = None if shared else actor
    _ensure_name_free(project, owner, kind, values["name"], besides=view.pk if view_id else None)
    if not view_id:
        _check_room(project, Q(is_shared=True) if shared else Q(owner=actor), kind)
    elif shared and not view.is_shared:
        _check_room(project, Q(is_shared=True), kind)
    view.owner = owner
    view.is_shared = shared
    view.name, view.kind, view.config = values["name"], kind, values["config"]
    view.updated_at = timezone.now()
    view.save()
    return view


def _ensure_name_free(
    project: Project, owner: Any, kind: str, name: str, *, besides: Any = None
) -> None:
    rows = SavedView.objects.filter(project=project, kind=kind, name__iexact=name)
    rows = rows.filter(owner=owner) if owner is not None else rows.filter(is_shared=True)
    if besides is not None:
        rows = rows.exclude(pk=besides)
    if rows.exists():
        raise _name_taken()


def delete(actor: Any, workspace: Workspace, project_id: str, view_id: str) -> SavedView:
    with transaction.atomic():
        project = _open(actor, workspace, project_id)
        view = _load(project, actor, view_id, lock=True)
        if view.is_shared:
            _manage(actor, workspace, project_id)
        view.delete()
    return view
