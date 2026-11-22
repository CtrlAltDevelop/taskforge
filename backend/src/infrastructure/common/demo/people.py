"""Users, the two workspaces, roles, members and invitations of the demo."""

from dataclasses import dataclass
from datetime import timedelta
from typing import Any

from django.contrib.auth import get_user_model
from django.utils import timezone

from infrastructure.accounts.models import Profile
from infrastructure.common.demo.base import EMAIL_DOMAIN, PASSWORD, Ctx
from infrastructure.workspaces import access, invitations, roles
from infrastructure.workspaces import services as workspaces
from infrastructure.workspaces.models import WorkspaceMember


@dataclass(frozen=True, slots=True)
class Person:
    key: str
    name: str
    role: str  # a built-in role name, "Support" (custom) or "" (owner, already a member)
    locale: str = "en"
    joined_days_ago: int = 60


# Two names in Arabic script (Persian, Arabic) so right-to-left shows up in lists and avatars.
PEOPLE: tuple[Person, ...] = (
    Person("owner", "Maya Torres", "", joined_days_ago=90),
    Person("admin", "Daniel Kim", "Admin", joined_days_ago=85),
    Person("member", "Priya Nair", "Member", joined_days_ago=70),
    Person("dev", "Lukas Brandt", "Member", joined_days_ago=55),
    Person("designer", "نگار رضایی", "Member", locale="fa", joined_days_ago=40),
    Person("viewer", "Chloe Martin", "Viewer", joined_days_ago=25),
    Person("guest", "خالد الحسن", "Support", locale="ar", joined_days_ago=10),
)
SUPPORT_GRANTS = (
    "workspace.view",
    "member.view",
    "role.view",
    "task.create",
    "task.update",
    "comment.create",
    "time.log",
    "chat.read",
    "chat.post",
)


def email_of(key: str) -> str:
    return f"{key}@{EMAIL_DOMAIN}"


def _make_user(key: str, name: str, locale: str = "en") -> Any:
    user = get_user_model().objects.create_user(
        username=key, email=email_of(key), password=PASSWORD
    )
    user.mark_email_verified()
    Profile.objects.filter(pk=user.pk).update(display_name=name, locale=locale)
    return user


def create_users(ctx: Ctx) -> None:
    for person in PEOPLE:
        ctx.users[person.key] = _make_user(person.key, person.name, person.locale)
    ctx.users["demo"] = _make_user("demo", "Demo User")


def _role_id(ctx: Ctx, name: str) -> str:
    if name == "Support":
        return str(ctx.extra["support_role"].role.pk)
    return str(access.builtin_role(name).pk) if name else ""


def _join(ctx: Ctx, key: str, role: str, days_ago: int) -> None:
    """Invite by email, then accept as that user: the same path a real person takes."""
    owner, user = ctx.owner, ctx.users[key]
    sent = invitations.create_invitations(ctx.ws, owner, [user.email], _role_id(ctx, role))
    invitations.accept(sent.created[0].token, user)
    # Backdate the join so "Joined ..." and member lists look lived-in (no service for it).
    joined = timezone.now() - timedelta(days=days_ago)
    WorkspaceMember.objects.filter(workspace=ctx.ws, user=user).update(joined_at=joined)


def create_workspaces(ctx: Ctx) -> None:
    owner = ctx.owner
    ctx.workspaces["main"] = workspaces.create(owner, "Acme Studio", "acme")
    ctx.workspaces["side"] = workspaces.create(owner, "Side Project", "side-project")
    ctx.extra["support_role"] = roles.create_role(ctx.ws, owner, "Support", SUPPORT_GRANTS)
    for person in PEOPLE:
        if person.role:
            _join(ctx, person.key, person.role, person.joined_days_ago)
    _join(ctx, "demo", "Member", 5)
    WorkspaceMember.objects.filter(workspace=ctx.ws, user=owner).update(
        joined_at=timezone.now() - timedelta(days=90)
    )
    # A small second workspace so the switcher has two entries, with one more person in it.
    side = ctx.workspaces["side"]
    sent = invitations.create_invitations(side, owner, [ctx.users["dev"].email])
    invitations.accept(sent.created[0].token, ctx.users["dev"])


def create_invitations_pending(ctx: Ctx) -> None:
    """One pending invitation by email and one shareable link, for the Pending tab."""
    invitations.create_invitations(
        ctx.ws, ctx.users["admin"], [f"newhire@{EMAIL_DOMAIN}"], _role_id(ctx, "Member")
    )
    ctx.extra["invite_link"] = invitations.create_link(
        ctx.ws, ctx.owner, expires_in=7 * 24 * 3600, max_uses=10, role_id=_role_id(ctx, "Viewer")
    )
