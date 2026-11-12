"""The messages the import and export controllers speak. JSON strings carry the open-ended parts
(mapping, analysis, counts); times are ISO 8601, empty when unset."""

from rest_framework import serializers


class Job(serializers.Serializer[dict[str, object]]):
    """An import. ``status``: uploaded analyzed queued running done failed cancelled undone.
    ``phase``: tasks | links while it runs. ``stats_json`` is what was made, ``problem_count`` how
    many rows or warnings the error report holds (read them with ``Get``)."""

    id = serializers.CharField()
    source = serializers.CharField()
    status = serializers.CharField()
    filename = serializers.CharField()
    project_id = serializers.CharField()
    total = serializers.IntegerField()
    done = serializers.IntegerField()
    phase = serializers.CharField()
    error = serializers.CharField()
    stats_json = serializers.CharField()
    problem_count = serializers.IntegerField()
    created_at = serializers.CharField()
    started_at = serializers.CharField()
    finished_at = serializers.CharField()
    version = serializers.IntegerField()


class Problem(serializers.Serializer[dict[str, object]]):
    line = serializers.IntegerField()
    message = serializers.CharField()
    level = serializers.CharField()


class Placeholder(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    name = serializers.CharField()
    email = serializers.CharField()
    tasks = serializers.IntegerField()


class ExportJob(serializers.Serializer[dict[str, object]]):
    """``status``: queued running done failed expired. ``download_path`` (done only) is a signed,
    short-lived path on the REST host; fetch it without a bearer token."""

    id = serializers.CharField()
    scope = serializers.CharField()
    project_id = serializers.CharField()
    status = serializers.CharField()
    filename = serializers.CharField()
    size = serializers.IntegerField()
    stats_json = serializers.CharField()
    error = serializers.CharField()
    download_path = serializers.CharField()
    created_at = serializers.CharField()
