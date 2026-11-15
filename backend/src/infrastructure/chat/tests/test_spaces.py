from typing import Any

import pytest
from django.db import IntegrityError, transaction

from infrastructure.chat import access, services
from infrastructure.chat.models import ChatMember, ChatSpace
from infrastructure.common.errors import ApiError
from infrastructure.workspaces import services as workspaces
from infrastructure.workspaces.access import PermissionDenied

pytestmark = pytest.mark.django_db


def names(spaces: list[Any]) -> list[str]:
    return [s.display_name for s in spaces]


def test_a_new_workspace_has_general_and_everyone_is_in_it(team: Any) -> None:
    general = ChatSpace.objects.get(workspace=team.ws, is_default=True)

    assert general.name == "general" and general.kind == "channel"
    assert access.members(general) == {team.owner.pk, team.admin.pk, team.member.pk, team.pm.pk}


def test_only_one_general_per_workspace_and_one_channel_per_project(team: Any) -> None:
    project = team.create(team.owner, "WEB", name="Website")

    with pytest.raises(IntegrityError), transaction.atomic():
        ChatSpace.objects.create(workspace=team.ws, name="again", is_default=True)
    with pytest.raises(IntegrityError), transaction.atomic():
        ChatSpace.objects.create(workspace=team.ws, name="again", project=project)
    assert ChatSpace.objects.get(project=project).name == "Website"


def test_listing_makes_the_channels_of_older_workspaces_and_projects(team: Any) -> None:
    project = team.create(team.owner, "WEB", name="Website")
    ChatSpace.objects.filter(workspace=team.ws).delete()

    listed = services.list_spaces(team.member, team.ws)

    assert names(listed.channels) == ["general", "Website"]
    assert ChatSpace.objects.filter(project=project).count() == 1


def test_a_guest_cannot_use_chat_at_all(team: Any) -> None:
    with pytest.raises(PermissionDenied):
        services.list_spaces(team.viewer, team.ws)


def test_create_a_channel_and_a_group(team: Any) -> None:
    channel = services.create_space(team.member, team.ws, "channel", "  #Random ", [])
    group = services.create_space(team.member, team.ws, "group", "Plans", [str(team.pm.pk)])

    assert (channel.name, channel.my_role, channel.joined) == ("Random", "owner", True)
    assert access.members(group) == {team.member.pk, team.pm.pk}
    assert names(services.list_spaces(team.pm, team.ws).groups) == ["Plans"]
    assert names(services.list_spaces(team.owner, team.ws).groups) == []


def test_creating_refuses_bad_names_duplicates_guests_and_small_groups(team: Any) -> None:
    services.create_space(team.member, team.ws, "channel", "random", [])
    for kind, name, ids in (
        ("channel", "RANDOM", []),
        ("channel", "  ", []),
        ("channel", "x" * 81, []),
        ("group", "Solo", []),
        ("group", "Guests", [str(team.viewer.pk)]),
        ("group", "Out", [str(team.outsider.pk)]),
        ("dm", "x", []),
    ):
        with pytest.raises(ApiError):
            services.create_space(team.member, team.ws, kind, name, ids)


def test_open_dm_is_idempotent_and_symmetric(team: Any) -> None:
    first = services.open_dm(team.member, team.ws, str(team.pm.pk))
    again = services.open_dm(team.member, team.ws, str(team.pm.pk))
    back = services.open_dm(team.pm, team.ws, str(team.member.pk))

    assert first.pk == again.pk == back.pk
    assert first.peer_id == str(team.pm.pk) and back.peer_id == str(team.member.pk)
    assert names(services.list_spaces(team.owner, team.ws).dms) == []
    with pytest.raises(ApiError):
        services.open_dm(team.member, team.ws, str(team.member.pk))
    with pytest.raises(ApiError):
        services.open_dm(team.member, team.ws, str(team.viewer.pk))


def test_open_dm_survives_losing_the_race(team: Any, monkeypatch: pytest.MonkeyPatch) -> None:
    real = ChatSpace.objects.filter
    calls = {"n": 0}
    other = services.open_dm(team.pm, team.ws, str(team.member.pk))

    class Blind:
        def first(self) -> None:
            return None

    def blind_once(*a: Any, **kw: Any) -> Any:
        calls["n"] += 1
        return Blind() if calls["n"] == 1 else real(*a, **kw)

    monkeypatch.setattr(ChatSpace.objects, "filter", blind_once)

    got = services.open_dm(team.member, team.ws, str(team.pm.pk))

    assert got.pk == other.pk
    assert ChatSpace.objects.filter(kind="dm").count() == 1


