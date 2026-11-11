"""What a file is, from its first bytes. The name a client gives is never trusted.

``sniff`` looks at the head of the content (and only then at the extension, to catch scripts whose
content is plain text). The answer says whether the file is a program or script, whether it is safe
to show inside a page (``inline``) and whether a thumbnail can be made.
"""

from dataclasses import dataclass
from typing import Final

HEAD_BYTES: Final = 4096

_SCRIPT_EXTENSIONS: Final = frozenset(
    {
        ".exe", ".dll", ".msi", ".com", ".scr", ".bat", ".cmd", ".ps1", ".vbs", ".vbe", ".js",
        ".jse", ".wsf", ".wsh", ".sh", ".bash", ".app", ".apk", ".jar", ".command", ".lnk", ".reg",
        ".hta", ".py", ".pl", ".rb", ".php", ".msc", ".scf", ".url", ".jnlp", ".cpl", ".gadget",
        ".iso", ".dmg", ".pkg", ".deb", ".rpm", ".docm", ".xlsm", ".pptm",
    }
)  # fmt: skip
# Shown inside a page without being a risk: pictures a browser decodes, PDF, video, plain text.
_INLINE: Final = frozenset(
    {
        "image/png", "image/jpeg", "image/gif", "image/webp", "application/pdf", "video/mp4",
        "video/webm", "text/plain",
    }
)  # fmt: skip
_THUMBNAILABLE: Final = frozenset(
    {"image/png", "image/jpeg", "image/gif", "image/webp", "application/pdf"}
)
_MARKUP_START: Final = (b"<html", b"<!doctype", b"<?xml", b"<svg", b"<script", b"<head", b"<body")


@dataclass(frozen=True, slots=True)
class Sniffed:
    mime: str
    executable: bool = False

    @property
    def inline(self) -> bool:
        return self.mime in _INLINE

    @property
    def thumbnailable(self) -> bool:
        return self.mime in _THUMBNAILABLE


def _extension(filename: str) -> str:
    dot = filename.rfind(".")
    return filename[dot:].lower() if dot >= 0 else ""


def is_script_name(filename: str) -> bool:
    """Whether the extension alone marks a program or script (``setup.exe``, ``run.bat``)."""
    return _extension(filename) in _SCRIPT_EXTENSIONS


def _looks_like_text(head: bytes) -> bool:
    if b"\0" in head:
        return False
    try:
        head.decode("utf-8")
    except UnicodeDecodeError as error:
        # A multi-byte character cut off by the end of the sample is still text.
        if error.start < len(head) - 4:
            return False
    return True


def _binary_type(head: bytes) -> str | None:
    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if head.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if head[:6] in (b"GIF87a", b"GIF89a"):
        return "image/gif"
    if head[:4] == b"RIFF" and head[8:12] == b"WEBP":
        return "image/webp"
    if head.startswith(b"%PDF-"):
        return "application/pdf"
    if head[4:8] == b"ftyp":
        return "video/mp4"
    if head.startswith(b"\x1a\x45\xdf\xa3"):
        return "video/webm"
    if head.startswith((b"PK\x03\x04", b"PK\x05\x06")):
        return "application/zip"
    return None


def _program_type(head: bytes) -> str | None:
    if head.startswith(b"MZ"):
        return "application/x-msdownload"
    if head.startswith(b"\x7fELF"):
        return "application/x-executable"
    if head[:4] in (
        b"\xcf\xfa\xed\xfe",
        b"\xce\xfa\xed\xfe",
        b"\xfe\xed\xfa\xce",
        b"\xfe\xed\xfa\xcf",
        b"\xca\xfe\xba\xbe",
    ):
        return "application/x-mach-binary"
    if head.startswith(b"#!"):
        return "text/x-shellscript"
    return None


def sniff(head: bytes, filename: str) -> Sniffed:
    """The type of a file whose first bytes are ``head`` (at most ``HEAD_BYTES`` are needed)."""
    program = _program_type(head)
    if program:
        return Sniffed(program, executable=True)
    mime = _binary_type(head)
    if mime:
        return Sniffed(mime)
    if is_script_name(filename) and _looks_like_text(head):
        return Sniffed("text/x-script", executable=True)
    if _looks_like_text(head):
        if head.lstrip().lower().startswith(_MARKUP_START):
            return Sniffed("text/html")
        return Sniffed("text/plain")
    return Sniffed("application/octet-stream")
