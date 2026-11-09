"""The nested workspace message shared by List and the mutating calls."""

from rest_framework import serializers


class Workspace(serializers.Serializer[dict[str, object]]):
    """One workspace as the caller sees it. Named for the message, not the class."""

    id = serializers.CharField()
    name = serializers.CharField()
    slug = serializers.CharField()
    logo = serializers.CharField()
    created_by = serializers.CharField()
    created_at = serializers.CharField()
    deleted_at = serializers.CharField()
    version = serializers.IntegerField()
    is_owner = serializers.BooleanField()


class Member(serializers.Serializer[dict[str, object]]):
    """One active member of a workspace."""

    user_id = serializers.CharField()
    display_name = serializers.CharField()
    email = serializers.CharField()
    joined_at = serializers.CharField()
    is_owner = serializers.BooleanField()
    status = serializers.CharField()


class Invitation(serializers.Serializer[dict[str, object]]):
    """One invitation. ``token`` is set only on Create and Resend, never on List."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    email = serializers.CharField()
    is_link = serializers.BooleanField()
    created_by = serializers.CharField()
    created_by_name = serializers.CharField()
    created_at = serializers.CharField()
    expires_at = serializers.CharField()
    max_uses = serializers.IntegerField()
    uses = serializers.IntegerField()
    state = serializers.CharField()
    token = serializers.CharField()
