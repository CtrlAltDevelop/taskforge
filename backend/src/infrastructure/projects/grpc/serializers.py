"""The messages the project controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class Feature(serializers.Serializer[dict[str, object]]):
    """One switch of a project and whether it is on."""

    key = serializers.CharField()
    enabled = serializers.BooleanField()


class FeatureInfo(serializers.Serializer[dict[str, object]]):
    """What a feature key means: the label and one line for the Features page."""

    key = serializers.CharField()
    label = serializers.CharField()
    description = serializers.CharField()


class Project(serializers.Serializer[dict[str, object]]):
    """A project as the caller sees it. In ``ListPrivate`` a project the caller cannot open
    (``can_open`` false) carries only identity, look, visibility, ``member_count``."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    name = serializers.CharField()
    key = serializers.CharField()
    description = serializers.CharField()
    icon = serializers.CharField()
    color = serializers.CharField()
    visibility = serializers.CharField()
    archived_at = serializers.CharField()
    version = serializers.IntegerField()
    task_counter = serializers.IntegerField()
    features = Feature(many=True)
    is_favorite = serializers.BooleanField()
    member_count = serializers.IntegerField()
    is_member = serializers.BooleanField()
    can_open = serializers.BooleanField()
    created_by = serializers.CharField()


class ProjectMember(serializers.Serializer[dict[str, object]]):
    """One active workspace member who belongs to a private project."""

    user_id = serializers.CharField()
    display_name = serializers.CharField()
    email = serializers.CharField()
    added_at = serializers.CharField()
