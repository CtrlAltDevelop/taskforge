"""TFQL against a project: names to ids, the AST, the text it renders back, and what it finds."""

from datetime import UTC, date, datetime
from typing import Any

import pytest

from infrastructure.customfields import services as fields
from infrastructure.filters import compile as compiler
from infrastructure.filters import language
from infrastructure.filters.language import Catalogue, QueryError
from infrastructure.tasks import links, services
from infrastructure.tasks.models import Task
from infrastructure.workflows import services as workflows
from infrastructure.workflows.models import Status

pytestmark = pytest.mark.django_db

TODAY = date(2026, 11, 10)


def _make(team: Any, project: Any, title: str, **kw: Any) -> Any:
    return services.create(team.owner, team.ws, str(project.pk), title, **kw)


def _ast(project: Any, text: str) -> dict[str, Any]:
    return language.parse_text(text, Catalogue(project))


def _find(team: Any, project: Any, text: str, who: Any = None) -> list[str]:
    cat = Catalogue(project)
    ast = language.parse_text(text, cat)
    rows = Task.objects.filter(project=project, deleted_at__isnull=True).filter(
        compiler.where(ast, cat, TODAY, who or team.member)
    )
    order = compiler.order(ast, cat)
    if not order:
        return sorted(t.title for t in rows)
    found = {t.title for t in rows}
    page, _ = services.list_page(team.member, team.ws, str(project.pk), sort=order, limit=500)
    return [t.title for t in page if t.title in found]


@pytest.fixture
def ids(project: Any) -> dict[str, str]:
    workflows.ensure(project)
    return {s.name: str(s.pk) for s in Status.objects.filter(project=project)}


# ------------------------------------------------------------------------------ resolving


def test_names_become_ids_and_back_again(team: Any, project: Any, ids: dict[str, str]) -> None:
    cat = Catalogue(project)
    ast = language.parse_text('status in ("In progress", done) AND assignee = me', cat)

    where = ast["where"]
    assert where["op"] == "and"
    assert where["args"][0]["values"] == [
        {"k": "id", "v": ids["In progress"]},
        {"k": "id", "v": ids["Done"]},
    ]
    assert where["args"][1]["values"] == [{"k": "me"}]
    assert language.render(ast, cat) == 'status IN ("In progress", Done) AND assignee = me'


def test_a_rename_keeps_a_saved_filter_working(team: Any, project: Any) -> None:
    field = fields.create(team.owner, team.ws, str(project.pk), name="Points", type="number")
    ast = _ast(project, '"Points" > 3')

    fields.update(
        team.owner, team.ws, str(project.pk), str(field.pk), field.version, {"name": "Effort"}
    )
    cat = Catalogue(project)

    assert language.canonical(ast, cat) == ast
    assert language.render(ast, cat) == '"Effort" > 3'
    with pytest.raises(QueryError):
        language.parse_text('"Points" > 3', cat)


@pytest.mark.parametrize(
    ("text", "position"),
    [
        ("nope = 1", 0),
        ("status = Nowhere", 9),
        ("priority = huge", 11),
        ("assignee = nobody", 11),
        ("due < nextweek", 6),
        ("due < 2026-02-30", 6),
        ("due < 5", 6),
        ("blocked = maybe", 10),
        ("id = WEB", 5),
        ('id = "OTHER-1"', 5),
        ("sprint = 1", 9),
        ("status ~ Active", 0),
        ("priority is empty", 0),
        ("blocked < true", 0),
        ("created is empty", 0),
        ("title < 3", 0),
        ("ORDER BY assignee", 9),
        ("ORDER BY nope", 9),
        ("ORDER BY blocked", 9),
    ],
)
def test_a_name_or_value_that_means_nothing_points_at_it(
    project: Any, ids: dict[str, str], text: str, position: int
) -> None:
    with pytest.raises(QueryError) as caught:
        _ast(project, text)

    assert caught.value.position == position


