"""Comments: threads, replies, reactions, mentions, a pin, an edit, a removal, a comment turned
into a subtask, and (in collab_files) comments with files."""

from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.comments import services as comments
from infrastructure.comments.models import Comment
from infrastructure.common.demo.base import Ctx
from infrastructure.common.demo.collab_text import body


def _say(ctx: Ctx, ref: str, by: str, *paragraphs: Any, parent: Comment | None = None) -> Comment:
    task = ctx.tasks[ref]
    return comments.create(
        ctx.users[by],
        ctx.ws,
        str(task.project_id),
        str(task.pk),
        body(*paragraphs),
        parent_id=str(parent.pk) if parent else "",
    )


def _react(ctx: Ctx, ref: str, comment: Comment, emoji: str, *by: str) -> None:
    task = ctx.tasks[ref]
    for key in by:
        comments.react(ctx.users[key], ctx.ws, str(task.project_id), str(comment.pk), emoji, True)


def create_comments(ctx: Ctx) -> None:
    u = ctx.users
    made: dict[str, Comment] = ctx.extra.setdefault("comments", {})

    # Checkout redesign: a long thread with replies, mentions and reactions.
    top = _say(
        ctx, "chk", "owner", ["Kicking this off. ", u["designer"], " can we have wires by Friday?"]
    )
    _say(ctx, "chk", "designer", "Yes, low-fi first, then hi-fi for the payment step.", parent=top)
    _say(
        ctx,
        "chk",
        "admin",
        ["Please loop in ", u["dev"], " early so the API shape is agreed."],
        parent=top,
    )
    _say(ctx, "chk", "dev", "Agreed. I'll draft the endpoint contract today.", parent=top)
    _react(ctx, "chk", top, "👍", "admin", "member", "dev")
    _react(ctx, "chk", top, "🎉", "designer")
    made["chk-top"] = top
    ask = _say(ctx, "chk", "member", "Do we keep Apple Pay in scope for the first release?")
    _say(ctx, "chk", "owner", "Yes, but behind a flag.", parent=ask)
    _react(ctx, "chk", ask, "👀", "owner", "dev")
    comments.pin(u["owner"], ctx.ws, str(ctx.tasks["chk"].project_id), str(top.pk), True)

    # Persian (right-to-left) discussion on the login task.
    fa = _say(
        ctx, "login", "designer", ["سلام ", u["dev"], "، طرح صفحهٔ ورود آماده است. لطفاً بررسی کنید."]
    )
    _say(ctx, "login", "dev", "Looks good. The error states are missing, though.", parent=fa)
    _say(ctx, "login", "designer", "حق با شماست، تا فردا اضافه می‌کنم.", parent=fa)
    _react(ctx, "login", fa, "❤️", "dev", "owner")
    made["login-fa"] = fa

    # An urgent crash with an edited comment and a removed one.
    first = _say(
        ctx, "crash", "dev", "Reproduced on a Pixel 7. The crash is in the push token refresh."
    )
    _say(
        ctx,
        "crash",
        "member",
        ["Customers are noticing. ", u["owner"], " should we pause the rollout?"],
    )
    typo = _say(ctx, "crash", "dev", "Fix is up for review, ETA this afternon.")
    comments.edit(
        u["dev"],
        ctx.ws,
        str(ctx.tasks["crash"].project_id),
        str(typo.pk),
        typo.version,
        body("Fix is up for review, ETA this afternoon."),
    )
    oops = _say(ctx, "crash", "admin", "Wrong task, sorry.")
    comments.delete(u["admin"], ctx.ws, str(ctx.tasks["crash"].project_id), str(oops.pk))
    _react(ctx, "crash", first, "🚀", "owner", "admin")

    # Support person (custom role) comments on a bug; the viewer only reads.
    bug = _say(ctx, "bug-a", "guest", "ملاحظة: هذا يحدث أيضاً على حاسوب المكتب.")
    _say(ctx, "bug-a", "dev", "Thanks, adding it to the repro steps.", parent=bug)
    _say(ctx, "bug-plus", "dev", "The plus sign is stripped by the URL encoder before validation.")
    _say(ctx, "bug-plus", "member", "I can pick up the test for this.")

    # More tasks so every project has some conversation.
    _say(
        ctx,
        "launch",
        "owner",
        "Launch checklist is in the linked doc. Please tick items as you go.",
    )
    _say(
        ctx,
        "perf",
        "dev",
        "Profile attached to the first run: the list rebuilds on every scroll tick.",
    )
    _say(
        ctx,
        "analytics",
        "admin",
        ["Events naming follows the doc. ", u["member"], " owns the dashboard."],
    )
    _say(ctx, "release", "owner", "Release notes draft is ready for review.")
    _say(ctx, "push", "designer", "Permission prompt copy: should it explain why before asking?")
    _say(ctx, "flaky", "dev", "Failed 3 out of 20 runs; always the payment mock timeout.")
    flaky_dup = _say(ctx, "flaky-dup", "admin", "Looks like a duplicate of the flaky test task.")
    _react(ctx, "flaky-dup", flaky_dup, "👍", "dev")

    # A comment promoted to a subtask.
    idea = _say(ctx, "launch", "member", "We should also announce this in the newsletter.")
    comments.to_subtask(u["owner"], ctx.ws, str(ctx.tasks["launch"].project_id), str(idea.pk))

    _spread_in_time(ctx)


def _spread_in_time(ctx: Ctx) -> None:
    """Comments were all made 'now': spread them over the last two weeks so the feed looks real."""
    now = timezone.now()
    rows = list(Comment.objects.filter(workspace=ctx.ws).order_by("created_at"))
    for index, comment in enumerate(rows):  # oldest first, so a reply stays after its parent
        when = now - timedelta(hours=(len(rows) - index) * 5)
        Comment.objects.filter(pk=comment.pk).update(created_at=when)
