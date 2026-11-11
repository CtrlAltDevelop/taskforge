"""Members of private projects, and the admin list of private projects.

``project.member.manage`` (or being the project's creator) adds and removes (also how an
admin joins a private project to open it); ``project.view_private`` gets the admin list.
Both read through ``visible_to(as_admin=True)`` only after ``access.require`` passed.
Only active workspace members can be project members, and a private project keeps at
least one of them.
"""

import uuid
from typing import Any

from django.db import transaction

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import services
from infrastructure.projects.models import Project, ProjectMember, Visibility
from infrastructure.projects.signals import announce
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember
from infrastructure.workspaces.signals import announce_access


def _active(project: Project) -> Any:
    return ProjectMember.objects.filter(
        project=project,
        user__workspace_memberships__workspace_id=project.workspace_id,
        user__workspace_memberships__status=MemberStatus.ACTIVE,
    )


def _workspace_member(workspace: Workspace, user_id: str) -> Any:
    try:
        pk = uuid.UUID(str(user_id))
    except ValueError:
        raise ApiError("No such member.", status=404) from None
    row = (
        WorkspaceMember.objects.filter(workspace=workspace, user_id=pk, status=MemberStatus.ACTIVE)
        .select_related("user")
        .first()
    )
    if row is None:
        raise ApiError("No such member.", status=404)
    return row.user


def list_members(actor: Any, workspace: Workspace, project_id: str) -> list[ProjectMember]:
    access.require(actor, services.VIEW, workspace)
    project = services.load(actor, workspace, project_id)
    return list(_active(project).select_related("user__profile").order_by("added_at", "pk"))


def add_member(actor: Any, workspace: Workspace, project_id: str, user_id: str) -> ProjectMember:
    """Add ``user_id`` (empty: the caller) to a private project."""
    with transaction.atomic():
        project = services.authorize(
            actor, workspace, project_id, "project.member.manage", lock=True, admin_reach=True
        )
        services.writable(project)
        if project.visibility != Visibility.PRIVATE:
            raise ApiError("Only private projects have members; this one is open.")
        user = _workspace_member(workspace, user_id or str(actor.pk))
        row, created = ProjectMember.objects.get_or_create(project=project, user=user)
        if created:
            announce_access(workspace, row.user_id)  # first: the sockets re-check, then hear of it
            announce(project, "member_added")
    return ProjectMember.objects.select_related("user__profile").get(pk=row.pk)


def remove_member(actor: Any, workspace: Workspace, project_id: str, user_id: str) -> None:
    with transaction.atomic():
        project = services.authorize(
            actor, workspace, project_id, "project.member.manage", lock=True, admin_reach=True
        )
        services.writable(project)
        try:
            pk = uuid.UUID(str(user_id))
        except ValueError:
            raise ApiError("No such member.", status=404) from None
        row = ProjectMember.objects.filter(project=project, user_id=pk).first()
        if row is None:
            raise ApiError("No such member.", status=404)
        counted = _active(project).filter(user_id=pk).exists()
        if project.visibility == Visibility.PRIVATE and counted and _active(project).count() <= 1:
            raise ApiError(
                "A private project needs at least one member.",
                status=409,
                title=ResponseTitle.LAST_MEMBER,
            )
        row.delete()
        announce_access(workspace, user_id)  # first: the sockets re-check, then hear of it
        announce(project, "member_removed")


def list_private(actor: Any, workspace: Workspace) -> list[services.ProjectView]:
    """Every private project (archived ones too, so they stay recoverable), for owners/admins;
    ``can_open`` is false unless a member."""
    access.require(actor, "project.view_private", workspace)
    rows = Project.objects.visible_to(actor, workspace, as_admin=True).filter(
        visibility=Visibility.PRIVATE
    )
    found = services.views(actor, workspace, rows, admin_list=True)
    return sorted(found, key=lambda v: (v.project.name.lower(), v.project.key))
