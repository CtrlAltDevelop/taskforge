"""Optional virus scan: a ClamAV daemon (``clamd``) is sent the file over its INSTREAM protocol.

Off unless ``ATTACHMENT_CLAMAV_ADDRESS`` ("host:port") is set. If it is set and the daemon cannot
be reached the upload is refused (``ScanUnavailable``): a file that could not be checked is not
kept.
"""

import socket
import struct
from pathlib import Path
from typing import Final

BLOCK: Final = 64 * 1024
TIMEOUT_SECONDS: Final = 30


class ScanUnavailable(Exception):
    """The scanner is configured but did not answer."""


class ScanTooLarge(Exception):
    """The scanner refused the file for its size: clamd's ``StreamMaxLength`` must be raised to at
    least ``ATTACHMENT_MAX_MB``."""


def scan(path: Path, address: str) -> str | None:
    """The name of what was found in the file at ``path``, ``None`` when it is clean or no scanner
    is configured (``address`` empty)."""
    if not address:
        return None
    host, _, port = address.rpartition(":")
    try:
        with socket.create_connection((host, int(port)), timeout=TIMEOUT_SECONDS) as conn:
            conn.sendall(b"zINSTREAM\0")
            with path.open("rb") as source:
                while block := source.read(BLOCK):
                    conn.sendall(struct.pack("!I", len(block)) + block)
            conn.sendall(struct.pack("!I", 0))
            reply = b""
            while not reply.endswith(b"\0"):
                part = conn.recv(1024)
                if not part:
                    break
                reply += part
    except (OSError, ValueError) as error:
        raise ScanUnavailable(str(error)) from error
    text = reply.rstrip(b"\0").decode("utf-8", "replace").strip()
    if "size limit exceeded" in text.lower():
        raise ScanTooLarge(text)
    if text.endswith("FOUND"):
        return text.removeprefix("stream:").removesuffix("FOUND").strip() or "malware"
    if not text.endswith("OK"):
        raise ScanUnavailable(text or "no answer")
    return None
