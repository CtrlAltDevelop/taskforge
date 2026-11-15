"""The kinds of notification, what each is called, and who gets which channel unless they say
otherwise. The defaults are quiet: everything lands in the inbox, only being assigned or mentioned
also pushes, and nothing is emailed until asked."""

from dataclasses import dataclass
from typing import Final

ASSIGNED: Final = "task.assigned"
MENTIONED: Final = "user.mentioned"
COMMENTED: Final = "comment.added"
STATUS_CHANGED: Final = "status.changed"
TASK_CHANGED: Final = "task.changed"
DUE_SOON: Final = "task.due_soon"
TIMER_LONG: Final = "timer.long"
AUTOMATION: Final = "automation.notice"
AUTOMATION_DISABLED: Final = "automation.disabled"
CHAT_MENTIONED: Final = "chat.mentioned"
CHAT_DM: Final = "chat.dm"
CHAT_CHANNEL_ALL: Final = "chat.channel_all"
CHAT_MESSAGE: Final = "chat.message"
CHAT_KINDS: Final = frozenset({CHAT_MENTIONED, CHAT_DM, CHAT_CHANNEL_ALL, CHAT_MESSAGE})


@dataclass(frozen=True, slots=True)
class Kind:
    key: str
    label: str
    inbox: bool = True
    push: bool = False
    email_mode: str = "off"


KINDS: Final = (
    Kind(ASSIGNED, "A task is assigned to you", push=True),
    Kind(MENTIONED, "Someone mentions you", push=True),
    Kind(COMMENTED, "A comment on a task you watch"),
    Kind(STATUS_CHANGED, "The status of a task you watch changes"),
    Kind(TASK_CHANGED, "A task you watch or work on is changed"),
    Kind(DUE_SOON, "A task assigned to you is due soon", push=True),
    Kind(TIMER_LONG, "Your timer has been running for a long time", push=True),
    Kind(AUTOMATION, "An automation sends you a message"),
    Kind(AUTOMATION_DISABLED, "An automation of yours was switched off", push=True),
    Kind(CHAT_MENTIONED, "Someone mentions you in chat", push=True),
    Kind(CHAT_DM, "Someone sends you a direct message", push=True),
    Kind(CHAT_CHANNEL_ALL, "Someone writes @channel or @here in a space of yours", push=True),
    Kind(CHAT_MESSAGE, "A message in a space you asked to follow closely", push=True),
)
BY_KEY: Final = {k.key: k for k in KINDS}

# The inbox filters: which kinds each one shows.
FILTERS: Final = {
    "mentions": (MENTIONED, CHAT_MENTIONED),
    "assigned": (ASSIGNED,),
}
