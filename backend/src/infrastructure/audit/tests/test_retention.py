"""Retention: off by default, and the one way an entry is ever deleted."""

from datetime import timedelta
from typing import Any

import pytest
from django.core.management import call_command
from django.db import models
from django.utils import timezone

from infrastructure.audit import recorder, retention
from infrastructure.audit.models import AuditEntry, ImmutableError


def _entry(days_old: int, action: str = "x.y") -> AuditEntry:
    entry = recorder.record(workspace_id="11111111-1111-1111-1111-111111111111", action=action,
                            target_type="x", target_id="1")  # fmt: skip
    entry.at = timezone.now() - timedelta(days=days_old)
    models.Model.save(entry, force_update=True)  # bypasses the guard: the fixture sets an age
    return entry


def test_nothing_is_purged_by_default(db: None, settings: Any) -> None:
    settings.AUDIT_RETENTION_DAYS = 0
    _entry(4000)
    assert retention.purge() == 0
    assert AuditEntry.objects.count() == 1


def test_entries_older_than_the_retention_go_and_newer_stay(db: None, settings: Any) -> None:
    settings.AUDIT_RETENTION_DAYS = 90
    old, fresh = _entry(120, "old.one"), _entry(10, "new.one")
    assert retention.purge() == 1
    assert list(AuditEntry.objects.values_list("pk", flat=True)) == [fresh.pk]
    assert not AuditEntry.objects.filter(pk=old.pk).exists()


def test_the_purge_command_reports_and_uses_the_setting(
    db: None, settings: Any, capsys: Any
) -> None:
    settings.AUDIT_RETENTION_DAYS = 30
    _entry(31)
    call_command("purge_audit")
    assert "removed 1" in capsys.readouterr().out
    assert AuditEntry.objects.count() == 0


def test_everything_else_still_refuses_to_delete_or_change(db: None, settings: Any) -> None:
    settings.AUDIT_RETENTION_DAYS = 1
    entry = _entry(5)
    with pytest.raises(ImmutableError):
        entry.delete()
    with pytest.raises(ImmutableError):
        AuditEntry.objects.filter(pk=entry.pk).delete()
    with pytest.raises(ImmutableError):
        AuditEntry.objects.filter(pk=entry.pk).update(action="x")
    entry.action = "changed"
    with pytest.raises(ImmutableError):
        entry.save()
