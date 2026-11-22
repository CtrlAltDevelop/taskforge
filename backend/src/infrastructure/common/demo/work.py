"""Projects, features, workflows, custom fields, saved filters and views of the demo."""

import uuid
from typing import Any

from infrastructure.common.demo.base import Ctx
from infrastructure.customfields import services as fields
from infrastructure.filters import services as filters
from infrastructure.projects import members as project_members
from infrastructure.projects import services as projects
from infrastructure.projects.features import FEATURE_KEYS
from infrastructure.savedviews import services as views
from infrastructure.workflows import services as workflows
from infrastructure.workflows.drafts import StatusDraft as S
from infrastructure.workflows.drafts import TransitionDraft as T
from infrastructure.workflows.drafts import WorkflowDraft
from infrastructure.workspaces import access

# key, name, project key, description, icon, colour, visibility
PROJECTS = (
    (
        "web",
        "Website",
        "WEB",
        "The marketing site, checkout and the customer web app.",
        "🌐",
        "#1E88E5",
        "open",
    ),
    (
        "mobile",
        "Mobile app",
        "MOB",
        "iOS and Android clients, shipped every two weeks.",
        "📱",
        "#8E24AA",
        "open",
    ),
    (
        "bugs",
        "Bug tracker",
        "BUG",
        "Everything customers report, triaged weekly.",
        "🐞",
        "#E53935",
        "open",
    ),
    ("marketing", "Marketing", "MKT", "Campaigns, content and launches.", "📣", "#FB8C00", "open"),
    (
        "private",
        "Leadership",
        "PRV",
        "Salary, board and deal notes. Owner and admin only.",
        "🔒",
        "#455A64",
        "private",
    ),
    (
        "archived",
        "Old site",
        "OLD",
        "The previous website, kept for reference.",
        "📦",
        "#757575",
        "open",
    ),
)

# (name, colour, category) in display order; the first not_started one is the default.
WEB_STATUSES = (
    ("Backlog", "#9E9E9E", "not_started"),
    ("In progress", "#1E88E5", "active"),
    ("In review", "#8E24AA", "active"),
    ("On hold", "#E53935", "active"),
    ("Done", "#43A047", "done"),
    ("Cancelled", "#757575", "cancelled"),
)
BUG_STATUSES = (
    ("Reported", "#9E9E9E", "not_started"),
    ("Triaged", "#FB8C00", "not_started"),
    ("In progress", "#1E88E5", "active"),
    ("In review", "#8E24AA", "active"),
    ("Fixed", "#43A047", "done"),
    ("Won't fix", "#757575", "cancelled"),
)
BUG_FLOW = (
    ("Reported", "Triaged"),
    ("Triaged", "In progress"),
    ("In progress", "In review"),
    ("In review", "In progress"),
    ("In review", "Fixed"),
    ("Reported", "Won't fix"),
    ("Triaged", "Won't fix"),
    ("In review", "Won't fix"),
)
MARKETING_STATUSES = (
    ("Idea", "#9E9E9E", "not_started"),
    ("Drafting", "#1E88E5", "active"),
    ("Review", "#8E24AA", "active"),
    ("Scheduled", "#FB8C00", "active"),
    ("Published", "#43A047", "done"),
    ("Dropped", "#757575", "cancelled"),
)
TEAM = ("Frontend", "Backend", "Design", "QA")
LABELS = ("bug", "feature", "chore", "docs", "customer")


def _opts(names: tuple[str, ...]) -> list[dict[str, str]]:
    palette = ("#1E88E5", "#43A047", "#8E24AA", "#FB8C00", "#E53935")
    return [
        {"id": uuid.uuid4().hex, "label": n, "color": palette[i % 5]} for i, n in enumerate(names)
    ]


def create_projects(ctx: Ctx) -> None:
    owner = ctx.owner
    for key, name, pkey, text, icon, color, visibility in PROJECTS:
        shown = projects.create(owner, ctx.ws, name, pkey, text, icon, color, visibility)
        ctx.projects[key] = shown.project
    members = ctx.users
    project = ctx.projects["private"]
    project_members.add_member(owner, ctx.ws, str(project.pk), str(members["admin"].pk))
    for key in ("web", "mobile", "bugs", "marketing"):
        _all_features(ctx, key)
    for key, who in (
        ("web", ("owner", "member")),
        ("mobile", ("dev",)),
        ("bugs", ("admin",)),
        ("marketing", ("designer", "owner")),
        ("private", ("admin",)),
    ):
        for person in who:
            projects.favorite(members[person], ctx.ws, str(ctx.projects[key].pk), True)


def _all_features(ctx: Ctx, key: str) -> None:
    pid = str(ctx.projects[key].pk)
    shown = projects.get(ctx.owner, ctx.ws, pid)
    updated = projects.set_features(ctx.owner, ctx.ws, pid, FEATURE_KEYS, shown.project.version)
    ctx.projects[key] = updated.project


def _statuses(spec: tuple[tuple[str, str, str], ...]) -> tuple[S, ...]:
    return tuple(
        S(key=name, name=name, color=color, category=cat, is_default=i == 0)
        for i, (name, color, cat) in enumerate(spec)
    )


