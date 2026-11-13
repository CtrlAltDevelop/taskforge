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
    default_locale = serializers.CharField()


class Member(serializers.Serializer[dict[str, object]]):
    """One active member of a workspace. ``is_owner`` means the role is Owner."""

    user_id = serializers.CharField()
    display_name = serializers.CharField()
    email = serializers.CharField()
    joined_at = serializers.CharField()
    is_owner = serializers.BooleanField()
    status = serializers.CharField()
    role_id = serializers.CharField()
    role_name = serializers.CharField()


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
    role_id = serializers.CharField()  # "" = Member
    role_name = serializers.CharField()


class Role(serializers.Serializer[dict[str, object]]):
    """A built-in or custom role with its permission keys and active member count."""

    id = serializers.CharField()
    name = serializers.CharField()
    is_builtin = serializers.BooleanField()
    permissions = serializers.ListField(child=serializers.CharField())
    member_count = serializers.IntegerField()
    version = serializers.IntegerField()


class PermissionInfo(serializers.Serializer[dict[str, object]]):
    """One key of the permission registry."""

    key = serializers.CharField()
    label = serializers.CharField()


class PermissionArea(serializers.Serializer[dict[str, object]]):
    """Registry keys grouped by area (the rows of the matrix screen)."""

    area = serializers.CharField()
    permissions = PermissionInfo(many=True)


class PermissionAnswer(serializers.Serializer[dict[str, object]]):
    """Whether the caller holds one key."""

    key = serializers.CharField()
    allowed = serializers.BooleanField()
