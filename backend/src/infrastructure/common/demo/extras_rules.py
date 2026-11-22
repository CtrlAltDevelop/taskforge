"""Demo rules and intake: automations (with runs), public forms (with submissions), templates.

Rules are created first and then fired through the engine, so runs are real: a comment that was
written, a status that was refused. Run times are spread over the last two weeks afterwards.
"""

import json
from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.automations import engine, spec
from infrastructure.automations import services as automations
from infrastructure.automations.models import AutomationRun
from infrastructure.common.demo.base import Ctx, day
from infrastructure.forms import services as forms
from infrastructure.forms import submit
from infrastructure.tasks.models import Task
from infrastructure.templates import apply as template_apply
from infrastructure.templates import services as templates


def _status(ctx: Ctx, project: str, name: str) -> str:
    return ctx.extra["status"][project][name]


def _rule(
    ctx: Ctx, project: str, name: str, trigger: dict[str, Any], actions: Any, **kw: Any
) -> Any:
    view = automations.create(
        ctx.owner, ctx.ws, str(ctx.projects[project].pk), name, trigger, actions, **kw
    )
    return view.automation


def _fire(rule: Any, task: Task, trigger: str, data: dict[str, Any] | None = None) -> None:
    event = {
        "type": trigger,
        "id": f"demo:{rule.pk}:{task.pk}",
        "task_id": str(task.pk),
        "depth": 0,
        "data": data or {},
    }
    engine.execute(rule.pk, event)


def create_automations(ctx: Ctx) -> None:
    """Seven rules: runs that succeed, fail and skip, a due-date rule, one switched off."""
    users, field = ctx.users, ctx.extra["fields"]
    thanks = {"type": "add_comment", "text": "Thanks for the report! We triage within two days."}
    ack = _rule(
        ctx,
        "bugs",
        "Acknowledge new bug reports",
        {"type": spec.TASK_CREATED},
        [thanks, {"type": "notify", "to": [str(users["admin"].pk)], "message": "New bug: {title}"}],
    )
    triage = _rule(
        ctx,
        "bugs",
        "Triaged bugs go to Lukas",
        {"type": spec.STATUS_CHANGED, "to_status": _status(ctx, "bugs", "Triaged")},
        [{"type": "set_assignee", "mode": "set", "user_ids": [str(users["dev"].pk)]}],
    )
    # Bugs may not jump from Reported to Fixed, so this rule's run fails (a visible error).
    fast = _rule(
        ctx,
        "bugs",
        "Fast-track assigned bugs",
        {"type": spec.ASSIGNED},
        [{"type": "set_status", "status": _status(ctx, "bugs", "Fixed")}],
    )
    stamp = _rule(
        ctx,
        "web",
        "Stamp the review date when work is done",
        {"type": spec.STATUS_CHANGED, "to_status": _status(ctx, "web", "Done")},
        [
            {
                "type": "set_field",
                "field": f"{spec.CUSTOM_PREFIX}{field['Review by'].pk}",
                "value": "{today}",
            },
            {"type": "add_comment", "text": "Done on {today}: {key} {title}"},
        ],
    )
    skipped = _rule(
        ctx,
        "web",
        "Celebrate urgent work shipped",
        {"type": spec.STATUS_CHANGED, "to_status": _status(ctx, "web", "Done")},
        [{"type": "notify", "to": ["creator"], "message": "Urgent work shipped: {title}"}],
        condition_tfql="priority = urgent",
    )
    _rule(
        ctx,
        "web",
        "Remind assignees three days before due",
        {"type": spec.DUE_DATE_REACHED, "days_before": 3},
        [{"type": "notify", "to": ["assignees"], "message": "{key} is due soon"}],
    )
    off = _rule(
        ctx,
        "marketing",
        "Tell the team when a post is published",
        {"type": spec.STATUS_CHANGED, "to_status": _status(ctx, "marketing", "Published")},
        [{"type": "add_comment", "text": "Published on {today}."}],
        enabled=False,
    )
    ctx.extra["automations"] = {
        "ack": ack,
        "triage": triage,
        "fast": fast,
        "stamp": stamp,
        "off": off,
    }
    _run_rules(ctx, ack, triage, fast, stamp, skipped)


def _run_rules(ctx: Ctx, ack: Any, triage: Any, fast: Any, stamp: Any, skipped: Any) -> None:
    bug = ctx.tasks["bug-b"]  # Reported: the fast-track rule cannot move it to Fixed
    _fire(ack, bug, spec.TASK_CREATED)
    _fire(ack, ctx.tasks["bug-plus"], spec.TASK_CREATED)
    _fire(
        triage,
        ctx.tasks["bug-plus"],
        spec.STATUS_CHANGED,
        {"to_status": triage.trigger["to_status"]},
    )
    _fire(fast, bug, spec.ASSIGNED, {"user_ids": [str(ctx.users["dev"].pk)]})
    done = Task.objects.filter(
        project=ctx.projects["web"], status_id=stamp.trigger["to_status"], deleted_at__isnull=True
    ).exclude(priority="urgent")
    for task in done[:2]:
        data = {"to_status": stamp.trigger["to_status"]}
        _fire(stamp, task, spec.STATUS_CHANGED, data)
        _fire(skipped, task, spec.STATUS_CHANGED, data)
    _spread_runs()


