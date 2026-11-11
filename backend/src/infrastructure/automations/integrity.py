"""A rule that names something that is gone is switched off, and its owner is told.

Checked when a project's workflow or custom fields change and when who may open what changes (a
member removed, a project made private). The rule keeps its settings and the reason, so the owner
can fix it and switch it on again (switching on is refused while it is still broken).
"""

from typing import Any

from django.db import transaction
from django.utils import timezone

from infrastructure.automations import signals, spec
from infrastructure.automations.models import Automation
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue, QueryError
from infrastructure.inbox import kinds, notify

REASON_MAX = 500


def problems_of(automation: Automation) -> list[str]:
    found = spec.dangling(automation.project, automation.trigger, automation.actions)
    ast = automation.condition_ast
    if ast and ast.get("where") is not None:
        try:
            language.canonical(ast, Catalogue(automation.project))
        except QueryError as error:
            found.append(f"The condition no longer holds up: {error.message}")
    return found


def _tell_owner(automation: Automation, reason: str) -> None:
    if automation.owner_id is None:
        return
    notify.notify(
        kind=kinds.AUTOMATION_DISABLED,
        recipients=[automation.owner_id],
        workspace=automation.workspace,
        project=automation.project,
        task=None,
        actor_id=None,
        payload={"automation": automation.name, "reason": reason},
        dedupe=f"automation-off:{automation.pk}:{automation.version}",
        fold=False,
    )


def disable(automation: Automation, reasons: list[str]) -> None:
    reason = " ".join(reasons)[:REASON_MAX]
    with transaction.atomic():
        automation.enabled = False
        automation.disabled_reason = reason
        automation.version += 1
        automation.updated_at = timezone.now()
        automation.save(update_fields=["enabled", "disabled_reason", "version", "updated_at"])
        signals.announce(automation, "updated")
    _tell_owner(automation, reason)


def _check(rows: Any) -> int:
    switched = 0
    for automation in rows.select_related("project", "workspace", "owner"):
        reasons = problems_of(automation)
        if reasons:
            disable(automation, reasons)
            switched += 1
    return switched


def check_project(project_id: Any) -> int:
    """Switch off the enabled rules of the project that are broken; returns how many."""
    return _check(Automation.objects.filter(project_id=project_id, enabled=True))


def check_workspace(workspace_id: Any) -> int:
    return _check(Automation.objects.filter(workspace_id=workspace_id, enabled=True))
