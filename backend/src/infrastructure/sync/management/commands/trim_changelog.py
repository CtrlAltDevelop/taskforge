from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.sync import services
from infrastructure.sync.publish import RETENTION_DAYS


class Command(BaseCommand):
    help = f"Delete change-log entries older than {RETENTION_DAYS} days (run it daily)."

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument("--days", type=int, default=RETENTION_DAYS)

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Trimmed {services.trim(options['days'])} entries.")