def test_join_and_leave_a_channel(team: Any) -> None:
    made = services.create_space(team.member, team.ws, "channel", "random", [])

    assert services.get(team.pm, team.ws, str(made.pk)).joined is False
    assert services.join(team.pm, team.ws, str(made.pk)).joined is True
    services.leave(team.pm, team.ws, str(made.pk))
    assert services.get(team.pm, team.ws, str(made.pk)).joined is False
    with pytest.raises(ApiError):
        services.leave(team.pm, team.ws, str(services.ensure_general(team.ws).pk))


def test_the_owner_leaving_a_group_passes_ownership_on(team: Any, group: Any) -> None:
    services.leave(team.owner, team.ws, str(group.pk))

    assert ChatMember.objects.filter(space=group, role="owner").count() == 1
    with pytest.raises(ApiError):
        services.get(team.owner, team.ws, str(group.pk))


def test_add_and_remove_members_of_a_group(team: Any, group: Any) -> None:
    services.add_members(team.member, team.ws, str(group.pk), [str(team.admin.pk)])
    assert team.admin.pk in access.members(group)
    with pytest.raises(PermissionDenied):
        services.remove_member(team.pm, team.ws, str(group.pk), str(team.admin.pk))

    services.remove_member(team.owner, team.ws, str(group.pk), str(team.admin.pk))

    assert team.admin.pk not in access.members(group)
    with pytest.raises(ApiError):
        services.add_members(team.owner, team.ws, str(group.pk), [str(team.viewer.pk)])
    with pytest.raises(ApiError):
        services.remove_member(team.owner, team.ws, str(group.pk), str(team.admin.pk))


def test_a_stranger_cannot_add_to_a_group(team: Any, group: Any) -> None:
    with pytest.raises(ApiError):
        services.add_members(team.admin, team.ws, str(group.pk), [str(team.admin.pk)])


def test_rename_and_archive_by_owner_or_admin_only(team: Any) -> None:
    made = services.create_space(team.member, team.ws, "channel", "random", [])
    pk = str(made.pk)

    renamed = services.update_space(team.member, team.ws, pk, name="chatter")
    archived = services.update_space(team.admin, team.ws, pk, set_archived=True, archived=True)
    restored = services.update_space(team.owner, team.ws, pk, set_archived=True)

    assert (renamed.name, renamed.version) == ("chatter", 2)
    assert archived.is_archived and archived.read_only and not restored.is_archived
    services.join(team.pm, team.ws, pk)
    with pytest.raises(PermissionDenied):
        services.update_space(team.pm, team.ws, pk, name="mine")


def test_defaults_dms_and_project_channels_are_not_renamed_or_archived(
    team: Any, general: Any
) -> None:
    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))
    project = team.create(team.owner, "WEB")
    channel = ChatSpace.objects.get(project=project)

    for space in (general, dm, channel):
        with pytest.raises(ApiError):
            services.update_space(team.owner, team.ws, str(space.pk), name="x")


def test_task_chats_list_visible_tasks_with_messages(team: Any) -> None:
    from infrastructure.comments import services as comments
    from infrastructure.comments.tests.conftest import say
    from infrastructure.tasks import services as tasks

    open_project = team.create(team.owner, "WEB")
    hidden = team.create(team.owner, "SEC", visibility="private")
    seen = tasks.create(team.owner, team.ws, str(open_project.pk), "Fix login")
    secret = tasks.create(team.owner, team.ws, str(hidden.pk), "Secret plan")
    tasks.create(team.owner, team.ws, str(open_project.pk), "Silent")
    for project, task in ((open_project, seen), (hidden, secret)):
        comments.create(team.owner, team.ws, str(project.pk), str(task.pk), say("hello"))

    mine = services.list_spaces(team.member, team.ws).task_chats
    theirs = services.list_spaces(team.owner, team.ws).task_chats
    found = services.list_spaces(team.owner, team.ws, query="login").task_chats

    assert [t["title"] for t in mine] == ["Fix login"]
    assert {t["title"] for t in theirs} == {"Fix login", "Secret plan"}
    assert [t["display_id"] for t in found] == ["WEB-1"]


def test_search_filters_by_name_and_a_dm_by_the_other_person(team: Any) -> None:
    services.create_space(team.member, team.ws, "channel", "random", [])
    services.open_dm(team.member, team.ws, str(team.pm.pk))

    hits = services.list_spaces(team.member, team.ws, query="RAND")
    nobody = services.list_spaces(team.member, team.ws, query="zzz")

    assert names(hits.channels) == ["random"] and hits.dms == []
    assert nobody.channels == [] and nobody.dms == []
    assert len(services.list_spaces(team.member, team.ws, query="pm").dms) == 1


def test_workspace_services_create_makes_general(team: Any, make_user: Any) -> None:
    ws = workspaces.create(make_user("zed"), "Zed Co", "zed-co")

    assert ChatSpace.objects.filter(workspace=ws, is_default=True).count() == 1
