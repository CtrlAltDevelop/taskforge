"""The extras seed builds every area it promises on top of the core seed."""

from typing import Any

import pytest

from infrastructure.automations.models import Automation, AutomationRun, RunStatus
from infrastructure.common.demo import core, extras
from infrastructure.common.demo.base import Ctx
from infrastructure.developer.models import ApiToken, Webhook, WebhookDelivery
from infrastructure.forms.models import Form, FormSubmission
from infrastructure.imports.models import ExportJob, ImportJob
from infrastructure.security.models import SecurityPolicy, TrustedDevice
from infrastructure.shortcuts.models import UserShortcut
from infrastructure.templates.models import Template

pytestmark = pytest.mark.django_db(transaction=True)


@pytest.fixture
def seeded(settings: Any, tmp_path: Any) -> Ctx:
    settings.DEBUG = True
    settings.MEDIA_ROOT = str(tmp_path)
    ctx = Ctx()
    core.seed(ctx)
    extras.seed(ctx)
    return ctx


def test_automations_have_succeeded_failed_and_skipped_runs(seeded: Ctx) -> None:
    statuses = set(AutomationRun.objects.values_list("status", flat=True))
    assert {RunStatus.SUCCEEDED, RunStatus.FAILED, RunStatus.SKIPPED_CONDITION} <= statuses
    assert Automation.objects.count() == 7
    assert Automation.objects.filter(enabled=False).count() == 1


def test_forms_have_submissions(seeded: Ctx) -> None:
    assert Form.objects.count() == 3 and Form.objects.filter(enabled=False).count() == 1
    assert FormSubmission.objects.count() == 5


def test_templates_tokens_and_webhooks(seeded: Ctx) -> None:
    assert Template.objects.filter(workspace=seeded.ws).count() == 4
    assert ApiToken.objects.filter(revoked_at__isnull=False).count() == 1
    assert ApiToken.objects.count() >= 5
    assert Webhook.objects.filter(active=False).count() == 1
    assert {"delivered", "failed", "gave_up"} <= set(
        WebhookDelivery.objects.values_list("status", flat=True)
    )


def test_security_imports_and_personal_settings(seeded: Ctx) -> None:
    assert seeded.extra["totp"]["recovery_codes"]
    assert SecurityPolicy.objects.filter(require_2fa=True).count() == 1
    assert TrustedDevice.objects.filter(revoked_at__isnull=False).count() == 1
    statuses = set(ImportJob.objects.values_list("status", flat=True))
    assert {"done", "failed", "analyzed"} <= statuses
    assert ExportJob.objects.count() == 1
    assert UserShortcut.objects.count() >= 4
