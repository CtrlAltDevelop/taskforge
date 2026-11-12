"""A person's shortcut overrides: read them all, bind or reset one."""

import re
from typing import Any

from django.db import transaction
from django.utils import timezone

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.shortcuts import keys
from infrastructure.shortcuts.models import UserShortcut

MAX_BINDINGS = 300
ACTION_ID = re.compile(r"^[a-z][a-z0-9_.:-]{0,79}$")


def get(user: Any) -> list[UserShortcut]:
    return list(UserShortcut.objects.filter(user=user).order_by("action_id"))


def set_binding(user: Any, action_id: str, raw_keys: str, *, reset: bool = False) -> None:
    """Bind ``action_id`` to ``raw_keys``; ``""`` unbinds it; ``reset`` drops the override so the
    default applies again. Two actions on one chord are refused and the other is named."""
    if not ACTION_ID.match(action_id):
        raise keys.invalid("That is not an action id.")
    with transaction.atomic():
        # Lock the person's rows so two devices cannot both take the same chord.
        mine = list(UserShortcut.objects.select_for_update().filter(user=user))
        if reset:
            UserShortcut.objects.filter(user=user, action_id=action_id).delete()
            return
        chord = keys.normalise(raw_keys)
        if chord:
            clash = next((s for s in mine if s.keys == chord and s.action_id != action_id), None)
            if clash:
                raise ApiError(
                    f"{chord} is already used by {clash.action_id}.",
                    409,
                    title=ResponseTitle.SHORTCUT_CONFLICT,
                    data={"action_id": clash.action_id},
                )
        if len(mine) >= MAX_BINDINGS and not any(s.action_id == action_id for s in mine):
            raise ApiError("Too many shortcuts.", title=ResponseTitle.SHORTCUT_INVALID)
        UserShortcut.objects.update_or_create(
            user=user, action_id=action_id, defaults={"keys": chord, "updated_at": timezone.now()}
        )
