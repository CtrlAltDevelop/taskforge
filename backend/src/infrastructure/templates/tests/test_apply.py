"""Applying a template: all or nothing, and tolerant of what changed since it was saved."""

import json
from typing import Any

import pytest

from infrastructure.audit.models import AuditEntry
from infrastructure.common.errors import ApiError
from infrastructure.projects.models import Project
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks.models import Task
from infrastructure.templates import apply, services

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


def _tasks(*titles: str, **extra: Any) -> list[dict[str, Any]]:
    return [{"ref": f"r{i}", "title": t, **extra} for i, t in enumerate(titles)]


def _template(team: Any, kind: str, body: dict[str, Any]) -> str:
    view = services.create(
        team.owner, team.ws, kind, "T", "", "workspace", json.dumps({"schema": 1, **body})
    )
    return view.id


def test_failure_midway_leaves_nothing_behind(team: Any, monkeypatch: pytest.MonkeyPatch) -> None:
    template_id = _template(team, "project", {"tasks": _tasks("one", "two", "three")})
    real = apply.task_services.create
    calls: list[str] = []

    def flaky(*args: Any, **kwargs: Any) -> Any:
        calls.append(args[3])
        if len(calls) == 2:
            raise ApiError("boom")
        return real(*args, **kwargs)

    monkeypatch.setattr(apply.task_services, "create", flaky)
    projects, tasks, audit = (m.objects.count() for m in (Project, Task, AuditEntry))
    with pytest.raises(ApiError):
        apply.apply(
            team.owner,
            team.ws,
            template_id,
            project=apply.ProjectParams(name="Fresh", key="FRSH"),
        )
    assert calls == ["one", "two"]  # it did get as far as the second task
    assert Project.objects.count() == projects
    assert not Project.objects.filter(key="FRSH").exists()
    assert Task.objects.count() == tasks
    assert AuditEntry.objects.count() == audit  # no template.applied, no project.created


def test_a_field_removed_since_is_skipped_with_a_warning(team: Any) -> None:
    project = team.create(team.owner, "WEB")
    gone = {"name": "Gone", "type": "text", "value": "x"}
    template_id = _template(team, "task", {"tasks": _tasks("a", "b", fields=[gone])})
    result = apply.apply(team.owner, team.ws, template_id, project_id=str(project.pk))
    assert len(result.task_ids) == 2
    assert [w.code for w in result.warnings] == ["FIELD_GONE"]  # once, not per task
    assert Task.objects.filter(project=project).count() == 2


def test_an_unknown_status_falls_back_to_the_default(team: Any) -> None:
    project = team.create(team.owner, "WEB")
    template_id = _template(team, "task", {"tasks": _tasks("a", status="Nonexistent")})
    result = apply.apply(team.owner, team.ws, template_id, project_id=str(project.pk))
    assert [w.code for w in result.warnings] == ["STATUS_GONE"]
    assert Task.objects.get(pk=result.task_ids[0]).status_id is not None


def test_a_non_member_assignee_is_left_unassigned(team: Any) -> None:
    project = team.create(team.owner, "WEB")
    stranger = str(team.outsider.pk)  # a member of another workspace only
    member = str(team.member.pk)
    template_id = _template(
        team, "task", {"tasks": _tasks("a", assignee_ids=[stranger, member, "not-a-uuid"])}
    )
    result = apply.apply(team.owner, team.ws, template_id, project_id=str(project.pk))
    task = Task.objects.get(pk=result.task_ids[0])
    assert [str(u) for u in task.assignee_ids()] == [member]
    assert [w.code for w in result.warnings] == ["PEOPLE_DROPPED"]
    assert "2 person" in result.warnings[0].message


def test_missing_variables_refuse_before_anything_is_made(team: Any) -> None:
    template_id = _template(team, "project", {"tasks": _tasks("Ship {{release}}")})
    before = Project.objects.count()
    with pytest.raises(ApiError):
        apply.apply(
            team.owner, team.ws, template_id, project=apply.ProjectParams(name="P", key="PP")
        )
    assert Project.objects.count() == before
