"""Seed a complete demo dataset (every area of the app) for local development."""

from importlib import import_module
from typing import Any

from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.test.utils import override_settings

from infrastructure.common.demo.base import EMAIL_DOMAIN, PASSWORD, Ctx

MODULES = ("core", "collab", "planning", "extras")  # run in this order; missing ones are skipped
USERNAMES = ("owner", "admin", "member", "dev", "designer", "viewer", "guest", "demo")


class Command(BaseCommand):
    help = "Seed the full demo dataset (development only). --reset wipes the demo users first."

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument("--reset", action="store_true", help="delete the demo users and data")

    def handle(self, *args: Any, **options: Any) -> None:
        if not settings.DEBUG:
            raise CommandError("seed_demo only runs with DEBUG on (development settings).")
        users = get_user_model().objects
        if options["reset"]:
            from infrastructure.common.demo.reset import wipe

            wipe()  # also clears the old one-user demo, which has no "owner"
        elif users.filter(username="owner").exists():
            self.stdout.write("Demo data already present; use --reset to rebuild it.")
            return
        ctx = Ctx()
        # Deliver inbox mail inside this process: the background thread would fight the open
        # transaction for SQLite's single write lock.
        with (
            override_settings(
                INBOX_SYNC_DELIVERY=True,
                AUTOMATIONS_SYNC_RUN=True,  # rules run in a thread otherwise, and lock SQLite
                IMPORTS_SYNC_RUN=True,
                WORKSPACE_EMAIL_ASYNC=False,
                CELERY_TASK_ALWAYS_EAGER=True,  # no broker needed: goal recounts run inline
                GOALS_RECOMPUTE_DEBOUNCE_SECONDS=0,
            ),
            transaction.atomic(),
        ):
            for name in MODULES:
                try:
                    module = import_module(f"infrastructure.common.demo.{name}")
                except ModuleNotFoundError as error:
                    if error.name != f"infrastructure.common.demo.{name}":
                        raise
                    self.stdout.write(f"  skip {name} (not written)")
                    continue
                module.seed(ctx)
                self.stdout.write(f"  seeded {name}")
        self.stdout.write(self.style.SUCCESS(f"Done. Log in as owner@{EMAIL_DOMAIN} / {PASSWORD}"))
