"""TFQL: the text form of a filter, and its parser. Pure (no database, no transport).

    status in (Active, "In review") AND assignee = me AND due < +7d ORDER BY priority DESC

Grammar (keywords are case-insensitive)::

    query  := [or] [ORDER BY item {"," item}]
    or     := and {OR and}
    and    := not {AND not}
    not    := [NOT] atom
    atom   := "(" or ")" | field IS [NOT] EMPTY | field [NOT] IN "(" value {"," value} ")"
            | field op value
    op     := "=" | "!=" | "~" | "!~" | "<" | "<=" | ">" | ">="
    item   := field [ASC | DESC]
    field  := WORD | STRING
    value  := STRING | WORD | NUMBER | DATE | RELATIVE | WORD "(" ")"

A value is a quoted string, a bare word (letters, digits, ``_``), a number, a date
(``2026-11-05``), a relative date (``+7d``, ``-2w``, ``+1m``, ``+1y``; ``today`` is ``+0d``) or a
function call (``currentSprint()``). The parser only reads the shape: what a field or a word means
is decided against a project (``resolve``). Every refusal is a ``QueryError`` with the character
position and length of what is wrong.
"""

import re
from dataclasses import dataclass, field
from typing import Final

MAX_LENGTH: Final = 2000
MAX_DEPTH: Final = 8
MAX_CONDITIONS: Final = 50
MAX_LIST: Final = 100
KEYWORDS: Final = frozenset({"and", "or", "not", "in", "is", "empty", "order", "by", "asc", "desc"})
COMPARATORS: Final = ("<=", ">=", "!=", "!~", "=", "~", "<", ">")


class QueryError(Exception):
    """A query that cannot be read or means nothing: ``position`` and ``length`` locate it."""

    def __init__(self, message: str, position: int = 0, length: int = 1) -> None:
        super().__init__(message)
        self.message = message
        self.position = position
        self.length = max(length, 1)


@dataclass(frozen=True, slots=True)
class Token:
    kind: str  # word | string | number | date | rel | symbol | end
    text: str  # the value (a string without its quotes and escapes)
    pos: int
    length: int


_TOKEN = re.compile(
    r"""
    (?P<space>\s+)
  | (?P<date>\d{4}-\d{2}-\d{2})(?![\w-])
  | (?P<rel>[+-]\d+[dwmy])(?![\w])
  | (?P<number>-?\d+(?:\.\d+)?)(?![\w])
  | (?P<word>[A-Za-z_][A-Za-z0-9_]*)
  | (?P<symbol><=|>=|!=|!~|[=~<>(),])
    """,
    re.VERBOSE,
)


def tokenize(source: str) -> list[Token]:
    if len(source) > MAX_LENGTH:
        raise QueryError(f"A query is at most {MAX_LENGTH} characters.", MAX_LENGTH, 1)
    tokens: list[Token] = []
    pos = 0
    while pos < len(source):
        if source[pos] == '"':
            text, end = _string(source, pos)
            tokens.append(Token("string", text, pos, end - pos))
            pos = end
            continue
        match = _TOKEN.match(source, pos)
        if match is None:
            raise QueryError(f"Unexpected character {source[pos]!r}.", pos, 1)
        kind = match.lastgroup or ""
        if kind != "space":
            tokens.append(Token(kind, match.group(), pos, match.end() - pos))
        pos = match.end()
    tokens.append(Token("end", "", len(source), 1))
    return tokens


def _string(source: str, start: int) -> tuple[str, int]:
    out: list[str] = []
    pos = start + 1
    while pos < len(source):
        char = source[pos]
        if char == "\\" and pos + 1 < len(source) and source[pos + 1] in '"\\':
            out.append(source[pos + 1])
            pos += 2
        elif char == '"':
            return "".join(out), pos + 1
        else:
            out.append(char)
            pos += 1
    raise QueryError("This string is never closed.", start, len(source) - start)


# ----------------------------------------------------------------------------------- the tree


@dataclass(frozen=True, slots=True)
class Value:
    kind: str  # string | word | number | date | rel | func
    text: str
    pos: int
    length: int


@dataclass(frozen=True, slots=True)
class Cmp:
    field: Token
    op: str  # = != ~ !~ < <= > >= in not_in empty not_empty
    values: tuple[Value, ...]
    pos: int
    length: int


@dataclass(frozen=True, slots=True)
class Group:
    op: str  # and | or
    args: tuple["Node", ...]


@dataclass(frozen=True, slots=True)
class Not:
    arg: "Node"


Node = Cmp | Group | Not


@dataclass(frozen=True, slots=True)
class OrderItem:
    field: Token
    desc: bool


@dataclass(slots=True)
class Query:
    where: Node | None = None
    order: list[OrderItem] = field(default_factory=list)


# ---------------------------------------------------------------------------------- the parser


