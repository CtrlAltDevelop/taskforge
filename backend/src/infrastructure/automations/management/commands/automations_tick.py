from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.automations import due


class Command(BaseCommand):
    help = (
        "The automations' clock (no Celery yet): fire the due-date-reached rules and prune old "
        "run history. Safe to run often; `make tick` runs it every minute."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        queued = due.scan_due()
        pruned = due.prune_runs()
        self.stdout.write(f"Due-date runs queued {queued}, runs pruned {pruned}.")
