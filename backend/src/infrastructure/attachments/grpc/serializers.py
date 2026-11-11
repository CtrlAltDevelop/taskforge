"""The messages the attachment controller speaks. Named for the message, not the class."""

from rest_framework import serializers

_INT64 = {"min_value": -(2**63), "max_value": 2**63 - 1}  # DSG reads these limits as int64


def _bytes() -> serializers.IntegerField:
    return serializers.IntegerField(**_INT64)


class Attachment(serializers.Serializer[dict[str, object]]):
    """A file on a task. ``comment_id`` is empty unless it was added to a comment. ``mime`` is
    what the content is, not what the uploader said. ``has_thumb`` says ``GET /api/files/{id}/link
    ?thumb=1`` has something to show. ``created_at`` is ISO 8601."""

    id = serializers.CharField()
    task_id = serializers.CharField()
    comment_id = serializers.CharField()
    uploader_id = serializers.CharField()
    filename = serializers.CharField()
    mime = serializers.CharField()
    size = _bytes()
    has_thumb = serializers.BooleanField()
    created_at = serializers.CharField()


class StorageUsage(serializers.Serializer[dict[str, object]]):
    """What a workspace stores. ``quota_bytes`` is 0 when there is no limit."""

    used_bytes = _bytes()
    quota_bytes = _bytes()
    file_count = serializers.IntegerField()
    max_file_bytes = _bytes()