class _Parser:
    def __init__(self, tokens: list[Token]) -> None:
        self.tokens = tokens
        self.i = 0
        self.conditions = 0

    @property
    def tok(self) -> Token:
        return self.tokens[self.i]

    def advance(self) -> Token:
        tok = self.tok
        if tok.kind != "end":
            self.i += 1
        return tok

    def is_word(self, *names: str) -> bool:
        return self.tok.kind == "word" and self.tok.text.lower() in names

    def is_symbol(self, text: str) -> bool:
        return self.tok.kind == "symbol" and self.tok.text == text

    def fail(self, message: str) -> QueryError:
        return QueryError(message, self.tok.pos, self.tok.length)

    def expect_symbol(self, text: str) -> Token:
        if not self.is_symbol(text):
            raise self.fail(f"Expected {text!r}.")
        return self.advance()

    def query(self) -> Query:
        result = Query()
        if not self.is_word("order") and self.tok.kind != "end":
            result.where = self.or_(1)
        if self.is_word("order"):
            self.advance()
            if not self.is_word("by"):
                raise self.fail("Expected BY after ORDER.")
            self.advance()
            result.order.append(self.order_item())
            while self.is_symbol(","):
                self.advance()
                result.order.append(self.order_item())
        if self.tok.kind != "end":
            raise self.fail("Unexpected text after the query.")
        return result

    def order_item(self) -> OrderItem:
        name = self.field_token()
        desc = False
        if self.is_word("asc", "desc"):
            desc = self.advance().text.lower() == "desc"
        return OrderItem(name, desc)

    def or_(self, depth: int) -> Node:
        args = [self.and_(depth)]
        while self.is_word("or"):
            self.advance()
            args.append(self.and_(depth))
        return args[0] if len(args) == 1 else Group("or", tuple(args))

    def and_(self, depth: int) -> Node:
        args = [self.not_(depth)]
        while self.is_word("and"):
            self.advance()
            args.append(self.not_(depth))
        return args[0] if len(args) == 1 else Group("and", tuple(args))

    def not_(self, depth: int) -> Node:
        if self.is_word("not"):
            start = self.advance()
            if depth >= MAX_DEPTH:
                raise QueryError("This query nests too deeply.", start.pos, start.length)
            return Not(self.not_(depth + 1))
        return self.atom(depth)

    def atom(self, depth: int) -> Node:
        if self.is_symbol("("):
            opener = self.advance()
            if depth >= MAX_DEPTH:
                raise QueryError("This query nests too deeply.", opener.pos, opener.length)
            inner = self.or_(depth + 1)
            self.expect_symbol(")")
            return inner
        return self.condition()

    def field_token(self) -> Token:
        tok = self.tok
        if tok.kind == "string" or (tok.kind == "word" and tok.text.lower() not in KEYWORDS):
            return self.advance()
        raise self.fail("Expected a field name.")

    def condition(self) -> Cmp:
        self.conditions += 1
        if self.conditions > MAX_CONDITIONS:
            raise self.fail(f"A query has at most {MAX_CONDITIONS} conditions.")
        name = self.field_token()
        if self.is_word("is"):
            self.advance()
            negate = False
            if self.is_word("not"):
                self.advance()
                negate = True
            if not self.is_word("empty"):
                raise self.fail("Expected EMPTY.")
            end = self.advance()
            return Cmp(
                name,
                "not_empty" if negate else "empty",
                (),
                name.pos,
                end.pos + end.length - name.pos,
            )
        negate = False
        if self.is_word("not"):
            self.advance()
            negate = True
            if not self.is_word("in"):
                raise self.fail("Expected IN after NOT.")
        if self.is_word("in"):
            self.advance()
            self.expect_symbol("(")
            values = [self.value()]
            while self.is_symbol(","):
                self.advance()
                values.append(self.value())
            if len(values) > MAX_LIST:
                raise QueryError(f"A list has at most {MAX_LIST} values.", values[0].pos, 1)
            close = self.expect_symbol(")")
            return Cmp(
                name,
                "not_in" if negate else "in",
                tuple(values),
                name.pos,
                close.pos + 1 - name.pos,
            )
        if self.tok.kind == "symbol" and self.tok.text in COMPARATORS:
            op = self.advance().text
            value = self.value()
            return Cmp(name, op, (value,), name.pos, value.pos + value.length - name.pos)
        raise self.fail("Expected an operator (=, !=, ~, !~, <, <=, >, >=, IN, IS EMPTY).")

    def value(self) -> Value:
        tok = self.tok
        if tok.kind in ("string", "number", "date", "rel"):
            self.advance()
            return Value(tok.kind, tok.text, tok.pos, tok.length)
        if tok.kind == "word" and tok.text.lower() not in KEYWORDS:
            self.advance()
            if self.is_symbol("("):
                self.advance()
                close = self.expect_symbol(")")
                return Value("func", tok.text, tok.pos, close.pos + 1 - tok.pos)
            return Value("word", tok.text, tok.pos, tok.length)
        raise self.fail("Expected a value.")


def parse(source: str) -> Query:
    """The query's tree, or a ``QueryError``. An empty query is valid (everything)."""
    return _Parser(tokenize(source)).query()
