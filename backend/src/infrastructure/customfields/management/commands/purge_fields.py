"""Hard-delete custom fields archived more than 30 days ago. Run daily from cron."""

from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.customfields import services


class Command(BaseCommand):
    help = "Purge custom fields archived more than 30 days ago (and their values)."

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Purged {services.purge_expired()} field(s).")
