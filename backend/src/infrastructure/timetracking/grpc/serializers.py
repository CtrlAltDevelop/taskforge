"""The messages the time controller speaks."""

from rest_framework import serializers


class Entry(serializers.Serializer[dict[str, object]]):
    """One time entry. ``duration_sec`` counts a running entry up to the server's now. Times are
    ISO 8601 with offset; ``ended_at`` is empty while it runs. ``flags``: ``running``, ``long``
    (over 24 h, for review) and ``overlap`` (another entry of the person covers part of it)."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    task_id = serializers.CharField()
    project_id = serializers.CharField()
    key = serializers.CharField()
    title = serializers.CharField()
    user_id = serializers.CharField()
    user_name = serializers.CharField()
    started_at = serializers.CharField()
    ended_at = serializers.CharField()
    duration_sec = serializers.IntegerField()
    note = serializers.CharField()
    billable = serializers.BooleanField()
    source = serializers.CharField()
    flags = serializers.ListField(child=serializers.CharField())


class SheetRow(serializers.Serializer[dict[str, object]]):
    """One task of a timesheet: seconds for each of the seven days, in order."""

    task_id = serializers.CharField()
    project_id = serializers.CharField()
    key = serializers.CharField()
    title = serializers.CharField()
    seconds = serializers.ListField(child=serializers.IntegerField())
    total = serializers.IntegerField()
    billable = serializers.IntegerField()


class PersonTotal(serializers.Serializer[dict[str, object]]):
    user_id = serializers.CharField()
    name = serializers.CharField()
    seconds = serializers.IntegerField()
    billable = serializers.IntegerField()
