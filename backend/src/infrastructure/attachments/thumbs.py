"""Thumbnails: a small JPEG of a picture or of the first page of a PDF.

Needs Pillow (and pypdfium2 for PDF); without them ``make`` answers ``None`` and the upload simply
has no thumbnail. A file that cannot be decoded also has none: a thumbnail is never a reason to
refuse a file. The pixel cap stops a small file that expands into a huge image.
"""

import io
import logging
import subprocess
import sys
from pathlib import Path
from typing import Any, Final

logger = logging.getLogger(__name__)

THUMB_SIZE: Final = 320
MAX_PIXELS: Final = 40_000_000
WORKER_SECONDS: Final = 20
WORKER_MEMORY_BYTES: Final = 1024 * 1024 * 1024
_IMAGES: Final = frozenset({"image/png", "image/jpeg", "image/gif", "image/webp"})


def _jpeg(image: Any) -> bytes:
    from PIL import Image

    image.thumbnail((THUMB_SIZE, THUMB_SIZE))
    if image.mode in ("RGBA", "LA", "P"):
        flat = Image.new("RGB", image.size, "white")
        rgba = image.convert("RGBA")
        flat.paste(rgba, mask=rgba.getchannel("A"))
        image = flat
    elif image.mode != "RGB":
        image = image.convert("RGB")
    out = io.BytesIO()
    image.save(out, "JPEG", quality=80)
    return out.getvalue()


def _picture(path: Path) -> bytes:
    from PIL import Image

    with Image.open(path, formats=["PNG", "JPEG", "GIF", "WEBP"]) as image:
        if image.width * image.height > MAX_PIXELS:
            raise ValueError("too many pixels")
        image.draft("RGB", (THUMB_SIZE * 2, THUMB_SIZE * 2))  # JPEG: decode at reduced size
        image.load()
        return _jpeg(image)


def _first_page(path: Path) -> bytes:
    import pypdfium2

    document = pypdfium2.PdfDocument(str(path))
    try:
        page = document[0]
        scale = THUMB_SIZE / max(page.get_width(), page.get_height(), 1)
        return _jpeg(page.render(scale=scale).to_pil())
    finally:
        document.close()


def make(path: Path, mime: str) -> bytes | None:
    """The JPEG thumbnail of the file at ``path`` (whose type is ``mime``), or ``None``."""
    try:
        if mime in _IMAGES:
            return _picture(path)
        if mime == "application/pdf":
            return _first_page(path)
    except Exception:  # noqa: BLE001 -- any decoder failure means "no thumbnail", never an error
        logger.info("no thumbnail for %s", path.name, exc_info=True)
    return None


def _limit() -> None:  # runs in the child, before it execs: a cap on memory and CPU time
    try:
        import resource

        # The memory cap goes last: in a parent already bigger than the cap (a test run, a fat web
        # worker) any Python allocation after it raises MemoryError inside preexec_fn.
        cpu = max(1, int(WORKER_SECONDS))  # setrlimit takes whole seconds
        resource.setrlimit(resource.RLIMIT_CPU, (cpu, cpu))
        resource.setrlimit(resource.RLIMIT_AS, (WORKER_MEMORY_BYTES, WORKER_MEMORY_BYTES))
    except (
        ImportError,
        ValueError,
        OSError,
        TypeError,
    ):  # not on this platform: the wall clock still applies
        pass


def make_isolated(path: Path, mime: str) -> bytes | None:
    """``make`` in a child process with a memory cap and a deadline, so a hostile PDF or picture
    that crashes or hangs a decoder cannot take the web worker with it (and PDFium, which is not
    thread-safe, never runs in two threads of this one)."""
    try:
        done = subprocess.run(  # noqa: S603 -- our own module, fixed arguments
            [sys.executable, "-I", __file__, str(path), mime],  # run as a script: no package needed
            capture_output=True,
            timeout=WORKER_SECONDS,
            check=False,
            preexec_fn=_limit,  # noqa: PLW1509
        )
    except (subprocess.SubprocessError, OSError):  # a timeout, or the child failing to start
        logger.warning("thumbnail worker failed for %s", path.name)
        return None
    return done.stdout or None if done.returncode == 0 else None


if __name__ == "__main__":  # the child: ``python thumbs.py PATH MIME``
    result = make(Path(sys.argv[1]), sys.argv[2])
    if result:
        sys.stdout.buffer.write(result)
