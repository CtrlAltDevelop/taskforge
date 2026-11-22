"""Create the tasks of ``taskdata`` through the task services, then link, trash and backdate."""

from datetime import timedelta
from typing import Any

from django.utils import timezone

from infrastructure.common.demo import taskdata
from infrastructure.common.demo.base import Ctx, day
from infrastructure.common.demo.richtext import rich
from infrastructure.projects import services as projects
from infrastructure.projects.models import Project
from infrastructure.sprints import services as sprints
from infrastructure.tasks import links
from infrastructure.tasks import services as tasks
from infrastructure.tasks.models import Task

LETTERS = {
    "o": "owner",
    "a": "admin",
    "m": "member",
    "d": "dev",
    "s": "designer",
    "v": "viewer",
    "g": "guest",
}
ORDER = ("web", "mobile", "bugs", "marketing", "private", "archived")
PROJECT_AGE = {"web": 90, "mobile": 75, "bugs": 60, "marketing": 45, "private": 30, "archived": 100}
SPREAD_DAYS = 85  # tasks without an explicit age are spread over this many days


def _field_values(ctx: Ctx, hints: dict[str, str], number: int) -> dict[str, str]:
    made, team, labels = ctx.extra["fields"], ctx.extra["team_options"], ctx.extra["label_options"]
    values: dict[str, str] = {}
    for name, hint in hints.items():
        if name == "Team":
            wire = team[hint]
        elif name == "Labels":
            wire = ",".join(labels[part] for part in hint.split(","))
        elif name == "Spec link":
            wire = f"https://example.com/specs/{number}"
        elif name == "Review by":
            wire = day(int(hint))
        elif name == "Sponsor":
            wire = str(ctx.users[LETTERS[hint]].pk)
        else:
            wire = hint
        values[str(made[name].pk)] = wire
    return values


def _create(ctx: Ctx, project_key: str, spec: taskdata.Spec) -> Task:
    project = ctx.projects[project_key]
    pid, actor = str(project.pk), ctx.users[LETTERS[spec.by]]
    parent = ctx.tasks[spec.parent] if spec.parent else None
    number = project.task_counter + 1
    fields = _field_values(ctx, spec.f, number) if project_key == "web" else {}
    task = tasks.create(
        actor,
        ctx.ws,
        pid,
        spec.title,
        description=rich(spec.desc),
        status=ctx.extra["status"][project_key][spec.status],
        priority=spec.prio,
        start_date=day(spec.start) if spec.start is not None else "",
        due_date=day(spec.due) if spec.due is not None else "",
        assignee_ids=[str(ctx.users[LETTERS[c]].pk) for c in spec.who],
        parent_id=str(parent.pk) if parent else "",
        field_values=fields,
    )
    if spec.est:
        task = tasks.update(
            actor, ctx.ws, pid, str(task.pk), task.version, {"estimate_sec": str(spec.est * 3600)}
        )
    if spec.pts:
        task = sprints.set_points(actor, ctx.ws, pid, str(task.pk), spec.pts)
    project.refresh_from_db(fields=["task_counter"])
    return task


def create_tasks(ctx: Ctx) -> int:
    count = 0
    for project_key in ORDER:
        for spec in taskdata.BY_PROJECT[project_key]:
            task = _create(ctx, project_key, spec)
            ctx.tasks[f"{project_key}-{task.number}"] = task
            if spec.ref:
                ctx.tasks[spec.ref] = task
            count += 1
    return count


def link_tasks(ctx: Ctx) -> None:
    for _project, ref, kind, other in taskdata.LINKS:
        links.add(ctx.owner, ctx.ws, str(ctx.tasks[ref].pk), str(ctx.tasks[other].pk), kind)


def trash_tasks(ctx: Ctx) -> None:
    for project_key, ref in taskdata.TRASHED:
        task = ctx.tasks[ref]
        tasks.delete(ctx.owner, ctx.ws, str(ctx.projects[project_key].pk), str(task.pk))


def archive_old_project(ctx: Ctx) -> None:
    pid = str(ctx.projects["archived"].pk)
    shown = projects.get(ctx.owner, ctx.ws, pid)
    projects.archive(ctx.owner, ctx.ws, pid, shown.project.version)


def backdate(ctx: Ctx) -> None:
    """Spread creation times over the last ~90 days so lists, charts and "5 days ago" look real.

    No service writes ``created_at``, so this is a plain update after the fact: it touches
    only timestamps, never ids, versions or ordering.
    """
    now = timezone.now()
    ordered: list[Task] = list(Task.objects.filter(workspace=ctx.ws).order_by("created_at"))
    for index, task in enumerate(ordered):
        spec_age = _age_of(ctx, task)
        age = spec_age or (index * 7) % SPREAD_DAYS + 1
        created = now - timedelta(days=age, hours=index % 9)
        Task.objects.filter(pk=task.pk).update(
            created_at=created, updated_at=created + timedelta(days=min(age, 3))
        )
    for key, age in PROJECT_AGE.items():
        Project.objects.filter(pk=ctx.projects[key].pk).update(created_at=now - timedelta(days=age))


def _age_of(ctx: Ctx, task: Task) -> int:
    """The explicit ``age`` of the spec a task came from (0 when none)."""
    for spec in taskdata.BY_PROJECT[_project_key(ctx, task)]:
        if spec.age and spec.title == task.title:
            return spec.age
    return 0


def _project_key(ctx: Ctx, task: Task) -> str:
    for key, project in ctx.projects.items():
        if project.pk == task.project_id:
            return key
    raise KeyError(task.project_id)


def counts(ctx: Ctx) -> dict[str, Any]:
    return {
        "tasks": Task.objects.filter(workspace=ctx.ws, deleted_at__isnull=True).count(),
        "trashed": Task.objects.filter(workspace=ctx.ws, deleted_at__isnull=False).count(),
    }
