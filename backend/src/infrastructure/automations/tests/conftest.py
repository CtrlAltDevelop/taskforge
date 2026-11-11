from dataclasses import replace
from typing import Any

import pytest

from infrastructure.automations import services
from infrastructure.customfields import services as fields
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks import services as tasks
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft, WorkflowDraft
from infrastructure.workflows.models import Status

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team


@pytest.fixture
def web(team: Any) -> Any:
    project = team.create(team.owner, "WEB")
    workflows.ensure(project)
    return project


@pytest.fixture
def other(team: Any) -> Any:
    project = team.create(team.owner, "OTH", name="Other")
    workflows.ensure(project)
    return project


def status_of(project: Any, name: str) -> Any:
    return Status.objects.get(project=project, name=name)


def make_task(team: Any, project: Any, title: str = "Task", **kw: Any) -> Any:
    return tasks.create(team.owner, team.ws, str(project.pk), title, **kw)


def edit(team: Any, project: Any, task: Any, **changes: Any) -> Any:
    current = tasks.get(team.owner, team.ws, str(project.pk), str(task.pk))
    return tasks.update(
        team.owner, team.ws, str(project.pk), str(task.pk), current.version, changes
    )


def make_rule(
    team: Any,
    project: Any,
    trigger: Any,
    actions: Any,
    *,
    actor: Any = None,
    name: str = "Rule",
    condition: str = "",
) -> Any:
    view = services.create(
        actor or team.owner,
        team.ws,
        str(project.pk),
        name,
        trigger,
        actions,
        condition_tfql=condition,
    )
    return view.automation


def comment_action(text: str = "hello") -> dict[str, Any]:
    return {"type": "add_comment", "text": text}


def date_field(team: Any, project: Any, name: str = "Completed on") -> Any:
    return fields.create(team.owner, team.ws, str(project.pk), name=name, type="date")


def add_status(team: Any, project: Any, name: str) -> Any:
    view = workflows.get(team.owner, team.ws, str(project.pk))
    draft = _draft(view)
    draft = replace(
        draft, statuses=(*draft.statuses, StatusDraft("new", name, "#112233", "active"))
    )
    workflows.update(team.owner, team.ws, str(project.pk), view.workflow.version, draft, {})
    return status_of(project, name)


def drop_status(team: Any, project: Any, name: str) -> None:
    view = workflows.get(team.owner, team.ws, str(project.pk))
    draft = _draft(view)
    kept = tuple(s for s in draft.statuses if s.name != name)
    workflows.update(
        team.owner,
        team.ws,
        str(project.pk),
        view.workflow.version,
        replace(draft, statuses=kept),
        {},
    )


def _draft(view: Any) -> WorkflowDraft:
    return WorkflowDraft(
        statuses=tuple(
            StatusDraft(str(s.pk), s.name, s.color, s.category, s.is_default) for s in view.statuses
        )
    )
