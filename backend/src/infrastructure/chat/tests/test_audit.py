"""Chat leaves entries for who did what, never for what was said."""

from typing import Any

from infrastructure.audit.models import AuditEntry
from infrastructure.chat import messages, services
from infrastructure.chat.tests.conftest import doc


def _actions(team: Any) -> list[str]:
    return list(AuditEntry.objects.filter(workspace=str(team.ws.pk)).values_list("action", flat=True))


def test_joining_and_leaving_a_channel_are_recorded(team: Any) -> None:
    channel = services.create_space(team.owner, team.ws, "channel", "random", [])
    services.join(team.member, team.ws, str(channel.pk))
    services.leave(team.member, team.ws, str(channel.pk))
    actions = _actions(team)
    assert actions.count("chat_member.created") >= 2  # the owner, then the joiner
    assert "chat_member.deleted" in actions


def test_a_message_is_recorded_without_its_text_and_a_dm_not_at_all(team: Any) -> None:
    channel = services.create_space(team.owner, team.ws, "channel", "random", [])
    messages.send(team.owner, team.ws, str(channel.pk), doc("secret plan"))
    entries = AuditEntry.objects.filter(workspace=str(team.ws.pk), action="chat_message.created")
    assert entries.count() == 1 and "secret plan" not in str(entries.first().changes)
    dm = services.open_dm(team.owner, team.ws, str(team.member.pk))
    messages.send(team.owner, team.ws, str(dm.pk), doc("private"))
    assert AuditEntry.objects.filter(workspace=str(team.ws.pk), action="chat_message.created").count() == 1
