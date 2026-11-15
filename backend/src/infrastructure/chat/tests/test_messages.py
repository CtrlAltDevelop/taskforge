import json
from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.chat import messages, services
from infrastructure.chat.models import ChatMessage
from infrastructure.chat.tests.conftest import doc, everyone, ping
from infrastructure.common.errors import ApiError
from infrastructure.workspaces.access import PermissionDenied

pytestmark = pytest.mark.django_db


def say(team: Any, who: Any, space: Any, *parts: Any, **kw: Any) -> ChatMessage:
    return messages.send(who, team.ws, str(space.pk), doc(*parts), **kw)


def test_send_and_list_with_a_cursor(team: Any, general: Any) -> None:
    for n in range(5):
        say(team, team.member, general, f"m{n}")

    newest = messages.list_page(team.pm, team.ws, str(general.pk), limit=2)
    older = messages.list_page(team.pm, team.ws, str(general.pk), before=newest.cursor, limit=10)

    assert [json.dumps(m.body).count("m") > 0 for m in newest.messages] == [True, True]
    assert len(older.messages) == 3 and older.cursor == ""
    assert older.messages[-1].created_at <= newest.messages[0].created_at
    assert newest.messages[0].author_name == "member"


def test_a_message_needs_a_member_of_a_space_that_is_open(team: Any, general: Any) -> None:
    channel = services.create_space(team.member, team.ws, "channel", "random", [])

    with pytest.raises(ApiError):
        say(team, team.pm, channel, "not joined")  # reads, but has not joined
    services.join(team.pm, team.ws, str(channel.pk))
    say(team, team.pm, channel, "now")
    services.update_space(team.member, team.ws, str(channel.pk), set_archived=True, archived=True)
    with pytest.raises(ApiError) as refused:
        say(team, team.pm, channel, "late")
    assert refused.value.status == 409


def test_the_body_is_sanitised_like_a_comment_and_capped(
    team: Any, general: Any, settings: Any
) -> None:
    bad = json.dumps({"type": "doc", "content": [{"type": "script"}]})
    with pytest.raises(ApiError):
        messages.send(team.member, team.ws, str(general.pk), bad)
    with pytest.raises(ApiError):
        messages.send(team.member, team.ws, str(general.pk), "")
    settings.CHAT_MAX_MESSAGE_KB = 1
    with pytest.raises(ApiError):
        say(team, team.member, general, "x" * 2000)


def test_a_client_id_makes_a_send_idempotent(team: Any, general: Any) -> None:
    cid = "0b6c1c5e-8c3f-4d57-9d0a-2b7d6a0a4c11"

    one = say(team, team.member, general, "hi", client_id=cid)
    two = say(team, team.member, general, "hi", client_id=cid)

    assert one.pk == two.pk and ChatMessage.objects.count() == 1
    with pytest.raises(ApiError):
        say(team, team.pm, general, "steal", client_id=cid)
    with pytest.raises(ApiError):
        say(team, team.member, general, "x", client_id="nope")


def test_a_mutation_id_applies_once(team: Any, general: Any) -> None:
    mid = "5f1f6b52-1d63-4a9e-8b5f-7a2d1f3c9e10"

    one = say(team, team.member, general, "a", client_mutation_id=mid)
    two = say(team, team.member, general, "a", client_mutation_id=mid)

    assert one.pk == two.pk and ChatMessage.objects.count() == 1


def test_threads_are_one_level_deep(team: Any, general: Any) -> None:
    top = say(team, team.member, general, "top")
    reply = say(team, team.pm, general, "re", parent_id=str(top.pk))

    with pytest.raises(ApiError):
        say(team, team.pm, general, "deeper", parent_id=str(reply.pk))
    with pytest.raises(ApiError):
        say(team, team.pm, general, "ghost", parent_id="3c4bd4f0-0000-4000-8000-000000000000")
    thread = messages.list_page(team.owner, team.ws, str(general.pk), thread_id=str(top.pk))
    assert [m.pk for m in thread.messages] == [top.pk, reply.pk]
    assert reply.parent_id == top.pk


def test_the_rate_limit_is_per_user_and_space(team: Any, general: Any, settings: Any) -> None:
    settings.CHAT_SENDS_PER_MINUTE = 2
    say(team, team.member, general, "1")
    say(team, team.member, general, "2")

    with pytest.raises(ApiError) as refused:
        say(team, team.member, general, "3")
    say(team, team.pm, general, "someone else is fine")
    assert refused.value.status == 429


