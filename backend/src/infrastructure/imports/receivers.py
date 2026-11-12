"""A person who joins the workspace with the email of a placeholder takes over that placeholder."""

import logging
from typing import Any

from django.db.models.signals import post_save

from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

logger = logging.getLogger(__name__)


def _joined(sender: Any, instance: WorkspaceMember, created: bool, **kw: Any) -> None:
    if not created or instance.status != MemberStatus.ACTIVE or not instance.user.email:
        return
    try:
        from infrastructure.imports import placeholders

        placeholders.claim_by_email(instance.workspace, instance.user)
    except Exception:  # noqa: BLE001 -- joining must never fail because of an old import
        logger.exception("imports could not claim placeholders for a new member")


def connect() -> None:
    post_save.connect(_joined, sender=WorkspaceMember, dispatch_uid="imports.member_joined")
