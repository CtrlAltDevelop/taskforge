"""A workspace's two-factor policy, and the one check that enforces it.

``check`` is called from ``workspaces.scoping.require_workspace``, the door every
workspace-scoped call goes through, so a member who has not enrolled once the grace
period is over is refused everywhere at once -- except in the security screens, which
resolve their workspace with ``enforce=False`` so the person can still enrol.
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any

from django.core.cache import cache
from django.db import transaction
from django.utils import timezone

from infrastructure.audit import recorder
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.security.models import ExternalIdentity, SecurityPolicy
from infrastructure.workspaces import access

MAX_GRACE_DAYS = 90
_CACHE_SECONDS = 30


def _cache_key(workspace_id: Any) -> str:
    return f"security:policy:{workspace_id}"


@dataclass(frozen=True, slots=True)
class PolicyState:
    require_2fa: bool
    grace_days: int
    enforced_from: datetime | None
    version: int

    @property
    def in_grace(self) -> bool:
        return (
            self.require_2fa
            and self.enforced_from is not None
            and self.enforced_from > timezone.now()
        )

    @property
    def enforcing(self) -> bool:
        return self.require_2fa and not self.in_grace


def policy_state(workspace: Any) -> PolicyState:
    """The policy, cached briefly: it is read by every workspace call."""
    key = _cache_key(workspace.pk)
    cached = cache.get(key)
    if cached is not None:
        return PolicyState(*cached)
    row = SecurityPolicy.objects.filter(workspace=workspace).first()
    state = (
        PolicyState(row.require_2fa, row.grace_days, row.enforced_from, row.version)
        if row
        else PolicyState(False, 7, None, 0)
    )
    cache.set(
        key,
        (state.require_2fa, state.grace_days, state.enforced_from, state.version),
        _CACHE_SECONDS,
    )
    return state


def has_totp(user: Any) -> bool:
    from infrastructure.auth.core.flows import enrolled_second_factors

    return "totp" in enrolled_second_factors(user)


def covered_by_sso(user: Any, workspace: Any) -> bool:
    """A person who signs in through the workspace's provider has its multi-factor instead."""
    return ExternalIdentity.objects.filter(
        user=user, provider__workspace=workspace, provider__enabled=True
    ).exists()


def is_blocked(user: Any, workspace: Any) -> bool:
    state = policy_state(workspace)
    if not state.enforcing:
        return False
    if hasattr(user, "service_account"):
        return False  # nobody can sign in as a service account; its tokens are the credential
    return not (has_totp(user) or covered_by_sso(user, workspace))


def check(user: Any, workspace: Any) -> None:
    """Refuse the call when the workspace requires two-factor and ``user`` has none."""
    if is_blocked(user, workspace):
        raise ApiError(
            "This workspace requires two-factor authentication. Turn it on in Security settings.",
            status=403,
            title=ResponseTitle.TWO_FACTOR_REQUIRED,
        )


def set_policy(
    workspace: Any, actor: Any, *, require_2fa: bool, grace_days: int, expected_version: int
) -> PolicyState:
    """Switch the requirement on or off (``security.manage``). Turning it on starts the grace."""
    if not 0 <= grace_days <= MAX_GRACE_DAYS:
        raise ApiError(
            f"The grace period is 0 to {MAX_GRACE_DAYS} days.",
            status=400,
            title=ResponseTitle.VALIDATION_ERROR,
        )
    with transaction.atomic():
        access.require(actor, "security.manage", workspace)
        row, created = SecurityPolicy.objects.select_for_update().get_or_create(workspace=workspace)
        # Before the first save a client sees version 0; a fresh row is version 1.
        if expected_version != (0 if created else row.version) and expected_version != row.version:
            raise ApiError(
                "The policy changed meanwhile.", status=409, title=ResponseTitle.VERSION_CONFLICT
            )
        was_on = row.require_2fa
        row.require_2fa = require_2fa
        row.grace_days = grace_days
        if require_2fa and (not was_on or row.enforced_from is None):
            row.enforced_from = timezone.now() + timedelta(days=grace_days)
        elif (
            require_2fa
            and was_on
            and row.enforced_from is not None
            and row.enforced_from > timezone.now()
        ):
            # A changed grace applies from now, but only while it is still running.
            row.enforced_from = timezone.now() + timedelta(days=grace_days)
        if not require_2fa:
            row.enforced_from = None
        row.updated_by = actor
        row.version += 1
        row.save()
        recorder.record(
            workspace_id=workspace.pk,
            action="security.policy_changed",
            target_type="workspace",
            target_id=workspace.pk,
            actor=actor,
            changes={"require_2fa": require_2fa, "grace_days": grace_days},
        )
    cache.delete(_cache_key(workspace.pk))
    return policy_state(workspace)