def test_edit_within_the_window_by_the_author_only(team: Any, general: Any) -> None:
    sent = say(team, team.member, general, "one")

    edited = messages.edit(team.member, team.ws, str(general.pk), str(sent.pk), 1, doc("two"))

    assert edited.version == 2 and edited.edited_at is not None
    with pytest.raises(PermissionDenied):
        messages.edit(team.pm, team.ws, str(general.pk), str(sent.pk), 2, doc("hijack"))
    with pytest.raises(ApiError) as stale:
        messages.edit(team.member, team.ws, str(general.pk), str(sent.pk), 1, doc("old"))
    assert stale.value.status == 409
    ChatMessage.objects.filter(pk=sent.pk).update(created_at=timezone.now() - timedelta(hours=25))
    with pytest.raises(ApiError):
        messages.edit(team.member, team.ws, str(general.pk), str(sent.pk), 2, doc("late"))


def test_delete_leaves_a_placeholder_and_replies_stay(team: Any, general: Any) -> None:
    top = say(team, team.member, general, "oops")
    say(team, team.pm, general, "reply", parent_id=str(top.pk))
    messages.react(team.pm, team.ws, str(general.pk), str(top.pk), "👍", True)

    gone = messages.delete(team.member, team.ws, str(general.pk), str(top.pk))
    again = messages.delete(team.member, team.ws, str(general.pk), str(top.pk))

    assert gone.is_deleted and gone.body == {} and again.version == gone.version
    assert gone.reaction_map == {}
    assert ChatMessage.objects.filter(space=general).count() == 2
    with pytest.raises(ApiError):
        messages.edit(team.member, team.ws, str(general.pk), str(top.pk), 2, doc("undo"))
    with pytest.raises(ApiError):
        messages.react(team.pm, team.ws, str(general.pk), str(top.pk), "👍", True)


def test_only_the_author_or_an_admin_deletes(team: Any, general: Any) -> None:
    sent = say(team, team.member, general, "hi")

    with pytest.raises(PermissionDenied):
        messages.delete(team.pm, team.ws, str(general.pk), str(sent.pk))
    assert messages.delete(team.admin, team.ws, str(general.pk), str(sent.pk)).is_deleted


def test_reactions_set_rather_than_toggle(team: Any, general: Any) -> None:
    sent = say(team, team.member, general, "hi")
    pk = str(sent.pk)

    messages.react(team.pm, team.ws, str(general.pk), pk, "👍", True)
    twice = messages.react(team.pm, team.ws, str(general.pk), pk, "👍", True)
    other = messages.react(team.owner, team.ws, str(general.pk), pk, "👍", True)
    off = messages.react(team.pm, team.ws, str(general.pk), pk, "👍", False)

    assert twice.reaction_map == {"👍": [str(team.pm.pk)]}
    assert other.reaction_map == {"👍": [str(team.pm.pk), str(team.owner.pk)]}
    assert off.reaction_map == {"👍": [str(team.owner.pk)]}
    for bad in ("", "two words", "x" * 17):
        with pytest.raises(ApiError):
            messages.react(team.pm, team.ws, str(general.pk), pk, bad, True)


def test_at_most_thirty_kinds_of_reaction(team: Any, general: Any) -> None:
    sent = say(team, team.member, general, "hi")
    for n in range(30):
        messages.react(team.pm, team.ws, str(general.pk), str(sent.pk), f"e{n}", True)

    with pytest.raises(ApiError):
        messages.react(team.pm, team.ws, str(general.pk), str(sent.pk), "extra", True)


def test_mentioning_somebody_who_cannot_see_the_space_is_refused_or_added(
    team: Any, group: Any
) -> None:
    with pytest.raises(ApiError) as refused:
        say(team, team.member, group, "hi ", ping(team.admin))
    assert refused.value.data == {"users": str(team.admin.pk)}
    with pytest.raises(ApiError):  # a plain member may not add, even asking
        say(team, team.pm, group, "hi ", ping(team.admin), grant_access=True)

    say(team, team.owner, group, "hi ", ping(team.admin), grant_access=True)

    assert team.admin.pk in services.access.members(group)


def test_a_dm_never_grows_and_guests_cannot_be_added(team: Any) -> None:
    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))

    with pytest.raises(ApiError):
        say(team, team.member, dm, ping(team.admin), grant_access=True)
    with pytest.raises(ApiError):
        say(team, team.member, dm, "x ", ping(team.viewer))


