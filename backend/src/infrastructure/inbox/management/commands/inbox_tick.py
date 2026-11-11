from typing import Any

from django.core.management.base import BaseCommand

from infrastructure.inbox import delivery, due, prefs, services


class Command(BaseCommand):
    help = (
        "The notifications' clock (run it every minute or so): bring back snoozed notifications, "
        "tell assignees about tasks due soon, send pushes and emails held for quiet hours or a "
        "digest, and retry the ones that failed."
    )

    def handle(self, *args: Any, **options: Any) -> None:
        woken = services.wake_snoozed()
        made = due.scan_due_soon()
        sent = delivery.deliver_due()
        pruned = prefs.prune_devices()
        self.stdout.write(
            f"Woke {woken}, due soon {made}, delivered {sent}, devices pruned {pruned}."
        )
