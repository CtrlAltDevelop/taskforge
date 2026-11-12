"""The one way a change is written to the log."""

import ipaddress
from typing import Any

from infrastructure.audit import context, redact
from infrastructure.audit.models import ActorType, AuditEntry


def _valid_ip(raw: str) -> str | None:
    try:
        return str(ipaddress.ip_address(raw))
    except ValueError:
        return None


def record(
    *,
    workspace_id: Any,
    action: str,
    target_type: str,
    target_id: Any,
    project_id: Any = None,
    changes: dict[str, Any] | None = None,
    actor: Any = None,
    actor_type: str = "",
    ip: str = "",
    user_agent: str = "",
) -> AuditEntry:
    """Append an entry. Called inside the changing transaction (a rollback takes it along).
    ``actor`` defaults to whoever the current call was authenticated as."""
    from infrastructure.sync.actor import current_actor

    who = (
        str(getattr(actor, "pk", actor) or "")
        if actor is not None
        else context.current_actor_id() or current_actor()
    )
    kind = (
        actor_type or context.current_actor_type() or (ActorType.USER if who else ActorType.SYSTEM)
    )
    seen_ip, seen_agent = context.current_client()
    ip, agent = ip or seen_ip, user_agent or seen_agent
    return AuditEntry.objects.create(
        workspace=workspace_id,
        actor=who,
        actor_type=kind,
        action=action[:80],
        target_type=target_type,
        target_id=str(target_id),
        project=project_id or None,
        changes=redact.clean(changes or {}),
        batch_id=context.current_batch(),
        ip=_valid_ip(ip),
        user_agent=agent,
    )
