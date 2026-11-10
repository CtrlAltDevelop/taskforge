"""Field definitions and the values tasks hold: the rules, on the services."""

import json
from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.customfields import services
from infrastructure.customfields.models import FieldDefinition, FieldValue
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db

OPTIONS = [{"label": "Bug", "color": "#FF0000"}, {"label": "Feature"}]


def _field(team: Any, project: Any, name: str = "Kind", type: str = "select", **extra: Any) -> Any:  # noqa: A002
    options = extra.pop("options", OPTIONS if type in ("select", "multiselect") else [])
    return services.create(
        team.owner, team.ws, str(project.pk), name=name, type=type, options=options, **extra
    )


def _task(team: Any, project: Any, who: Any = None, **values: str) -> Any:
    return tasks.create(
        who or team.member, team.ws, str(project.pk), "A task", field_values=values or None
    )


def _ids(field: Any) -> dict[str, str]:
    return {o["label"]: o["id"] for o in field.options}


def _edit(team: Any, project: Any, task: Any, **values: str) -> Any:
    return tasks.update(
        team.member,
        team.ws,
        str(project.pk),
        str(task.pk),
        task.version,
        {"field_values": values},
    )


@pytest.mark.parametrize(
    ("type", "good", "wire"),
    [
        ("text", "Acme", "Acme"),
        ("number", "3.50", "3.5"),
        ("date", "2026-12-24", "2026-12-24"),
        ("checkbox", "true", "true"),
        ("url", "https://a.example/b", "https://a.example/b"),
        ("money", "10 USD", "10.00 USD"),
    ],
)
def test_every_plain_type_saves_and_reads_back(
    team: Any,
    project: Any,
    type: str,
    good: str,
    wire: str,  # noqa: A002
) -> None:
    field = _field(team, project, "F", type)

    task = _task(team, project, **{str(field.pk): good})

    assert task.custom_values == {str(field.pk): wire}
    assert tasks.get(team.viewer, team.ws, str(project.pk), str(task.pk)).custom_values == {
        str(field.pk): wire
    }


def test_select_multiselect_and_user_values(team: Any, project: Any) -> None:
    kind = _field(team, project, "Kind")
    labels = _field(team, project, "Labels", "multiselect")
    owner = _field(team, project, "Reviewer", "user")
    ids = _ids(labels)

    task = _task(
        team,
        project,
        **{
            str(kind.pk): _ids(kind)["Bug"],
            str(labels.pk): f"{ids['Feature']},{ids['Bug']}",
            str(owner.pk): str(team.admin.pk),
        },
    )

    assert task.custom_values[str(kind.pk)] == _ids(kind)["Bug"]
    assert task.custom_values[str(labels.pk)] == f"{ids['Bug']},{ids['Feature']}"
    assert task.custom_values[str(owner.pk)] == str(team.admin.pk)


def test_user_field_refuses_someone_outside_the_workspace(team: Any, project: Any) -> None:
    field = _field(team, project, "Reviewer", "user")

    with pytest.raises(ApiError) as refusal:
        _task(team, project, **{str(field.pk): str(team.outsider.pk)})

    assert refusal.value.title is ResponseTitle.FIELD_INVALID


def test_invalid_value_refuses_the_create_and_leaves_nothing(team: Any, project: Any) -> None:
    field = _field(team, project, "Points", "number")

    with pytest.raises(ApiError) as refusal:
        _task(team, project, **{str(field.pk): "lots"})

    assert refusal.value.title is ResponseTitle.FIELD_INVALID
    assert tasks.list_page(team.owner, team.ws, str(project.pk))[0] == []


def test_required_field_blocks_task_creation_naming_every_missing_field(
    team: Any, project: Any
) -> None:
    a = _field(team, project, "Customer", "text", required=True)
    b = _field(team, project, "Points", "number", required=True)
    _field(team, project, "Notes", "text")

    with pytest.raises(ApiError) as refusal:
        _task(team, project)

    assert refusal.value.title is ResponseTitle.FIELD_REQUIRED
    assert set(json.loads((refusal.value.data or {})["fields"])) == {str(a.pk), str(b.pk)}
    assert "Customer" in str(refusal.value)
    assert _task(team, project, **{str(a.pk): "x", str(b.pk): "1"}).number == 1


