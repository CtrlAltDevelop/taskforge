"""Sign-in and account-security events, filed under every workspace the person belongs to (an
admin of a workspace sees who signed in to it, not what they did elsewhere)."""

import logging
from typing import Any, Final

from infrastructure.audit import recorder

log = logging.getLogger(__name__)

# AuthEvent types worth showing an admin; failures have no person to file them under.
AUDITED: Final = frozenset(
    {
        "login_succeeded",
        "password_changed",
        "second_factor_enrolled",
        "second_factor_removed",
    }
)


def record(event_type: str, user: Any, ip: str, user_agent: str) -> None:
    if event_type not in AUDITED or user is None:
        return
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    try:
        workspaces = list(
            WorkspaceMember.objects.filter(user=user, status=MemberStatus.ACTIVE).values_list(
                "workspace_id", flat=True
            )
        )
        for workspace_id in workspaces:
            recorder.record(
                workspace_id=workspace_id,
                action=f"auth.{event_type}",
                target_type="user",
                target_id=user.pk,
                actor=user,
                ip=ip,
                user_agent=user_agent,
            )
    except Exception:  # never let the log stop a sign-in; the failure itself is logged
        log.exception("Could not record %s for the audit log", event_type)
