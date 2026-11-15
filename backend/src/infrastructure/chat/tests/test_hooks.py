from typing import Any

import pytest

from infrastructure.chat import access, messages, services
from infrastructure.chat.models import ChatMember, ChatSpace
from infrastructure.chat.tests.conftest import doc
from infrastructure.common.errors import ApiError
from infrastructure.projects import members as project_members
from infrastructure.projects import services as projects
from infrastructure.workspaces import registry

pytestmark = pytest.mark.django_db


def test_a_new_project_gets_its_channel(team: Any) -> None:
    project = team.create(team.owner, "WEB", name="Website")

    channel = ChatSpace.objects.get(project=project)

    assert (channel.name, channel.kind, channel.created_by_id) == (
        "Website",
        "channel",
        team.owner.pk,
    )
    assert access.members(channel) == {team.owner.pk, team.admin.pk, team.member.pk, team.pm.pk}


def test_a_private_project_channel_has_exactly_its_members_and_follows_changes(team: Any) -> None:
    project = team.create(team.pm, "SEC", visibility="private", name="Secure")
    channel = ChatSpace.objects.get(project=project)
    assert access.members(channel) == {team.pm.pk}

    project_members.add_member(team.pm, team.ws, str(project.pk), str(team.member.pk))
    assert access.members(channel) == {team.pm.pk, team.member.pk}
    assert ChatMember.objects.filter(space=channel, user=team.member).exists()
    messages.send(team.member, team.ws, str(channel.pk), doc("in"))

    project_members.remove_member(team.pm, team.ws, str(project.pk), str(team.member.pk))

    assert access.members(channel) == {team.pm.pk}
    assert not ChatMember.objects.filter(space=channel, user=team.member).exists()
    with pytest.raises(ApiError):
        messages.list_page(team.member, team.ws, str(channel.pk))


def test_renaming_follows_and_archiving_makes_the_channel_read_only(team: Any) -> None:
    project = team.create(team.owner, "WEB", name="Website")
    channel = ChatSpace.objects.get(project=project)
    version = projects.get(team.owner, team.ws, str(project.pk)).project.version

    projects.update(team.owner, team.ws, str(project.pk), version, name="Site")
    assert ChatSpace.objects.get(pk=channel.pk).name == "Site"

    version = projects.get(team.owner, team.ws, str(project.pk)).project.version
    projects.archive(team.owner, team.ws, str(project.pk), version)
    with pytest.raises(ApiError) as refused:
        messages.send(team.member, team.ws, str(channel.pk), doc("late"))
    assert refused.value.status == 409
    assert services.get(team.member, team.ws, str(channel.pk)).read_only
    assert messages.list_page(team.member, team.ws, str(channel.pk)).messages == []

    version = projects.get(team.owner, team.ws, str(project.pk)).project.version
    projects.restore(team.owner, team.ws, str(project.pk), version)
    messages.send(team.member, team.ws, str(channel.pk), doc("back"))


def test_archived_spaces_are_hidden_unless_asked_for(team: Any) -> None:
    project = team.create(team.owner, "WEB", name="Website")
    version = projects.get(team.owner, team.ws, str(project.pk)).project.version
    projects.archive(team.owner, team.ws, str(project.pk), version)

    plain = services.list_spaces(team.member, team.ws)
    full = services.list_spaces(team.member, team.ws, include_archived=True)

    assert "Website" not in [s.name for s in plain.channels]
    assert "Website" in [s.name for s in full.channels]


def test_the_permission_keys_and_their_grants(team: Any) -> None:
    keys = {"chat.read", "chat.post", "chat.manage"}

    assert keys <= registry.ALL_KEYS
    for role in ("Owner", "Admin", "Member"):
        assert keys <= registry.BUILTIN_GRANTS[role]
    assert not keys & registry.BUILTIN_GRANTS["Viewer"]


def test_a_member_cannot_archive_another_persons_channel_but_admin_can(team: Any) -> None:
    made = services.create_space(team.member, team.ws, "channel", "random", [])
    services.join(team.pm, team.ws, str(made.pk))

    with pytest.raises(ApiError):
        services.update_space(team.pm, team.ws, str(made.pk), set_archived=True, archived=True)
    assert services.update_space(
        team.admin, team.ws, str(made.pk), set_archived=True, archived=True
    ).is_archived
