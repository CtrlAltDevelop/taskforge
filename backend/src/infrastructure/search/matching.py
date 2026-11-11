"""How a folded query is matched against ``SearchEntry`` and ranked, per database.

PostgreSQL: the generated ``search_vector`` (``simple`` config: Persian, Arabic and Latin alike)
matched as prefixes, plus trigram word similarity on the title for typos. Elsewhere (SQLite in
development and most tests) plain substring matching with no typo tolerance and no relevance score.
"""

from collections.abc import Callable, Iterator
from contextlib import contextmanager
from typing import Any

from django.conf import settings
from django.db import OperationalError, connection, transaction
from django.db.models import Case, Exists, F, FloatField, Q, QuerySet, When
from django.db.models.expressions import RawSQL

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.search.models import SearchEntry

TABLE = SearchEntry._meta.db_table
TYPO_MIN_LENGTH = 4  # shorter words are too ambiguous for trigram matching
TYPO_THRESHOLD = 0.35
ASSIGNED_BONUS = 0.3
RECENCY_WEIGHT = 0.2
RECENCY_HALF_DAYS = 30


def on_postgres() -> bool:
    return connection.vendor == "postgresql"


@contextmanager
def session() -> Iterator[None]:
    """On PostgreSQL: a transaction with a statement time limit and the typo threshold (``SET
    LOCAL``, so both end with it)."""
    if not on_postgres():
        yield
        return
    try:
        with transaction.atomic(), connection.cursor() as cursor:
            cursor.execute("SET LOCAL statement_timeout = %s", [settings.SEARCH_TIMEOUT_MS])
            cursor.execute("SET LOCAL pg_trgm.word_similarity_threshold = %s", [TYPO_THRESHOLD])
            yield
    except OperationalError as error:
        if "statement timeout" not in str(error).lower():
            raise
        raise ApiError(
            "That search took too long. Narrow it down.", title=ResponseTitle.VALIDATION_ERROR
        ) from None


def _postgres(rows: QuerySet[SearchEntry], words: list[str]) -> QuerySet[SearchEntry]:
    prefixes = " & ".join(f"{w}:*" for w in words)
    # Every word must be long enough, or a short one would be skipped and still "match".
    typos = words if all(len(w) >= TYPO_MIN_LENGTH for w in words) else []
    clauses = [f"{TABLE}.search_vector @@ to_tsquery('simple', %s)"]
    params: list[Any] = [prefixes]
    if typos:
        clauses.append("(" + " AND ".join(f"%s <%% {TABLE}.title" for _ in typos) + ")")
        params.extend(typos)
    # ponytail: `extra` for the two PostgreSQL-only operators; Django has no lookup for them.
    rows = rows.extra(where=["(" + " OR ".join(clauses) + ")"], params=params)
    score = RawSQL(
        f"ts_rank_cd({TABLE}.search_vector, to_tsquery('simple', %s))"
        f" + word_similarity(%s, {TABLE}.title)"
        f" + {RECENCY_WEIGHT} / (1 + extract(epoch from now() - {TABLE}.updated_at)"
        f" / {RECENCY_HALF_DAYS * 86400}.0)",
        [prefixes, " ".join(words)],
        output_field=FloatField(),
    )
    return rows.annotate(score=score)


def _substring(rows: QuerySet[SearchEntry], words: list[str]) -> QuerySet[SearchEntry]:
    for word in words:
        rows = rows.filter(Q(title__contains=word) | Q(body__contains=word))
    hit = Case(When(title__contains=words[0], then=1.0), default=0.0, output_field=FloatField())
    return rows.annotate(score=hit)


def match(rows: QuerySet[SearchEntry], words: list[str], mine: Exists) -> QuerySet[SearchEntry]:
    """``rows`` limited to what matches ``words`` (all of them), best first."""
    if not words:
        return rows.annotate(score=Case(When(Exists(mine), then=1.0), default=0.0)).order_by(
            "-score", "-updated_at", "id"
        )
    matcher: Callable[[QuerySet[SearchEntry], list[str]], QuerySet[SearchEntry]] = (
        _postgres if on_postgres() else _substring
    )
    rows = matcher(rows, words)
    bonus = Case(When(Exists(mine), then=ASSIGNED_BONUS), default=0.0, output_field=FloatField())
    return rows.annotate(total=F("score") + bonus).order_by("-total", "-updated_at", "id")
