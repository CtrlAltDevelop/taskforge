"""The messages the security controllers speak. Times are ISO-8601 text; ids are text."""

from rest_framework import serializers


class TrustedDevice(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    label = serializers.CharField()
    created_at = serializers.CharField()
    last_used_at = serializers.CharField()
    expires_at = serializers.CharField()


class RoleMapping(serializers.Serializer[dict[str, object]]):
    """A value of the group claim and the id of the role it grants."""

    group = serializers.CharField()
    role_id = serializers.CharField()


class Provider(serializers.Serializer[dict[str, object]]):
    """The saved identity provider. The client secret is never sent back: ``has_secret``."""

    configured = serializers.BooleanField()
    name = serializers.CharField()
    issuer = serializers.CharField()
    client_id = serializers.CharField()
    has_secret = serializers.BooleanField()
    scopes = serializers.CharField()
    allowed_domains = serializers.ListField(child=serializers.CharField())
    group_claim = serializers.CharField()
    group_roles = serializers.ListField(child=RoleMapping())
    default_role_id = serializers.CharField()
    auto_create_users = serializers.BooleanField()
    enabled = serializers.BooleanField()
    enforce_sso = serializers.BooleanField()
    version = serializers.IntegerField()
    redirect_uri = serializers.CharField()
