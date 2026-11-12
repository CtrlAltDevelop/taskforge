"""Repeat rules: an RRULE (the part people write: ``FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH``), the
dates it makes, and the sentence that says it in words.

Only what a person can set in the editor is accepted (FREQ, INTERVAL, BYDAY with an optional
"nth", BYMONTHDAY, BYMONTH, BYSETPOS, COUNT, UNTIL); anything else is refused, never guessed.
Dates are wall-clock dates in the series' time zone, so a daylight-saving change never moves a
Monday to Sunday. A day past the end of a short month ("the 31st") lands on the month's last day.
"""

from collections.abc import Iterator
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta
from typing import Final

from dateutil import rrule

FREQS: Final = {
    "DAILY": rrule.DAILY,
    "WEEKLY": rrule.WEEKLY,
    "MONTHLY": rrule.MONTHLY,
    "YEARLY": rrule.YEARLY,
}
DAYS: Final = ("MO", "TU", "WE", "TH", "FR", "SA", "SU")
DAY_NAMES: Final = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
ORDINALS: Final = {1: "1st", 2: "2nd", 3: "3rd", 4: "4th", 5: "5th", -1: "last"}
MAX_INTERVAL: Final = 366
MAX_COUNT: Final = 1000
SCAN_LIMIT: Final = 100_000  # occurrences looked at to answer one question


class RuleError(ValueError):
    """The rule cannot be used; the message says why, for the person who wrote it."""


@dataclass(frozen=True, slots=True)
class Rule:
    freq: str
    interval: int = 1
    byday: tuple[tuple[int, int], ...] = ()  # (nth or 0, weekday 0=Monday)
    bymonthday: tuple[int, ...] = ()
    bymonth: tuple[int, ...] = ()
    bysetpos: tuple[int, ...] = ()
    count: int | None = None
    until: date | None = None


def _ints(raw: str, name: str, low: int, high: int, *, zero: bool = False) -> tuple[int, ...]:
    out = []
    for part in raw.split(","):
        try:
            n = int(part)
        except ValueError:
            raise RuleError(f"{name} is a list of numbers.") from None
        if not low <= n <= high or (n == 0 and not zero):
            raise RuleError(f"{name} must be between {low} and {high}.")
        out.append(n)
    return tuple(out)


def _byday(raw: str) -> tuple[tuple[int, int], ...]:
    out = []
    for part in raw.split(","):
        text = part.strip().upper()
        code = text[-2:]
        if code not in DAYS:
            raise RuleError(f"{part!r} is not a weekday (MO, TU, WE, TH, FR, SA, SU).")
        head = text[:-2]
        nth = 0
        if head:
            try:
                nth = int(head)
            except ValueError:
                raise RuleError(f"{part!r} is not a weekday.") from None
            if nth == 0 or not -1 <= nth <= 5:
                raise RuleError("The nth weekday is 1 to 5, or -1 for the last.")
        out.append((nth, DAYS.index(code)))
    return tuple(out)


def parse(text: str) -> Rule:
    """The rule of ``FREQ=...;INTERVAL=...`` (an ``RRULE:`` prefix is allowed)."""
    body = text.strip()
    if body.upper().startswith("RRULE:"):
        body = body[6:]
    if not body or len(body) > 200:
        raise RuleError("Write the rule as FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH.")
    parts: dict[str, str] = {}
    for item in body.split(";"):
        key, sep, value = item.partition("=")
        key = key.strip().upper()
        if not sep or not value.strip() or key in parts:
            raise RuleError(f"{item!r} is not KEY=VALUE, or is repeated.")
        parts[key] = value.strip()
    unknown = set(parts) - {
        "FREQ", "INTERVAL", "BYDAY", "BYMONTHDAY", "BYMONTH", "BYSETPOS", "COUNT", "UNTIL"
    }  # fmt: skip
    if unknown:
        raise RuleError(f"{sorted(unknown)[0]} is not supported.")
    if parts.get("FREQ", "").upper() not in FREQS:
        raise RuleError("FREQ is DAILY, WEEKLY, MONTHLY or YEARLY.")
    rule = Rule(
        freq=parts["FREQ"].upper(),
        interval=_ints(parts.get("INTERVAL", "1"), "INTERVAL", 1, MAX_INTERVAL)[0],
        byday=_byday(parts["BYDAY"]) if "BYDAY" in parts else (),
        bymonthday=_ints(parts["BYMONTHDAY"], "BYMONTHDAY", -31, 31)
        if "BYMONTHDAY" in parts
        else (),
        bymonth=_ints(parts["BYMONTH"], "BYMONTH", 1, 12) if "BYMONTH" in parts else (),
        bysetpos=_ints(parts["BYSETPOS"], "BYSETPOS", -5, 5) if "BYSETPOS" in parts else (),
        count=_ints(parts["COUNT"], "COUNT", 1, MAX_COUNT)[0] if "COUNT" in parts else None,
        until=_until(parts["UNTIL"]) if "UNTIL" in parts else None,
    )
    _check(rule)
    return rule


