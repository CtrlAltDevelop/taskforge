"""Tick the checklist from what the server sees: a task created, an invitation sent."""

import logging
from typing import Any

from django.db import transaction
from django.db.models.signals import post_delete, post_save
from django.dispatch import receiver

from infrastructure.home import onboarding, summary
from infrastructure.sync.actor import current_actor
from infrastructure.tasks.models import Task, TaskAssignee
from infrastructure.workspaces.models import Invitation

logger = logging.getLogger(__name__)


def _tick(user_id: Any, workspace_id: Any, step: str) -> None:
    try:
        with transaction.atomic():  # a savepoint: a failure here must not poison the caller's
            onboarding.tick_for(user_id, workspace_id, step)
    except Exception:  # noqa: BLE001 -- the checklist is a nicety, never a reason to fail
        logger.exception("could not tick onboarding step %s", step)


@receiver(post_save, sender=Task, dispatch_uid="home.task_created")
def task_created(sender: Any, instance: Task, created: bool, **kwargs: Any) -> None:
    if created and not onboarding.is_building_samples():
        _tick(instance.created_by_id, instance.workspace_id, "create_task")


@receiver(post_save, sender=Task, dispatch_uid="home.task_saved")
def task_saved(sender: Any, instance: Task, **kwargs: Any) -> None:
    """A task changed: the people it concerns see it on Home at once, not after 30 s."""
    people = {
        instance.created_by_id,
        *TaskAssignee.objects.filter(task_id=instance.pk).values_list("user_id", flat=True),
    }
    if actor := current_actor():
        people.add(actor)
    for user_id in people:
        summary.forget(user_id, instance.workspace_id)


@receiver(post_save, sender=TaskAssignee, dispatch_uid="home.assignee_added")
@receiver(post_delete, sender=TaskAssignee, dispatch_uid="home.assignee_removed")
def assignee_changed(sender: Any, instance: TaskAssignee, **kwargs: Any) -> None:
    workspace_id = Task.objects.filter(pk=instance.task_id).values_list("workspace_id", flat=True)
    for found in workspace_id:
        summary.forget(instance.user_id, found)


@receiver(post_save, sender=Invitation, dispatch_uid="home.invitation_created")
def invitation_created(sender: Any, instance: Invitation, created: bool, **kwargs: Any) -> None:
    if created:
        _tick(instance.created_by_id, instance.workspace_id, "invite_member")