def test_custom_fields_resolve_by_name_and_by_option(team: Any, project: Any) -> None:
    pid = str(project.pk)
    sel = fields.create(
        team.owner,
        team.ws,
        pid,
        name="Env",
        type="select",
        options=[{"label": "dev"}, {"label": "prod"}],
    )
    fields.create(team.owner, team.ws, pid, name="Story points", type="number")
    fields.create(team.owner, team.ws, pid, name="Done?", type="checkbox")

    ast = _ast(project, 'env = prod AND "story points" >= 3 AND "Done?" = true')

    assert ast["where"]["args"][0]["field"] == f"cf:{sel.pk}"
    assert ast["where"]["args"][0]["values"] == [{"k": "id", "v": sel.options[1]["id"]}]
    with pytest.raises(QueryError):
        _ast(project, "env = staging")
    with pytest.raises(QueryError):
        _ast(project, "env > prod")


def test_nested_groups_of_one_kind_flatten(project: Any) -> None:
    flat = _ast(project, "priority = high AND (priority = low AND priority = none)")

    assert flat["where"]["op"] == "and" and len(flat["where"]["args"]) == 3


# --------------------------------------------------------------------------- round trips

ROUND_TRIPS = [
    "",
    "status = Done",
    "status != Done",
    'status IN ("In progress", Done)',
    "status NOT IN (Done)",
    "category = done",
    "category in (active, not_started)",
    "priority = high",
    "priority NOT IN (low, none)",
    "assignee = me",
    "assignee != me",
    "assignee IS EMPTY",
    "assignee IS NOT EMPTY",
    "due < +7d",
    "due <= -2w",
    "due > today",
    "due = 2026-11-05",
    "due >= +3m",
    "due < -1y",
    "due IS EMPTY",
    "start IS NOT EMPTY",
    "created >= -30d",
    "updated < today",
    'title ~ "fix"',
    'title !~ "wip"',
    'title = "exact title"',
    'title = "she said \\"hi\\" \\\\ bye"',
    'title = "x\' OR 1=1; DROP TABLE tasks; --"',
    "blocked = true",
    "blocked = false",
    "id = 12",
    "id IN (1, 2, 3)",
    "sprint = currentSprint()",
    "sprint != currentSprint()",
    "priority = high AND status = Done",
    "priority = high OR status = Done",
    "(priority = high OR status = Done) AND assignee = me",
    "priority = high AND (status = Done OR assignee = me)",
    "NOT priority = high",
    "NOT (priority = high OR status = Done)",
    "NOT (priority = high AND NOT status = Done)",
    "priority = high ORDER BY due",
    "ORDER BY priority DESC, due, title DESC",
    "ORDER BY created DESC, id",
    "due < +7d AND status != Done AND assignee = me ORDER BY priority DESC",
]


@pytest.mark.parametrize("text", ROUND_TRIPS)
def test_text_to_ast_to_text_is_lossless(project: Any, ids: dict[str, str], text: str) -> None:
    cat = Catalogue(project)
    ast = language.parse_text(text, cat)

    rendered = language.render(ast, cat)

    assert language.parse_text(rendered, cat) == ast
    assert language.render(language.parse_text(rendered, cat), cat) == rendered
    assert language.canonical(ast, cat) == ast


