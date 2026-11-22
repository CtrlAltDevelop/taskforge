"""Inbox and watchers: the notifications the comments, chat and assignments already made, plus
the kinds nothing else triggers in a demo, then read/unread/snoozed/archived states and
per-person preferences."""

from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.common.demo.base import Ctx
from infrastructure.inbox import kinds, notify, prefs, watchers
from infrastructure.inbox import services as inbox
from infrastructure.inbox.models import Notification


def _extra(ctx: Ctx, kind: str, to: str, ref: str, payload: dict[str, Any], tag: str) -> None:
    task = ctx.tasks[ref]
    notify.notify(
        kind=kind,
        recipients=[ctx.users[to].pk],
        workspace=ctx.ws,
        project=task.project,
        task=task,
        actor_id=None,
        payload={"title": task.title, "key": task.display_id, **payload},
        dedupe=f"demo:{tag}",
    )


def create_watchers(ctx: Ctx) -> None:
    """Some people follow tasks they did not touch; the viewer only follows."""
    for who, refs in {
        "viewer": ("chk", "login", "crash", "launch"),
        "owner": ("perf", "analytics", "bug-a"),
        "admin": ("crash", "push"),
        "guest": ("bug-plus",),
    }.items():
        for ref in refs:
            task = ctx.tasks[ref]
            watchers.watch(ctx.users[who], ctx.ws, str(task.project_id), str(task.pk), on=True)


def create_notifications(ctx: Ctx) -> None:
    # Kinds that come from timers, automations, goals and webhooks (their own demo data lives in
    # the planning and extras modules; these rows make every kind visible in the inbox).
    _extra(ctx, kinds.DUE_SOON, "owner", "release", {"due_date": "soon"}, "due-owner")
    _extra(ctx, kinds.DUE_SOON, "dev", "crash", {"due_date": "tomorrow"}, "due-dev")
    _extra(ctx, kinds.TIMER_LONG, "dev", "perf", {"hours": 9}, "timer-dev")
    _extra(
        ctx,
        kinds.AUTOMATION,
        "owner",
        "bug-b",
        {"automation": "Triage new bugs", "message": "Assigned to the on-call"},
        "auto-owner",
    )
    _extra(
        ctx,
        kinds.AUTOMATION_DISABLED,
        "admin",
        "bug-b",
        {"automation": "Close stale bugs", "reason": "It failed 5 times in a row."},
        "auto-off",
    )
    _extra(
        ctx,
        kinds.WEBHOOK_DISABLED,
        "admin",
        "chk",
        {"webhook": "Slack #builds", "reason": "The endpoint returned 410."},
        "hook-off",
    )
    _extra(
        ctx,
        kinds.GOAL_AT_RISK,
        "owner",
        "launch",
        {"goal": "Ship iOS 2.4", "progress": 0.35},
        "goal-risk",
    )
    _extra(
        ctx, kinds.GOAL_REACHED, "owner", "analytics", {"goal": "Instrument the funnel"}, "goal-ok"
    )
    _extra(
        ctx,
        kinds.STATUS_CHANGED,
        "member",
        "chk",
        {"from": "To do", "to": "In progress"},
        "status-m",
    )
    _extra(ctx, kinds.TASK_CHANGED, "designer", "login", {}, "changed-d")

    # States for the owner and the member: some read, some archived, one snoozed.
    for key in ("owner", "member"):
        me = ctx.users[key]
        rows = list(Notification.objects.filter(user=me, workspace=ctx.ws).order_by("updated_at"))
        ids = [str(r.pk) for r in rows]
        third = len(ids) // 3
        inbox.mark_read(me, ctx.ws, ids[:third], all_=False, read=True)
        inbox.archive(me, ctx.ws, ids[third : third + 2], archived=True)
        if len(ids) > 6:
            later = (timezone.now() + timedelta(days=1)).isoformat()
            inbox.snooze(me, ctx.ws, ids[-1], later)
    # Everyone else keeps their notifications unread.


def create_preferences(ctx: Ctx) -> None:
    u = ctx.users
    prefs.set_pref(u["owner"], kinds.COMMENTED, inbox=True, push=True, email_mode="digest")
    prefs.set_pref(u["owner"], kinds.STATUS_CHANGED, inbox=False, push=False, email_mode="off")
    prefs.set_pref(u["admin"], kinds.MENTIONED, inbox=True, push=True, email_mode="instant")
    prefs.set_pref(u["dev"], kinds.CHAT_CHANNEL_ALL, inbox=True, push=False, email_mode="off")
    prefs.set_pref(u["member"], kinds.DUE_SOON, inbox=True, push=True, email_mode="digest")
    prefs.set_settings(
        u["owner"], timezone="Europe/Paris", quiet_start="22:00", quiet_end="07:00", digest_hour=8
    )
    prefs.set_settings(
        u["designer"], timezone="Asia/Tehran", quiet_start="23:00", quiet_end="08:00", digest_hour=9
    )
