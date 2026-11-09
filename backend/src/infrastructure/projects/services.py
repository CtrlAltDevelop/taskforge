"""Every project rule. gRPC renders the answer; nothing here knows a transport.

Order of checks, which is what keeps private projects invisible: the workspace-level
``access.require`` first (it says nothing about any project), then ``_load`` which reads
through ``visible_to`` -- so an invisible, foreign or unknown id is the same
404. Mutations load the row ``select_for_update`` and refuse an archived project
(``PROJECT_ARCHIVED``) except Restore; writes are optimistic-locked by ``expected_version``.
Member/admin-list code is in ``members.py``.
"""

import uuid
from collections.abc import Iterable
from dataclasses import dataclass
from typing import Any

from django.db import IntegrityError, transaction
from django.db.models import Count, F
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects.features import FEATURE_KEYS
from infrastructure.projects.fields import (
    CLEANERS,
    clean_color,
    clean_description,
    clean_icon,
    clean_key,
    clean_name,
    clean_visibility,
)
from infrastructure.projects.models import (
    Project,
    ProjectFavorite,
    ProjectMember,
    Visibility,
)
from infrastructure.projects.signals import announce
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace

VIEW = "workspace.view"


@dataclass(frozen=True, slots=True)
class ProjectView:
    project: Project
    is_favorite: bool
    member_count: int
    is_member: bool
    can_open: bool  # false only in the admin list, for a private project the caller is not in


def not_found() -> ApiError:
    return ApiError("No such project.", status=404)


def _archived() -> ApiError:
    return ApiError(
        "This project is archived and read-only. Restore it first.",
        status=409,
        title=ResponseTitle.PROJECT_ARCHIVED,
    )


def _conflict() -> ApiError:
    return ApiError(
        "The project changed since you loaded it; reload and retry.",
        status=409,
        title=ResponseTitle.VERSION_CONFLICT,
    )


def _key_taken() -> ApiError:
    return ApiError(
        "That key is already used in this workspace.", status=409, title=ResponseTitle.KEY_TAKEN
    )


def load(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    *,
    lock: bool = False,
    as_admin: bool = False,
) -> Project:
    """The project if ``actor`` may see it, else 404. Never query ``Project`` any other way."""
    try:
        pk = uuid.UUID(str(project_id))
    except ValueError:
        raise not_found() from None
    rows = Project.objects.visible_to(actor, workspace, as_admin=as_admin).filter(pk=pk)
    project = (rows.select_for_update() if lock else rows).first()
    if project is None:
        raise not_found()
    return project


def authorize(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    key: str,
    *,
    lock: bool = False,
    admin_reach: bool = False,
) -> Project:
    """``require(key)`` then load. Holding the key (``admin_reach``: also for a private project
    the caller is not in) or being the project's creator (see ``access.CREATOR_KEYS``) passes;
    anything else is the original refusal."""
    try:
        access.require(actor, key, workspace)
    except access.PermissionDenied as denied:
        try:
            project = load(actor, workspace, project_id, lock=lock)
        except ApiError:
            raise denied from None
        access.require(actor, key, workspace, resource=project)
        return project
    return load(actor, workspace, project_id, lock=lock, as_admin=admin_reach)


def writable(project: Project) -> None:
    if project.archived_at is not None:
        raise _archived()


def views(
    actor: Any, workspace: Workspace, projects: Iterable[Project], *, admin_list: bool = False
) -> list[ProjectView]:
    """Wrap projects with the caller's flags and member counts, in three queries."""
    rows = list(projects)
    ids = [p.pk for p in rows]
    counts = dict(
        ProjectMember.objects.filter(
            project_id__in=ids,
            user__workspace_memberships__workspace=workspace,
            user__workspace_memberships__status=MemberStatus.ACTIVE,
        )
        .values("project_id")
        .annotate(n=Count("user_id", distinct=True))
        .values_list("project_id", "n")
    )
    mine = set(
        ProjectMember.objects.filter(project_id__in=ids, user=actor).values_list(
            "project_id", flat=True
        )
    )
    starred = set(
        ProjectFavorite.objects.filter(project_id__in=ids, user=actor).values_list(
            "project_id", flat=True
        )
    )
    return [
        ProjectView(
            p,
            is_favorite=p.pk in starred,
            member_count=counts.get(p.pk, 0),
            is_member=p.pk in mine,
            can_open=not admin_list or p.visibility == Visibility.OPEN or p.pk in mine,
        )
        for p in rows
    ]


def view_of(actor: Any, workspace: Workspace, project: Project) -> ProjectView:
    return views(actor, workspace, [project])[0]


def _bump(project: Project, expected_version: int, **changes: Any) -> Project:
    """Apply ``changes`` only if the row is still at ``expected_version``; bump the version."""
    try:
        with transaction.atomic():  # savepoint: a key clash must not poison the caller's tx
            updated = Project.objects.filter(pk=project.pk, version=expected_version).update(
                version=F("version") + 1, updated_at=timezone.now(), **changes
            )
    except IntegrityError:
        raise _key_taken() from None
    if not updated:
        raise _conflict()
    return Project.objects.get(pk=project.pk)


def list_projects(
    actor: Any, workspace: Workspace, include_archived: bool = False
) -> list[ProjectView]:
    """Visible projects, favorites first, then by name."""
    access.require(actor, VIEW, workspace)
    rows = Project.objects.visible_to(actor, workspace)
    if not include_archived:
        rows = rows.filter(archived_at__isnull=True)
    found = views(actor, workspace, rows)
    return sorted(found, key=lambda v: (not v.is_favorite, v.project.name.lower(), v.project.key))


