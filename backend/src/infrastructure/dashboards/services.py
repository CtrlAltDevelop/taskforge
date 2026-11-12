"""Dashboards: who may see and change them, saving a whole dashboard at once, and the data behind
a widget (computed per viewer, cached for a minute under a key that names the viewer)."""

import csv
import io
import uuid
from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date, datetime
from typing import Any, Final

from django.core.cache import cache
from django.db import IntegrityError, transaction
from django.db.models import Q
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.dashboards import config as cfg
from infrastructure.dashboards import metrics
from infrastructure.dashboards.models import Dashboard, Visibility, Widget
from infrastructure.filters import query as filter_query
from infrastructure.filters.models import SavedFilter
from infrastructure.projects.models import Project
from infrastructure.tasks import services as task_services
from infrastructure.tasks.models import Task
from infrastructure.workspaces import access
from infrastructure.workspaces.models import Workspace

VIEW: Final = "workspace.view"
MANAGE: Final = "dashboard.manage"
CACHE_SECONDS: Final = 60
DRILL_MAX: Final = 5000
NAME_MAX: Final = 80
TITLE_MAX: Final = 80
TEMPLATES: Final = ("project_overview", "my_work")


def not_found() -> ApiError:
    return ApiError("No such dashboard.", status=404)


@dataclass(frozen=True, slots=True)
class WidgetInput:
    id: str  # a client-made uuid for a new widget, or an existing widget's id
    type: str
    title: str
    config: Any


@dataclass(frozen=True, slots=True)
class View:
    dashboard: Dashboard
    widgets: list[Widget]
    can_edit: bool


@dataclass(frozen=True, slots=True)
class Drilled:
    tasks: list[Task]
    truncated: bool  # more than DRILL_MAX tasks counted: the list is the first DRILL_MAX


@dataclass(frozen=True, slots=True)
class Computed:
    result: metrics.Result
    computed_at: datetime
    cached: bool


# ------------------------------------------------------------------------------- access


def _visible(actor: Any, workspace: Workspace) -> Any:
    """Dashboards of ``workspace`` this person may open: their own, the workspace's, and those of
    projects they can open (a workspace-wide dashboard about a private project is for the
    project's people only: its name and widgets would say what is in it)."""
    projects = Project.objects.visible_to(actor, workspace)
    return Dashboard.objects.filter(workspace=workspace).filter(
        Q(owner=actor)
        | Q(visibility=Visibility.WORKSPACE, project__isnull=True)
        | Q(visibility=Visibility.WORKSPACE, project__in=projects)
        | Q(visibility=Visibility.PROJECT, project__in=projects)
    )


def _manages(actor: Any, workspace: Workspace) -> bool:
    return access.can(actor, MANAGE, workspace).allowed


def _can_edit(actor: Any, dashboard: Dashboard, can_manage: bool) -> bool:
    """The owner, or (for a shared dashboard) someone who holds ``dashboard.manage``."""
    if dashboard.owner_id == actor.pk:
        return True
    return dashboard.visibility != Visibility.PERSONAL and can_manage


def _require_edit(actor: Any, workspace: Workspace, dashboard: Dashboard) -> None:
    """The owner, or a manager for a shared dashboard; anyone else is told what they lack."""
    if dashboard.owner_id != actor.pk:
        access.require(actor, MANAGE, workspace)


def _load(actor: Any, workspace: Workspace, dashboard_id: str, *, lock: bool = False) -> Dashboard:
    access.require(actor, VIEW, workspace)
    try:
        pk = uuid.UUID(str(dashboard_id))
    except ValueError:
        raise not_found() from None
    rows = _visible(actor, workspace)
    dashboard = (rows.select_for_update() if lock else rows).filter(pk=pk).first()
    if dashboard is None:
        raise not_found()
    return dashboard


def _view(
    actor: Any, workspace: Workspace, dashboard: Dashboard, can_manage: bool | None = None
) -> View:
    if can_manage is None:
        can_manage = _manages(actor, workspace)
    return View(dashboard, list(dashboard.widgets.all()), _can_edit(actor, dashboard, can_manage))


