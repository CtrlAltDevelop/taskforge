"""What the security app decides at sign-in, called from ``auth.core.flows.complete_login``.

``complete_login`` is the one function every sign-in ends in. It asks this module two
questions: may this account use this *first factor* at all (SSO-only workspaces), and may it
skip the *second factor* (a single-sign-on login, or a trusted device).
"""

from typing import Any

from django.http import HttpRequest

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import devices
from infrastructure.security.models import IdentityProvider
from infrastructure.workspaces.models import MemberStatus, WorkspaceMember
from infrastructure.workspaces.registry import OWNER

SSO_METHOD = "sso"


def is_sso(method: str) -> bool:
    return method == SSO_METHOD or method.startswith(f"{SSO_METHOD}:")


def check_first_factor(user: Any, method: str) -> None:
    """Refuse a password (or code, or link) sign-in for members of an SSO-only workspace.

    Owners are exempt: they keep one way in if the identity provider is unreachable.
    """
    if is_sso(method):
        return
    enforcing = IdentityProvider.objects.filter(
        enforce_sso=True,
        enabled=True,
        workspace__deleted_at__isnull=True,
        workspace__members__user=user,
        workspace__members__status=MemberStatus.ACTIVE,
    ).values_list("workspace_id", flat=True)
    workspace_ids = list(enforcing)
    if not workspace_ids:
        return
    owned = WorkspaceMember.objects.filter(
        user=user,
        workspace_id__in=workspace_ids,
        status=MemberStatus.ACTIVE,
        role__is_builtin=True,
        role__name=OWNER,
    ).values_list("workspace_id", flat=True)
    if set(workspace_ids) - set(owned):
        raise ApiError(
            "Your workspace requires single sign-on. Use Continue with SSO.",
            status=403,
            title=ResponseTitle.SSO_REQUIRED,
        )


def skips_second_factor(request: HttpRequest, user: Any, method: str) -> str:
    """Why this sign-in needs no local second factor: ``sso``, ``trusted_device`` or ``""``."""
    if is_sso(method):
        return "sso"  # the identity provider did the multi-factor
    if devices.is_trusted(request, user):
        return "trusted_device"
    return ""