def test_every_custom_field_operator_round_trips(team: Any, project: Any) -> None:
    pid = str(project.pk)
    specs: list[tuple[str, str, dict[str, Any]]] = [
        ("Note", "text", {}),
        ("Pts", "number", {}),
        ("Due2", "date", {}),
        ("Flag", "checkbox", {}),
        ("Env", "select", {"options": [{"label": "dev"}, {"label": "prod x"}]}),
        ("Tags", "multiselect", {"options": [{"label": "a"}, {"label": "b"}]}),
        ("Owner", "user", {}),
    ]
    for name, kind, extra in specs:
        fields.create(team.owner, team.ws, pid, name=name, type=kind, **extra)
    cat = Catalogue(project)
    texts = [
        '"Note" ~ "x"',
        '"Note" = "y"',
        '"Note" IN ("a", "b")',
        '"Note" IS EMPTY',
        '"Pts" > 2',
        '"Pts" <= 2.5',
        '"Pts" != 3',
        '"Pts" IS NOT EMPTY',
        '"Due2" < +7d',
        '"Due2" = 2026-12-01',
        '"Due2" IS EMPTY',
        '"Flag" = true',
        '"Flag" != true',
        '"Env" = dev',
        '"Env" IN (dev, "prod x")',
        '"Env" NOT IN (dev)',
        '"Env" IS EMPTY',
        '"Tags" = a',
        '"Tags" IN (a, b)',
        '"Tags" != a',
        '"Tags" IS NOT EMPTY',
        '"Owner" = me',
        '"Owner" IS EMPTY',
        'ORDER BY "Pts" DESC, "Env"',
    ]

    for text in texts:
        ast = language.parse_text(text, cat)
        assert language.parse_text(language.render(ast, cat), cat) == ast, text


# --------------------------------------------------------------------------- client ASTs


@pytest.mark.parametrize(
    "bad",
    [
        None,
        [],
        "status = Done",
        {"where": "x"},
        {"where": {"op": "boom"}},
        {"where": {"op": "cmp"}},
        {"where": {"op": "cmp", "field": "nope", "cmp": "eq", "values": []}},
        {"where": {"op": "cmp", "field": "status", "cmp": "eq", "values": [{"k": "id", "v": "x"}]}},
        {"where": {"op": "cmp", "field": "title", "cmp": "eq", "values": [{"k": "zzz", "v": 1}]}},
        {
            "where": {
                "op": "cmp",
                "field": "due",
                "cmp": "lt",
                "values": [{"k": "rel", "n": 1, "u": "x"}],
            }
        },
        {"where": {"op": "cmp", "field": "title", "cmp": "eq", "values": []}},
        {"where": {"op": "and", "args": "x"}},
        {"where": {"op": "not"}},
        {"where": None, "order": [{"field": "assignee"}]},
        {"where": None, "order": 5},
    ],
)
def test_a_client_ast_that_does_not_hold_up_is_refused(project: Any, bad: Any) -> None:
    with pytest.raises(QueryError):
        language.canonical(bad, Catalogue(project))