def list_dashboards(actor: Any, workspace: Workspace, project_id: str = "") -> list[View]:
    """Dashboards the caller may open; with ``project_id`` those of that project only."""
    access.require(actor, VIEW, workspace)
    rows = _visible(actor, workspace).prefetch_related("widgets")
    if project_id:
        rows = rows.filter(project=_project(actor, workspace, project_id))
    can_manage = _manages(actor, workspace)  # once, not once per dashboard
    return [_view(actor, workspace, d, can_manage) for d in rows.order_by("name", "pk")]


def get(actor: Any, workspace: Workspace, dashboard_id: str) -> View:
    return _view(actor, workspace, _load(actor, workspace, dashboard_id))


def _project(actor: Any, workspace: Workspace, project_id: str) -> Project:
    project = (
        Project.objects.visible_to(actor, workspace)
        .filter(pk=_uuid(project_id, "The project"))
        .first()
    )
    if project is None:
        raise ApiError("No such project.", status=404)
    return project


def _uuid(raw: str, what: str) -> uuid.UUID:
    try:
        return uuid.UUID(str(raw))
    except ValueError:
        raise cfg.invalid(f"{what} is not an id.") from None


# ------------------------------------------------------------------------------- saving


def _name(raw: str) -> str:
    cleaned = " ".join(str(raw).split())
    if not cleaned or len(cleaned) > NAME_MAX:
        raise cfg.invalid(f"A dashboard's name is 1-{NAME_MAX} characters.")
    return cleaned


def _resolve_filter(
    actor: Any, workspace: Workspace, project: Project | None, config: dict[str, Any]
) -> None:
    """A widget that names a saved filter must name one the saver may open."""
    filter_id = config["source"]["filter_id"]
    if not filter_id:
        return
    from infrastructure.filters import services as filter_services

    found = (
        filter_services._visible(workspace, project, actor)  # noqa: SLF001 - the filters' own rule
        .filter(pk=filter_id)
        .first()
    )
    if found is None:
        raise cfg.invalid("That saved filter does not exist or is not yours to use.")


def _widget_inputs(
    actor: Any,
    workspace: Workspace,
    project: Project | None,
    items: Sequence[WidgetInput],
    already: dict[str, str],
) -> list[tuple[WidgetInput, dict[str, Any]]]:
    """The widgets checked. ``already`` maps a widget id to the saved filter it already used: a
    manager who only moves a card must not be refused for a filter that is the owner's."""
    if len(items) > cfg.MAX_WIDGETS:
        raise ApiError(
            f"A dashboard holds at most {cfg.MAX_WIDGETS} widgets.",
            status=400,
            title=ResponseTitle.DASHBOARD_LIMIT,
        )
    seen: set[str] = set()
    out = []
    for item in items:
        wid = str(_uuid(item.id, "A widget's id"))
        if wid in seen:
            raise cfg.invalid("Two widgets share an id.")
        seen.add(wid)
        if len(item.title) > TITLE_MAX:
            raise cfg.invalid(f"A widget's title is at most {TITLE_MAX} characters.")
        config = cfg.normalise(item.type, item.config)
        if already.get(wid) != config["source"]["filter_id"]:
            _resolve_filter(actor, workspace, project, config)
        out.append((item, config))
    return out


def _layout(raw: Any, widget_ids: list[str]) -> list[dict[str, Any]]:
    """The grid placement of each widget; one the client did not place goes under the others."""
    placed: dict[str, dict[str, Any]] = {}
    for cell in raw or []:
        try:
            wid = str(cell["widget_id"])
            x, y, w, h = int(cell["x"]), int(cell["y"]), int(cell["w"]), int(cell["h"])
        except (KeyError, TypeError, ValueError):
            raise cfg.invalid("A layout cell is {widget_id, x, y, w, h}.") from None
        if wid not in widget_ids or wid in placed:
            raise cfg.invalid("The layout names a widget twice or one that is not there.")
        if x < 0 or y < 0 or w < 1 or h < 1 or h > 12 or x + w > cfg.GRID_COLUMNS:
            raise cfg.invalid(f"A widget must fit the {cfg.GRID_COLUMNS}-column grid.")
        placed[wid] = {"widget_id": wid, "x": x, "y": y, "w": w, "h": h}
    bottom = max((c["y"] + c["h"] for c in placed.values()), default=0)
    for wid in widget_ids:
        if wid not in placed:
            placed[wid] = {"widget_id": wid, "x": 0, "y": bottom, "w": 6, "h": 3}
            bottom += 3
    return [placed[w] for w in widget_ids]


