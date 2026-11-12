from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.imports import exports


class Command(BaseCommand):
    help = "Delete export zips older than a day. Run it daily (`make purge`)."

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Expired exports removed {exports.purge_old()}.")
