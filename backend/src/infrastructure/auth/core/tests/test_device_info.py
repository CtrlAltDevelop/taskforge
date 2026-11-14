from types import SimpleNamespace

import pytest
from django.core.cache import cache
from django.test import override_settings

from infrastructure.auth.core import device

GOOD = "model=Pixel 8;os=android;osVersion=14;screen=1080x2400@2.75;locale=en-US;tz=Europe/Paris"


def test_good_header_parses_and_labels() -> None:
    info = device.parse(GOOD)
    assert info is not None
    assert info.label == "Pixel 8 · Android 14"
    assert info.tz == "Europe/Paris"


@pytest.mark.parametrize(
    "raw",
    [
        "",
        "os=android",  # model missing
        "model=Pixel",  # os missing
        "model=Pixel;os=android;os=ios",  # duplicate key
        "model=Pixel;os",  # pair without =
        "model=;os=android",
        "model=Pixel;os=Android",  # uppercase os rejected
        "model=Pix\x00el;os=android",
        "model=Pixé;os=android",
        "model=" + "a" * 600 + ";os=android",
        "model=a=b;os=android",
    ],
)
def test_bad_headers_are_ignored(raw: str) -> None:
    assert device.parse(raw) is None


def test_bad_optional_values_are_dropped_not_fatal() -> None:
    cache.clear()
    info = device.parse("model=Pixel 8;os=android;screen=big;locale=!!")
    assert info is not None
    assert info.screen == ""
    assert info.locale == ""
    assert device.rejection_counts()["key"] == 2


def test_fingerprint_stable_per_user_and_ignores_versions() -> None:
    a = device.parse(GOOD)
    b = device.parse(GOOD.replace("osVersion=14", "osVersion=15") + ";build=99")
    other = device.parse(GOOD.replace("Pixel 8", "Pixel 9"))
    assert a and b and other
    assert device.fingerprint(1, a) == device.fingerprint(1, b)
    assert device.fingerprint(1, a) != device.fingerprint(2, a)
    assert len(device.fingerprint(1, a)) == 32
    assert device.fingerprint(1, other) != device.fingerprint(1, a)


def test_pepper_changes_the_fingerprint() -> None:
    info = device.parse(GOOD)
    assert info
    before = device.fingerprint(1, info)
    with override_settings(DEVICE_FINGERPRINT_PEPPER="another-pepper"):
        assert device.fingerprint(1, info) != before


def test_name_from_user_agent_and_clean_name() -> None:
    assert device.name_from_user_agent("Mozilla (Macintosh) Chrome/1 Safari/2") == "Chrome on macOS"
    assert device.name_from_user_agent("curl/8") == device.UNKNOWN_DEVICE
    assert device.clean_name("  My   phone ") == "My phone"
    for bad in ("", "   ", "x" * 81, "a\x01b"):
        with pytest.raises(ValueError):
            device.clean_name(bad)


@pytest.mark.django_db
def test_from_request_respects_the_switch() -> None:
    request = SimpleNamespace(META={device.REST_META_KEY: GOOD})
    with override_settings(COLLECT_DEVICE_INFO=False):
        assert device.from_request(request) is None
    with override_settings(DEVICE_FINGERPRINT_PEPPER=""):
        assert device.from_request(request) is None
