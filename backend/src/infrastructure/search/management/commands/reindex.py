from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.search import index


class Command(BaseCommand):
    help = "Rebuild the search index (after an import or a restore). Normal edits need no reindex."

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument("--workspace", default="", help="Only this workspace id.")

    def handle(self, *args: Any, **options: Any) -> None:
        written = index.reindex(options["workspace"] or None)
        self.stdout.write(f"Indexed {written} rows.")
