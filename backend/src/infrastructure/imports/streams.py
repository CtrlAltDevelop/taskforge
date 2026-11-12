"""Reading an uploaded file without loading it: a plain file or a zip, as text, as CSV rows, or as
the items of one JSON array.

Nothing here keeps more than one row (or one array item, or one read block) in memory, so a file
of any size is read in constant space. A zip is opened with ``zipfile`` and one member is read
as a stream; its declared size is checked first against ``MAX_MEMBER_BYTES`` (a zip bomb names a
small file and inflates it; the stream is cut at the limit as well).
"""

import csv
import io
import json
import zipfile
from collections.abc import Iterator
from typing import IO, Any, Final

from infrastructure.common.errors import ApiError

MAX_MEMBER_BYTES: Final = 2 * 1024**3
MAX_FIELD_BYTES: Final = 1024 * 1024  # one cell (a long description) of a CSV
BLOCK: Final = 1 << 16
WANTED: Final = (".csv", ".json")


def refused(message: str) -> ApiError:
    return ApiError(message, status=422)


class _Limited(io.RawIOBase):
    """A binary stream that fails when more than ``limit`` bytes come out of it."""

    def __init__(self, inner: IO[bytes], limit: int) -> None:
        self._inner, self._left = inner, limit

    def readable(self) -> bool:
        return True

    def readinto(self, buffer: Any) -> int:
        data = self._inner.read(min(len(buffer), self._left + 1))
        if len(data) > self._left:
            raise refused("The file inflates to more than 2 GB: refused.")
        self._left -= len(data)
        buffer[: len(data)] = data
        return len(data)


def default_member(names: list[str]) -> str:
    """The file to read when a zip holds several: the one ``tasks.json`` (what a TaskForge export
    of a project holds beside its spreadsheet and side files), else none."""
    found = [n for n in names if n == "tasks.json" or n.endswith("/tasks.json")]
    return found[0] if len(found) == 1 else ""


def open_binary(path_or_file: Any, member: str = "") -> tuple[IO[bytes], str]:
    """The data stream of an upload and the name of what it is: the file itself, or the one
    ``.csv``/``.json`` inside a zip (``member`` names it when there are several)."""
    if not zipfile.is_zipfile(path_or_file):
        path_or_file.seek(0)
        return path_or_file, ""
    path_or_file.seek(0)
    archive = zipfile.ZipFile(path_or_file)
    names = [
        i.filename
        for i in archive.infolist()
        if not i.is_dir() and i.filename.lower().endswith(WANTED) and "__MACOSX" not in i.filename
    ]
    if member:
        names = [n for n in names if n == member]
    elif len(names) > 1 and (chosen := default_member(names)):
        names = [chosen]
    if not names:
        raise refused("The zip holds no .csv or .json file.")
    if len(names) > 1 and not member:
        raise refused(f"The zip holds several files ({', '.join(sorted(names)[:5])}); name one.")
    info = archive.getinfo(names[0])
    if info.file_size > MAX_MEMBER_BYTES:
        raise refused("The file inside the zip is larger than 2 GB.")
    return io.BufferedReader(_Limited(archive.open(info), MAX_MEMBER_BYTES)), names[0]


def member_names(path_or_file: Any) -> list[str]:
    """The ``.csv``/``.json`` files of a zip (empty for a plain file)."""
    if not zipfile.is_zipfile(path_or_file):
        path_or_file.seek(0)
        return []
    path_or_file.seek(0)
    return [
        i.filename
        for i in zipfile.ZipFile(path_or_file).infolist()
        if not i.is_dir() and i.filename.lower().endswith(WANTED) and "__MACOSX" not in i.filename
    ]


def text_of(binary: IO[bytes]) -> io.TextIOBase:
    """The stream as text: UTF-8 (with or without a byte-order mark) or, failing that, as
    Windows-1252, which is what spreadsheet exports of old tools are."""
    head = binary.read(BLOCK)
    try:
        head.decode("utf-8-sig")
        encoding = "utf-8-sig"
    except UnicodeDecodeError as error:
        # A multi-byte character cut by the block end is not a bad file.
        encoding = "utf-8-sig" if error.start >= len(head) - 3 else "cp1252"
    rest = io.BufferedReader(_Prepend(head, binary))
    return io.TextIOWrapper(rest, encoding=encoding, errors="replace", newline="")


class _Prepend(io.RawIOBase):
    def __init__(self, head: bytes, inner: IO[bytes]) -> None:
        self._head, self._inner = head, inner

    def readable(self) -> bool:
        return True

    def readinto(self, buffer: Any) -> int:
        if self._head:
            n = min(len(buffer), len(self._head))
            buffer[:n] = self._head[:n]
            self._head = self._head[n:]
            return n
        data = self._inner.read(len(buffer))
        buffer[: len(data)] = data
        return len(data)


MAX_LINE: Final = 2 * MAX_FIELD_BYTES


