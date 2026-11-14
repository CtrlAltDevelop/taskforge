"""Folder changes are audited like every other goal mutation."""

from typing import Any

import pytest

from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.goals import services
from infrastructure.goals.models import GoalFolder
from infrastructure.projects.tests import conftest as project_fixtures

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


def _actions(team: Any) -> list[str]:
    rows = AuditEntry.objects.filter(workspace=team.ws.pk, action__startswith="goal.folder")
    return [r.action for r in rows.order_by("id")]


def test_create_rename_and_delete_each_write_an_entry(team: Any) -> None:
    folder = services.save_folder(team.owner, team.ws, "", "Q1")
    services.save_folder(team.owner, team.ws, str(folder.pk), "Q2")
    services.delete_folder(team.owner, team.ws, str(folder.pk))
    assert _actions(team) == ["goal.folder_created", "goal.folder_renamed", "goal.folder_deleted"]
    assert not GoalFolder.objects.exists()


def test_a_refused_change_writes_nothing(team: Any) -> None:
    with pytest.raises(ApiError):
        services.save_folder(team.viewer, team.ws, "", "Nope")
    assert _actions(team) == []