def test_an_id_from_another_project_is_not_a_value(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    workflows.ensure(other)
    foreign = str(Status.objects.filter(project=other).first().pk)
    ast = {
        "where": {
            "op": "cmp",
            "field": "status",
            "cmp": "eq",
            "values": [{"k": "id", "v": foreign}],
        },
        "order": [],
    }

    with pytest.raises(QueryError):
        language.canonical(ast, Catalogue(project))


# ---------------------------------------------------------------------------- what it finds


def test_status_priority_and_category(team: Any, project: Any, ids: dict[str, str]) -> None:
    _make(team, project, "a", priority="high")
    _make(team, project, "b", priority="low", status=ids["In progress"])
    _make(team, project, "c", status=ids["Done"])

    assert _find(team, project, "priority = high") == ["a"]
    assert _find(team, project, "priority in (high, low)") == ["a", "b"]
    assert _find(team, project, "priority != high") == ["b", "c"]
    assert _find(team, project, 'status = "In progress"') == ["b"]
    assert _find(team, project, "status != Done") == ["a", "b"]
    assert _find(team, project, "category = done") == ["c"]
    assert _find(team, project, "category in (not_started, active)") == ["a", "b"]
    assert _find(team, project, "NOT status = Done AND priority != low") == ["a"]


def test_text_matches_ignoring_case_and_never_as_sql(team: Any, project: Any) -> None:
    _make(team, project, "Fix the Login")
    _make(team, project, 'x" OR 1=1 --')
    _make(team, project, "'; DROP TABLE tasks; --")
    _make(team, project, "100% sure_thing")

    assert _find(team, project, 'title ~ "login"') == ["Fix the Login"]
    assert _find(team, project, 'title = "fix THE login"') == ["Fix the Login"]
    assert _find(team, project, 'title = "x\\" OR 1=1 --"') == ['x" OR 1=1 --']
    assert _find(team, project, 'title ~ "\'; DROP"') == ["'; DROP TABLE tasks; --"]
    assert _find(team, project, 'title ~ "100%"') == ["100% sure_thing"]
    assert _find(team, project, 'title !~ "--"') == ["100% sure_thing", "Fix the Login"]
    assert Task.objects.filter(project=project).count() == 4  # nothing was run


def test_assignee_me_and_empty(team: Any, project: Any) -> None:
    _make(team, project, "mine", assignee_ids=[str(team.member.pk)])
    _make(team, project, "theirs", assignee_ids=[str(team.admin.pk)])
    _make(team, project, "nobody")
    username = team.member.username

    assert _find(team, project, "assignee = me") == ["mine"]
    assert _find(team, project, "assignee != me") == ["nobody", "theirs"]
    assert _find(team, project, "assignee IS EMPTY") == ["nobody"]
    assert _find(team, project, f"assignee = {username}", who=team.owner) == ["mine"]
    assert _find(team, project, "assignee = me", who=team.admin) == ["theirs"]


def test_dates_absolute_relative_and_empty(team: Any, project: Any) -> None:
    _make(team, project, "overdue", due_date="2026-11-01")
    _make(team, project, "today", due_date="2026-11-10")
    _make(team, project, "soon", due_date="2026-11-14")
    _make(team, project, "later", due_date="2027-02-01")
    _make(team, project, "undated")

    assert _find(team, project, "due < today") == ["overdue"]
    assert _find(team, project, "due <= today") == ["overdue", "today"]
    assert _find(team, project, "due >= today AND due <= +7d") == ["soon", "today"]
    assert _find(team, project, "due > +1m") == ["later"]
    assert _find(team, project, "due = 2026-11-14") == ["soon"]
    assert _find(team, project, "due != 2026-11-14") == ["later", "overdue", "today", "undated"]
    assert _find(team, project, "due IS EMPTY") == ["undated"]
    assert _find(team, project, "due IS NOT EMPTY AND due < -1w") == ["overdue"]


def test_relative_months_clamp_to_the_end_of_the_month() -> None:
    assert compiler._shift(date(2026, 1, 31), 1, "m") == date(2026, 2, 28)
    assert compiler._shift(date(2024, 2, 29), 1, "y") == date(2025, 2, 28)
    assert compiler._shift(date(2026, 12, 15), 2, "m") == date(2027, 2, 15)
    assert compiler._shift(date(2026, 3, 1), -1, "m") == date(2026, 2, 1)
    assert compiler._shift(date(2026, 11, 10), -2, "w") == date(2026, 10, 27)


def test_created_compares_by_day(team: Any, project: Any) -> None:
    _make(team, project, "now")
    today = datetime.now(UTC).date().isoformat()  # the filter compares UTC days

    assert _find(team, project, f"created = {today}") == ["now"]
    assert _find(team, project, "created < 2000-01-01") == []
    assert _find(team, project, "updated >= 2000-01-01") == ["now"]


def test_blocked_id_and_sprint(team: Any, project: Any) -> None:
    blocker = _make(team, project, "blocker")
    blocked = _make(team, project, "blocked")
    links.add(team.owner, team.ws, str(blocker.pk), str(blocked.pk), "blocks")

    assert _find(team, project, "blocked = true") == ["blocked"]
    assert _find(team, project, "blocked = false") == ["blocker"]
    assert _find(team, project, f"id = {blocker.number}") == ["blocker"]
    both = f'id in ("WEB-{blocked.number}", {blocker.number})'
    assert _find(team, project, both) == ["blocked", "blocker"]
    assert _find(team, project, "sprint = currentSprint()") == []  # no active sprint here
    assert _find(team, project, "sprint != currentSprint()") == ["blocked", "blocker"]


def test_custom_fields_find_by_value(team: Any, project: Any) -> None:
    pid = str(project.pk)
    points = fields.create(team.owner, team.ws, pid, name="Points", type="number")
    env = fields.create(
        team.owner, team.ws, pid, name="Env", type="select",
        options=[{"label": "dev"}, {"label": "prod"}],
    )  # fmt: skip
    tags = fields.create(
        team.owner, team.ws, pid, name="Tags", type="multiselect",
        options=[{"label": "a"}, {"label": "b"}],
    )  # fmt: skip
    note = fields.create(team.owner, team.ws, pid, name="Note", type="text")
    flag = fields.create(team.owner, team.ws, pid, name="Flag", type="checkbox")
    when = fields.create(team.owner, team.ws, pid, name="When", type="date")
    dev, prod = (o["id"] for o in env.options)
    a, b = (o["id"] for o in tags.options)
    _make(team, project, "one", field_values={
        str(points.pk): "3", str(env.pk): dev, str(tags.pk): f"{a},{b}",
        str(note.pk): "Hello World", str(flag.pk): "true", str(when.pk): "2026-11-12",
    })  # fmt: skip
    _make(team, project, "two", field_values={
        str(points.pk): "8", str(env.pk): prod, str(tags.pk): b,
        str(flag.pk): "false", str(when.pk): "2026-12-20",
    })  # fmt: skip
    _make(team, project, "three")

    assert _find(team, project, '"Points" > 3') == ["two"]
    assert _find(team, project, '"Points" >= 3') == ["one", "two"]
    assert _find(team, project, '"Points" != 3') == ["three", "two"]
    assert _find(team, project, '"Points" IS EMPTY') == ["three"]
    assert _find(team, project, "env = dev") == ["one"]
    assert _find(team, project, "env in (dev, prod)") == ["one", "two"]
    assert _find(team, project, "env not in (dev)") == ["three", "two"]
    assert _find(team, project, "env IS EMPTY") == ["three"]
    assert _find(team, project, "tags = a") == ["one"]
    assert _find(team, project, "tags in (a, b)") == ["one", "two"]
    assert _find(team, project, "tags != a") == ["three", "two"]
    assert _find(team, project, "tags IS NOT EMPTY") == ["one", "two"]
    assert _find(team, project, 'note ~ "hello"') == ["one"]
    assert _find(team, project, 'note = "hello world"') == ["one"]
    assert _find(team, project, "note IS EMPTY") == ["three", "two"]
    assert _find(team, project, "flag = true") == ["one"]
    assert _find(team, project, "flag = false") == ["three", "two"]  # untouched boxes are unticked
    assert _find(team, project, "when < 2026-12-01") == ["one"]
    assert _find(team, project, "when >= 2026-11-10 AND when <= +10d") == ["one"]
    assert _find(team, project, "when IS EMPTY") == ["three"]
    assert _find(team, project, '"Points" > 3 OR env = dev') == ["one", "two"]
    assert _find(team, project, "NOT (env = dev OR env = prod)") == ["three"]


def test_order_by_names_the_sort(team: Any, project: Any) -> None:
    _make(team, project, "low", priority="low", due_date="2026-11-20")
    _make(team, project, "urgent", priority="urgent", due_date="2026-11-25")
    _make(team, project, "high", priority="high", due_date="2026-11-20")

    assert _find(team, project, "ORDER BY priority") == ["urgent", "high", "low"]
    assert _find(team, project, "ORDER BY priority DESC") == ["low", "high", "urgent"]
    assert _find(team, project, "ORDER BY due, priority") == ["high", "low", "urgent"]
    ordered = compiler.order(_ast(project, "ORDER BY due DESC, id"), Catalogue(project))
    assert ordered == [("due_date", True), ("number", False)]


def test_a_condition_cannot_reach_other_projects(team: Any, project: Any) -> None:
    other = team.create(team.owner, "API", name="Api")
    _make(team, project, "mine")
    services.create(team.owner, team.ws, str(other.pk), "theirs")

    assert _find(team, project, 'title ~ ""') == ["mine"]


# ----------------------------------------------------------------------------- the property


def _random_query(rng: Any, depth: int = 0) -> str:
    """A random valid query from pieces of the grammar."""
    atoms = [
        "priority = high",
        "priority != low",
        "priority in (high, low)",
        "priority not in (none)",
        'status = "In progress"',
        'status in (Done, "To do")',
        "category = active",
        "assignee = me",
        "assignee is empty",
        "assignee is not empty",
        'title ~ "a \\"b\\" c"',
        'title !~ "x\\\\y"',
        "title = plain",
        "due < +7d",
        "due >= -2w",
        "due = today",
        "due > 2026-11-05",
        "due is empty",
        "start <= +1m",
        "created > -1y",
        "updated < today",
        "blocked = true",
        "blocked = false",
        "id in (1, 2, 3)",
        "sprint = currentSprint()",
    ]
    if depth >= 3 or rng.random() < 0.45:
        return rng.choice(atoms)
    kind = rng.choice(["and", "or", "not", "paren"])
    if kind == "not":
        return f"NOT ({_random_query(rng, depth + 1)})"
    if kind == "paren":
        return f"({_random_query(rng, depth + 1)})"
    parts = [_random_query(rng, depth + 1) for _ in range(rng.randint(2, 4))]
    return f" {kind.upper()} ".join(parts)


def test_any_valid_query_survives_text_ast_text_ast(project: Any, ids: dict[str, str]) -> None:
    import random

    rng = random.Random(14)
    cat = Catalogue(project)
    orders = ["", " ORDER BY priority", " ORDER BY due DESC, title", " ORDER BY created, id DESC"]
    for _ in range(400):
        text = _random_query(rng) + rng.choice(orders)

        ast = language.parse_text(text, cat)
        rendered = language.render(ast, cat)
        again = language.parse_text(rendered, cat)

        assert again == ast, text
        assert language.render(again, cat) == rendered, text
        assert language.canonical(ast, cat) == ast, text


def test_relative_dates_have_a_reasonable_reach(project: Any) -> None:
    for text in (
        "due < +99999999d",
        "due < -40000d",
        "due < +101y",
        "due < +1201m",
        "due < +5201w",
    ):
        with pytest.raises(QueryError):
            _ast(project, text)
    _ast(project, "due < +36500d AND due > -100y")
    huge = {
        "where": {
            "op": "cmp",
            "field": "due",
            "cmp": "lt",
            "values": [{"k": "rel", "n": 10**12, "u": "d"}],
        },
        "order": [],
    }
    with pytest.raises(QueryError):
        language.canonical(huge, Catalogue(project))


def test_shifting_past_the_ends_of_the_calendar_stops_there() -> None:
    assert compiler._shift(date(9999, 12, 31), 5, "d") == date.max
    assert compiler._shift(date(9999, 6, 1), 3, "y") == date.max
    assert compiler._shift(date(1, 1, 5), -9, "d") == date.min


def test_order_by_is_limited_like_a_list_sort(project: Any) -> None:
    _ast(project, "ORDER BY due, title, priority")
    with pytest.raises(QueryError) as many:
        _ast(project, "ORDER BY due, title, priority, id")
    with pytest.raises(QueryError) as twice:
        _ast(project, "ORDER BY due, due DESC")

    assert many.value.position == 31 and twice.value.position == 14


def test_a_deeply_nested_ast_is_refused_not_crashed(project: Any) -> None:
    node: dict[str, Any] = {
        "op": "cmp", "field": "priority", "cmp": "eq", "values": [{"k": "id", "v": "high"}]
    }  # fmt: skip
    for _ in range(3000):
        node = {"op": "not", "arg": node}

    with pytest.raises(QueryError):
        language.canonical({"where": node, "order": []}, Catalogue(project))