def _line(text: io.TextIOBase) -> str:
    """The next physical line, refused when it is longer than ``MAX_LINE`` (so a file with no
    line breaks cannot fill memory before any limit is looked at)."""
    got = text.readline(MAX_LINE)
    if len(got) >= MAX_LINE and not got.endswith("\n"):
        raise refused("A line of the file is longer than 2 MB: it is not a CSV file.")
    return got


def csv_rows(text: io.TextIOBase) -> tuple[list[str], Iterator[tuple[int, list[str]]]]:
    """The header and an iterator of ``(line, cells)``. The delimiter (comma, semicolon or tab)
    is sniffed from the first line. A cell over ``MAX_FIELD_BYTES`` is a refusal, not a crash."""
    first = _line(text)
    if not first.strip():
        raise refused("The file is empty.")
    delimiter = max(",;\t", key=first.count) if any(d in first for d in ",;\t") else ","
    csv.field_size_limit(MAX_FIELD_BYTES)

    def lines() -> Iterator[str]:
        yield first
        while line := _line(text):
            yield line

    reader = csv.reader(lines(), delimiter=delimiter)
    try:
        header = [h.strip() for h in next(reader)]
    except (StopIteration, csv.Error):
        raise refused("The file has no header row.") from None

    def rows() -> Iterator[tuple[int, list[str]]]:
        while True:
            try:
                cells = next(reader)
            except StopIteration:
                return
            except csv.Error as error:
                yield reader.line_num, [f"\x00{error}"]  # the caller records it and goes on
                continue
            if any(c.strip() for c in cells):
                yield reader.line_num, cells

    return header, rows()


MAX_ITEM_BYTES: Final = 64 * 1024 * 1024  # one JSON item (an issue with its whole history)


class _Reader:
    """A cursor over a text stream that decodes one JSON value at a time."""

    def __init__(self, text: io.TextIOBase) -> None:
        self.text, self.buffer, self.pos, self.eof = text, "", 0, False

    def _fill(self, size: int = 0) -> bool:
        if self.eof:
            return False
        chunk = self.text.read(size or BLOCK)
        if not chunk:
            self.eof = True
            return False
        self.buffer = self.buffer[self.pos :] + chunk
        self.pos = 0
        if len(self.buffer) > MAX_ITEM_BYTES:
            raise refused("One entry of the JSON file is larger than 64 MB.")
        return True

    def peek(self, skip: str = " \t\r\n\ufeff") -> str:
        """The next character that is not in ``skip`` (not consumed); "" at the end."""
        while True:
            while self.pos < len(self.buffer) and self.buffer[self.pos] in skip:
                self.pos += 1
            if self.pos < len(self.buffer):
                return self.buffer[self.pos]
            if not self._fill():
                return ""

    def value(self) -> Any:
        decoder = json.JSONDecoder()
        self.peek()  # raw_decode does not skip leading whitespace
        grow = BLOCK
        while True:
            try:
                item, end = decoder.raw_decode(self.buffer, self.pos)
            except json.JSONDecodeError:
                # Read twice as much each time a value is still incomplete: a large item is
                # decoded a few times, not once per block.
                if not self._fill(grow):
                    raise refused("The JSON is cut off or malformed.") from None
                grow *= 2
                continue
            if end >= len(self.buffer) and self._fill():
                continue  # a number or literal at the block edge may go on
            self.pos = end
            return item


def _array_items(reader: _Reader) -> Iterator[Any]:
    while True:
        c = reader.peek(" \t\r\n,")
        if c in ("", "]"):
            return
        yield reader.value()


def json_items(text: io.TextIOBase, *keys: str) -> Iterator[Any]:
    """Each item of the top-level array, or (when the file is an object) of the first member
    named in ``keys`` that holds an array, read one at a time. Other members of the object are
    decoded and dropped, so they should be small (Jira and ClickUp keep their lists apart)."""
    reader = _Reader(text)
    first = reader.peek()
    if first == "[":
        reader.pos += 1
        yield from _array_items(reader)
        return
    if first != "{":
        raise refused("The file is not a JSON list or object.")
    reader.pos += 1
    while True:
        c = reader.peek(" \t\r\n,")
        if c in ("", "}"):
            raise refused(f"No list named {', '.join(keys)} in the file.")
        name = reader.value()
        if reader.peek() != ":":
            raise refused("The JSON is malformed.")
        reader.pos += 1
        if name in keys and reader.peek() == "[":
            reader.pos += 1
            yield from _array_items(reader)
            return
        reader.value()


def json_members_before(text: io.TextIOBase, key: str) -> dict[str, Any]:
    """The members of a top-level JSON object that come before ``key`` (the project, statuses and
    so on of our own export), decoded; ``{}`` when the file is not an object."""
    reader = _Reader(text)
    if reader.peek() != "{":
        return {}
    reader.pos += 1
    found: dict[str, Any] = {}
    while True:
        c = reader.peek(" \t\r\n,")
        if c in ("", "}"):
            return found
        name = reader.value()
        if reader.peek() != ":":
            raise refused("The JSON is malformed.")
        reader.pos += 1
        if name == key:
            return found
        found[str(name)] = reader.value()
