import socket
import struct
import threading
from collections.abc import Iterator
from pathlib import Path

import pytest

from infrastructure.attachments import scan


class FakeClam:
    """Speaks just enough clamd INSTREAM: reads the stream, answers ``reply``."""

    def __init__(self, reply: bytes) -> None:
        self.reply = reply
        self.received = b""
        self.server = socket.socket()
        self.server.bind(("127.0.0.1", 0))
        self.server.listen(1)
        self.address = f"127.0.0.1:{self.server.getsockname()[1]}"
        self.thread = threading.Thread(target=self._serve, daemon=True)
        self.thread.start()

    def _serve(self) -> None:
        conn, _ = self.server.accept()
        with conn:
            command = b""
            while not command.endswith(b"\0"):
                command += conn.recv(1)
            assert command == b"zINSTREAM\0"
            while True:
                (size,) = struct.unpack("!I", conn.recv(4))
                if size == 0:
                    break
                left = size
                while left:
                    part = conn.recv(left)
                    self.received += part
                    left -= len(part)
            conn.sendall(self.reply)


@pytest.fixture
def clam(request: pytest.FixtureRequest) -> Iterator[FakeClam]:
    fake = FakeClam(request.param)
    yield fake
    fake.server.close()


@pytest.mark.parametrize("clam", [b"stream: OK\0"], indirect=True)
def test_a_clean_file_passes_and_is_streamed_whole(clam: FakeClam, tmp_path: Path) -> None:
    path = tmp_path / "f"
    path.write_bytes(b"hello" * 100_000)

    assert scan.scan(path, clam.address) is None
    assert clam.received == path.read_bytes()


@pytest.mark.parametrize("clam", [b"stream: Eicar-Test-Signature FOUND\0"], indirect=True)
def test_an_infected_file_is_reported_by_name(clam: FakeClam, tmp_path: Path) -> None:
    path = tmp_path / "f"
    path.write_bytes(b"x")

    assert scan.scan(path, clam.address) == "Eicar-Test-Signature"


def test_an_unreachable_scanner_fails_closed(tmp_path: Path) -> None:
    path = tmp_path / "f"
    path.write_bytes(b"x")

    with pytest.raises(scan.ScanUnavailable):
        scan.scan(path, "127.0.0.1:1")


def test_no_scanner_configured_means_no_scan(tmp_path: Path) -> None:
    path = tmp_path / "f"
    path.write_bytes(b"x")

    assert scan.scan(path, "") is None


@pytest.mark.parametrize("clam", [b"INSTREAM size limit exceeded. ERROR\0"], indirect=True)
def test_a_file_over_the_scanners_limit_is_told_apart_from_a_scanner_that_is_down(
    clam: FakeClam, tmp_path: Path
) -> None:
    path = tmp_path / "f"
    path.write_bytes(b"x")

    with pytest.raises(scan.ScanTooLarge):
        scan.scan(path, clam.address)
