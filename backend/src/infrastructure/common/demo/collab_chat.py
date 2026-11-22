"""Chat: General, a project channel, custom channels, a private group, DMs, threads, reactions,
an @channel, an edited and a removed message, mutes and unread counts."""

from typing import Any

from infrastructure.chat import messages as chat
from infrastructure.chat import services as spaces
from infrastructure.common.demo.base import Ctx
from infrastructure.common.demo.collab_text import body, broadcast


def _send(ctx: Ctx, space: Any, by: str, *paragraphs: Any, parent: Any = None, **kw: Any) -> Any:
    return chat.send(
        ctx.users[by],
        ctx.ws,
        str(space.pk),
        body(*paragraphs),
        parent_id=str(parent.pk) if parent else "",
        **kw,
    )


def _react(ctx: Ctx, space: Any, message: Any, emoji: str, *by: str) -> None:
    for key in by:
        chat.react(ctx.users[key], ctx.ws, str(space.pk), str(message.pk), emoji, True)


def create_chat(ctx: Ctx) -> None:
    u = ctx.users
    owner = u["owner"]
    general = spaces.ensure_general(ctx.ws)
    web = spaces.ensure_project_channel(ctx.projects["web"])
    design = spaces.create_space(owner, ctx.ws, "channel", "design", [])
    random = spaces.create_space(u["admin"], ctx.ws, "channel", "random", [])
    for key in ("member", "dev", "designer"):
        spaces.join(u[key], ctx.ws, str(design.pk))
    leads = spaces.create_space(
        owner, ctx.ws, "group", "Leads", [str(u["admin"].pk), str(u["member"].pk)]
    )

    # General: announcements, an @channel, a thread, reactions.
    hello = _send(ctx, general, "owner", "Welcome to the new TaskForge workspace! 🎉")
    _react(ctx, general, hello, "🎉", "admin", "member", "dev", "designer")
    _send(
        ctx,
        general,
        "owner",
        [broadcast("channel"), " sprint planning moves to 10:00 on Monday."],
        confirm_broadcast=True,
    )
    q = _send(ctx, general, "member", "Where do we keep the brand assets?")
    _send(ctx, general, "designer", "في مجلد التصميم المشترك. ربما أضيفه إلى الدليل.", parent=q)
    _send(
        ctx, general, "admin", ["It's in the handbook under Design, ", u["member"], "."], parent=q
    )
    _react(ctx, general, q, "👍", "owner")
    _send(ctx, general, "dev", "Reminder: the staging DB is reset tonight.")

    # Project channel for Web app.
    crash = _send(ctx, web, "dev", "Checkout API is ready for the front end to try.")
    _send(ctx, web, "designer", ["عالی! ", u["dev"], " چه زمانی می‌توانم تست کنم؟"], parent=crash)
    _send(ctx, web, "dev", "Right now, on staging.", parent=crash)
    _send(ctx, web, "member", "Pushed the empty-state illustration.")
    _react(ctx, web, crash, "🚀", "owner", "member")

    # Design channel in Persian and English, with an edit and a removal.
    d1 = _send(ctx, design, "designer", "به‌روزرسانی سامانهٔ طراحی: رنگ‌های جدید اضافه شد.")
    _react(ctx, design, d1, "❤️", "member", "owner")
    typo = _send(ctx, design, "member", "Spaceing tokens are now 4px based.")
    chat.edit(
        u["member"],
        ctx.ws,
        str(design.pk),
        str(typo.pk),
        typo.version,
        body("Spacing tokens are now 4px based."),
    )
    oops = _send(ctx, design, "dev", "wrong channel")
    chat.delete(u["dev"], ctx.ws, str(design.pk), str(oops.pk))
    _send(ctx, random, "admin", "Friday lunch: pizza or tacos? 🍕🌮")
    spaces.join(owner, ctx.ws, str(random.pk))
    _react(ctx, random, _send(ctx, random, "owner", "Tacos."), "🌮", "admin")

    # A private group and direct messages (some unread for the owner).
    _send(ctx, leads, "admin", "Budget review before Friday, please.")
    _send(ctx, leads, "member", "I'll bring the numbers.")
    dm = spaces.open_dm(u["member"], ctx.ws, str(owner.pk))
    _send(ctx, dm, "member", ["Hi ", owner, ", can you approve the Apple Pay flag?"])
    _send(ctx, dm, "member", "No rush, before Wednesday is fine.")
    dm2 = spaces.open_dm(owner, ctx.ws, str(u["designer"].pk))
    _send(ctx, dm2, "owner", "Thanks for the checkout mockups, they look great.")
    _send(ctx, dm2, "designer", "ممنون! فردا نسخهٔ تاریک را هم می‌فرستم.")
    dm3 = spaces.open_dm(u["dev"], ctx.ws, str(u["admin"].pk))
    _send(ctx, dm3, "dev", "Can you review my PR when you have a minute?")

    # Owner has read General and the design thread; mutes #random; follows #web closely.
    spaces.mark_read(owner, ctx.ws, str(general.pk))
    spaces.mark_read(owner, ctx.ws, str(design.pk))
    spaces.mute(owner, ctx.ws, str(random.pk), forever=True)
    spaces.set_notify(owner, ctx.ws, str(web.pk), True)
    ctx.extra["chat"] = {"general": general, "web": web, "design": design, "dm_owner": dm}
