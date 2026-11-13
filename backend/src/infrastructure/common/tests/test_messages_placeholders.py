"""Every sentence keeps the same ``{placeholders}`` in every language."""

from string import Formatter

from infrastructure.common.locales import SUPPORTED_LOCALES
from infrastructure.common.messages import TEXT


def _fields(template: str) -> set[str]:
    return {name for _, name, _, _ in Formatter().parse(template) if name}


def test_every_template_has_identical_placeholders_in_all_locales() -> None:
    for key, entry in TEXT.items():
        expected = _fields(entry["en"])
        for lang in SUPPORTED_LOCALES:
            assert _fields(entry[lang]) == expected, (key, lang)
