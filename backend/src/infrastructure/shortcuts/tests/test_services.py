"""Chord rules and the per-person overrides."""

import pytest
from django.contrib.auth import get_user_model

from infrastructure.common.errors import ApiError
from infrastructure.common.responses import ResponseTitle
from infrastructure.shortcuts import keys, services


@pytest.fixture
def zoe(db: None) -> object:
    return get_user_model().objects.create_user("zoe", "zoe@x.test", "pw-123456-x")


@pytest.fixture
def max_(db: None) -> object:
    return get_user_model().objects.create_user("max", "max@x.test", "pw-123456-x")


@pytest.mark.parametrize(
    ("raw", "chord"),
    [
        ("Shift+Mod+K", "mod+shift+k"),
        (" ctrl+alt+Enter ", "ctrl+alt+enter"),
    ],
)
def test_normalise_orders_modifiers(raw: str, chord: str) -> None:
    assert keys.normalise(raw) == chord


def test_empty_chord_is_unbound() -> None:
    assert keys.normalise("  ") == ""


@pytest.mark.parametrize(
    "raw", ["mod+", "mod+mod+k", "mod+ctrl+k", "hyper+k", "mod+t", "mod+shift+n", "kk", "f13"]
)
def test_bad_chords_refused(raw: str) -> None:
    with pytest.raises(ApiError) as refusal:
        keys.normalise(raw)
    assert refusal.value.title == ResponseTitle.SHORTCUT_INVALID


def test_bind_get_rebind_reset(zoe: object) -> None:
    services.set_binding(zoe, "task.create", "Mod+Shift+C")
    assert [(s.action_id, s.keys) for s in services.get(zoe)] == [("task.create", "mod+shift+c")]
    services.set_binding(zoe, "task.create", "alt+c")
    assert [s.keys for s in services.get(zoe)] == ["alt+c"]
    services.set_binding(zoe, "task.create", "", reset=True)
    assert services.get(zoe) == []


def test_unbind_keeps_an_empty_override(zoe: object) -> None:
    services.set_binding(zoe, "task.create", "")
    assert [(s.action_id, s.keys) for s in services.get(zoe)] == [("task.create", "")]


def test_conflict_names_the_other_action(zoe: object) -> None:
    services.set_binding(zoe, "task.create", "alt+c")
    with pytest.raises(ApiError) as refusal:
        services.set_binding(zoe, "project.create", "ALT+C")
    assert refusal.value.title == ResponseTitle.SHORTCUT_CONFLICT
    assert refusal.value.data == {"action_id": "task.create"}


def test_rebinding_the_same_action_to_its_own_chord_is_fine(zoe: object) -> None:
    services.set_binding(zoe, "task.create", "alt+c")
    services.set_binding(zoe, "task.create", "alt+c")


def test_bindings_are_personal(zoe: object, max_: object) -> None:
    services.set_binding(zoe, "task.create", "alt+c")
    services.set_binding(max_, "project.create", "alt+c")  # same chord, other person: no clash
    assert [s.action_id for s in services.get(max_)] == ["project.create"]
    services.set_binding(max_, "task.create", "", reset=True)  # cannot touch zoe's
    assert [s.action_id for s in services.get(zoe)] == ["task.create"]


@pytest.mark.parametrize("action_id", ["", "Task.Create", "1task", "a b", "x" * 81])
def test_bad_action_id_refused(zoe: object, action_id: str) -> None:
    with pytest.raises(ApiError):
        services.set_binding(zoe, action_id, "alt+c")


def test_limit(zoe: object, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(services, "MAX_BINDINGS", 1)
    services.set_binding(zoe, "a.one", "alt+1")
    services.set_binding(zoe, "a.one", "alt+2")  # replacing is not adding
    with pytest.raises(ApiError):
        services.set_binding(zoe, "a.two", "alt+3")


def test_a_change_tells_only_that_persons_devices(
    zoe: object,
    monkeypatch: pytest.MonkeyPatch,
    django_capture_on_commit_callbacks: object,
) -> None:
    sent: list[tuple[str, dict[str, object]]] = []

    class Recorder:
        def publish(self, channel: str, payload: dict[str, object]) -> None:
            sent.append((channel, payload))

    monkeypatch.setattr("infrastructure.sync.publish.get_broker", lambda: Recorder())

    with django_capture_on_commit_callbacks(execute=True):  # type: ignore[operator]
        services.set_binding(zoe, "nav.inbox", "alt+j")
        services.set_binding(zoe, "nav.inbox", "", reset=True)

    assert [p["event"]["type"] for _, p in sent] == ["shortcuts.changed"] * 2  # type: ignore[index]
    assert {p["room"] for _, p in sent} == {f"user:{zoe.pk}"}  # type: ignore[attr-defined]
    assert all(p["event"]["entity_id"] == str(zoe.pk) for _, p in sent)  # type: ignore[index,attr-defined]


def test_a_refused_change_tells_nobody(
    zoe: object, monkeypatch: pytest.MonkeyPatch, django_capture_on_commit_callbacks: object
) -> None:
    sent: list[object] = []
    monkeypatch.setattr(
        "infrastructure.sync.publish.get_broker",
        lambda: type("B", (), {"publish": lambda self, c, p: sent.append(p)})(),
    )
    with (
        django_capture_on_commit_callbacks(execute=True),  # type: ignore[operator]
        pytest.raises(ApiError),
    ):
        services.set_binding(zoe, "nav.inbox", "mod+t")
    assert sent == []