def _until(raw: str) -> date:
    try:
        return datetime.strptime(raw[:8], "%Y%m%d").date()
    except ValueError:
        raise RuleError("UNTIL is a date like 20261231.") from None


def _check(rule: Rule) -> None:
    if rule.count is not None and rule.until is not None:
        raise RuleError("Use COUNT or UNTIL, not both.")
    if any(nth for nth, _ in rule.byday) and rule.freq not in ("MONTHLY", "YEARLY"):
        raise RuleError("'First Monday' style weekdays need a monthly or yearly rule.")
    if rule.bymonthday and rule.freq not in ("MONTHLY", "YEARLY"):
        raise RuleError("BYMONTHDAY needs a monthly or yearly rule.")
    if rule.bymonth and rule.freq != "YEARLY":
        raise RuleError("BYMONTH needs a yearly rule.")
    if rule.byday and rule.freq == "DAILY":
        raise RuleError("BYDAY needs a weekly, monthly or yearly rule.")
    if rule.bymonthday and rule.byday:
        raise RuleError("Choose a day of the month or a weekday, not both.")
    if len([d for d in rule.bymonthday if d > 28]) > 0 and len(rule.bymonthday) > 1:
        raise RuleError("Give one BYMONTHDAY when it is past the 28th.")


def render(rule: Rule) -> str:
    """The canonical text of a rule (what is stored and shown back)."""
    parts = [f"FREQ={rule.freq}"]
    if rule.interval != 1:
        parts.append(f"INTERVAL={rule.interval}")
    if rule.byday:
        parts.append("BYDAY=" + ",".join((str(n) if n else "") + DAYS[d] for n, d in rule.byday))
    if rule.bymonthday:
        parts.append("BYMONTHDAY=" + ",".join(map(str, rule.bymonthday)))
    if rule.bymonth:
        parts.append("BYMONTH=" + ",".join(map(str, rule.bymonth)))
    if rule.bysetpos:
        parts.append("BYSETPOS=" + ",".join(map(str, rule.bysetpos)))
    if rule.count is not None:
        parts.append(f"COUNT={rule.count}")
    if rule.until is not None:
        parts.append("UNTIL=" + rule.until.strftime("%Y%m%d"))
    return ";".join(parts)


def _build(rule: Rule, anchor: datetime) -> rrule.rrule:
    kwargs: dict[str, object] = {"dtstart": anchor, "interval": rule.interval}
    if rule.byday:
        kwargs["byweekday"] = [rrule.weekday(d, n or None) for n, d in rule.byday]
    monthday = list(rule.bymonthday)
    setpos = list(rule.bysetpos)
    if len(monthday) == 1 and monthday[0] > 28:
        # "the 31st" in a month with fewer days is its last day: the set {31st, last day} has
        # the 31st when there is one, and the last day otherwise (the first of the set wins).
        monthday, setpos = [monthday[0], -1], [1]
    if monthday:
        kwargs["bymonthday"] = monthday
    if rule.bymonth:
        kwargs["bymonth"] = list(rule.bymonth)
    if setpos:
        kwargs["bysetpos"] = setpos
    if rule.until is not None:
        kwargs["until"] = datetime.combine(rule.until, time.max)
    if rule.freq == "WEEKLY" and not rule.byday:
        kwargs["byweekday"] = rrule.weekday(anchor.weekday())
    if rule.freq == "MONTHLY" and not (monthday or rule.byday):
        kwargs["bymonthday"] = _clamped_day(anchor.day)
        if anchor.day > 28:
            kwargs["bysetpos"] = 1  # the 30th, or the last day when the month is shorter
    if rule.freq == "YEARLY" and not (monthday or rule.byday or rule.bymonth):
        kwargs["bymonth"] = anchor.month
        kwargs["bymonthday"] = _clamped_day(anchor.day)
        if anchor.day > 28:
            kwargs["bysetpos"] = 1
    return rrule.rrule(FREQS[rule.freq], **kwargs)


