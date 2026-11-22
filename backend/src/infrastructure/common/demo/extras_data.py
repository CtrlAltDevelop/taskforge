"""Demo imports and exports, plus each person's own leftovers: shortcuts, recents, searches."""

import io

from django.test.utils import override_settings
from django.utils import timezone

from infrastructure.common.demo.base import Ctx
from infrastructure.home import onboarding
from infrastructure.home import summary as home
from infrastructure.imports import exports
from infrastructure.imports import services as imports
from infrastructure.imports.models import ImportJob
from infrastructure.imports.models import Status as ImportStatus
from infrastructure.search import services as search
from infrastructure.shortcuts import services as shortcuts

JIRA_CSV = (
    "Summary,Issue key,Issue id,Issue Type,Status,Priority,Assignee,Created\n"
    "Legacy billing epic,BIL-1,20001,Epic,To Do,High,owner@example.com,12/Sep/26 10:30 AM\n"
    "Invoice PDF layout,BIL-2,20002,Story,In Progress,Medium,dev@example.com,14/Sep/26 11:00 AM\n"
    "Tax rounding bug,BIL-3,20003,Bug,Done,Highest,member@example.com,15/Sep/26 9:15 AM\n"
)
GENERIC_CSV = (
    "Name;Details;State;Owner;Due\n"
    "Order office chairs;Ten of them;Open;admin@example.com;2026-12-01\n"
    "Renew the domain;;Done;nobody@example.net;2026-12-02\n"
    ";a row without a title;Open;;\n"
)


def _upload(ctx: Ctx, text: str, name: str) -> ImportJob:
    return imports.upload(ctx.owner, ctx.ws, io.BytesIO(text.encode()), name)


def _run(ctx: Ctx, text: str, name: str, target: dict[str, str]) -> ImportJob:
    job = imports.analyze(ctx.owner, ctx.ws, str(_upload(ctx, text, name).pk)).job
    return imports.start(ctx.owner, ctx.ws, str(job.pk), {**job.mapping, "target": target})


def create_imports(ctx: Ctx) -> None:
    """A finished Jira import (new project), a finished CSV import with one bad row, one waiting
    for its mapping, one that failed, and a finished project export."""
    web = {"project_id": str(ctx.projects["web"].pk)}
    with override_settings(IMPORTS_SYNC_RUN=True):
        _run(ctx, JIRA_CSV, "jira-billing.csv", {"name": "Billing (from Jira)", "key": "BIL"})
        _run(ctx, GENERIC_CSV, "office-todo.csv", {"project_id": str(ctx.projects["marketing"].pk)})
        waiting = _upload(ctx, GENERIC_CSV, "waiting.csv")
        imports.analyze(ctx.owner, ctx.ws, str(waiting.pk))
        broken = imports.analyze(
            ctx.owner, ctx.ws, str(_upload(ctx, GENERIC_CSV, "broken.csv").pk)
        ).job
        ImportJob.objects.filter(pk=broken.pk).update(
            status=ImportStatus.FAILED,
            error="The file ended in the middle of a row.",
            finished_at=timezone.now(),
            attempts=1,
        )
        exports.start(ctx.owner, ctx.ws, web["project_id"])


def create_personal(ctx: Ctx) -> None:
    """Shortcut overrides, recently opened tasks, saved searches and first-run state."""
    owner, dev, member = ctx.owner, ctx.users["dev"], ctx.users["member"]
    for action, keys in (("task.new", "alt+n"), ("nav.inbox", "alt+i"), ("nav.chat", "alt+c")):
        shortcuts.set_binding(owner, action, keys)
    shortcuts.set_binding(dev, "task.new", "alt+shift+n")
    shortcuts.set_binding(dev, "nav.home", "")  # unbound on purpose
    for user, refs in (
        (owner, ("chk", "login", "launch")),
        (member, ("crash", "bug-b")),
        (dev, ("flutter", "perf")),
    ):
        for ref in refs:
            home.record_recent(user, ctx.ws, str(ctx.tasks[ref].pk))
    for text in ("checkout", "login bug", "نگار", "due this week"):
        search.remember(owner, ctx.ws, text)
    search.remember(member, ctx.ws, "release")
    onboarding.dismiss(owner, ctx.ws)
    onboarding.complete_step(ctx.users["demo"], ctx.ws, "open_palette")
