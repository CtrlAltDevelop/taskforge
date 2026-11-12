from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.audit import retention


class Command(BaseCommand):
    help = "Delete audit entries older than DJANGO_AUDIT_RETENTION_DAYS (0 keeps all). Run daily."

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Audit entries removed {retention.purge()}.")
