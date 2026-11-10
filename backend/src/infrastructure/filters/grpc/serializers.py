"""The messages the query and filter controllers speak. Named for the message, not the class."""

from rest_framework import serializers


class QueryProblem(serializers.Serializer[dict[str, object]]):
    """Where a query is wrong: the character ``position`` and ``length`` of the culprit."""

    position = serializers.IntegerField()
    length = serializers.IntegerField()
    message = serializers.CharField()


class QuerySuggestion(serializers.Serializer[dict[str, object]]):
    """Something that could be typed next. ``text`` replaces the query from ``start`` to the
    cursor; ``kind`` is ``field``, ``operator``, ``value`` or ``keyword``; ``label`` is a hint."""

    text = serializers.CharField()
    kind = serializers.CharField()
    start = serializers.IntegerField()
    label = serializers.CharField()


class Filter(serializers.Serializer[dict[str, object]]):
    """A saved filter. ``ast_json`` is what a task call takes as ``filter_ast``; ``tfql`` is the
    same filter as text, rendered with today's names (empty if a field it used is gone).
    ``visibility`` is ``private``, ``project`` or ``workspace``; ``project_id`` is empty for a
    filter that is not tied to a project."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    owner_id = serializers.CharField()
    name = serializers.CharField()
    visibility = serializers.CharField()
    ast_json = serializers.CharField()
    tfql = serializers.CharField()
    version = serializers.IntegerField()
    updated_at = serializers.CharField()
