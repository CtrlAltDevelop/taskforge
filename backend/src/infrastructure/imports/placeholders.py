"""Placeholders: the people an import could not match to a member, and handing their tasks over."""

from typing import Any

from django.db import transaction

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.imports.models import PlaceholderAssignment, PlaceholderUser
from infrastructure.projects.models import ProjectMember, Visibility
from infrastructure.tasks.models import TaskAssignee
from infrastructure.workspaces import access
from infrastructure.workspaces.models import MemberStatus, Workspace, WorkspaceMember

MANAGE = "data.manage"


def _hand_over(holder: PlaceholderUser, user: Any) -> int:
    """Make ``user`` an assignee of every task the placeholder had; returns how many."""
    rows = list(
        PlaceholderAssignment.objects.filter(placeholder=holder).select_related("task__project")
    )
    made = 0
    for row in rows:
        task = row.task
        visible = (
            task.project.visibility != Visibility.PRIVATE
            or ProjectMember.objects.filter(project=task.project, user=user).exists()
        )
        if visible and not task.deleted_at:
            _, created = TaskAssignee.objects.get_or_create(task=task, user=user)
            made += int(created)
    PlaceholderAssignment.objects.filter(placeholder=holder).delete()
    holder.claimed_by = user
    holder.save(update_fields=["claimed_by"])
    return made


def claim_by_email(workspace: Workspace, user: Any) -> int:
    """Hand over every unclaimed placeholder with ``user``'s email; returns the tasks assigned."""
    email = (user.email or "").lower()
    if not email:
        return 0
    total = 0
    with transaction.atomic():
        for holder in PlaceholderUser.objects.select_for_update().filter(
            workspace=workspace, key=email, claimed_by__isnull=True
        ):
            total += _hand_over(holder, user)
    return total


def list_unclaimed(actor: Any, workspace: Workspace) -> list[PlaceholderUser]:
    access.require(actor, MANAGE, workspace)
    return list(
        PlaceholderUser.objects.filter(workspace=workspace, claimed_by__isnull=True).order_by(
            "name"
        )
    )


def claim(actor: Any, workspace: Workspace, placeholder_id: str, user_id: str) -> int:
    """An admin hands a placeholder's tasks to a member."""
    access.require(actor, MANAGE, workspace)
    with transaction.atomic():
        holder = (
            PlaceholderUser.objects.select_for_update()
            .filter(pk=placeholder_id, workspace=workspace, claimed_by__isnull=True)
            .first()
        )
        member = (
            WorkspaceMember.objects.select_related("user")
            .filter(workspace=workspace, user_id=user_id, status=MemberStatus.ACTIVE)
            .first()
        )
        if holder is None or member is None:
            raise ApiError("No such placeholder or member.", status=404)
        assigned = _hand_over(holder, member.user)
        recorder.record(
            workspace_id=workspace.pk,
            action="placeholder.claimed",
            target_type="placeholder",
            target_id=holder.pk,
            actor=actor,
            changes={"claimed_by": str(member.user_id), "tasks": assigned},
        )
        return assigned


def task_counts(ids: list[Any]) -> dict[Any, int]:
    """How many tasks wait on each placeholder."""
    from django.db.models import Count

    rows = (
        PlaceholderAssignment.objects.filter(placeholder_id__in=ids)
        .values("placeholder_id")
        .annotate(n=Count("pk"))
    )
    return {r["placeholder_id"]: r["n"] for r in rows}
