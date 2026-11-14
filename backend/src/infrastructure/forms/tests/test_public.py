"""The public form endpoints: what a stranger can learn and cause."""

import json
from typing import Any

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import Client

from infrastructure.common.errors import ApiError
from infrastructure.forms import ratelimit, services, submit
from infrastructure.forms.models import Form, FormSubmission
from infrastructure.projects.tests import conftest as project_fixtures
from infrastructure.tasks.models import Task

make_user = project_fixtures.make_user
add_member = project_fixtures.add_member
_commit_hooks_run_now = project_fixtures._commit_hooks_run_now
team = project_fixtures.team

BASE = "/api/v1/public/forms"
FIELDS = [
    {"id": "t", "kind": "title", "label": "Title"},
    {"id": "d", "kind": "description", "label": "Details"},
    {"id": "f", "kind": "file", "label": "Screenshot", "max_files": 1},
]


@pytest.fixture
def form(team: Any) -> Form:
    project = team.create(team.owner, "WEB")
    view = services.create(team.owner, team.ws, str(project.pk), "Bug", fields=FIELDS)
    return view.form


def _post(token: str, **extra: Any) -> Any:
    data = {"answers": json.dumps({"t": "Broken"}), **extra}
    return Client().post(f"{BASE}/{token}/submit", data)


def test_get_returns_the_definition_only(form: Form) -> None:
    body = Client().get(f"{BASE}/{form.token}").json()["data"]
    assert body["name"] == "Bug"
    assert body["honeypot_field"] == "website"
    leaked = json.dumps(body)
    for secret in (str(form.pk), str(form.project_id), str(form.workspace_id), form.token):
        assert secret not in leaked
    assert "owner" not in body and "token" not in body


def test_disabled_deleted_and_unknown_are_the_same_404(form: Form, team: Any) -> None:
    unknown = Client().get(f"{BASE}/nope")
    Form.objects.filter(pk=form.pk).update(enabled=False)
    disabled = Client().get(f"{BASE}/{form.token}")
    disabled_post = _post(form.token)
    token = form.token
    Form.objects.filter(pk=form.pk).delete()
    deleted = Client().get(f"{BASE}/{token}")
    assert unknown.status_code == disabled.status_code == deleted.status_code == 404
    assert disabled_post.status_code == 404
    assert unknown.json() == disabled.json() == deleted.json()


def test_submit_answers_with_a_reference_and_no_task_id(form: Form) -> None:
    response = _post(form.token)
    assert response.status_code == 201
    body = response.json()["data"]
    assert set(body) == {"reference"} and body["reference"].startswith("F-")
    task = Task.objects.get()
    assert str(task.pk) not in response.content.decode()
    assert FormSubmission.objects.get().reference == body["reference"]


def test_honeypot_is_dropped_silently(form: Form) -> None:
    response = _post(form.token, website="http://spam.example")
    assert response.status_code == 201  # believable
    assert response.json()["data"]["reference"].startswith("F-")
    assert Task.objects.count() == 0
    assert FormSubmission.objects.count() == 0


def test_ip_is_stored_hashed(form: Form) -> None:
    Client().post(
        f"{BASE}/{form.token}/submit",
        {"answers": json.dumps({"t": "Hi"})},
        REMOTE_ADDR="203.0.113.7",
    )
    stored = FormSubmission.objects.get().ip_hash
    assert stored == ratelimit.hash_ip("203.0.113.7")
    assert "203.0.113.7" not in stored and len(stored) == 64


def test_field_validation_is_the_shared_one(form: Form) -> None:
    assert _post(form.token, answers="not json").status_code == 400
    stranger = _post(form.token, answers=json.dumps({"t": "x", "zzz": "y"}))
    assert stranger.status_code == 422
    empty = _post(form.token, answers=json.dumps({"t": "  "}))
    assert empty.status_code == 422
    assert Task.objects.count() == 0


def test_unknown_file_field_and_script_upload_are_refused(form: Form) -> None:
    other = SimpleUploadedFile("a.txt", b"hello")
    assert _post(form.token, nope=other).status_code == 422
    script = SimpleUploadedFile("run.exe", b"MZ\x90\x00")
    assert _post(form.token, f=script).status_code in (400, 422)
    assert Task.objects.count() == 0  # the refused attachment rolled the task back


def test_file_count_and_size_limits(form: Form, settings: Any) -> None:
    two = [SimpleUploadedFile("a.txt", b"a"), SimpleUploadedFile("b.txt", b"b")]
    response = Client().post(
        f"{BASE}/{form.token}/submit", {"answers": json.dumps({"t": "x"}), "f": two}
    )
    assert response.status_code == 422  # the field takes one
    settings.FORMS_MAX_FILE_BYTES = 3
    big = SimpleUploadedFile("big.txt", b"abcdef")
    assert _post(form.token, f=big).status_code == 422
    assert Task.objects.count() == 0


def test_oversized_body_is_refused_before_parsing(form: Form, settings: Any) -> None:
    settings.FORMS_MAX_TOTAL_BYTES = 10
    response = Client().post(
        f"{BASE}/{form.token}/submit",
        {"answers": json.dumps({"t": "x"}), "pad": "x" * (1024 * 1024 + 100)},
    )
    assert response.status_code == 413


def test_submit_service_honeypot_creates_nothing(form: Form) -> None:
    reference = submit.submit(
        form.token,
        answers={"t": "x"},
        email="",
        honeypot="bot",
        captcha_token="",
        files={},
        ip="1.2.3.4",
        locale="en",
    )
    assert reference.startswith("F-") and Task.objects.count() == 0


def test_unknown_token_service_is_generic_404() -> None:
    with pytest.raises(ApiError) as caught:
        submit.live_form("x" * 65)
    assert caught.value.status == 404
