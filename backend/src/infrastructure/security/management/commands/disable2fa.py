"""Recovery for a locked-out account: ``manage.py disable2fa <username-or-email>``.

Removes the person's authenticator and recovery codes, forgets their trusted devices and ends
every session, so the next sign-in is a plain one. Run on the server by an operator; there is
deliberately no way to do this over the API.
"""

from typing import Any

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError

from infrastructure.security import twofactor


class Command(BaseCommand):
    help = "Turn off two-factor authentication for one account (locked-out recovery)."

    def add_arguments(self, parser: Any) -> None:
        parser.add_argument("account", help="the account's username or email address")

    def handle(self, *args: Any, **options: Any) -> None:
        account = str(options["account"]).strip()
        users = get_user_model()._default_manager
        user = (
            users.filter(username__iexact=account).first()
            or users.filter(email__iexact=account).first()
        )
        if user is None:
            raise CommandError(f"No account matches '{account}'.")
        removed = twofactor.admin_disable(user)
        self.stdout.write(
            self.style.SUCCESS(
                f"Two-factor authentication is off for {user.username} ({removed} factor(s) "
                "removed, sessions ended)."
            )
        )
