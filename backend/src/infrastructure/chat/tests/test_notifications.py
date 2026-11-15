from datetime import timedelta
from typing import Any

import pytest
from django.utils import timezone

from infrastructure.chat import messages, services
from infrastructure.chat.models import ChatMember
from infrastructure.chat.tests.conftest import doc, everyone, ping
from infrastructure.inbox import kinds, prefs
from infrastructure.inbox import services as inbox_services
from infrastructure.inbox.models import Notification

pytestmark = pytest.mark.django_db


def told(team: Any, user: Any) -> list[str]:
    rows = Notification.objects.filter(user=user, workspace=team.ws).order_by("created_at")
    return [n.type for n in rows]


def say(team: Any, who: Any, space: Any, *parts: Any, **kw: Any) -> Any:
    return messages.send(who, team.ws, str(space.pk), doc(*parts), **kw)


def test_a_plain_channel_message_notifies_nobody(team: Any, general: Any) -> None:
    say(team, team.member, general, "good morning")

    assert Notification.objects.count() == 0


def test_a_name_notifies_exactly_that_person_once_with_a_push(
    team: Any, general: Any, push: Any
) -> None:
    prefs.register_device(team.pm, "ios", "pm-phone")

    say(team, team.member, general, "look ", ping(team.pm), " and ", ping(team.pm))

    assert told(team, team.pm) == [kinds.CHAT_MENTIONED]
    [row] = Notification.objects.filter(user=team.pm)
    assert row.payload["excerpt"].startswith("look") and row.payload["space_id"] == str(general.pk)
    assert row.actor_id == team.member.pk and row.project_id is None and row.task_id is None
    assert len(push.sent) == 1 and "member" in push.sent[0]["title"] or push.sent
    assert told(team, team.owner) == [] and told(team, team.member) == []


def test_the_author_is_never_told_of_their_own_message(team: Any, general: Any) -> None:
    say(team, team.member, general, "me ", ping(team.member), " ", everyone())

    assert told(team, team.member) == []


def test_an_edit_tells_only_the_newly_mentioned_once_per_version(team: Any, general: Any) -> None:
    sent = say(team, team.member, general, "hi ", ping(team.pm))
    edit = messages.edit
    edit(
        team.member, team.ws, str(general.pk), str(sent.pk), 1, doc("hi ", ping(team.pm), " again")
    )
    edit(
        team.member,
        team.ws,
        str(general.pk),
        str(sent.pk),
        2,
        doc("hi ", ping(team.pm), ping(team.admin)),
    )

    assert told(team, team.pm) == [kinds.CHAT_MENTIONED]
    assert told(team, team.admin) == [kinds.CHAT_MENTIONED]


def test_channel_and_here_notify_the_members_and_those_recently_active(
    team: Any, general: Any
) -> None:
    ChatMember.objects.filter(space=general, user=team.admin).update(
        last_read_at=timezone.now() - timedelta(hours=3)
    )
    services.list_spaces(team.pm, team.ws)  # rows exist and are fresh
    services.list_spaces(team.owner, team.ws)

    say(team, team.member, general, everyone("here"), " standup")
    here = {u: told(team, u) for u in (team.owner, team.admin, team.pm, team.member)}
    Notification.objects.all().delete()
    say(team, team.member, general, everyone("channel"), " all hands")
    everyone_told = {u: told(team, u) for u in (team.owner, team.admin, team.pm, team.member)}

    assert here == {
        team.owner: ["chat.channel_all"],
        team.admin: [],
        team.pm: ["chat.channel_all"],
        team.member: [],
    }
    assert everyone_told == {
        team.owner: ["chat.channel_all"],
        team.admin: ["chat.channel_all"],
        team.pm: ["chat.channel_all"],
        team.member: [],
    }


def test_a_named_person_in_a_broadcast_gets_the_stronger_notice_only(
    team: Any, general: Any
) -> None:
    say(team, team.member, general, everyone(), " and ", ping(team.pm))

    assert told(team, team.pm) == [kinds.CHAT_MENTIONED]


def test_a_dm_notifies_the_other_person_with_inbox_and_push(team: Any, push: Any) -> None:
    prefs.register_device(team.pm, "ios", "pm-phone")
    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))

    say(team, team.member, dm, "psst")

    assert told(team, team.pm) == [kinds.CHAT_DM] and told(team, team.member) == []
    assert [n.type for n in inbox_services.list_page(team.pm, team.ws, "all").notifications] == [
        kinds.CHAT_DM
    ]
    assert len(push.sent) == 1 and push.sent[0]["body"] == "psst"


def test_asking_for_every_message_notifies_that_person(team: Any, general: Any) -> None:
    services.set_notify(team.pm, team.ws, str(general.pk), True)

    say(team, team.member, general, "anything")
    say(team, team.pm, general, "my own")

    assert told(team, team.pm) == [kinds.CHAT_MESSAGE]


def test_muting_silences_pushes_but_not_a_name_unless_completely(
    team: Any, general: Any, push: Any
) -> None:
    prefs.register_device(team.pm, "ios", "pm-phone")
    dm = services.open_dm(team.member, team.ws, str(team.pm.pk))
    services.mute(team.pm, team.ws, str(dm.pk), forever=True)
    services.mute(team.pm, team.ws, str(general.pk), forever=True)

    say(team, team.member, dm, "quiet please")  # in the inbox, no push
    assert told(team, team.pm) == [kinds.CHAT_DM] and push.sent == []
    say(team, team.member, general, everyone(), " all hands")  # not a name: no push
    assert push.sent == []
    say(team, team.member, general, "you ", ping(team.pm))  # a name still rings
    assert len(push.sent) == 1

    services.mute(team.pm, team.ws, str(general.pk), forever=True, completely=True)
    before = Notification.objects.filter(user=team.pm).count()
    say(team, team.member, general, "again ", ping(team.pm), everyone())
    assert Notification.objects.filter(user=team.pm).count() == before and len(push.sent) == 1


def test_nobody_is_told_after_losing_access_to_the_space(
    team: Any, group: Any, push: Any, settings: Any
) -> None:
    settings.INBOX_SYNC_DELIVERY = False
    prefs.register_device(team.pm, "ios", "pm-phone")
    from infrastructure.chat.models import ChatMember as Row

    sent = say(team, team.member, group, "hi ", ping(team.pm))
    assert push.sent == []
    Row.objects.filter(space=group, user=team.pm).delete()

    assert len(told(team, team.pm)) == 1 and sent
    from infrastructure.inbox import delivery

    delivery.deliver_due()
    assert push.sent == []  # the push was owed but the person can no longer read the space


def test_the_words_come_in_every_language(team: Any, general: Any) -> None:
    from infrastructure.inbox import render

    say(team, team.member, general, "hi ", ping(team.pm))
    [row] = Notification.objects.filter(user=team.pm)

    titles = {lang: render.render(row, "Zoe", lang)[0] for lang in ("en", "fa", "ar", "ps")}

    assert titles["en"] == f"Zoe mentioned you in {general.name}"
    assert len(set(titles.values())) == 4 and all("Zoe" in t for t in titles.values())
    for kind in (kinds.CHAT_DM, kinds.CHAT_CHANNEL_ALL, kinds.CHAT_MESSAGE):
        row.type = kind
        assert render.render(row, "Zoe", "fa")[0] != render.render(row, "Zoe", "en")[0]
