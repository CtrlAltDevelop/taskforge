"""Create a demo user, workspace, project and a few tasks for local development."""

from datetime import date, timedelta
from typing import Any

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

DEMO_USER = "demo"
DEMO_PASSWORD = "demo-password-123"  # dev only; refused unless DEBUG
DEMO_TASKS = (
    ("Write the launch announcement", "high", 3),
    ("Fix the login redirect", "urgent", 1),
    ("Review onboarding copy", "normal", 7),
    ("Tidy the backlog", "low", 14),
    ("Plan next sprint", "none", 0),
)


class Command(BaseCommand):
    help = "Seed a demo user, workspace, project and tasks (development only; safe to re-run)."

    def handle(self, *args: Any, **options: Any) -> None:
        if not settings.DEBUG:
            raise CommandError("seed_demo only runs with DEBUG on (development settings).")
        from infrastructure.projects import services as projects
        from infrastructure.tasks import services as tasks
        from infrastructure.workspaces import services as workspaces

        users = get_user_model().objects
        if users.filter(username=DEMO_USER).exists():
            self.stdout.write("Demo data already present; nothing to do.")
            return
        with transaction.atomic():
            user = users.create_user(
                username=DEMO_USER, email="demo@example.com", password=DEMO_PASSWORD
            )
            workspace = workspaces.create(user, "Demo", "demo")
            project = projects.create(user, workspace, "Website", "WEB").project
            for title, priority, days in DEMO_TASKS:
                due = (date.today() + timedelta(days=days)).isoformat() if days else ""
                tasks.create(
                    user, workspace, str(project.pk), title, priority=priority, due_date=due
                )
        self.stdout.write(self.style.SUCCESS(f"Seeded: log in as {DEMO_USER} / {DEMO_PASSWORD}"))