def test_broadcast_in_a_dm_is_refused_and_a_big_channel_needs_confirming(
    team: Any, general: Any, make_user: Any, add_member: Any, settings: Any
) -> None:
    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))
    with pytest.raises(ApiError):
        say(team, team.member, dm, everyone())
    settings.CHAT_BROADCAST_CONFIRM_ABOVE = 5
    for n in range(3):
        add_member(team.ws, make_user(f"extra{n}"), "Member")

    with pytest.raises(ApiError) as asked:
        say(team, team.member, general, everyone("here"))
    sent = say(team, team.member, general, everyone(), confirm_broadcast=True)

    assert asked.value.data == {"member_count": "7"}
    assert sent.body["content"][0]["content"][0]["attrs"] == {"id": "channel", "label": "channel"}
    say(team, team.member, general, "no broadcast needs no confirmation")


def test_messages_of_a_former_member_read_as_former_member(team: Any, general: Any) -> None:
    from infrastructure.workspaces import members

    say(team, team.pm, general, "bye")
    members.remove(team.ws, team.owner, str(team.pm.pk))

    [only] = messages.list_page(team.member, team.ws, str(general.pk)).messages

    assert only.author_name == "Former member"


def test_a_dm_with_a_former_member_is_read_only_history(team: Any) -> None:
    from infrastructure.workspaces import members

    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))
    say(team, team.pm, dm, "before")
    members.remove(team.ws, team.owner, str(team.pm.pk))

    with pytest.raises(ApiError) as refused:
        say(team, team.member, dm, "hello?")
    shown = services.get(team.member, team.ws, str(dm.pk))

    assert refused.value.status == 409 and shown.read_only and shown.display_name == "Former member"
    assert len(messages.list_page(team.member, team.ws, str(dm.pk)).messages) == 1


def test_a_group_survives_a_member_leaving_the_workspace(team: Any, group: Any) -> None:
    from infrastructure.workspaces import members

    members.remove(team.ws, team.owner, str(team.pm.pk))

    say(team, team.member, group, "still here")
    assert services.access.members(group) == {team.owner.pk, team.member.pk}


def test_unread_counts_follow_the_read_mark_across_devices(team: Any, general: Any) -> None:
    services.list_spaces(team.pm, team.ws)  # the pm is read up to now
    first = say(team, team.member, general, "one")
    say(team, team.member, general, "two")
    say(team, team.pm, general, "mine does not count")

    def unread() -> int:
        return services.get(team.pm, team.ws, str(general.pk)).unread

    assert unread() == 2
    services.mark_read(team.pm, team.ws, str(general.pk), str(first.pk))
    assert unread() == 1
    services.mark_read(team.pm, team.ws, str(general.pk))
    assert unread() == 0
    services.mark_read(team.pm, team.ws, str(general.pk), str(first.pk))  # never moves back
    assert unread() == 0
    messages.delete(team.member, team.ws, str(general.pk), str(first.pk))
    say(team, team.member, general, "three")
    assert unread() == 1
    with pytest.raises(ApiError):
        services.mark_read(
            team.pm, team.ws, str(general.pk), "3c4bd4f0-0000-4000-8000-000000000000"
        )


def test_mute_and_notify_settings(team: Any, general: Any) -> None:
    gid = str(general.pk)

    until = (timezone.now() + timedelta(hours=1)).isoformat()
    timed = services.mute(team.pm, team.ws, gid, until=until, completely=True)
    forever = services.mute(team.pm, team.ws, gid, forever=True)
    cleared = services.mute(team.pm, team.ws, gid)
    notified = services.set_notify(team.pm, team.ws, gid, True)

    assert timed.my_row.muted and timed.my_row.muted_completely
    assert forever.my_row.muted and not forever.my_row.muted_completely
    assert not cleared.my_row.muted and notified.my_row.notify_all
    with pytest.raises(ApiError):
        services.mute(team.pm, team.ws, gid, until="tomorrow-ish")
    channel = services.create_space(team.member, team.ws, "channel", "random", [])
    with pytest.raises(ApiError):  # not in it: nothing to set
        services.mute(team.pm, team.ws, str(channel.pk), forever=True)


def test_mentionable_lists_only_people_who_can_see_the_space(team: Any, group: Any) -> None:
    people, count = services.mentionable(team.member, team.ws, str(group.pk))
    found, _ = services.mentionable(team.member, team.ws, str(group.pk), "pm")

    assert {u.get_username() for u in people} == {"owner", "member", "pm"} and count == 3
    assert [u.get_username() for u in found] == ["pm"]
    with pytest.raises(ApiError):
        services.mentionable(team.admin, team.ws, str(group.pk))
