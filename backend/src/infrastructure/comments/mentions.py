"""Who a comment may mention: people who can see the task, and nobody else.

A mentioned person must be an active member of the workspace and able to open the task's project
(an open project: every member; a private one: its members). Anyone else is refused, naming them,
unless the author may manage that private project's members and asks (``grant_access``): they are
added to it, so the mention reaches somebody who can read what it points at.
"""

from typing import Any

from django.contrib.auth import get_user_model
from django.db.models import Q

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import members as project_members
from infrastructure.projects.models import Project, ProjectMember, Visibility
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

MANAGE = "project.member.manage"
PICKER_LIMIT = 20


def display_name(user: Any) -> str:
    profile = getattr(user, "profile", None)
    return (profile.display_name if profile else "") or user.get_username()


def _members(workspace: Workspace) -> Any:
    return WorkspaceMember.objects.filter(workspace=workspace, status=MemberStatus.ACTIVE)


def can_see(workspace: Workspace, project: Project) -> set[Any]:
    """Ids of the active members of ``workspace`` who can open ``project``."""
    everyone = set(_members(workspace).values_list("user_id", flat=True))
    if project.visibility == Visibility.OPEN:
        return everyone
    inside = set(ProjectMember.objects.filter(project=project).values_list("user_id", flat=True))
    return everyone & inside


def candidates(
    workspace: Workspace, project: Project, query: str = "", limit: int = PICKER_LIMIT
) -> list[Any]:
    """The people the picker offers: those who can see the task, matching ``query`` on their name
    or email, by name."""
    users = get_user_model().objects.filter(pk__in=can_see(workspace, project), is_active=True)
    needle = query.strip()
    if needle:
        users = users.filter(
            Q(profile__display_name__icontains=needle) | Q(email__icontains=needle)
        )
    return list(users.select_related("profile").order_by("profile__display_name", "email")[:limit])


def resolve(
    actor: Any,
    workspace: Workspace,
    project: Project,
    user_ids: list[Any],
    *,
    grant_access: bool,
) -> list[Any]:
    """The people to record as mentioned, or ``ApiError`` (``MENTION_NO_ACCESS``, ``data.users``
    naming who) for the ones who cannot see the task. With ``grant_access`` and the right to manage
    the project's members, those who are workspace members are added to a private project."""
    if not user_ids:
        return []
    seeing = can_see(workspace, project)
    outside = [u for u in user_ids if u not in seeing]
    if outside:
        in_workspace = set(
            _members(workspace).filter(user_id__in=outside).values_list("user_id", flat=True)
        )
        grantable = (
            grant_access
            and project.visibility == Visibility.PRIVATE
            and access.can(actor, MANAGE, project).allowed  # the creator of a project counts
        )
        refused = [u for u in outside if not (grantable and u in in_workspace)]
        if refused:
            raise ApiError(
                "Somebody mentioned cannot see this task.",
                title=ResponseTitle.MENTION_NO_ACCESS,
                data={"users": ",".join(str(u) for u in refused)},
            )
        for user_id in outside:
            project_members.grant(workspace, project, user_id)
    return list(get_user_model().objects.filter(pk__in=user_ids).select_related("profile"))
