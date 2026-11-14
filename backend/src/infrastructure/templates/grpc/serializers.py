"""The messages the template controller speaks. Times are ISO 8601, empty when unset."""

from rest_framework import serializers


class Template(serializers.Serializer[dict[str, object]]):
    """``kind``: task | project. ``visibility``: workspace | private. Built-in templates have
    ``builtin`` set and an id starting ``builtin:``. ``content_json`` is the snapshot (tasks with
    day offsets, workflow, fields, ...); the gallery list leaves it empty and ``Get`` fills it.
    ``variables`` are the ``{{names}}`` to ask for when applying; ``includes`` names what a
    project template holds (workflow, fields, automations, features, tasks)."""

    id = serializers.CharField()
    kind = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
    visibility = serializers.CharField()
    builtin = serializers.BooleanField()
    created_by = serializers.CharField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()
    version = serializers.IntegerField()
    task_count = serializers.IntegerField()
    variables = serializers.ListField(child=serializers.CharField())
    includes = serializers.ListField(child=serializers.CharField())
    status_names = serializers.ListField(child=serializers.CharField())
    can_edit = serializers.BooleanField()
    content_json = serializers.CharField()


class Variable(serializers.Serializer[dict[str, object]]):
    name = serializers.CharField()
    value = serializers.CharField()


class Warning(serializers.Serializer[dict[str, object]]):
    """Something in the template that no longer fits and was skipped."""

    code = serializers.CharField()
    message = serializers.CharField()