def _check_share(
    actor: Any,
    workspace: Workspace,
    visibility: str,
    project: Project | None,
    existing: Dashboard | None,
) -> None:
    """Sharing needs ``dashboard.manage`` -- when it starts or changes. Saving a shared
    dashboard's cards again, as its owner, is not sharing it again."""
    if visibility not in dict(Visibility.CHOICES):
        raise cfg.invalid("Visibility is personal, project or workspace.")
    if visibility == Visibility.PROJECT and project is None:
        raise cfg.invalid("A project dashboard needs a project.")
    if visibility == Visibility.PERSONAL:
        return
    unchanged = (
        existing is not None
        and existing.visibility == visibility
        and existing.project_id == (project.pk if project else None)
        and existing.owner_id == actor.pk
    )
    if not unchanged:
        access.require(actor, MANAGE, workspace)


def save(
    actor: Any,
    workspace: Workspace,
    dashboard_id: str,
    *,
    name: str,
    visibility: str,
    project_id: str,
    widgets: Sequence[WidgetInput],
    layout: Any,
    expected_version: int = 0,
) -> View:
    """Create (empty ``dashboard_id``) or replace a dashboard and its widgets in one go. Changing
    one must say which ``expected_version``; a stale one is a 409."""
    access.require(actor, VIEW, workspace)
    clean_name = _name(name)
    project = _project(actor, workspace, project_id) if project_id else None
    with transaction.atomic():
        existing = _load(actor, workspace, dashboard_id, lock=True) if dashboard_id else None
        already: dict[str, str] = {}
        if existing is not None:
            _require_edit(actor, workspace, existing)
            if not expected_version:
                raise cfg.invalid("Send the version you are changing (expected_version).")
            if existing.version != expected_version:
                raise ApiError(
                    f"The dashboard changed (now version {existing.version}); reload and retry.",
                    status=409,
                    title=ResponseTitle.VERSION_CONFLICT,
                )
            already = {
                str(w.pk): str(w.config.get("source", {}).get("filter_id", ""))
                for w in existing.widgets.all()
            }
        _check_share(actor, workspace, visibility, project, existing)
        inputs = _widget_inputs(actor, workspace, project, widgets, already)
        dashboard = existing or Dashboard(workspace=workspace, owner=actor)
        dashboard.name, dashboard.visibility = clean_name, visibility
        dashboard.project = project
        try:
            _write_widgets(dashboard, inputs)
        except IntegrityError:
            raise cfg.invalid("A widget id is already taken.") from None
        dashboard.layout = _layout(layout, [str(i.id) for i, _ in inputs])
        dashboard.updated_at = timezone.now()
        if existing is not None:
            dashboard.version += 1
        dashboard.save()
    saved = Dashboard.objects.prefetch_related("widgets").get(pk=dashboard.pk)
    return _view(actor, workspace, saved)


def _write_widgets(dashboard: Dashboard, inputs: list[tuple[WidgetInput, dict[str, Any]]]) -> None:
    """Make the dashboard's widgets exactly ``inputs`` (a changed config bumps its version, which
    is what retires its cached numbers)."""
    if dashboard._state.adding:  # noqa: SLF001 - the widgets need its primary key
        dashboard.save()
    have = {str(w.pk): w for w in dashboard.widgets.all()}
    for position, (item, config) in enumerate(inputs):
        wid = str(uuid.UUID(str(item.id)))
        row = have.pop(wid, None)
        if row is None:
            if Widget.objects.filter(pk=wid).exists():
                raise cfg.invalid("A widget id is already taken.")
            Widget.objects.create(
                pk=wid,
                dashboard=dashboard,
                type=item.type,
                title=item.title,
                config=config,
                position=position,
            )
            continue
        changed = (row.type, row.config, row.title) != (item.type, config, item.title)
        row.type, row.title, row.config, row.position = item.type, item.title, config, position
        if changed:
            row.version += 1
        row.save()
    for gone in have.values():
        gone.delete()


