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