def get(actor: Any, workspace: Workspace, project_id: str) -> ProjectView:
    access.require(actor, VIEW, workspace)
    return view_of(actor, workspace, load(actor, workspace, project_id))


def create(
    actor: Any,
    workspace: Workspace,
    name: str,
    key: str,
    description: str = "",
    icon: str = "",
    color: str = "",
    visibility: str = Visibility.OPEN,
) -> ProjectView:
    access.require(actor, "project.create", workspace)
    fields = {
        "name": clean_name(name),
        "key": clean_key(key),
        "description": clean_description(description),
        "icon": clean_icon(icon),
        "color": clean_color(color),
        "visibility": clean_visibility(visibility),
    }
    try:
        with transaction.atomic():
            project = Project.objects.create(workspace=workspace, created_by=actor, **fields)
            if project.visibility == Visibility.PRIVATE:
                ProjectMember.objects.create(project=project, user=actor)
            announce(project, "created")
    except IntegrityError:
        raise _key_taken() from None
    return view_of(actor, workspace, project)


def update(
    actor: Any, workspace: Workspace, project_id: str, expected_version: int, **changes: str
) -> ProjectView:
    """``changes`` holds only the fields the caller sent (name, key, description, icon, color,
    visibility). A key can change only while no task exists. Going private adds the actor."""
    with transaction.atomic():
        project = authorize(actor, workspace, project_id, "project.update", lock=True)
        writable(project)
        cleaned = {name: CLEANERS[name](value) for name, value in changes.items()}
        if cleaned.get("key", project.key) != project.key and project.task_counter:
            raise ApiError(
                "The key cannot change once the project has tasks.",
                status=409,
                title=ResponseTitle.KEY_LOCKED,
            )
        cleaned = {k: v for k, v in cleaned.items() if getattr(project, k) != v}
        if not cleaned:
            if project.version != expected_version:
                raise _conflict()
            return view_of(actor, workspace, project)
        updated = _bump(project, expected_version, **cleaned)
        if updated.visibility == Visibility.PRIVATE:
            ProjectMember.objects.get_or_create(project=updated, user=actor)
        announce(updated, "updated")
    return view_of(actor, workspace, updated)


def archive(
    actor: Any, workspace: Workspace, project_id: str, expected_version: int
) -> ProjectView:
    with transaction.atomic():
        project = authorize(actor, workspace, project_id, "project.archive", lock=True)
        writable(project)
        updated = _bump(project, expected_version, archived_at=timezone.now())
        announce(updated, "archived")
    return view_of(actor, workspace, updated)


def restore(
    actor: Any, workspace: Workspace, project_id: str, expected_version: int
) -> ProjectView:
    """Un-archive. Restoring a project that is not archived changes nothing."""
    with transaction.atomic():
        project = authorize(
            actor, workspace, project_id, "project.archive", lock=True, admin_reach=True
        )
        if project.archived_at is not None:
            project = _bump(project, expected_version, archived_at=None)
            announce(project, "restored")
    return views(actor, workspace, [project], admin_list=True)[0]


def set_features(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    enabled_keys: Iterable[str],
    expected_version: int,
) -> ProjectView:
    """Replace the enabled set. Unknown keys are refused; switching off keeps the data."""
    keys = set(enabled_keys)
    unknown = sorted(keys - set(FEATURE_KEYS))
    if unknown:
        raise ApiError(f"Unknown features: {', '.join(unknown)}.")
    with transaction.atomic():
        project = authorize(actor, workspace, project_id, "project.update", lock=True)
        writable(project)
        stored = {**project.settings, "features": [k for k in FEATURE_KEYS if k in keys]}
        updated = _bump(project, expected_version, settings=stored)
        announce(updated, "features")
    return view_of(actor, workspace, updated)


def enabled_features(project: Project) -> frozenset[str]:
    return frozenset(project.settings.get("features", ())) & set(FEATURE_KEYS)


def favorite(actor: Any, workspace: Workspace, project_id: str, is_favorite: bool) -> ProjectView:
    """Star or unstar for the caller. Starring needs a non-archived project; unstarring never."""
    access.require(actor, VIEW, workspace)
    project = load(actor, workspace, project_id)
    if is_favorite:
        writable(project)
        ProjectFavorite.objects.get_or_create(user=actor, project=project)
    else:
        ProjectFavorite.objects.filter(user=actor, project=project).delete()
    return view_of(actor, workspace, project)


def next_task_number(project: Project) -> int:
    """Atomically take the next task number of ``project`` (1, 2, 3 ...). Phase 06 calls this
    inside the transaction that creates the task; the row lock lives until it commits.
    An archived project is refused (``PROJECT_ARCHIVED``)."""
    with transaction.atomic():
        writable(Project.objects.filter(pk=project.pk).select_for_update().get())
        Project.objects.filter(pk=project.pk).update(task_counter=F("task_counter") + 1)
        number: int = Project.objects.values_list("task_counter", flat=True).get(pk=project.pk)
    return number


def number_task(actor: Any, workspace: Workspace, project_id: str) -> int:
    """``next_task_number`` for a project the actor may see and that is not archived."""
    with transaction.atomic():
        project = load(actor, workspace, project_id, lock=True)
        return next_task_number(project)
