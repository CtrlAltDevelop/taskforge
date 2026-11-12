"""Turn ``post_save`` / ``post_delete`` of the tracked models into audit entries.

They run inside the transaction of the change, so the entry and the change stand or fall
together. ``pre_save`` takes a snapshot of the watched fields so an edit can say "before -> after".
"""

from typing import Any

from django.apps import apps
from django.db.models.signals import post_delete, post_save, pre_save

from infrastructure.audit import changes, context
from infrastructure.audit.tracking import TRACKED


def _pre(sender: Any, instance: Any, **_: Any) -> None:
    instance._audit_before = None
    if instance._state.adding or instance.pk is None:
        return
    fields = TRACKED[sender._meta.label].fields
    row = sender._base_manager.filter(pk=instance.pk).values(*fields).first()
    instance._audit_before = row


def _saved(sender: Any, instance: Any, created: bool, raw: bool = False, **_: Any) -> None:
    if raw or context.is_suppressed():
        return
    if created:
        changes.created(instance)
    else:
        changes.updated(instance, getattr(instance, "_audit_before", None))


def _deleted(sender: Any, instance: Any, **_: Any) -> None:
    if not context.is_suppressed():
        changes.deleted(instance)


def connect() -> None:
    for label in TRACKED:
        model = apps.get_model(label)
        uid = f"audit:{label}"
        pre_save.connect(_pre, sender=model, dispatch_uid=f"{uid}:pre")
        post_save.connect(_saved, sender=model, dispatch_uid=f"{uid}:save")
        post_delete.connect(_deleted, sender=model, dispatch_uid=f"{uid}:delete")
