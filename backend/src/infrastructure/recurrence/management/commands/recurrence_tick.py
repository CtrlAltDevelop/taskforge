from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.recurrence import clock


class Command(BaseCommand):
    help = (
        "The recurring tasks' clock (no Celery yet): make the instances that are due and the "
        "next one of after-completion series whose hook was missed. Safe to run often and from "
        "several machines; `make tick` runs it every minute."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        made = clock.generate_due()
        continued = clock.catch_up_completions()
        self.stdout.write(f"Recurring tasks made {made}, continued after completion {continued}.")
