"""The kinds of notification, what each is called, and who gets which channel unless they say
otherwise. The defaults are quiet: everything lands in the inbox, only being assigned or mentioned
also pushes, and nothing is emailed until asked."""

from dataclasses import dataclass
from typing import Final

ASSIGNED: Final = "task.assigned"
MENTIONED: Final = "user.mentioned"
COMMENTED: Final = "comment.added"
STATUS_CHANGED: Final = "status.changed"
DUE_SOON: Final = "task.due_soon"
TIMER_LONG: Final = "timer.long"


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
    Kind(DUE_SOON, "A task assigned to you is due soon", push=True),
    Kind(TIMER_LONG, "Your timer has been running for a long time", push=True),
)
BY_KEY: Final = {k.key: k for k in KINDS}

# The inbox filters: which kinds each one shows.
FILTERS: Final = {
    "mentions": (MENTIONED,),
    "assigned": (ASSIGNED,),
}
