"""Hard-delete workspaces soft-deleted more than 7 days ago. Run daily from cron."""

from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.workspaces import services


class Command(BaseCommand):
    help = "Purge workspaces deleted more than 7 days ago (and their logo files)."

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Purged {services.purge_expired()} workspace(s).")
