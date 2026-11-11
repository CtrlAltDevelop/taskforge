import pytest

from infrastructure.attachments import sniff

PNG = b"\x89PNG\r\n\x1a\n" + b"\0" * 16
JPEG = b"\xff\xd8\xff\xe0" + b"\0" * 16
GIF = b"GIF89a" + b"\0" * 16
WEBP = b"RIFF\x00\x00\x00\x00WEBPVP8 "
PDF = b"%PDF-1.7\n%\xe2\xe3\xcf\xd3\n"
MP4 = b"\x00\x00\x00\x18ftypmp42" + b"\0" * 8
WEBM = b"\x1a\x45\xdf\xa3" + b"\0" * 16
ZIP = b"PK\x03\x04" + b"\0" * 16
EXE = b"MZ\x90\x00" + b"\0" * 16
ELF = b"\x7fELF\x02\x01\x01" + b"\0" * 16
MACHO = b"\xcf\xfa\xed\xfe" + b"\0" * 16
SCRIPT = b"#!/bin/sh\necho hi\n"


@pytest.mark.parametrize(
    ("head", "mime"),
    [
        (PNG, "image/png"),
        (JPEG, "image/jpeg"),
        (GIF, "image/gif"),
        (WEBP, "image/webp"),
        (PDF, "application/pdf"),
        (MP4, "video/mp4"),
        (WEBM, "video/webm"),
        (ZIP, "application/zip"),
        (b"just some notes\n", "text/plain"),
    ],
)
def test_the_content_decides_the_type(head: bytes, mime: str) -> None:
    assert sniff.sniff(head, "whatever.bin").mime == mime


def test_the_extension_cannot_make_a_program_look_like_a_picture() -> None:
    found = sniff.sniff(EXE, "holiday.png")

    assert found.executable and found.mime == "application/x-msdownload"


@pytest.mark.parametrize("head", [EXE, ELF, MACHO, SCRIPT])
def test_programs_and_scripts_are_executables(head: bytes) -> None:
    assert sniff.sniff(head, "x").executable


def test_a_picture_named_like_a_program_is_still_a_picture() -> None:
    assert not sniff.sniff(PNG, "setup.exe").executable


@pytest.mark.parametrize("name", ["run.bat", "a.CMD", "x.ps1", "setup.msi", "evil.js", "t.vbs"])
def test_a_script_by_extension_is_blocked_even_when_its_content_looks_like_text(name: str) -> None:
    assert sniff.sniff(b"echo hi\n", name).executable


@pytest.mark.parametrize(
    ("head", "name"),
    [(PNG, "a.png"), (PDF, "a.pdf"), (MP4, "a.mp4"), (b"plain\n", "a.txt")],
)
def test_images_pdf_video_and_text_show_inline(head: bytes, name: str) -> None:
    assert sniff.sniff(head, name).inline


@pytest.mark.parametrize(
    "head", [b"<html><script>alert(1)</script>", b"<?xml version='1.0'?><svg>", b"<svg xmlns=", ZIP]
)
def test_markup_and_archives_are_downloads_never_shown_in_the_page(head: bytes) -> None:
    found = sniff.sniff(head, "x.html")

    assert not found.inline


def test_unknown_binary_is_an_opaque_download() -> None:
    found = sniff.sniff(b"\x00\x01\x02\x03" * 8, "data.bin")

    assert found.mime == "application/octet-stream" and not found.inline and not found.executable


def test_what_pillow_and_pdfium_can_thumbnail() -> None:
    assert sniff.sniff(PNG, "a").thumbnailable and sniff.sniff(PDF, "a").thumbnailable
    assert not sniff.sniff(MP4, "a").thumbnailable