def delete(actor: Any, workspace: Workspace, dashboard_id: str) -> uuid.UUID:
    """Delete a dashboard; answers its id (the row has none left afterwards)."""
    with transaction.atomic():
        dashboard = _load(actor, workspace, dashboard_id, lock=True)
        _require_edit(actor, workspace, dashboard)
        gone = dashboard.pk
        dashboard.delete()
    return gone


# ------------------------------------------------------------------------------- templates


def _w(kind: str, title: str, **config: Any) -> WidgetInput:
    return WidgetInput(str(uuid.uuid4()), kind, title, config)


def template_widgets(name: str) -> list[WidgetInput]:
    if name == "project_overview":
        return [
            _w(cfg.NUMBER, "Open tasks", scope="open"),
            _w(cfg.NUMBER, "Done", scope="done"),
            _w(cfg.BAR, "Tasks by status", group_by="status"),
            _w(cfg.PIE, "By priority", group_by="priority", scope="open"),
            _w(cfg.WORKLOAD, "Workload", measure="count"),
            _w(cfg.LINE, "Created per week", group_by="created_week"),
        ]
    if name == "my_work":
        mine = {"source": {"tfql": "assignee = me"}}
        return [
            _w(cfg.NUMBER, "Open for me", scope="open", **mine),
            _w(cfg.NUMBER, "Done by me", scope="done", **mine),
            _w(cfg.BAR, "My tasks by status", group_by="status", **mine),
            _w(cfg.TABLE, "My open tasks by project", group_by="project", scope="open", **mine),
            _w(cfg.PIE, "My work by priority", group_by="priority", scope="open", **mine),
            _w(cfg.LINE, "Assigned to me, by week", group_by="created_week", **mine),
        ]
    raise cfg.invalid(f"A template is one of: {', '.join(TEMPLATES)}.")


def from_template(actor: Any, workspace: Workspace, template: str, project_id: str = "") -> View:
    """A personal dashboard made from a template (``project_overview`` needs a project)."""
    if template == "project_overview" and not project_id:
        raise cfg.invalid("The project overview is about one project.")
    widgets = template_widgets(template)
    title = {"project_overview": "Project overview", "my_work": "My work"}[template]
    return save(
        actor,
        workspace,
        "",
        name=title,
        visibility=Visibility.PERSONAL,
        project_id=project_id,
        widgets=widgets,
        layout=[],
    )


# ------------------------------------------------------------------------------- data


def _scope(
    actor: Any, workspace: Workspace, project: Project | None, today: str, offset: int
) -> metrics.Scope:
    try:
        day = date.fromisoformat(today) if today else timezone.localdate()
    except ValueError:
        raise cfg.invalid("today is a date like 2026-11-05.") from None
    if not -14 * 60 <= offset <= 14 * 60:
        raise cfg.invalid("The UTC offset is in minutes, within a day of UTC.")
    return metrics.Scope(actor, workspace, project, day, offset)


def _tfql(workspace: Workspace, config: dict[str, Any]) -> str:
    filter_id = config["source"]["filter_id"]
    if not filter_id:
        return str(config["source"]["tfql"])
    from infrastructure.filters import services as filter_services
    from infrastructure.filters.language import Catalogue

    row = SavedFilter.objects.filter(pk=filter_id, workspace=workspace).first()
    if row is None:
        raise cfg.invalid("The saved filter of this widget is gone.")
    project = row.project
    cat = Catalogue(project) if project else Catalogue(None, workspace)
    text = filter_services._text_of(row, cat)  # noqa: SLF001 - rendered by the filters' own code
    if not text and row.ast:
        raise cfg.invalid("The saved filter of this widget no longer holds up. Edit the widget.")
    return text


def _widget(actor: Any, workspace: Workspace, widget_id: str) -> tuple[Dashboard, Widget]:
    try:
        pk = uuid.UUID(str(widget_id))
    except ValueError:
        raise not_found() from None
    access.require(actor, VIEW, workspace)
    widget = Widget.objects.select_related("dashboard").filter(pk=pk).first()
    if widget is None or _visible(actor, workspace).filter(pk=widget.dashboard_id).first() is None:
        raise not_found()
    return widget.dashboard, widget


