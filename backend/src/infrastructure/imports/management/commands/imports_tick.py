from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.imports import engine


class Command(BaseCommand):
    help = (
        "The imports' clock (no Celery yet): resume the import runs whose process died. Safe to "
        "run often; `make tick` runs it every minute."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        self.stdout.write(f"Stalled imports resumed {engine.resume_stalled()}.")
