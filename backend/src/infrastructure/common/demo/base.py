"""What the seed modules share. ``core`` fills it; later modules read it.

Fill-in contract (names the other modules rely on):
  ctx.users:     owner, admin, member, dev, designer, viewer, guest (+ ``pending`` is an invitation)
  ctx.workspaces: main (the rich one), side (a second, small one for the switcher)
  ctx.projects:  web, mobile, bugs, marketing, private, archived  (Project objects, workspace=main)
  ctx.tasks:     key -> Task for every task core creates (keys are listed in core.py)
"""

from dataclasses import dataclass, field
from datetime import date, timedelta
from typing import Any

PASSWORD = "demo-password-123"  # development only; seed_demo refuses to run without DEBUG
EMAIL_DOMAIN = "example.com"


def day(offset: int = 0) -> str:
    """ISO date ``offset`` days from today (negative = past)."""
    return (date.today() + timedelta(days=offset)).isoformat()


@dataclass
class Ctx:
    users: dict[str, Any] = field(default_factory=dict)
    workspaces: dict[str, Any] = field(default_factory=dict)
    projects: dict[str, Any] = field(default_factory=dict)
    tasks: dict[str, Any] = field(default_factory=dict)
    extra: dict[str, Any] = field(default_factory=dict)  # anything a module hands on

    @property
    def ws(self) -> Any:
        return self.workspaces["main"]

    @property
    def owner(self) -> Any:
        return self.users["owner"]
