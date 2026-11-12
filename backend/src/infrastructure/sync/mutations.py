"""Applying a change once, however many times a client sends it.

An offline client keeps its changes in an outbox and sends them when it can; an answer that never
arrived means it sends the same change again. Every such call carries a ``client_mutation_id``: the
first one is applied and remembered, a repeat gets the entity as it is now. Without an id the call
is applied as it always was.
"""

import uuid
from collections.abc import Callable
from datetime import timedelta
from typing import Any, Final

from django.db import IntegrityError, transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.sync.models import AppliedMutation
from infrastructure.workspaces.models import Workspace

KEEP_DAYS: Final = 30  # a client that was offline longer than this starts over from a snapshot


def _id(raw: str) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise ApiError("client_mutation_id must be a UUID.", status=400) from None


def once[T](
    actor: Any,
    workspace: Workspace,
    mutation_id: str,
    rpc: str,
    apply: Callable[[], T],
    *,
    entity: Callable[[T], tuple[str, Any]],
    current: Callable[[AppliedMutation], T],
) -> T:
    """Run ``apply`` unless ``mutation_id`` was applied already (then ``current`` answers).

    ``entity(result)`` names what the change touched (type, id) for the record. A mutation id
    belongs to the person who first used it: another person sending it is refused."""
    if not mutation_id:
        return apply()
    key = _id(mutation_id)
    found = AppliedMutation.objects.filter(workspace=workspace, client_mutation_id=key).first()
    if found is not None:
        return _replay(actor, found, rpc, current)
    try:
        with transaction.atomic():
            result = apply()
            kind, ident = entity(result)
            AppliedMutation.objects.create(
                workspace=workspace,
                client_mutation_id=key,
                actor=str(actor.pk),
                rpc=rpc,
                entity_type=kind,
                entity_id=ident,
            )
        return result
    except IntegrityError:
        # Two sends of the same change raced: the other one won; answer with its result.
        found = AppliedMutation.objects.filter(workspace=workspace, client_mutation_id=key).first()
        if found is None:
            raise
        return _replay(actor, found, rpc, current)


def _replay[T](
    actor: Any, found: AppliedMutation, rpc: str, current: Callable[[AppliedMutation], T]
) -> T:
    if found.actor != str(actor.pk):
        raise ApiError("That mutation id was used by someone else.", status=409)
    if found.rpc != rpc:
        raise ApiError("That mutation id was used for a different change.", status=409)
    return current(found)


def purge(now: Any = None) -> int:
    """Forget mutations older than ``KEEP_DAYS``; returns how many."""
    cutoff = (now or timezone.now()) - timedelta(days=KEEP_DAYS)
    return AppliedMutation.objects.filter(created_at__lt=cutoff).delete()[0]
