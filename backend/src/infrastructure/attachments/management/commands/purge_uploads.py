from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.attachments import services


class Command(BaseCommand):
    help = "Remove uploads that were never completed and have expired, with their chunks (daily)."

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Purged {services.purge_expired()} uploads.")
