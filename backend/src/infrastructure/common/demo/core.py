"""Core of the demo: people, workspaces, projects, workflows, fields, tasks, filters, views.

Fills ``ctx.users`` (owner, admin, member, dev, designer, viewer, guest, demo), ``ctx.workspaces``
(main = "Acme Studio", side = "Side Project"), ``ctx.projects`` (web, mobile, bugs, marketing,
private, archived) and ``ctx.tasks`` (every ``Spec.ref`` plus ``"<project>-<number>"``).
``ctx.extra`` also holds ``status`` (project -> status name -> id), ``fields`` (web custom
fields by name), ``team_options`` / ``label_options`` and ``support_role``.
"""

from infrastructure.common.demo import people, taskseed, work
from infrastructure.common.demo.base import Ctx


def seed(ctx: Ctx) -> None:
    people.create_users(ctx)
    people.create_workspaces(ctx)
    work.create_projects(ctx)
    work.create_workflows(ctx)
    work.create_fields(ctx)
    taskseed.create_tasks(ctx)
    taskseed.link_tasks(ctx)
    work.create_filters_and_views(ctx)
    people.create_invitations_pending(ctx)
    taskseed.trash_tasks(ctx)
    taskseed.archive_old_project(ctx)
    taskseed.backdate(ctx)