def test_default_fills_a_new_task_and_satisfies_required(team: Any, project: Any) -> None:
    field = _field(team, project, "Env", "text", required=True, default="prod")

    task = _task(team, project)

    assert task.custom_values == {str(field.pk): "prod"}


def test_required_value_cannot_be_cleared_but_optional_can(team: Any, project: Any) -> None:
    need = _field(team, project, "Need", "text", required=True)
    free = _field(team, project, "Free", "text")
    task = _task(team, project, **{str(need.pk): "a", str(free.pk): "b"})

    with pytest.raises(ApiError) as refusal:
        _edit(team, project, task, **{str(need.pk): ""})
    cleared = _edit(team, project, task, **{str(free.pk): ""})

    assert refusal.value.title is ResponseTitle.FIELD_REQUIRED
    assert cleared.custom_values == {str(need.pk): "a"}


def test_old_task_without_a_required_value_can_still_be_edited(team: Any, project: Any) -> None:
    task = _task(team, project)
    _field(team, project, "Need", "text", required=True)

    edited = tasks.update(
        team.member, team.ws, str(project.pk), str(task.pk), task.version, {"title": "New"}
    )

    assert edited.title == "New"


def test_unknown_or_foreign_field_is_refused(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    foreign = _field(team, other, "Elsewhere", "text")

    for bad in ("nope", str(foreign.pk)):
        with pytest.raises(ApiError) as refusal:
            _task(team, project, **{bad: "x"})
        assert refusal.value.title is ResponseTitle.FIELD_INVALID


def test_different_fields_merge_and_the_same_field_conflicts(team: Any, project: Any) -> None:
    a = _field(team, project, "A", "text")
    b = _field(team, project, "B", "text")
    task = _task(team, project)

    first = _edit(team, project, task, **{str(a.pk): "one"})
    merged = tasks.update(
        team.admin,
        team.ws,
        str(project.pk),
        str(task.pk),
        task.version,
        {"field_values": {str(b.pk): "two"}},
    )
    with pytest.raises(ApiError) as refusal:
        tasks.update(
            team.admin,
            team.ws,
            str(project.pk),
            str(task.pk),
            task.version,
            {"field_values": {str(a.pk): "mine"}},
        )

    assert first.version == 2 and merged.version == 3
    assert merged.custom_values == {str(a.pk): "one", str(b.pk): "two"}
    assert refusal.value.title is ResponseTitle.VERSION_CONFLICT
    assert refusal.value.data == {"field": f"field:{a.pk}", "current": "one", "version": 3}


def test_viewer_cannot_set_values(team: Any, project: Any) -> None:
    field = _field(team, project, "A", "text")
    task = _task(team, project)

    with pytest.raises(access.PermissionDenied):
        tasks.update(
            team.viewer,
            team.ws,
            str(project.pk),
            str(task.pk),
            1,
            {"field_values": {str(field.pk): "x"}},
        )


# ---------------------------------------------------------------- definitions


def test_only_people_who_manage_the_project_edit_definitions(team: Any, project: Any) -> None:
    for who in (team.viewer, team.outsider):
        with pytest.raises((access.PermissionDenied, ApiError)):
            services.create(who, team.ws, str(project.pk), name="X", type="text")
    created = services.create(team.admin, team.ws, str(project.pk), name="X", type="text")

    assert created.position == 0
    assert [f.name for f in services.list_fields(team.viewer, team.ws, str(project.pk))] == ["X"]


def test_a_creator_manages_fields_of_their_own_project(team: Any) -> None:
    mine = team.create(team.pm, "PMS", name="Pms")

    created = services.create(team.pm, team.ws, str(mine.pk), name="X", type="text")

    assert created.name == "X"


def test_name_is_unique_ignoring_case_and_archived_names_are_free(team: Any, project: Any) -> None:
    first = _field(team, project, "Customer", "text")

    with pytest.raises(ApiError) as refusal:
        _field(team, project, "customer", "text")
    services.archive(team.owner, team.ws, str(project.pk), str(first.pk), first.version)
    again = _field(team, project, "customer", "text")

    assert refusal.value.title is ResponseTitle.FIELD_NAME_TAKEN
    with pytest.raises(ApiError) as clash:  # restoring would now clash
        services.restore(team.owner, team.ws, str(project.pk), str(first.pk), 2)
    assert clash.value.title is ResponseTitle.FIELD_NAME_TAKEN
    assert again.pk != first.pk


def test_at_most_fifty_active_fields(team: Any, project: Any) -> None:
    for n in range(services.MAX_ACTIVE):
        _field(team, project, f"F{n}", "text")

    with pytest.raises(ApiError) as refusal:
        _field(team, project, "One more", "text")

    assert refusal.value.title is ResponseTitle.FIELD_LIMIT


def test_other_workspace_and_archived_project_are_refused(team: Any, project: Any) -> None:
    with pytest.raises(ApiError):
        services.list_fields(team.outsider, team.ws, str(project.pk))
    from infrastructure.projects import services as project_services

    project_services.archive(team.owner, team.ws, str(project.pk), project.version)
    with pytest.raises(ApiError) as refusal:
        services.create(team.owner, team.ws, str(project.pk), name="X", type="text")
    assert refusal.value.title is ResponseTitle.PROJECT_ARCHIVED


def test_reorder_needs_every_active_field(team: Any, project: Any) -> None:
    a, b, c = (_field(team, project, n, "text") for n in "abc")

    ordered = services.reorder(
        team.owner, team.ws, str(project.pk), [str(c.pk), str(a.pk), str(b.pk)]
    )
    with pytest.raises(ApiError):
        services.reorder(team.owner, team.ws, str(project.pk), [str(a.pk)])

    assert [f.name for f in ordered] == ["c", "a", "b"]


def test_edit_name_required_default_and_stale_version(team: Any, project: Any) -> None:
    field = _field(team, project, "Env", "text")

    edited = services.update(
        team.owner,
        team.ws,
        str(project.pk),
        str(field.pk),
        1,
        {"name": "Environment", "required": True, "default": "prod", "hidden_views": ["board"]},
    )
    with pytest.raises(ApiError) as stale:
        services.update(team.owner, team.ws, str(project.pk), str(field.pk), 1, {"name": "X"})

    assert (edited.name, edited.required, edited.default, edited.version) == (
        "Environment",
        True,
        "prod",
        2,
    )
    assert edited.hidden_views == ["board"]
    assert stale.value.title is ResponseTitle.VERSION_CONFLICT


def test_default_must_be_valid_for_the_type(team: Any, project: Any) -> None:
    with pytest.raises(ApiError) as refusal:
        _field(team, project, "N", "number", default="abc")

    assert refusal.value.title is ResponseTitle.FIELD_INVALID


# ------------------------------------------------------------------ type changes


def test_text_and_url_convert_but_other_changes_are_refused(team: Any, project: Any) -> None:
    field = _field(team, project, "Link", "text")
    number = _field(team, project, "N", "number")
    _task(team, project, **{str(field.pk): "https://ok.example"})

    converted = services.update(
        team.owner, team.ws, str(project.pk), str(field.pk), 1, {"type": "url"}
    )
    with pytest.raises(ApiError) as refusal:
        services.update(team.owner, team.ws, str(project.pk), str(number.pk), 1, {"type": "text"})

    assert converted.type == "url"
    assert refusal.value.title is ResponseTitle.FIELD_INVALID


def test_text_with_a_non_url_value_cannot_become_url(team: Any, project: Any) -> None:
    field = _field(team, project, "Link", "text")
    _task(team, project, **{str(field.pk): "not a url"})

    with pytest.raises(ApiError) as refusal:
        services.update(team.owner, team.ws, str(project.pk), str(field.pk), 1, {"type": "url"})

    assert refusal.value.title is ResponseTitle.FIELD_INVALID
    assert FieldDefinition.objects.get(pk=field.pk).type == "text"


# ----------------------------------------------------------------- option remap


def test_removing_a_used_option_needs_a_remap_and_changes_nothing_without_it(
    team: Any, project: Any
) -> None:
    field = _field(team, project, "Kind")
    ids = _ids(field)
    task = _task(team, project, **{str(field.pk): ids["Bug"]})
    keep = [o for o in field.options if o["label"] == "Feature"]

    with pytest.raises(ApiError) as refusal:
        services.update(team.owner, team.ws, str(project.pk), str(field.pk), 1, {"options": keep})

    assert refusal.value.title is ResponseTitle.OPTION_NEEDS_REMAP
    assert json.loads((refusal.value.data or {})["options"]) == {ids["Bug"]: 1}
    assert FieldValue.objects.get(task=task).value_text == ids["Bug"]
    assert len(FieldDefinition.objects.get(pk=field.pk).options) == 2


def test_remap_moves_values_and_counts_an_edit_on_each_task(team: Any, project: Any) -> None:
    field = _field(team, project, "Kind")
    ids = _ids(field)
    task = _task(team, project, **{str(field.pk): ids["Bug"]})
    keep = [o for o in field.options if o["label"] == "Feature"]

    services.update(
        team.owner,
        team.ws,
        str(project.pk),
        str(field.pk),
        1,
        {"options": keep},
        {ids["Bug"]: ids["Feature"]},
    )

    fresh = tasks.get(team.owner, team.ws, str(project.pk), str(task.pk))
    assert fresh.custom_values == {str(field.pk): ids["Feature"]}
    assert fresh.version == task.version + 1


def test_remap_to_nothing_clears_and_multiselect_is_remapped_per_option(
    team: Any, project: Any
) -> None:
    single = _field(team, project, "Kind")
    multi = _field(team, project, "Labels", "multiselect")
    s, m = _ids(single), _ids(multi)
    task = _task(
        team, project, **{str(single.pk): s["Bug"], str(multi.pk): f"{m['Bug']},{m['Feature']}"}
    )

    services.update(
        team.owner,
        team.ws,
        str(project.pk),
        str(single.pk),
        1,
        {"options": [o for o in single.options if o["label"] == "Feature"]},
        {s["Bug"]: ""},
    )
    services.update(
        team.owner,
        team.ws,
        str(project.pk),
        str(multi.pk),
        1,
        {"options": [o for o in multi.options if o["label"] == "Feature"]},
        {m["Bug"]: ""},
    )

    fresh = tasks.get(team.owner, team.ws, str(project.pk), str(task.pk))
    assert fresh.custom_values == {str(multi.pk): m["Feature"]}


def test_removing_an_unused_option_needs_no_remap_and_default_follows_the_remap(
    team: Any, project: Any
) -> None:
    field = _field(team, project, "Kind")
    ids = _ids(field)
    services.update(team.owner, team.ws, str(project.pk), str(field.pk), 1, {"default": ids["Bug"]})
    keep = [o for o in field.options if o["label"] == "Feature"]

    updated = services.update(
        team.owner, team.ws, str(project.pk), str(field.pk), 2, {"options": keep}
    )

    assert updated.default == ""


def test_remap_target_must_be_a_kept_option(team: Any, project: Any) -> None:
    field = _field(team, project, "Kind")
    ids = _ids(field)
    _task(team, project, **{str(field.pk): ids["Bug"]})

    with pytest.raises(ApiError) as refusal:
        services.update(
            team.owner,
            team.ws,
            str(project.pk),
            str(field.pk),
            1,
            {"options": [o for o in field.options if o["label"] == "Feature"]},
            {ids["Bug"]: "zzz"},
        )

    assert refusal.value.title is ResponseTitle.FIELD_INVALID


# ------------------------------------------------------------- archive / restore


def test_archive_hides_values_and_restore_brings_them_back(team: Any, project: Any) -> None:
    field = _field(team, project, "Customer", "text", required=True)
    task = _task(team, project, **{str(field.pk): "Acme"})

    archived = services.archive(team.owner, team.ws, str(project.pk), str(field.pk), 1)
    hidden = tasks.get(team.owner, team.ws, str(project.pk), str(task.pk))
    second = _task(team, project)  # the archived field is no longer required
    restored = services.restore(team.owner, team.ws, str(project.pk), str(field.pk), 2)
    shown = tasks.get(team.owner, team.ws, str(project.pk), str(task.pk))

    assert archived.archived_at is not None and hidden.custom_values == {}
    assert second.custom_values == {}
    assert restored.archived_at is None and shown.custom_values == {str(field.pk): "Acme"}
    assert FieldValue.objects.filter(field=field).count() == 1


def test_archived_fields_are_listed_only_for_editors_and_values_cannot_be_set(
    team: Any, project: Any
) -> None:
    field = _field(team, project, "Customer", "text")
    services.archive(team.owner, team.ws, str(project.pk), str(field.pk), 1)

    with pytest.raises(access.PermissionDenied):
        services.list_fields(team.viewer, team.ws, str(project.pk), include_archived=True)
    listed = services.list_fields(team.owner, team.ws, str(project.pk), include_archived=True)
    with pytest.raises(ApiError):
        _task(team, project, **{str(field.pk): "x"})

    assert [f.pk for f in listed] == [field.pk]
    assert services.list_fields(team.viewer, team.ws, str(project.pk)) == []


def test_purge_removes_only_fields_archived_more_than_thirty_days_ago(
    team: Any, project: Any
) -> None:
    old = _field(team, project, "Old", "text")
    recent = _field(team, project, "Recent", "text")
    live = _field(team, project, "Live", "text")
    task = _task(team, project, **{str(old.pk): "x"})
    for field in (old, recent):
        services.archive(team.owner, team.ws, str(project.pk), str(field.pk), 1)
    FieldDefinition.objects.filter(pk=old.pk).update(
        archived_at=timezone.now() - timedelta(days=31)
    )

    purged = services.purge_expired()

    assert purged == 1
    assert set(FieldDefinition.objects.values_list("pk", flat=True)) == {recent.pk, live.pk}
    assert FieldValue.objects.filter(task=task).count() == 0
    with pytest.raises(ApiError):  # past the window it can no longer be restored
        services.restore(team.owner, team.ws, str(project.pk), str(old.pk), 2)


def test_restore_after_the_window_is_gone(team: Any, project: Any) -> None:
    field = _field(team, project, "Old", "text")
    services.archive(team.owner, team.ws, str(project.pk), str(field.pk), 1)
    FieldDefinition.objects.filter(pk=field.pk).update(
        archived_at=timezone.now() - timedelta(days=31)
    )

    with pytest.raises(ApiError) as refusal:
        services.restore(team.owner, team.ws, str(project.pk), str(field.pk), 2)

    assert refusal.value.status == 404


def test_a_default_user_who_left_never_blocks_task_creation_or_field_edits(
    team: Any, project: Any
) -> None:
    field = _field(team, project, "Reviewer", "user", default=str(team.admin.pk))
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    WorkspaceMember.objects.filter(user=team.admin).update(status=MemberStatus.REMOVED)

    task = _task(team, project)
    renamed = services.update(
        team.owner, team.ws, str(project.pk), str(field.pk), 1, {"name": "Checker"}
    )

    assert task.custom_values == {}
    assert renamed.name == "Checker" and renamed.default == str(team.admin.pk)


def test_a_required_field_whose_default_no_longer_fits_is_reported_missing(
    team: Any, project: Any
) -> None:
    _field(team, project, "Reviewer", "user", required=True, default=str(team.admin.pk))
    from infrastructure.workspaces.models import MemberStatus, WorkspaceMember

    WorkspaceMember.objects.filter(user=team.admin).update(status=MemberStatus.REMOVED)

    with pytest.raises(ApiError) as refusal:
        _task(team, project)

    assert refusal.value.title is ResponseTitle.FIELD_REQUIRED


@pytest.mark.parametrize("bad_id", ["a,b", "x" * 3000, "o-bug", "ABC"])
def test_option_ids_must_be_the_form_the_server_issues(
    team: Any, project: Any, bad_id: str
) -> None:
    with pytest.raises(ApiError) as refusal:
        _field(team, project, "Kind", options=[{"id": bad_id, "label": "X"}])

    assert refusal.value.title is ResponseTitle.FIELD_INVALID


def test_a_full_multiselect_default_fits_the_column(team: Any, project: Any) -> None:
    options = [{"label": f"o{n}"} for n in range(types_max())]
    probe = _field(team, project, "Many", "multiselect", options=options)
    everything = ",".join(o["id"] for o in probe.options)

    saved = services.update(
        team.owner, team.ws, str(project.pk), str(probe.pk), 1, {"default": everything}
    )

    assert saved.default == everything


def types_max() -> int:
    from infrastructure.customfields.types import OPTIONS_MAX

    return OPTIONS_MAX
