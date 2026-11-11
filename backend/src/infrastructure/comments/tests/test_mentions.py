"""Mentions: who the picker offers, who may be mentioned, and the user.mentioned event."""

from collections.abc import Iterator
from typing import Any

import pytest

from infrastructure.comments import mentions, services
from infrastructure.comments.models import CommentMention
from infrastructure.comments.signals import user_mentioned
from infrastructure.comments.tests.conftest import ping, say
from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.projects import members as project_members
from infrastructure.tasks import services as tasks
from infrastructure.workspaces import members

pytestmark = pytest.mark.django_db


@pytest.fixture
def heard() -> Iterator[list[tuple[str, int, str]]]:
    """Every ``user.mentioned`` sent: (user id, comment version, comment id)."""
    got: list[tuple[str, int, str]] = []

    def listen(sender: Any, **kw: Any) -> None:
        got.append((kw["user_id"], kw["version"], kw["comment_id"]))

    user_mentioned.connect(listen)
    yield got
    user_mentioned.disconnect(listen)


def _post(team: Any, project: Any, task: Any, *parts: Any, who: Any = None, **kw: Any) -> Any:
    return services.create(
        who or team.member, team.ws, str(project.pk), str(task.pk), say(*parts), **kw
    )


def _names(users: list[Any]) -> set[str]:
    return {u.username for u in users}


# -- the picker ---------------------------------------------------------------------------------


def test_the_picker_lists_everyone_who_can_open_an_open_project(team: Any, project: Any) -> None:
    found = mentions.candidates(team.ws, project)

    assert _names(found) == {"owner", "admin", "member", "viewer", "pm"}  # the outsider is not here


def test_the_picker_of_a_private_project_lists_only_its_members(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    project_members.add_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))

    assert _names(mentions.candidates(team.ws, secret)) == {"pm", "member"}


def test_a_removed_member_is_not_offered(team: Any, project: Any) -> None:
    members.remove(team.ws, team.owner, str(team.viewer.pk))

    assert "viewer" not in _names(mentions.candidates(team.ws, project))


def test_the_picker_narrows_by_name_or_email_and_is_capped(team: Any, project: Any) -> None:
    assert _names(mentions.candidates(team.ws, project, "memb")) == {"member"}
    assert len(mentions.candidates(team.ws, project, limit=2)) == 2


# -- who may be mentioned -----------------------------------------------------------------------


def test_a_person_who_can_see_the_task_can_be_mentioned(team: Any, project: Any) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")

    made = _post(team, project, task, "hey ", ping(team.viewer, "Vic"))

    assert made.mention_ids == [str(team.viewer.pk)]
    assert CommentMention.objects.filter(comment=made, user=team.viewer).exists()


def test_somebody_who_cannot_see_the_task_blocks_the_comment_and_is_named(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    task = tasks.create(team.pm, team.ws, str(secret.pk), "Hidden")

    with pytest.raises(ApiError) as refusal:
        _post(team, secret, task, ping(team.member), who=team.pm)

    assert refusal.value.title is ResponseTitle.MENTION_NO_ACCESS
    assert (refusal.value.data or {})["users"] == str(team.member.pk)
    assert CommentMention.objects.count() == 0


def test_somebody_outside_the_workspace_is_never_mentionable_even_with_a_grant(
    team: Any, project: Any
) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")

    with pytest.raises(ApiError):
        _post(team, project, task, ping(team.outsider), who=team.owner, grant_access=True)


def test_a_project_manager_can_grant_access_to_the_mentioned(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    task = tasks.create(team.pm, team.ws, str(secret.pk), "Hidden")

    made = _post(team, secret, task, ping(team.member), who=team.pm, grant_access=True)

    assert made.mention_ids == [str(team.member.pk)]
    assert team.member.pk in mentions.can_see(team.ws, secret)  # now able to open it


def test_asking_for_a_grant_without_the_right_changes_nothing(team: Any) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    project_members.add_member(team.pm, team.ws, str(secret.pk), str(team.member.pk))
    task = tasks.create(team.pm, team.ws, str(secret.pk), "Hidden")

    with pytest.raises(ApiError):  # a plain member may not add members
        _post(team, secret, task, ping(team.viewer), who=team.member, grant_access=True)
    assert team.viewer.pk not in mentions.can_see(team.ws, secret)


# -- user.mentioned -----------------------------------------------------------------------------


def test_each_person_is_announced_once_per_comment_however_often_they_are_mentioned(
    team: Any, project: Any, heard: list[Any]
) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")

    made = _post(
        team, project, task, ping(team.viewer), " and again ", ping(team.viewer), ping(team.owner)
    )

    assert sorted(h[0] for h in heard) == sorted([str(team.viewer.pk), str(team.owner.pk)])
    assert {h[1:] for h in heard} == {(1, str(made.pk))}


def test_an_edit_announces_only_the_people_newly_mentioned(
    team: Any, project: Any, heard: list[Any]
) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")
    made = _post(team, project, task, ping(team.viewer))
    heard.clear()

    services.edit(
        team.member, team.ws, str(project.pk), str(made.pk), 1,
        say(ping(team.viewer), " and ", ping(team.owner)),
    )  # fmt: skip

    assert heard == [(str(team.owner.pk), 2, str(made.pk))]


def test_a_mention_taken_out_and_put_back_is_announced_again(
    team: Any, project: Any, heard: list[Any]
) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")
    made = _post(team, project, task, ping(team.viewer))
    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("never mind"))
    heard.clear()

    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 2, say(ping(team.viewer)))

    assert [h[0] for h in heard] == [str(team.viewer.pk)]
    assert CommentMention.objects.filter(comment=made).count() == 1


def test_an_edit_that_drops_a_mention_removes_it(team: Any, project: Any) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")
    made = _post(team, project, task, ping(team.viewer), ping(team.owner))

    edited = services.edit(
        team.member, team.ws, str(project.pk), str(made.pk), 1, say(ping(team.owner))
    )

    assert edited.mention_ids == [str(team.owner.pk)]


def test_a_refused_comment_announces_nobody(team: Any, heard: list[Any]) -> None:
    secret = team.create(team.pm, "SEC", visibility="private", name="Secret")
    task = tasks.create(team.pm, team.ws, str(secret.pk), "Hidden")

    with pytest.raises(ApiError):
        _post(team, secret, task, ping(team.viewer), who=team.pm)

    assert heard == []


def test_the_label_a_client_sends_is_replaced_by_the_persons_real_name(
    team: Any, project: Any
) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")

    made = _post(team, project, task, "hi ", ping(team.viewer, "Somebody Else"))

    label = made.body["content"][0]["content"][1]["attrs"]["label"]
    assert label == mentions.display_name(team.viewer)


def test_mentioning_yourself_tells_nobody(team: Any, project: Any, heard: list[Any]) -> None:
    task = tasks.create(team.owner, team.ws, str(project.pk), "T")

    _post(team, project, task, ping(team.owner), ping(team.viewer), who=team.owner)

    assert [h[0] for h in heard] == [str(team.viewer.pk)]
