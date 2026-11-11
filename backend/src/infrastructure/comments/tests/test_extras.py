"""Reactions, pinning, edit history and turning a comment into a subtask."""

from typing import Any

import pytest

from infrastructure.comments import services
from infrastructure.comments.models import CommentReaction
from infrastructure.comments.tests.conftest import ping, say
from infrastructure.common.errors import ApiError
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _add(team: Any, project: Any, task: Any, text: str = "hi", who: Any = None) -> Any:
    return services.create(who or team.member, team.ws, str(project.pk), str(task.pk), say(text))


def _react(
    team: Any, project: Any, comment: Any, emoji: str, on: bool = True, who: Any = None
) -> Any:
    return services.react(who or team.member, team.ws, str(project.pk), str(comment.pk), emoji, on)


# -- reactions ----------------------------------------------------------------------------------


def test_a_reaction_is_added_and_listed_by_who_gave_it(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task)

    got = _react(team, project, made, "👍")
    _react(team, project, made, "👍", who=team.owner)
    both = _react(team, project, made, "🎉", who=team.owner)

    assert got.reaction_map == {"👍": [str(team.member.pk)]}
    assert both.reaction_map == {
        "👍": [str(team.member.pk), str(team.owner.pk)],
        "🎉": [str(team.owner.pk)],
    }


def test_reacting_twice_is_one_reaction_and_undoing_what_is_not_there_is_nothing(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    _react(team, project, made, "👍")
    _react(team, project, made, "👍")
    _react(team, project, made, "👀", on=False)
    after = _react(team, project, made, "👍", on=False)

    assert after.reaction_map == {}
    assert CommentReaction.objects.count() == 0


def test_a_reaction_that_raced_in_does_not_fail_the_second_request(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)
    CommentReaction.objects.create(
        comment_id=made.pk, user=team.member, emoji="👍"
    )  # the other tab won

    got = _react(team, project, made, "👍")

    assert got.reaction_map == {"👍": [str(team.member.pk)]}


@pytest.mark.parametrize("emoji", ["", " ", "a b", "x" * 17, "\n", "👍\u0000"])
def test_a_reaction_must_be_one_short_token(team: Any, project: Any, task: Any, emoji: str) -> None:
    made = _add(team, project, task)

    with pytest.raises(ApiError):
        _react(team, project, made, emoji)


def test_one_comment_holds_a_limited_number_of_different_reactions(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)
    for n in range(services.MAX_EMOJIS):
        _react(team, project, made, f"e{n}")

    with pytest.raises(ApiError):
        _react(team, project, made, "one-too-many")
    _react(team, project, made, "e0", who=team.owner)  # one already there is still fine


def test_only_those_who_may_comment_react_and_not_on_a_removed_comment(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    with pytest.raises(access.PermissionDenied):
        _react(team, project, made, "👍", who=team.viewer)
    services.delete(team.member, team.ws, str(project.pk), str(made.pk))
    with pytest.raises(ApiError):
        _react(team, project, made, "👍")


# -- pinning ------------------------------------------------------------------------------------


def test_a_moderator_pins_and_unpins(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task)

    pinned = services.pin(team.admin, team.ws, str(project.pk), str(made.pk), True)
    unpinned = services.pin(team.admin, team.ws, str(project.pk), str(made.pk), False)

    assert (pinned.pinned, unpinned.pinned) == (True, False)


def test_a_member_who_may_edit_tasks_can_pin_too_but_a_viewer_cannot(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    assert services.pin(team.member, team.ws, str(project.pk), str(made.pk), True).pinned
    with pytest.raises(access.PermissionDenied):
        services.pin(team.viewer, team.ws, str(project.pk), str(made.pk), False)


def test_a_task_keeps_only_a_few_comments_pinned(team: Any, project: Any, task: Any) -> None:
    made = [_add(team, project, task, str(n)) for n in range(services.MAX_PINNED + 1)]
    for c in made[: services.MAX_PINNED]:
        services.pin(team.admin, team.ws, str(project.pk), str(c.pk), True)

    with pytest.raises(ApiError):
        services.pin(team.admin, team.ws, str(project.pk), str(made[-1].pk), True)


def test_a_removed_comment_cannot_be_pinned(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task)
    services.delete(team.member, team.ws, str(project.pk), str(made.pk))

    with pytest.raises(ApiError):
        services.pin(team.admin, team.ws, str(project.pk), str(made.pk), True)


# -- history ------------------------------------------------------------------------------------


def test_the_history_lists_every_body_the_comment_had_oldest_first(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task, "one")
    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("two"))
    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 2, say("three"))

    history = services.history(team.viewer, team.ws, str(project.pk), str(made.pk))

    texts = [r.body["content"][0]["content"][0]["text"] for r in history]
    assert texts == ["one", "two", "three"]
    assert history[-1].current is True and not any(r.current for r in history[:-1])


def test_a_comment_never_edited_has_just_its_one_body(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task)

    assert len(services.history(team.viewer, team.ws, str(project.pk), str(made.pk))) == 1


def test_the_history_of_a_removed_comment_is_empty_and_an_outsider_sees_nothing(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)
    with pytest.raises(ApiError):
        services.history(team.outsider, team.ws, str(project.pk), str(made.pk))
    services.delete(team.member, team.ws, str(project.pk), str(made.pk))

    assert services.history(team.viewer, team.ws, str(project.pk), str(made.pk)) == []


# -- comment to subtask -------------------------------------------------------------------------


def test_a_comment_becomes_a_subtask_titled_by_its_first_line(
    team: Any, project: Any, task: Any
) -> None:
    made = services.create(
        team.member,
        team.ws,
        str(project.pk),
        str(task.pk),
        say("Check the redirect ", ping(team.owner, "Olly")),
    )

    sub = services.to_subtask(team.member, team.ws, str(project.pk), str(made.pk))

    assert (
        sub.parent_id == task.pk and sub.title == "Check the redirect @owner"
    )  # the real name, not the sent label
    assert Task.objects.get(pk=sub.pk).description["type"] == "doc"  # the content came along


def test_a_long_first_line_is_cut_to_a_title(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task, "x" * 800)

    sub = services.to_subtask(team.member, team.ws, str(project.pk), str(made.pk))

    assert 0 < len(sub.title) <= 500 and sub.title.endswith("…")


def test_turning_a_comment_into_a_subtask_needs_the_right_to_create_tasks(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    with pytest.raises(access.PermissionDenied):
        services.to_subtask(team.viewer, team.ws, str(project.pk), str(made.pk))
    services.delete(team.member, team.ws, str(project.pk), str(made.pk))
    with pytest.raises(ApiError):
        services.to_subtask(team.member, team.ws, str(project.pk), str(made.pk))


def test_a_subtask_made_from_a_comment_is_a_real_subtask(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task, "do this")

    sub = services.to_subtask(team.member, team.ws, str(project.pk), str(made.pk))

    assert [
        t.pk
        for t in tasks.list_page(team.viewer, team.ws, str(project.pk), include_subtasks=True)[0]
        if t.parent_id
    ] == [sub.pk]
