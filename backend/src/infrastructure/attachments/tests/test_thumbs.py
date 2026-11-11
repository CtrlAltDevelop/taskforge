import io
from pathlib import Path

import pytest
from PIL import Image

from infrastructure.attachments import thumbs


def _image(path: Path, fmt: str, size: tuple[int, int] = (800, 600), mode: str = "RGB") -> Path:
    Image.new(mode, size, "red").save(path, fmt)
    return path


def _dimensions(data: bytes) -> tuple[int, int]:
    return Image.open(io.BytesIO(data)).size


@pytest.mark.parametrize(
    ("fmt", "mime"),
    [("PNG", "image/png"), ("JPEG", "image/jpeg"), ("GIF", "image/gif"), ("WEBP", "image/webp")],
)
def test_pictures_get_a_small_jpeg(tmp_path: Path, fmt: str, mime: str) -> None:
    path = _image(tmp_path / "p", fmt)

    data = thumbs.make(path, mime)

    assert data is not None
    assert max(_dimensions(data)) <= thumbs.THUMB_SIZE
    assert Image.open(io.BytesIO(data)).format == "JPEG"


def test_a_picture_with_transparency_is_flattened(tmp_path: Path) -> None:
    path = _image(tmp_path / "p", "PNG", mode="RGBA")

    assert thumbs.make(path, "image/png") is not None


def test_a_small_picture_is_not_blown_up(tmp_path: Path) -> None:
    path = _image(tmp_path / "p", "PNG", size=(40, 30))

    data = thumbs.make(path, "image/png")

    assert data is not None and _dimensions(data) == (40, 30)


def test_the_first_page_of_a_pdf_is_drawn(tmp_path: Path) -> None:
    path = tmp_path / "doc.pdf"
    Image.new("RGB", (612, 792), "white").save(path, "PDF")

    data = thumbs.make(path, "application/pdf")

    assert data is not None and max(_dimensions(data)) <= thumbs.THUMB_SIZE


def test_a_broken_file_has_no_thumbnail_and_does_not_raise(tmp_path: Path) -> None:
    broken = tmp_path / "x"
    broken.write_bytes(b"\x89PNG\r\n\x1a\nnot really")

    assert thumbs.make(broken, "image/png") is None
    assert thumbs.make(broken, "application/pdf") is None


def test_a_type_with_no_thumbnail_returns_none(tmp_path: Path) -> None:
    path = tmp_path / "v"
    path.write_bytes(b"\x00" * 64)

    assert thumbs.make(path, "video/mp4") is None


def test_a_picture_too_large_to_decode_safely_is_refused(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(thumbs, "MAX_PIXELS", 100)
    path = _image(tmp_path / "p", "PNG", size=(50, 50))

    assert thumbs.make(path, "image/png") is None


def test_the_isolated_worker_makes_the_same_thumbnail(tmp_path: Path) -> None:
    path = _image(tmp_path / "p", "PNG")

    data = thumbs.make_isolated(path, "image/png")

    assert data is not None and max(_dimensions(data)) <= thumbs.THUMB_SIZE


def test_the_isolated_worker_returns_nothing_for_a_broken_file_or_a_hang(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    broken = tmp_path / "x"
    broken.write_bytes(b"\x89PNG\r\n\x1a\nnot really")
    assert thumbs.make_isolated(broken, "image/png") is None

    good = _image(tmp_path / "p", "PNG")
    monkeypatch.setattr(thumbs, "WORKER_SECONDS", 0.001)  # the deadline passes before it can finish
    assert thumbs.make_isolated(good, "image/png") is None
