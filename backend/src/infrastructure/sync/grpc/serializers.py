"""The messages the sync controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class SyncEntry(serializers.Serializer[dict[str, object]]):
    """One change: ``cursor`` is its log id (a decimal string; keep the highest you have seen),
    ``type`` is ``task.created`` / ``task.updated`` / ``task.deleted`` / ``project.created`` /
    ``project.updated`` / ``workflow.updated`` / ``fields.updated`` / ``access.changed``, or
    ``sync.gap`` (a single entry: the cursor is older than the log, read the screens again) or
    ``sync.more`` (last entry of a full page: ask again from its cursor).
    ``project_id`` is empty for a workspace-level change. Hints only: ids and a version."""

    cursor = serializers.CharField()
    type = serializers.CharField()
    project_id = serializers.CharField()
    entity_id = serializers.CharField()
    version = serializers.IntegerField()
    actor = serializers.CharField()
    at = serializers.CharField()