def _spread_runs() -> None:
    now = timezone.now()
    for index, run in enumerate(AutomationRun.objects.order_by("started_at")):
        when = now - timedelta(days=13 - index * 2, hours=index)
        AutomationRun.objects.filter(pk=run.pk).update(
            started_at=when, finished_at=when + timedelta(seconds=1) if run.finished_at else None
        )


def create_forms(ctx: Ctx) -> None:
    """Three forms (two live, one off) and five public submissions that became tasks."""
    fields, owner = ctx.extra["fields"], ctx.owner
    bug = forms.create(
        owner,
        ctx.ws,
        str(ctx.projects["bugs"].pk),
        "Report a bug",
        fields=[
            {"id": "title", "kind": "title", "label": "What went wrong?"},
            {"id": "what", "kind": "description", "label": "Steps to reproduce"},
        ],
        description="Tell us what happened. We read every report.",
        send_confirmation=False,
    ).form
    feedback = forms.create(
        owner,
        ctx.ws,
        str(ctx.projects["web"].pk),
        "Website feedback",
        fields=[
            {"id": "title", "kind": "title", "label": "Summary"},
            {"id": "what", "kind": "description", "label": "Details"},
            {"id": "team", "kind": "custom", "custom_field_id": str(fields["Team"].pk)},
            {"id": "who", "kind": "custom", "custom_field_id": str(fields["Customer"].pk)},
        ],
        defaults={
            "priority": "low",
            "field_defaults": {str(fields["Labels"].pk): ctx.extra["label_options"]["customer"]},
        },
        require_email=True,
        brand_color="#1E88E5",
        send_confirmation=False,
    ).form
    forms.create(
        owner,
        ctx.ws,
        str(ctx.projects["marketing"].pk),
        "Content request",
        fields=[{"id": "title", "kind": "title", "label": "What do you need written?"}],
        enabled=False,
    )
    ctx.extra["forms"] = {"bug": bug, "feedback": feedback}
    _submissions(ctx, bug, feedback)


def _submissions(ctx: Ctx, bug: Any, feedback: Any) -> None:
    team = ctx.extra["team_options"]
    sent = (
        (bug, {"title": "Cannot reset my password", "what": "The email never arrives."}, ""),
        (bug, {"title": "Dark mode flickers on load", "what": "Safari 17, every refresh."}, ""),
        (
            bug,
            {
                "title": "خطا در ورود با شمارهٔ موبایل",
                "what": "بعد از وارد کردن کد، صفحه خالی می‌شود.",
            },
            "",
        ),
        (
            feedback,
            {
                "title": "Pricing page is hard to read",
                "what": "Too much text.",
                "team": team["Design"],
                "who": "Initech",
            },
            "alex@initech.example",
        ),
        (
            feedback,
            {
                "title": "Checkout is great",
                "what": "Fast and clear.",
                "team": team["Frontend"],
                "who": "Globex",
            },
            "sam@globex.example",
        ),
    )
    for index, (form, answers, email) in enumerate(sent):
        submit.submit(
            form.token,
            answers=answers,
            email=email,
            honeypot="",
            captcha_token="",
            files={},
            ip=f"203.0.113.{10 + index}",
            locale="fa" if index == 2 else "en",
        )


def create_templates(ctx: Ctx) -> None:
    """A hand-written task template (with a variable), three saved from real work, one applied."""
    owner, pid = ctx.owner, lambda key: str(ctx.projects[key].pk)  # noqa: E731
    onboarding = json.dumps(
        {
            "schema": 1,
            "tasks": [
                {
                    "ref": "kick",
                    "title": "Kick-off call with {{customer}}",
                    "priority": "high",
                    "due_offset": 2,
                },
                {
                    "ref": "data",
                    "parent": "kick",
                    "title": "Collect {{customer}}'s data",
                    "due_offset": 5,
                },
                {
                    "ref": "train",
                    "parent": "kick",
                    "title": "Train {{customer}}'s team",
                    "due_offset": 9,
                },
                {"ref": "review", "title": "30-day review with {{customer}}", "due_offset": 30},
            ],
        }
    )
    checklist = templates.create(
        owner,
        ctx.ws,
        "task",
        "Customer onboarding",
        "Steps for every new customer.",
        "workspace",
        onboarding,
    )
    templates.save_from_project(
        owner,
        ctx.ws,
        pid("marketing"),
        "Campaign kit",
        "Marketing workflow and tasks.",
        "workspace",
        ["workflow", "tasks"],
        False,
    )
    templates.save_from_project(
        owner,
        ctx.ws,
        pid("web"),
        "Product squad",
        "Workflow, fields and rules of Website.",
        "workspace",
        ["workflow", "fields", "automations", "features"],
        False,
    )
    templates.save_from_task(
        ctx.users["member"],
        ctx.ws,
        pid("web"),
        str(ctx.tasks["chk"].pk),
        "Checkout epic",
        "My private copy of the checkout plan.",
        "private",
        True,
    )
    template_apply.apply(
        owner,
        ctx.ws,
        checklist.id,
        project_id=pid("mobile"),
        variables={"customer": "Globex"},
        start_date=day(0),
    )
