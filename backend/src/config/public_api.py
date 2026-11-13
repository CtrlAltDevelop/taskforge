"""The anonymous API at ``/api/public/``: intake forms. Kept out of the versioned API so a layer
that demands credentials can exempt the whole prefix (see ``infrastructure.common.public_routes``).
"""

from ninja import NinjaAPI

from infrastructure.common.errors import register_error_handlers
from infrastructure.common.responses import EnvelopeAPI, EnvelopeRenderer
from infrastructure.common.throttling import default_throttles
from infrastructure.forms.rest.public import build_router


def build_public_api() -> NinjaAPI:
    api = EnvelopeAPI(
        title="Public API",
        version="1.0.0",
        urls_namespace="api-public",
        throttle=default_throttles(),
        docs_url=None,
        renderer=EnvelopeRenderer(),
    )
    api.add_router("/forms", build_router(), tags=["Public forms"])
    register_error_handlers(api)
    return api


public_api = build_public_api()
