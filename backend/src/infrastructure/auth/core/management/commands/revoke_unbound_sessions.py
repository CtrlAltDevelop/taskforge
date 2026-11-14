"""End every live session that is not bound to a DPoP key (phase 39).

Sessions issued before binding existed (or while ``DJANGO_DPOP_MODE`` was ``off``) are
bearer-only. ``required`` mode already refuses their tokens, so this only tidies up: it retires the
rows so the Sessions list does not show devices that can no longer sign anything. Safe to run
twice; ``--dry-run`` counts without revoking.
"""

from typing import Any

from django.apps import apps
from django.core.management.base import BaseCommand, CommandParser

from infrastructure.common.app_labels import app_installed
from infrastructure.oauth.core.credentials import TOKEN_MODE_APPS

REASON = "dpop_unbound"


def _live_unbound(mode: str, app_label: str) -> Any:
    """The mode's live session rows whose ``dpop_jkt`` is empty."""
    if mode == "sliding":
        return apps.get_model(app_label, "SlidingToken").objects.filter(
            revoked_at__isnull=True, dpop_jkt=""
        )
    name = "OAuthSession" if mode == "session" else "TokenFamily"
    return apps.get_model(app_label, name).objects.filter(revoked_at__isnull=True, dpop_jkt="")


class Command(BaseCommand):
    help = "Revoke every live session that is not bound to a DPoP key."

    def add_arguments(self, parser: CommandParser) -> None:
        parser.add_argument("--dry-run", action="store_true", help="Count, do not revoke.")

    def handle(self, *args: Any, **options: Any) -> None:
        total = 0
        for mode, app_label in TOKEN_MODE_APPS.items():
            if not app_installed(app_label):
                continue
            rows = list(_live_unbound(mode, app_label))
            total += len(rows)
            if not options["dry_run"]:
                for row in rows:
                    row.revoke(REASON)
        verb = "Would revoke" if options["dry_run"] else "Revoked"
        self.stdout.write(f"{verb} {total} unbound session(s).")
