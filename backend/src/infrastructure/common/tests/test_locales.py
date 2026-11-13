"""Which languages exist, which run right-to-left, and how a request picks one."""

import pytest

from infrastructure.common.locales import (
    DEFAULT_LOCALE,
    SUPPORTED_LOCALES,
    is_rtl,
    localized_message,
    normalize_locale,
    pick_from_accept_language,
)


def test_launch_languages_are_english_persian_arabic_pashto() -> None:
    assert SUPPORTED_LOCALES == ("en", "fa", "ar", "ps")


@pytest.mark.parametrize(
    ("raw", "expected"),
    [("en-US", "en"), ("FA", "fa"), ("ar_EG", "ar"), ("ps-AF", "ps"), ("fr", None), ("", None)],
)
def test_normalize_keeps_the_language_and_drops_the_region(raw: str, expected: str | None) -> None:
    assert normalize_locale(raw) == expected


def test_arabic_script_languages_run_right_to_left() -> None:
    assert [is_rtl(code) for code in ("en", "fa", "ar", "ps")] == [False, True, True, True]


def test_accept_language_takes_the_best_supported_by_quality() -> None:
    assert pick_from_accept_language("fr;q=0.9, fa;q=0.8, en;q=0.5") == "fa"
    assert pick_from_accept_language("ar-EG,ar;q=0.9,en;q=0.1") == "ar"


def test_accept_language_with_nothing_supported_falls_back() -> None:
    assert pick_from_accept_language("fr, de;q=0.5") == DEFAULT_LOCALE
    assert pick_from_accept_language("") == DEFAULT_LOCALE
    assert pick_from_accept_language("*;q=0.5;;;garbage") == DEFAULT_LOCALE


def test_a_known_title_is_translated_and_an_unknown_one_falls_back_to_english() -> None:
    persian = localized_message("NOT_FOUND", "fa", "Not found.")
    assert persian != "Not found."
    assert localized_message("NOT_FOUND", "en", "Not found.") == "Not found."
    assert localized_message("SOME_NEW_TITLE", "fa", "English text.") == "English text."


class _Profile:
    def __init__(self, locale: str) -> None:
        self.locale = locale


class _User:
    is_authenticated = True

    def __init__(self, locale: str) -> None:
        self.profile = _Profile(locale)


class _Request:
    def __init__(self, header: str = "", user: object | None = None) -> None:
        self.META = {"HTTP_ACCEPT_LANGUAGE": header} if header else {}
        self.user = user


def test_a_signed_in_persons_saved_language_beats_the_header() -> None:
    from infrastructure.common.locales import request_locale

    assert request_locale(_Request("fa", _User("ar"))) == "ar"


def test_without_a_saved_language_the_header_decides() -> None:
    from infrastructure.common.locales import request_locale

    assert request_locale(_Request("ps", _User(""))) == "ps"
    assert request_locale(_Request("ps", None)) == "ps"
    assert request_locale(_Request()) == DEFAULT_LOCALE
