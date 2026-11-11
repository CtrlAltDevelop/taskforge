"""Creating, listing, replying to, editing and deleting comments."""

from datetime import timedelta
from typing import Any

import pytest
from django.test import override_settings
from django.utils import timezone

from infrastructure.comments import services
from infrastructure.comments.models import Comment, CommentRevision
from infrastructure.comments.tests.conftest import say
from infrastructure.common.errors import ApiError
from infrastructure.workspaces import access

pytestmark = pytest.mark.django_db


def _add(team: Any, project: Any, task: Any, text: str = "hi", who: Any = None, **kw: Any) -> Any:
    return services.create(
        who or team.member, team.ws, str(project.pk), str(task.pk), say(text), **kw
    )


def test_a_member_comments_and_it_comes_back_listed(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task, "Looks good")

    page = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk))

    assert [c.pk for c in page.comments] == [made.pk]
    got = page.comments[0]
    assert (got.author_id, got.version, got.parent_id, got.pinned) == (
        team.member.pk,
        1,
        None,
        False,
    )
    assert got.body["content"][0]["content"][0]["text"] == "Looks good"
    assert got.edited_at is None and got.is_deleted is False


def test_a_viewer_reads_but_cannot_write(team: Any, project: Any, task: Any) -> None:
    with pytest.raises(access.PermissionDenied):
        _add(team, project, task, who=team.viewer)
    with pytest.raises(ApiError):  # an outsider cannot even read
        services.list_page(team.outsider, team.ws, str(project.pk), str(task.pk))


def test_comments_come_oldest_first_and_load_earlier_pages_back(
    team: Any, project: Any, task: Any
) -> None:
    for n in range(5):
        _add(team, project, task, f"c{n}")

    last = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk), limit=2)
    earlier = services.list_page(
        team.viewer, team.ws, str(project.pk), str(task.pk), before=last.cursor, limit=2
    )
    first = services.list_page(
        team.viewer, team.ws, str(project.pk), str(task.pk), before=earlier.cursor, limit=2
    )

    texts = [
        [c.body["content"][0]["content"][0]["text"] for c in p.comments]
        for p in (last, earlier, first)
    ]
    assert texts == [["c3", "c4"], ["c1", "c2"], ["c0"]]
    assert last.cursor and earlier.cursor and first.cursor == ""


def test_a_reply_hangs_under_a_top_level_comment_one_level_deep(
    team: Any, project: Any, task: Any
) -> None:
    top = _add(team, project, task, "question")
    reply = _add(team, project, task, "answer", who=team.owner, parent_id=str(top.pk))

    assert reply.parent_id == top.pk
    with pytest.raises(ApiError):
        _add(team, project, task, "too deep", parent_id=str(reply.pk))


def test_a_reply_must_belong_to_the_same_task(team: Any, project: Any, task: Any) -> None:
    from infrastructure.tasks import services as tasks

    other = tasks.create(team.owner, team.ws, str(project.pk), "Other")
    top = _add(team, project, other, "elsewhere")

    with pytest.raises(ApiError):
        _add(team, project, task, "crossed", parent_id=str(top.pk))


def test_a_blank_or_invalid_comment_is_refused(team: Any, project: Any, task: Any) -> None:
    for bad in ("", "[]", say("   ")):
        with pytest.raises(ApiError):
            services.create(team.member, team.ws, str(project.pk), str(task.pk), bad)


def test_comments_are_scoped_to_their_workspace_and_task(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    with pytest.raises(ApiError):
        services.list_page(team.outsider, team.other_ws, str(project.pk), str(task.pk))
    with pytest.raises(ApiError):
        services.edit(team.outsider, team.other_ws, str(project.pk), str(made.pk), 1, say("x"))


def test_a_deleted_task_has_no_comments_to_add(team: Any, project: Any, task: Any) -> None:
    from infrastructure.tasks import services as tasks

    tasks.delete(team.owner, team.ws, str(project.pk), str(task.pk))

    with pytest.raises(ApiError):
        _add(team, project, task)


def test_an_archived_project_takes_no_new_comments(team: Any, project: Any, task: Any) -> None:
    from infrastructure.projects import services as projects

    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError):
        _add(team, project, task)
    assert services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk)).comments == []


