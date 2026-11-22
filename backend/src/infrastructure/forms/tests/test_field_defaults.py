"""A form can start its tasks with project field values — labels are a multi-select field."""

import json
from typing import Any

import pytest
from django.test import Client

from infrastructure.common.errors import ApiError
from infrastructure.customfields import services as fields
from infrastructure.customfields.models import FieldDefinition
from infrastructure.customfields.values import current
from infrastructure.forms import services
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks.models import Task

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team

FIELDS = [{"id": "t", "kind": "title", "label": "Title"}]


@pytest.fixture
def labels(team: Any) -> tuple[Any, FieldDefinition, dict[str, str]]:
    project = team.create(team.owner, "WEB")
    field = fields.create(
        team.owner,
        team.ws,
        str(project.pk),
        name="Labels",
        type="multiselect",
        options=[{"label": "bug"}, {"label": "intake"}],
    )
    return project, field, {o["label"]: o["id"] for o in field.options}


def _submit(form: Any) -> Task:
    response = Client().post(
        f"/api/v1/public/forms/{form.token}/submit", {"answers": json.dumps({"t": "Broken"})}
    )
    assert response.status_code == 201
    return Task.objects.get()


def _labels_of(task: Task, field: FieldDefinition) -> list[str]:
    return [p for p in current(task, str(field.pk)).split(",") if p]


def test_default_labels_are_put_on_every_task_the_form_makes(team: Any, labels: Any) -> None:
    project, field, ids = labels
    defaults = {"field_defaults": {str(field.pk): f"{ids['bug']},{ids['intake']}"}}

    view = services.create(
        team.owner, team.ws, str(project.pk), "Bug", fields=FIELDS, defaults=defaults
    )

    assert view.form.defaults["field_defaults"] == defaults["field_defaults"]
    task = _submit(view.form)
    assert set(_labels_of(task, field)) == {ids["bug"], ids["intake"]}


def test_a_default_for_a_field_that_is_not_the_projects_is_refused(team: Any, labels: Any) -> None:
    project, _, _ = labels
    with pytest.raises(ApiError):
        services.create(
            team.owner,
            team.ws,
            str(project.pk),
            "Bug",
            fields=FIELDS,
            defaults={"field_defaults": {"00000000-0000-0000-0000-000000000000": "x"}},
        )


def test_a_default_that_names_a_missing_option_is_refused(team: Any, labels: Any) -> None:
    project, field, _ = labels
    with pytest.raises(ApiError):
        services.create(
            team.owner,
            team.ws,
            str(project.pk),
            "Bug",
            fields=FIELDS,
            defaults={"field_defaults": {str(field.pk): "nope"}},
        )


def test_a_default_that_went_stale_is_skipped_not_fatal(team: Any, labels: Any) -> None:
    project, field, ids = labels
    view = services.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Bug",
        fields=FIELDS,
        defaults={"field_defaults": {str(field.pk): ids["bug"]}},
    )
    fields.archive(team.owner, team.ws, str(project.pk), str(field.pk), field.version)

    task = _submit(view.form)

    assert task.title == "Broken"


def test_the_visitors_own_answer_wins_over_the_default(team: Any, labels: Any) -> None:
    project, field, ids = labels
    form_fields = [*FIELDS, {"id": "l", "kind": "custom", "custom_field_id": str(field.pk)}]
    view = services.create(
        team.owner,
        team.ws,
        str(project.pk),
        "Bug",
        fields=form_fields,
        defaults={"field_defaults": {str(field.pk): ids["bug"]}},
    )

    Client().post(
        f"/api/v1/public/forms/{view.form.token}/submit",
        {"answers": json.dumps({"t": "Hi", "l": ids["intake"]})},
    )

    assert _labels_of(Task.objects.get(), field) == [ids["intake"]]
