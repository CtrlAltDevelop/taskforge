"""Goals (objectives, key results of every kind, check-ins) and dashboards (every widget)."""

import uuid

from infrastructure.common.demo.base import Ctx
from infrastructure.dashboards import config as widgets
from infrastructure.dashboards import services as dashboards
from infrastructure.dashboards.models import Visibility
from infrastructure.dashboards.services import WidgetInput
from infrastructure.goals import services as goals

CHECKOUT_TASKS = ("chk", "chk-audit", "chk-pay", "chk-wire", "chk-hifi", "chk-api")


def _ids(ctx: Ctx, *keys: str) -> list[str]:
    return [str(ctx.users[k].pk) for k in keys]


def _check_ins(ctx: Ctx, view: goals.GoalView, index: int, readings: tuple[int, ...]) -> None:
    for value in readings:
        goals.add_check_in(
            ctx.users["admin"], ctx.ws, str(view.krs[index].kr.pk), value, "Weekly update"
        )


def _goal_tree(ctx: Ctx) -> dict[str, goals.Goal]:
    owner, ws, made = ctx.owner, ctx.ws, {}
    folder = goals.save_folder(owner, ws, "", "Company 2026")
    top = goals.create(
        owner, ws, "Launch the new checkout", "2026-09-01", "2027-02-28", folder_id=str(folder.pk),
        description="One objective for the quarter: fewer steps, more orders.",
        owner_id=str(ctx.users["admin"].pk), contributor_ids=_ids(ctx, "dev", "designer"),
    )  # fmt: skip
    gid = str(top.goal.pk)
    goals.create_kr(
        owner,
        ws,
        gid,
        "Screens in the checkout",
        "number",
        start_value=5,
        target_value=3,
        current_value=4,
    )
    goals.create_kr(owner, ws, gid, "Wallet payment adoption", "percentage", current_value=35)
    goals.create_kr(owner, ws, gid, "Legal sign-off", "boolean")
    view = goals.create_kr(
        owner,
        ws,
        gid,
        "Checkout tasks done",
        "linked",
        task_ids=[str(ctx.tasks[r].pk) for r in CHECKOUT_TASKS],
    )
    _check_ins(ctx, view, 0, (5, 4))
    _check_ins(ctx, view, 1, (10, 22, 35))
    made["checkout"] = view.goal
    child = goals.create(
        owner, ws, "Raise conversion by 10%", "2026-09-01", "2027-02-28", parent_id=gid,
        folder_id=str(folder.pk), owner_id=str(ctx.users["member"].pk),
    )  # fmt: skip
    goals.create_kr(
        owner,
        ws,
        str(child.goal.pk),
        "Conversion rate",
        "percentage",
        start_value=2,
        target_value=12,
        current_value=5,
    )
    made["conversion"] = child.goal
    shipped = goals.create(
        owner, ws, "Fix the crash backlog", "2026-06-01", "2026-08-31", folder_id=str(folder.pk)
    )
    goals.create_kr(
        owner,
        ws,
        str(shipped.goal.pk),
        "Open crash reports",
        "number",
        start_value=40,
        target_value=0,
        current_value=0,
    )
    made["crashes"] = shipped.goal
    private = goals.create(
        owner, ws, "Hire two engineers", "2026-09-01", "2027-03-31", private=True
    )
    goals.create_kr(
        owner,
        ws,
        str(private.goal.pk),
        "Offers accepted",
        "number",
        target_value=2,
        current_value=1,
    )
    made["hiring"] = private.goal
    return made


def _widget(kind: str, title: str, **config: object) -> WidgetInput:
    return WidgetInput(str(uuid.uuid4()), kind, title, config)


def _dashboards(ctx: Ctx) -> None:
    owner, ws = ctx.owner, ctx.ws
    web = str(ctx.projects["web"].pk)
    sprint = str(ctx.extra["sprints"]["active"].pk)
    every = [
        _widget(widgets.NUMBER, "Open tasks", scope="open"),
        _widget(widgets.NUMBER, "Points in sprint", measure="points", sprint_id=sprint),
        _widget(widgets.BAR, "Tasks by status", group_by="status"),
        _widget(widgets.LINE, "Created per week", group_by="created_week"),
        _widget(widgets.PIE, "By priority", group_by="priority", scope="open"),
        _widget(widgets.TABLE, "Open by project", group_by="project", scope="open"),
        _widget(widgets.BURNDOWN, "Sprint 13 burndown", sprint_id=sprint, project_id=web),
        _widget(widgets.WORKLOAD, "Who is busy", measure="estimate_hours"),
        _widget(widgets.GOALS, "Goals", scope="open"),
    ]
    dashboards.save(
        owner, ws, "", name="Company health", visibility=Visibility.WORKSPACE, project_id="",
        widgets=every, layout=[],
    )  # fmt: skip
    dashboards.save(
        ctx.users["admin"], ws, "", name="Web project board", visibility=Visibility.PROJECT,
        project_id=web, widgets=dashboards.template_widgets("project_overview"), layout=[],
    )  # fmt: skip
    dashboards.from_template(owner, ws, "project_overview", web)
    dashboards.from_template(ctx.users["dev"], ws, "my_work")


def seed(ctx: Ctx) -> None:
    ctx.extra["goals"] = _goal_tree(ctx)
    _dashboards(ctx)