def test_an_archived_project_keeps_its_comments_even_from_their_author(
    team: Any, project: Any, task: Any
) -> None:
    from infrastructure.projects import services as projects

    made = _add(team, project, task)
    projects.archive(team.owner, team.ws, str(project.pk), project.version)

    with pytest.raises(ApiError):
        services.delete(team.owner, team.ws, str(project.pk), str(made.pk))


# -- editing ------------------------------------------------------------------------------------


def test_an_edit_bumps_the_version_marks_it_edited_and_keeps_the_old_body(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task, "first")

    edited = services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("second"))

    assert edited.version == 2 and edited.edited_at is not None
    assert edited.body["content"][0]["content"][0]["text"] == "second"
    [old] = CommentRevision.objects.filter(comment=made)
    assert old.body["content"][0]["content"][0]["text"] == "first"


def test_only_the_author_edits_and_a_stale_version_conflicts(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)

    with pytest.raises(access.PermissionDenied):
        services.edit(team.owner, team.ws, str(project.pk), str(made.pk), 1, say("mine now"))
    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("v2"))
    with pytest.raises(ApiError) as stale:
        services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("v2 again"))

    assert stale.value.status == 409


def test_an_edit_is_allowed_for_a_day_by_default_and_the_window_is_a_setting(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task)
    Comment.objects.filter(pk=made.pk).update(created_at=timezone.now() - timedelta(hours=25))

    with pytest.raises(ApiError):
        services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("late"))
    with override_settings(COMMENT_EDIT_WINDOW_HOURS=48):
        services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("in time"))


def test_a_deleted_comment_cannot_be_edited(team: Any, project: Any, task: Any) -> None:
    made = _add(team, project, task)
    services.delete(team.member, team.ws, str(project.pk), str(made.pk))

    with pytest.raises(ApiError):
        services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("zombie"))


# -- deleting -----------------------------------------------------------------------------------


def test_the_author_or_a_moderator_deletes_and_nobody_else(
    team: Any, project: Any, task: Any
) -> None:
    mine = _add(team, project, task)
    theirs = _add(team, project, task, who=team.owner)

    with pytest.raises(access.PermissionDenied):
        services.delete(team.member, team.ws, str(project.pk), str(theirs.pk))
    services.delete(team.member, team.ws, str(project.pk), str(mine.pk))
    services.delete(team.admin, team.ws, str(project.pk), str(theirs.pk))  # a moderator

    page = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk))
    assert [c.is_deleted for c in page.comments] == [True, True]


def test_a_deleted_comment_shows_as_removed_with_nothing_of_its_content(
    team: Any, project: Any, task: Any
) -> None:
    made = _add(team, project, task, "secret")
    services.edit(team.member, team.ws, str(project.pk), str(made.pk), 1, say("secret 2"))

    services.delete(team.member, team.ws, str(project.pk), str(made.pk))

    gone = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk)).comments[0]
    assert gone.is_deleted and gone.body == {} and list(gone.mention_ids) == []
    assert CommentRevision.objects.filter(comment=made).count() == 0  # the history goes too


def test_replies_keep_their_place_when_the_comment_above_is_deleted(
    team: Any, project: Any, task: Any
) -> None:
    top = _add(team, project, task, "question")
    reply = _add(team, project, task, "answer", parent_id=str(top.pk))

    services.delete(team.member, team.ws, str(project.pk), str(top.pk))

    page = services.list_page(team.viewer, team.ws, str(project.pk), str(task.pk))
    assert [(c.pk, c.is_deleted) for c in page.comments] == [(top.pk, True), (reply.pk, False)]
    assert page.comments[1].parent_id == top.pk
