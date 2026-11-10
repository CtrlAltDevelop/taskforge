"""The messages the field controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class FieldOption(serializers.Serializer[dict[str, object]]):
    """A choice of a select field. ``id`` is empty on an option that is new in a save."""

    id = serializers.CharField()
    label = serializers.CharField()
    color = serializers.CharField()


class OptionRemap(serializers.Serializer[dict[str, object]]):
    """What the values of a removed option become: ``to_option`` empty clears them."""

    from_option = serializers.CharField()
    to_option = serializers.CharField()


class Field(serializers.Serializer[dict[str, object]]):
    """A custom field. ``type`` is text, number, select, multiselect, date, checkbox, url, user or
    money; ``default`` is a value in its wire form; ``hidden_views`` the views that do not show it;
    ``archived_at`` is set while it is archived (restorable for 30 days)."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    name = serializers.CharField()
    type = serializers.CharField()
    options = FieldOption(many=True)
    required = serializers.BooleanField()
    default = serializers.CharField()
    hidden_views = serializers.ListField(child=serializers.CharField())
    position = serializers.IntegerField()
    version = serializers.IntegerField()
    archived_at = serializers.CharField()
