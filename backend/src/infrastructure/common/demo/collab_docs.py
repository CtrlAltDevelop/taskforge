"""Docs: a workspace wiki with nested pages, project docs, versions, a restricted page, task links
and a Persian page."""

import json
from typing import Any

from infrastructure.common.demo.base import Ctx
from infrastructure.docs import services as docs


def _inline(text: str) -> list[dict[str, Any]]:
    return [{"type": "text", "text": text}]


def _blocks(*items: tuple[Any, ...]) -> str:
    """Items: ("h", level, text) ("p", text) ("b", text) ("c", text, checked) ("code", lang, text)
    ("callout", tone, text) ("task", task) ("page", doc, label) ("table", rows) ("divider",)."""
    out: list[dict[str, Any]] = []
    for item in items:
        kind = item[0]
        if kind == "h":
            out.append(
                {"type": "heading", "attrs": {"level": item[1]}, "content": _inline(item[2])}
            )
        elif kind == "p":
            out.append({"type": "paragraph", "content": _inline(item[1])})
        elif kind == "b":
            out.append({"type": "bullet_item", "attrs": {"indent": 0}, "content": _inline(item[1])})
        elif kind == "c":
            out.append(
                {
                    "type": "checklist_item",
                    "attrs": {"indent": 0, "checked": item[2]},
                    "content": _inline(item[1]),
                }
            )
        elif kind == "code":
            out.append({"type": "code", "attrs": {"language": item[1]}, "text": item[2]})
        elif kind == "callout":
            out.append({"type": "callout", "attrs": {"tone": item[1]}, "content": _inline(item[2])})
        elif kind == "task":
            out.append({"type": "task_card", "attrs": {"task_id": str(item[1].pk)}})
        elif kind == "page":
            out.append(
                {
                    "type": "paragraph",
                    "content": [
                        {"type": "text", "text": "See "},
                        {
                            "type": "mention",
                            "attrs": {"doc_id": str(item[1].doc.pk), "label": item[2]},
                        },
                    ],
                }
            )
        elif kind == "table":
            out.append(
                {
                    "type": "table",
                    "attrs": {"header": True},
                    "rows": [[_inline(c) for c in row] for row in item[1]],
                }
            )
        elif kind == "divider":
            out.append({"type": "divider"})
    return json.dumps(out, ensure_ascii=False)


def _new(
    ctx: Ctx,
    by: str,
    title: str,
    blocks: str,
    *,
    parent: Any = None,
    project: str = "",
    icon: str = "",
) -> Any:
    pid = str(ctx.projects[project].pk) if project else ""
    return docs.create(
        ctx.users[by], ctx.ws, pid, str(parent.doc.pk) if parent else "", title, icon, blocks
    )


def _revise(ctx: Ctx, by: str, view: Any, blocks: str, title: str = "") -> Any:
    changes = {"blocks": blocks}
    if title:
        changes["title"] = title
    return docs.update(ctx.users[by], ctx.ws, str(view.doc.pk), view.content.version, changes)


