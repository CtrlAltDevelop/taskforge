from typing import Any

import pytest

from infrastructure.common.errors import ApiError
from infrastructure.inbox import kinds, prefs
from infrastructure.inbox.models import PushDevice


def test_a_new_person_gets_the_quiet_defaults(team: Any) -> None:
    got = prefs.get(team.member)

    rows = {r["event_type"]: r for r in got["prefs"]}
    assert list(rows) == [k.key for k in kinds.KINDS]
    assert rows[kinds.ASSIGNED] == {
        "event_type": kinds.ASSIGNED,
        "label": "A task is assigned to you",
        "inbox": True,
        "push": True,
        "email_mode": "off",
    }
    assert rows[kinds.STATUS_CHANGED]["push"] is False
    assert all(r["email_mode"] == "off" and r["inbox"] for r in rows.values())
    assert got["settings"] == {
        "timezone": "UTC",
        "quiet_start": "",
        "quiet_end": "",
        "digest_hour": 8,
    }


def test_a_choice_is_kept_per_person_and_per_kind(team: Any) -> None:
    prefs.set_pref(team.member, kinds.COMMENTED, inbox=False, push=True, email_mode="digest")

    mine = {r["event_type"]: r for r in prefs.get(team.member)["prefs"]}
    theirs = {r["event_type"]: r for r in prefs.get(team.owner)["prefs"]}
    assert (mine[kinds.COMMENTED]["inbox"], mine[kinds.COMMENTED]["push"]) == (False, True)
    assert mine[kinds.COMMENTED]["email_mode"] == "digest"
    assert theirs[kinds.COMMENTED]["inbox"] is True
    prefs.set_pref(team.member, kinds.COMMENTED, inbox=True, push=False, email_mode="off")
    assert prefs.effective(team.member.pk, kinds.COMMENTED).push is False


@pytest.mark.parametrize(
    ("kind", "mode"), [("nonsense", "off"), (kinds.ASSIGNED, "hourly"), (kinds.ASSIGNED, "")]
)
def test_unknown_kinds_and_modes_are_refused(team: Any, kind: str, mode: str) -> None:
    with pytest.raises(ApiError):
        prefs.set_pref(team.member, kind, inbox=True, push=True, email_mode=mode)


def test_settings_are_validated_and_kept(team: Any) -> None:
    prefs.set_settings(
        team.member, timezone="Asia/Tehran", quiet_start="22:00", quiet_end="07:30", digest_hour=9
    )

    assert prefs.get(team.member)["settings"] == {
        "timezone": "Asia/Tehran",
        "quiet_start": "22:00",
        "quiet_end": "07:30",
        "digest_hour": 9,
    }
    prefs.set_settings(team.member, timezone="UTC", quiet_start="", quiet_end="", digest_hour=0)
    assert prefs.get(team.member)["settings"]["quiet_start"] == ""


@pytest.mark.parametrize(
    "bad",
    [
        {"timezone": "Mars/Olympus", "quiet_start": "", "quiet_end": "", "digest_hour": 8},
        {"timezone": "UTC", "quiet_start": "22:00", "quiet_end": "", "digest_hour": 8},
        {"timezone": "UTC", "quiet_start": "25:00", "quiet_end": "07:00", "digest_hour": 8},
        {"timezone": "UTC", "quiet_start": "22:00", "quiet_end": "22:00", "digest_hour": 8},
        {"timezone": "UTC", "quiet_start": "", "quiet_end": "", "digest_hour": 24},
    ],
)
def test_bad_settings_are_refused(team: Any, bad: dict[str, Any]) -> None:
    with pytest.raises(ApiError):
        prefs.set_settings(team.member, **bad)


def test_devices_are_registered_once_and_belong_to_who_registered_last(team: Any) -> None:
    prefs.register_device(team.member, "android", "tok-1")
    prefs.register_device(team.member, "android", "tok-1")
    prefs.register_device(team.owner, "ios", "tok-1")  # the phone changed hands

    [device] = PushDevice.objects.all()
    assert (device.user_id, device.platform) == (team.owner.pk, "ios")


def test_a_device_is_unregistered_only_by_its_owner(team: Any) -> None:
    prefs.register_device(team.member, "web", "tok-2")

    prefs.unregister_device(team.owner, "tok-2")
    assert PushDevice.objects.count() == 1
    prefs.unregister_device(team.member, "tok-2")
    assert PushDevice.objects.count() == 0


@pytest.mark.parametrize(("platform", "token"), [("symbian", "x"), ("ios", ""), ("ios", "x" * 600)])
def test_bad_devices_are_refused(team: Any, platform: str, token: str) -> None:
    with pytest.raises(ApiError):
        prefs.register_device(team.member, platform, token)


def test_a_person_keeps_at_most_ten_devices_the_newest(team: Any) -> None:
    for n in range(13):
        prefs.register_device(team.member, "android", f"tok-{n}")

    tokens = set(PushDevice.objects.values_list("token", flat=True))
    assert len(tokens) == 10 and "tok-12" in tokens and "tok-0" not in tokens


def test_devices_not_seen_for_months_are_pruned(team: Any) -> None:
    from datetime import timedelta

    from django.utils import timezone

    prefs.register_device(team.member, "android", "old")
    prefs.register_device(team.member, "android", "new")
    PushDevice.objects.filter(token="old").update(last_seen_at=timezone.now() - timedelta(days=90))

    assert prefs.prune_devices() == 1
    assert list(PushDevice.objects.values_list("token", flat=True)) == ["new"]


@pytest.mark.parametrize("tz", ["Europe", "x" * 70, ""])
def test_odd_time_zones_are_refused_cleanly(team: Any, tz: str) -> None:
    with pytest.raises(ApiError):
        prefs.set_settings(team.member, timezone=tz, quiet_start="", quiet_end="", digest_hour=8)


def test_a_quiet_time_with_a_zone_in_it_is_refused(team: Any) -> None:
    with pytest.raises(ApiError):
        prefs.set_settings(
            team.member, timezone="UTC", quiet_start="22:00+05:00", quiet_end="07:00", digest_hour=8
        )
