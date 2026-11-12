"""When a series makes its next instance: the shared arithmetic of the clock, the editor's preview
and the calendar's ghosts, so what is shown is what is made."""

from datetime import UTC, date, datetime, time, timedelta
from typing import Final
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from infrastructure.common.errors import ApiError
from infrastructure.recurrence import rules
from infrastructure.recurrence.models import Mode, RecurrenceSeries

MAX_LEAD_DAYS: Final = 30


def zone(name: str) -> ZoneInfo:
    try:
        return ZoneInfo(name or "UTC")
    except (ZoneInfoNotFoundError, ValueError, OSError):
        raise ApiError("Unknown time zone.") from None


def clock_time(text: str) -> time:
    try:
        if len(text) != 5 or text[2] != ":":
            raise ValueError(text)
        return time(int(text[:2]), int(text[3:]))
    except ValueError:
        raise ApiError("The time of day must be HH:MM.") from None


def parse_rule(text: str) -> rules.Rule:
    try:
        return rules.parse(text)
    except rules.RuleError as error:
        raise ApiError(str(error)) from None


def today(series: RecurrenceSeries, now: datetime) -> date:
    return now.astimezone(zone(series.timezone)).date()


def run_at(series: RecurrenceSeries, due: date) -> datetime:
    """The moment (UTC) the instance for ``due`` is made: ``lead_days`` before it, at the series'
    local time of day, so a daylight-saving change keeps the wall clock."""
    local = datetime.combine(due - timedelta(days=series.lead_days), series.at_time)
    return local.replace(tzinfo=zone(series.timezone)).astimezone(UTC)


def is_last(rule: rules.Rule, index: int) -> bool:
    """``COUNT`` is a number of instances (the first is index 0): none follows index ``index``."""
    return rule.count is not None and index + 1 >= rule.count


def following(series: RecurrenceSeries, rule: rules.Rule, day: date, index: int) -> date | None:
    """The date of the instance after the one for ``day`` (number ``index``), or None at the end."""
    if series.mode != Mode.SCHEDULE or is_last(rule, index):
        return None
    found = rules.dates(
        rule,
        series.starts_on,
        after=day,
        skip_weekends=series.skip_weekends,
        limit=1,
        until=series.ends_on,
    )
    return found[0] if found else None


def ahead(series: RecurrenceSeries, rule: rules.Rule, limit: int) -> list[date]:
    """The next ``limit`` dates the clock will make for a schedule series (from ``next_due_on``)."""
    first = series.next_due_on
    if series.mode != Mode.SCHEDULE or first is None or series.paused:
        return []
    if rule.count is not None:
        limit = min(limit, rule.count - 1 - series.last_index)
    if limit <= 0:
        return []
    return rules.dates(
        rule,
        series.starts_on,
        after=first - timedelta(days=1),
        skip_weekends=series.skip_weekends,
        limit=limit,
        until=series.ends_on,
    )


def plan(series: RecurrenceSeries, rule: rules.Rule, after: date) -> None:
    """Set ``next_due_on`` / ``next_run_at`` to the first date strictly after ``after`` (schedule
    mode; an after-completion series waits for its open instance to be completed)."""
    due = None
    if series.mode == Mode.SCHEDULE and not is_last(rule, series.last_index):
        found = rules.dates(
            rule,
            series.starts_on,
            after=after,
            skip_weekends=series.skip_weekends,
            limit=1,
            until=series.ends_on,
        )
        due = found[0] if found else None
    series.next_due_on = due
    series.next_run_at = run_at(series, due) if due else None


def chain(
    rule: rules.Rule, start: date, limit: int, *, skip_weekends: bool, until: date | None
) -> list[date]:
    """What an after-completion rule would make if each instance were finished on its day."""
    found: list[date] = []
    day = start
    count_left = (rule.count - 1) if rule.count is not None else limit
    while len(found) < min(limit, count_left):
        nxt = rules.after_completion(rule, day, skip_weekends=skip_weekends)
        if nxt is None or (until and nxt > until) or (rule.until and nxt > rule.until):
            break
        found.append(nxt)
        day = nxt
    return found
