"""The messages the inbox controllers speak. Named for the message, not the class."""

from rest_framework import serializers


class Notification(serializers.Serializer[dict[str, object]]):
    """One notification. ``payload`` is JSON with what the screen needs (``title`` and ``key`` of
    the task, ``from``/``to`` of a change, the first lines of a comment). ``count`` is how many
    events were folded into it. Times are ISO 8601, empty when not set."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    type = serializers.CharField()
    task_id = serializers.CharField()
    project_id = serializers.CharField()
    actor_id = serializers.CharField()
    actor_name = serializers.CharField()
    payload = serializers.CharField()
    count = serializers.IntegerField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()
    read_at = serializers.CharField()
    snoozed_until = serializers.CharField()
    archived_at = serializers.CharField()


class PrefRow(serializers.Serializer[dict[str, object]]):
    """What one kind of event does for the caller. ``email_mode``: off, instant or digest."""

    event_type = serializers.CharField()
    label = serializers.CharField()
    inbox = serializers.BooleanField()
    push = serializers.BooleanField()
    email_mode = serializers.CharField()


class InboxSettings(serializers.Serializer[dict[str, object]]):
    """``quiet_start``/``quiet_end`` are ``HH:MM`` in ``timezone`` (both empty: no quiet hours);
    ``digest_hour`` is the local hour (0-23) the daily digest goes out."""

    timezone = serializers.CharField()
    quiet_start = serializers.CharField()
    quiet_end = serializers.CharField()
    digest_hour = serializers.IntegerField()


class WatchState(serializers.Serializer[dict[str, object]]):
    """Whether the caller watches a task, and how many people do."""

    watching = serializers.BooleanField()
    watcher_count = serializers.IntegerField()
