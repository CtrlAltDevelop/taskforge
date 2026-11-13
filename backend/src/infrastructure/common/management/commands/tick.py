from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.common import dueworkers


class Command(BaseCommand):
    help = (
        "Run every registered due-work callable once: the clock of the whole app. `make tick` "
        "runs it every minute in debug; in production Celery beat runs the same callables."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        for name, result in dueworkers.run_all().items():
            failed = isinstance(result, Exception)
            style = self.style.ERROR if failed else self.style.SUCCESS
            self.stdout.write(style(f"{name}: {'FAILED ' if failed else ''}{result!r}"))