def _key(widget: Widget, dashboard: Dashboard, actor: Any, today: str, offset: int) -> str:
    # The viewer is part of the key: two people never share a cached number, so what one may not
    # see can never be served to the other. So is the project the dashboard is about.
    return (
        f"dash:{widget.pk}:v{widget.version}:p{dashboard.project_id}:u{actor.pk}:{today}:{offset}"
    )


def widget_data(
    actor: Any,
    workspace: Workspace,
    widget_id: str,
    *,
    today: str = "",
    offset_minutes: int = 0,
    refresh: bool = False,
) -> Computed:
    dashboard, widget = _widget(actor, workspace, widget_id)
    scope = _scope(actor, workspace, dashboard.project, today, offset_minutes)
    key = _key(widget, dashboard, actor, scope.today.isoformat(), offset_minutes)
    if refresh:
        cache.delete(key)
    hit = cache.get(key)
    if hit is not None:
        return Computed(hit[0], hit[1], True)
    now = timezone.now()
    result = metrics.compute(
        scope, widget.type, widget.config, _tfql(workspace, widget.config), now
    )
    cache.set(key, (result, now), CACHE_SECONDS)
    return Computed(result, now, False)


def preview(
    actor: Any,
    workspace: Workspace,
    project_id: str,
    kind: str,
    raw_config: Any,
    *,
    today: str = "",
    offset_minutes: int = 0,
) -> Computed:
    """The numbers of a widget that is not saved yet (the picker's live preview); never cached."""
    access.require(actor, VIEW, workspace)
    project = _project(actor, workspace, project_id) if project_id else None
    config = cfg.normalise(kind, raw_config)
    _resolve_filter(actor, workspace, project, config)
    scope = _scope(actor, workspace, project, today, offset_minutes)
    now = timezone.now()
    return Computed(metrics.compute(scope, kind, config, _tfql(workspace, config), now), now, False)


def drilldown(
    actor: Any,
    workspace: Workspace,
    widget_id: str,
    bucket: str = "",
    *,
    today: str = "",
    offset_minutes: int = 0,
) -> Drilled:
    """The tasks behind a widget's number (or one bucket of it), as the task list shows them.
    Past ``DRILL_MAX`` tasks the list says it is cut short. A burndown lists the open tasks of its
    sprint."""
    dashboard, widget = _widget(actor, workspace, widget_id)
    scope = _scope(actor, workspace, dashboard.project, today, offset_minutes)
    rows = metrics.drilldown(
        scope, widget.type, widget.config, _tfql(workspace, widget.config), bucket
    )
    try:
        found = filter_query.timed(
            lambda: list(rows.order_by("project_id", "number")[: DRILL_MAX + 1])
        )
    except filter_query.StatementTimeout:
        raise ApiError(
            "This widget takes too long to compute. Narrow its filter.",
            status=400,
            title=ResponseTitle.DASHBOARD_TOO_HEAVY,
        ) from None
    return Drilled(
        task_services.present_many(found[:DRILL_MAX], actor, workspace), len(found) > DRILL_MAX
    )


def export_csv(
    actor: Any,
    workspace: Workspace,
    widget_id: str,
    *,
    today: str = "",
    offset_minutes: int = 0,
) -> str:
    """A widget's numbers as CSV (its buckets, or its series for a chart over time)."""
    data = widget_data(actor, workspace, widget_id, today=today, offset_minutes=offset_minutes)
    out = io.StringIO()
    writer = csv.writer(out)
    result = data.result
    if result.series:
        writer.writerow(["series", "x", "value"])
        for series in result.series:
            writer.writerows([series.name, p.x, str(p.y)] for p in series.points)
    elif result.buckets:
        writer.writerow(["key", "label", "value"])
        writer.writerows([b.key, _safe(b.label), str(b.value)] for b in result.buckets)
    else:
        writer.writerow(["value"])
        writer.writerow([str(result.total)])
    return out.getvalue()


def _safe(cell: str) -> str:
    """A spreadsheet runs a cell that starts with = + - @ as a formula: quote it."""
    return "'" + cell if cell[:1] in ("=", "+", "-", "@", "\t", "\r") else cell
