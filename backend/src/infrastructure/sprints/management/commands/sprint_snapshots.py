from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.sprints import snapshots


class Command(BaseCommand):
    help = (
        "Write the daily burndown snapshots of every active sprint, back-filling any day that "
        "was missed (workspace midnight). Safe to run often; `make tick` runs it every minute."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Sprint snapshots written: {snapshots.take_all()}.")