def _clamped_day(day: int) -> list[int] | int:
    return [day, -1] if day > 28 else day


def dates(
    rule: Rule,
    starts_on: date,
    *,
    after: date | None = None,
    skip_weekends: bool = False,
    limit: int = 10,
    until: date | None = None,
) -> list[date]:
    """The next ``limit`` dates of the rule that fall strictly after ``after`` (else from
    ``starts_on`` itself), counting from ``starts_on``. Weekend dates are left out with
    ``skip_weekends``; nothing is returned past ``until``."""
    anchor = datetime.combine(starts_on, time.min)
    found: list[date] = []
    seen = 0
    for n, moment in enumerate(_build(rule, anchor)):
        if n >= SCAN_LIMIT:
            break
        day = moment.date()
        if until is not None and day > until:
            break
        if skip_weekends and day.weekday() >= 5:
            continue
        seen += 1  # COUNT is a number of instances: weekends that are skipped are not one
        if rule.count is not None and seen > rule.count:
            break
        if after is not None and day <= after:
            continue
        found.append(day)
        if len(found) >= limit:
            break
    return found


def after_completion(rule: Rule, completed_on: date, *, skip_weekends: bool = False) -> date | None:
    """The next date when the repeat counts from the day the task was finished: ``INTERVAL``
    days, weeks, months or years later (month ends clamp). A weekend moves to Monday when
    weekends are skipped."""
    n = rule.interval
    if rule.freq == "DAILY":
        nxt = completed_on + timedelta(days=n)
    elif rule.freq == "WEEKLY":
        nxt = completed_on + timedelta(weeks=n)
    else:
        months = n if rule.freq == "MONTHLY" else 12 * n
        total = completed_on.year * 12 + completed_on.month - 1 + months
        year, month = divmod(total, 12)
        month += 1
        first_next = date(year + (month == 12), month % 12 + 1, 1)
        last = (first_next - timedelta(days=1)).day
        nxt = date(year, month, min(completed_on.day, last))
    if skip_weekends and nxt.weekday() >= 5:
        nxt += timedelta(days=7 - nxt.weekday())
    return nxt


def describe(rule: Rule, mode: str = "schedule") -> str:
    """The rule in words: "Every 2 weeks on Mon, Thu", "Every month on the 1st Monday"."""
    n = rule.interval
    unit = {"DAILY": "day", "WEEKLY": "week", "MONTHLY": "month", "YEARLY": "year"}[rule.freq]
    if mode == "after_completion":
        return f"{n} {unit}{'' if n == 1 else 's'} after it is completed"
    weekdays = tuple(sorted(d for _, d in rule.byday))
    if rule.freq == "WEEKLY" and weekdays == (0, 1, 2, 3, 4) and n == 1:
        return "Every weekday"
    every = f"Every {unit}" if n == 1 else f"Every {n} {unit}s"
    text = every
    if rule.freq == "WEEKLY" and rule.byday:
        text += " on " + ", ".join(DAY_NAMES[d] for d in sorted({d for _, d in rule.byday}))
    elif rule.byday:
        text += " on the " + " and ".join(
            f"{ORDINALS.get(nth, f'{nth}th')} {DAY_NAMES[d]}" if nth else DAY_NAMES[d]
            for nth, d in rule.byday
        )
    elif rule.bymonthday:
        days = ", ".join(
            "the last day" if d == -1 else f"the {_ordinal(d)}" for d in rule.bymonthday
        )
        text += f" on {days}"
    if rule.bymonth:
        months = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ]
        text += " in " + ", ".join(months[m - 1] for m in rule.bymonth)
    if rule.count is not None:
        text += f", {rule.count} time{'' if rule.count == 1 else 's'}"
    if rule.until is not None:
        text += f", until {rule.until.isoformat()}"
    return text


def _ordinal(n: int) -> str:
    if 10 <= n % 100 <= 20:
        return f"{n}th"
    return f"{n}{ {1: 'st', 2: 'nd', 3: 'rd'}.get(n % 10, 'th') }"


def walk(rule: Rule, starts_on: date, *, skip_weekends: bool = False) -> Iterator[date]:
    """Every date of the rule from ``starts_on`` on (for tests and previews of long ranges)."""
    yield from dates(rule, starts_on, skip_weekends=skip_weekends, limit=SCAN_LIMIT)
