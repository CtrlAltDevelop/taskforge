"""Rules, intake, imports, developer tools and security of the demo (everything not in core).

Order matters: rules fire with the engine run inline; webhooks come last so no later change
queues a real delivery. Fills ``ctx.extra`` with ``automations``, ``forms`` and ``totp``.
"""

from django.test.utils import override_settings

from infrastructure.common.demo import extras_data, extras_dev, extras_rules
from infrastructure.common.demo.base import Ctx


def seed(ctx: Ctx) -> None:
    with override_settings(AUTOMATIONS_SYNC_RUN=True):
        extras_rules.create_automations(ctx)
        extras_rules.create_forms(ctx)
        extras_rules.create_templates(ctx)
        extras_data.create_imports(ctx)
    extras_data.create_personal(ctx)
    extras_dev.create_tokens(ctx)
    extras_dev.create_security(ctx)
    extras_dev.create_webhooks(ctx)
