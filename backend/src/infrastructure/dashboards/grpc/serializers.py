"""The messages the dashboard controllers speak. Numbers travel as decimal text (``"12.50"``) so
no client rounds them; times are ISO 8601."""

from rest_framework import serializers


class Widget(serializers.Serializer[dict[str, object]]):
    """``config_json`` is the widget's config as ``dashboards.config.normalise`` returns it."""

    id = serializers.CharField()
    type = serializers.CharField()
    title = serializers.CharField()
    config_json = serializers.CharField()
    version = serializers.IntegerField()


class Dashboard(serializers.Serializer[dict[str, object]]):
    """``layout_json`` is ``[{widget_id, x, y, w, h}]`` on a 12-column grid; ``can_edit`` says
    whether the caller may save or delete it."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    owner_id = serializers.CharField()
    name = serializers.CharField()
    visibility = serializers.CharField()
    layout_json = serializers.CharField()
    version = serializers.IntegerField()
    can_edit = serializers.BooleanField()
    widgets = Widget(many=True)
    updated_at = serializers.CharField()


class WidgetInput(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    type = serializers.CharField()
    title = serializers.CharField()
    config_json = serializers.CharField()


class Bucket(serializers.Serializer[dict[str, object]]):
    key = serializers.CharField()
    label = serializers.CharField()
    value = serializers.CharField()


class Point(serializers.Serializer[dict[str, object]]):
    x = serializers.CharField()
    y = serializers.CharField()


class Series(serializers.Serializer[dict[str, object]]):
    name = serializers.CharField()
    points = Point(many=True)


class DrillTask(serializers.Serializer[dict[str, object]]):
    """A task behind a number: enough for a list row and to open it."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    display_id = serializers.CharField()
    title = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()
    priority = serializers.CharField()
    due_date = serializers.CharField()
    points = serializers.CharField()
    assignee_ids = serializers.ListField(child=serializers.CharField())