def _save_workflow(ctx: Ctx, key: str, draft: WorkflowDraft) -> None:
    pid = str(ctx.projects[key].pk)
    current = workflows.get(ctx.owner, ctx.ws, pid)
    workflows.update(ctx.owner, ctx.ws, pid, current.workflow.version, draft, {})


def create_workflows(ctx: Ctx) -> None:
    """Web and marketing: six statuses, every category. Bugs: restricted transitions."""
    _save_workflow(ctx, "web", WorkflowDraft(statuses=_statuses(WEB_STATUSES)))
    _save_workflow(ctx, "marketing", WorkflowDraft(statuses=_statuses(MARKETING_STATUSES)))
    admin_role = str(access.builtin_role("Admin").pk)
    flow = tuple(
        T(
            a,
            b,
            required_role_id=admin_role if b == "Won't fix" and a == "In review" else "",
            require_assignee=(a, b) == ("Triaged", "In progress"),
        )
        for a, b in BUG_FLOW
    )
    _save_workflow(
        ctx,
        "bugs",
        WorkflowDraft(statuses=_statuses(BUG_STATUSES), transitions=flow, restrict=True),
    )
    for key in ("web", "mobile", "bugs", "marketing", "private", "archived"):
        shown = workflows.get(ctx.owner, ctx.ws, str(ctx.projects[key].pk))
        ctx.extra.setdefault("status", {})[key] = {s.name: str(s.pk) for s in shown.statuses}


def create_fields(ctx: Ctx) -> None:
    """Nine field types on Website; Team is required and defaults to Frontend."""
    owner, pid = ctx.owner, str(ctx.projects["web"].pk)
    team = _opts(TEAM)
    specs: tuple[dict[str, Any], ...] = (
        {
            "name": "Team",
            "type": "select",
            "options": team,
            "required": True,
            "default": team[0]["id"],
        },
        {"name": "Labels", "type": "multiselect", "options": _opts(LABELS)},
        {"name": "Customer", "type": "text"},
        {"name": "Spec link", "type": "url"},
        {"name": "Budget", "type": "money"},
        {"name": "Effort", "type": "number"},
        {"name": "Review by", "type": "date"},
        {"name": "Needs QA", "type": "checkbox", "default": "false"},
        {"name": "Sponsor", "type": "user"},
    )
    made = {}
    for spec in specs:
        field = fields.create(owner, ctx.ws, pid, **spec)
        made[field.name] = field
    ctx.extra["fields"] = made
    ctx.extra["team_options"] = {o["label"]: o["id"] for o in team}
    ctx.extra["label_options"] = {o["label"]: o["id"] for o in made["Labels"].options}


def create_filters_and_views(ctx: Ctx) -> None:
    admin, owner = ctx.users["admin"], ctx.owner
    filters.save(
        owner,
        ctx.ws,
        "",
        name="Overdue anywhere",
        text="due < +0d AND category != done",
        visibility="workspace",
    )
    for key, project in ctx.projects.items():
        if key in ("private", "archived"):
            continue
        pid = str(project.pk)
        for name, text, who, visibility in _filters(key, ctx):
            filters.save(who, ctx.ws, pid, name=name, text=text, visibility=visibility)
        _views(ctx, key, pid, owner, admin)


def _filters(key: str, ctx: Ctx) -> list[tuple[str, str, Any, str]]:
    owner, dev, member = ctx.owner, ctx.users["dev"], ctx.users["member"]
    common = [
        ("Due this week", "due <= +7d AND category != done", owner, "project"),
        ("My open tasks", "assignee = me AND category != done", member, "private"),
        ("Urgent or high", "priority in (urgent, high)", owner, "project"),
    ]
    extra = {
        "web": [("Needs design", "assignee = me", dev, "private")],
        "bugs": [("Unassigned bugs", "assignee IS EMPTY", owner, "project")],
    }
    return common + extra.get(key, [])


def _views(ctx: Ctx, key: str, pid: str, owner: Any, admin: Any) -> None:
    status_ids = ctx.extra["status"][key]
    busy = status_ids.get("In progress") or next(iter(status_ids.values()))
    saved = (
        (
            admin,
            "Board by status",
            "board",
            False,
            {"group_by": "status", "limits": {busy: 2 if key == "bugs" else 4}},
            True,
            1,
        ),
        (
            owner,
            "Team calendar",
            "calendar",
            True,
            {"mode": "month", "color_by": "priority", "hide_done": True},
            True,
            2,
        ),
        (
            owner,
            "Roadmap",
            "timeline",
            True,
            {"zoom": "week", "group_by": "assignee", "critical_path": True},
            False,
            3,
        ),
        (
            owner,
            "Compact list",
            "list",
            True,
            {"columns": ["status", "assignee", "due_date"], "sort": [], "group_by": "status"},
            False,
            4,
        ),
        (
            ctx.users["member"],
            "My list",
            "list",
            False,
            {"columns": ["status", "priority", "due_date"], "group_by": ""},
            False,
            5,
        ),
    )
    for who, name, kind, shared, config, pinned, order in saved:
        views.save(
            who,
            ctx.ws,
            pid,
            name=name,
            kind=kind,
            config=config,
            shared=shared,
            pinned_as_tab=pinned,
            tab_order=order,
        )
