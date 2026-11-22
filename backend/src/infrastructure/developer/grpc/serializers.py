"""The messages the developer controllers speak. Times are ISO 8601, empty when unset."""

from rest_framework import serializers


class ApiToken(serializers.Serializer[dict[str, object]]):
    """``prefix`` identifies the token in lists; the secret is only ever in ``ApiTokenCreated``.
    ``status``: active | expired | revoked. ``service_account_id`` is set for a service account's
    token."""

    id = serializers.CharField()
    name = serializers.CharField()
    prefix = serializers.CharField()
    scopes = serializers.ListField(child=serializers.CharField())
    status = serializers.CharField()
    expires_at = serializers.CharField()
    last_used_at = serializers.CharField()
    revoked_at = serializers.CharField()
    created_at = serializers.CharField()
    service_account_id = serializers.CharField()  # empty for a person's own token


class ServiceAccount(serializers.Serializer[dict[str, object]]):
    """A workspace-owned identity for scripts. ``user_id`` is the member row it acts as (it shows
    in the member list), ``role_id`` / ``role_name`` what its tokens may do at most. ``active`` is
    false when someone removed it from the members."""

    id = serializers.CharField()
    name = serializers.CharField()
    user_id = serializers.CharField()
    role_id = serializers.CharField()
    role_name = serializers.CharField()
    active = serializers.BooleanField()
    token_count = serializers.IntegerField()
    created_at = serializers.CharField()


class Webhook(serializers.Serializer[dict[str, object]]):
    """``secret`` signs the payloads (see ``signing``); ``disabled_reason`` is why the system
    switched the webhook off (empty when it did not)."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    name = serializers.CharField()
    url = serializers.CharField()
    secret = serializers.CharField()
    events = serializers.ListField(child=serializers.CharField())
    active = serializers.BooleanField()
    disabled_reason = serializers.CharField()
    version = serializers.IntegerField()
    created_at = serializers.CharField()
    last_status = serializers.CharField()
    last_at = serializers.CharField()


class Delivery(serializers.Serializer[dict[str, object]]):
    """``status``: pending | delivered | failed | gave_up. ``payload_json`` is the request body
    as sent, ``request_headers_json`` its headers."""

    id = serializers.CharField()
    webhook_id = serializers.CharField()
    event = serializers.CharField()
    event_id = serializers.CharField()
    status = serializers.CharField()
    status_code = serializers.IntegerField()
    attempt = serializers.IntegerField()
    error = serializers.CharField()
    response_snippet = serializers.CharField()
    payload_json = serializers.CharField()
    request_headers_json = serializers.CharField()
    next_retry_at = serializers.CharField()
    created_at = serializers.CharField()
    at = serializers.CharField()
    duration_ms = serializers.IntegerField()
    resend_of = serializers.CharField()


class CatalogItem(serializers.Serializer[dict[str, object]]):
    key = serializers.CharField()
    label = serializers.CharField()