def create_docs(ctx: Ctx) -> None:
    t = ctx.tasks
    handbook = _new(
        ctx,
        "owner",
        "Team handbook",
        _blocks(
            ("h", 1, "Welcome to Acme Studio"),
            ("p", "How we work, who owns what and where to find things."),
            ("callout", "info", "Everything here is a living page: edit it, it keeps versions."),
        ),
        icon="📘",
    )
    process = _new(
        ctx,
        "admin",
        "How we work",
        _blocks(
            ("h", 2, "Cadence"),
            ("b", "Two-week sprints, planning on Monday."),
            ("b", "Demo and retro on the last Friday."),
            ("h", 2, "Definition of done"),
            ("c", "Code reviewed", True),
            ("c", "Tests written", True),
            ("c", "Docs updated", False),
        ),
        parent=handbook,
        icon="🧭",
    )
    _new(
        ctx,
        "admin",
        "On-call rota",
        _blocks(
            (
                "table",
                [["Week", "Primary", "Backup"], ["1", "Lukas", "Priya"], ["2", "Priya", "Daniel"]],
            ),
        ),
        parent=process,
        icon="📟",
    )
    onboarding = _new(
        ctx,
        "owner",
        "Onboarding checklist",
        _blocks(
            ("c", "Get access to the repo", True),
            ("c", "Read the handbook", False),
            ("c", "Ship a small fix", False),
        ),
        parent=handbook,
        icon="✅",
    )

    # A page that grows through several saved versions.
    notes = _new(
        ctx,
        "owner",
        "Meeting notes",
        _blocks(("h", 2, "Planning"), ("p", "Agenda to follow.")),
        icon="📝",
    )
    notes = _revise(
        ctx,
        "member",
        notes,
        _blocks(("h", 2, "Planning"), ("p", "Goals for the sprint."), ("b", "Checkout redesign")),
    )
    notes = _revise(
        ctx,
        "owner",
        notes,
        _blocks(
            ("h", 2, "Planning"),
            ("p", "Goals for the sprint."),
            ("b", "Checkout redesign"),
            ("b", "Crash fix on Android"),
        ),
        "Sprint planning notes",
    )

    # Project docs, linked to tasks, with a task card and a page mention.
    api = _new(
        ctx,
        "dev",
        "Checkout API contract",
        _blocks(
            ("h", 1, "Checkout API"),
            ("code", "json", '{"cart_id": "c_123", "method": "card"}'),
            ("callout", "warning", "Idempotency keys are required on every POST."),
            ("task", t["chk-api"]),
            ("page", process, "How we work"),
        ),
        project="web",
        icon="🔌",
    )
    docs.link_task(
        ctx.users["dev"],
        ctx.ws,
        str(t["chk-api"].project_id),
        str(t["chk-api"].pk),
        str(api.doc.pk),
    )
    spec = _new(
        ctx,
        "designer",
        "Checkout design spec",
        _blocks(
            ("h", 1, "Checkout design"),
            ("p", "Wires, hi-fi mockups and dark-mode variants."),
            ("task", t["chk-hifi"]),
        ),
        project="web",
        icon="🎨",
    )
    docs.link_task(
        ctx.users["designer"], ctx.ws, str(t["chk"].project_id), str(t["chk"].pk), str(spec.doc.pk)
    )
    plan = _new(
        ctx,
        "owner",
        "iOS 2.4 launch plan",
        _blocks(
            ("h", 1, "Launch plan"),
            ("c", "Freeze the build", True),
            ("c", "Submit to review", False),
            ("task", t["release"]),
        ),
        project="mobile",
        icon="🚀",
    )
    docs.link_task(
        ctx.users["owner"],
        ctx.ws,
        str(t["release"].project_id),
        str(t["release"].pk),
        str(plan.doc.pk),
    )
    _new(
        ctx,
        "member",
        "Bug triage guide",
        _blocks(("h", 2, "Severity"), ("b", "Urgent: customers blocked."), ("b", "Low: cosmetic.")),
        project="bugs",
        icon="🐞",
    )

    # Restricted to the owner and admin, and an archived page.
    secret = _new(
        ctx, "owner", "Salary bands", _blocks(("p", "Confidential: managers only.")), icon="🔒"
    )
    docs.set_access(
        ctx.users["owner"], ctx.ws, str(secret.doc.pk), True, [str(ctx.users["admin"].pk)]
    )
    old = _new(ctx, "owner", "Old roadmap (2023)", _blocks(("p", "Superseded.")), icon="🗄️")
    docs.archive(ctx.users["owner"], ctx.ws, str(old.doc.pk))

    # A page in Persian (right-to-left).
    _new(
        ctx,
        "designer",
        "راهنمای سبک طراحی",
        _blocks(
            ("h", 1, "راهنمای سبک طراحی"),
            ("p", "رنگ‌ها، فاصله‌ها و قواعد نوشتاری محصول در این صفحه گردآوری شده است."),
            ("b", "از رنگ‌های سامانهٔ طراحی استفاده کنید."),
        ),
        icon="🎨",
    )
    ctx.extra["docs"] = {"handbook": handbook, "process": process, "onboarding": onboarding}
