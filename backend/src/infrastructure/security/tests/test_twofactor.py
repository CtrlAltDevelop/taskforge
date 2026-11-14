"""Step-up for two-factor settings: replay, drift window, recovery codes and lockout."""

from types import SimpleNamespace
from typing import Any

import pyotp
import pytest
from django.contrib.auth import get_user_model
from django.test import RequestFactory

from infrastructure.auth.core.errors import AuthError
from infrastructure.auth.twofactor import services as factor_services
from infrastructure.auth.twofactor.models import SecondFactor
from infrastructure.common.responses import ResponseTitle
from infrastructure.security import twofactor

NOW = 1_800_000_000  # a fixed clock, so a code's time step cannot change under the test
STEP = factor_services.TOTP_PERIOD


@pytest.fixture(autouse=True)
def _frozen_clock(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(factor_services, "time", SimpleNamespace(time=lambda: NOW))


@pytest.fixture
def request_() -> Any:
    request = RequestFactory().post("/")
    request.META["REMOTE_ADDR"] = "127.0.0.1"
    return request


@pytest.fixture
def user(db: None) -> Any:
    return get_user_model()._default_manager.create_user(username="zoe", email="zoe@example.com")


@pytest.fixture
def secret(user: Any) -> str:
    _, secret, _ = factor_services.begin_totp(user)
    SecondFactor.objects.get(user=user).confirm()
    return secret


def _code(secret: str, steps_from_now: int = 0) -> str:
    counter = NOW // STEP + steps_from_now
    return pyotp.TOTP(secret, interval=STEP).at(counter * STEP)


def _refused(user: Any, code: str) -> AuthError:
    with pytest.raises(AuthError) as caught:
        twofactor.step_up(user, code)
    return caught.value


def test_a_time_step_cannot_be_used_twice(user: Any, secret: str) -> None:
    code = _code(secret)
    twofactor.step_up(user, code)
    assert _refused(user, code).title == ResponseTitle.INVALID_CODE


def test_an_older_step_is_refused_once_a_newer_one_was_used(user: Any, secret: str) -> None:
    twofactor.step_up(user, _code(secret, 0))
    assert _refused(user, _code(secret, -1)).status == 400  # replay of an earlier step
    twofactor.step_up(user, _code(secret, 1))  # a later one still works


@pytest.mark.parametrize("drift", [-1, 1])
def test_one_step_of_clock_drift_is_accepted(user: Any, secret: str, drift: int) -> None:
    twofactor.step_up(user, _code(secret, drift))


@pytest.mark.parametrize("drift", [-2, 2])
def test_two_steps_of_drift_are_refused(user: Any, secret: str, drift: int) -> None:
    assert _refused(user, _code(secret, drift)).title == ResponseTitle.INVALID_CODE


def test_a_recovery_code_works_once(user: Any, secret: str, request_: Any) -> None:
    codes = factor_services.twofactor_service.generate_recovery_codes(request_, user)
    twofactor.step_up(user, codes[0])
    assert _refused(user, codes[0]).title == ResponseTitle.INVALID_CODE
    twofactor.step_up(user, codes[1].lower())  # case and dashes do not matter
    assert twofactor.status(user).unused_recovery_codes == len(codes) - 2


def test_regenerating_invalidates_the_old_codes(user: Any, secret: str, request_: Any) -> None:
    old = factor_services.twofactor_service.generate_recovery_codes(request_, user)
    new = twofactor.regenerate_codes(request_, user, _code(secret))
    assert len(new) == len(old) and not set(new) & set(old)
    assert _refused(user, old[0]).title == ResponseTitle.INVALID_CODE
    assert twofactor.status(user).unused_recovery_codes == len(new)
    twofactor.step_up(user, new[0])


def test_regenerating_needs_a_valid_code(user: Any, secret: str, request_: Any) -> None:
    old = factor_services.twofactor_service.generate_recovery_codes(request_, user)
    with pytest.raises(AuthError):
        twofactor.regenerate_codes(request_, user, "000000")
    assert twofactor.status(user).unused_recovery_codes == len(old)  # untouched


def test_repeated_failures_lock_the_account_even_for_a_right_code(
    user: Any, secret: str, settings: Any
) -> None:
    settings.SECURITY_MFA_MAX_FAILURES = 3
    for _ in range(3):
        assert _refused(user, "000000").title == ResponseTitle.INVALID_CODE
    locked = _refused(user, _code(secret))
    assert locked.status == 429
    assert locked.title == ResponseTitle.SECOND_FACTOR_LOCKED


def test_a_success_clears_the_failure_count(user: Any, secret: str, settings: Any) -> None:
    settings.SECURITY_MFA_MAX_FAILURES = 3
    for _ in range(2):
        _refused(user, "000000")
    twofactor.step_up(user, _code(secret))
    for _ in range(2):  # a fresh budget: two more misses do not lock
        _refused(user, "000000")
    twofactor.step_up(user, _code(secret, 1))


def test_lockout_is_per_account(user: Any, secret: str, settings: Any) -> None:
    settings.SECURITY_MFA_MAX_FAILURES = 1
    _refused(user, "000000")
    assert _refused(user, "000000").status == 429
    other = get_user_model()._default_manager.create_user(username="al", email="al@example.com")
    assert _refused(other, "000000").title == ResponseTitle.SECOND_FACTOR_NOT_SET_UP
