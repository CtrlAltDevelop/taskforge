"""The messages the search controller speaks."""

from rest_framework import serializers


class Span(serializers.Serializer[dict[str, object]]):
    """Characters ``start`` up to ``end`` of a string, in UTF-16 units (Dart's and JavaScript's)."""

    start = serializers.IntegerField()
    end = serializers.IntegerField()


class Hit(serializers.Serializer[dict[str, object]]):
    """One result. ``kind`` is task, comment, project or member. ``id`` is that thing's own id;
    ``task_id``, ``project_id`` and ``key`` (``WEB-12`` or the project key) say where it is. For a
    comment ``title`` is its task's title, ``snippet`` its text and ``author`` who wrote it; for a
    person ``snippet`` is the email. ``title_marks`` and ``snippet_marks`` are the matched words."""

    kind = serializers.CharField()
    id = serializers.CharField()
    task_id = serializers.CharField()
    project_id = serializers.CharField()
    key = serializers.CharField()
    title = serializers.CharField()
    title_marks = Span(many=True)
    snippet = serializers.CharField()
    snippet_marks = Span(many=True)
    project_name = serializers.CharField()
    status = serializers.CharField()
    author = serializers.CharField()
    updated_at = serializers.CharField()
