"""The messages the task controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class Task(serializers.Serializer[dict[str, object]]):
    """A task. ``parent_id`` is the task it is a subtask of (``""`` at the top) and ``depth`` how
    far down it is; ``progress_done`` of ``progress_total`` count everything under it (live
    subtasks at any depth, and the ones in a done status). ``status`` is the id of one of the
    project's statuses (see the workflow);
    ``status_name`` and ``status_category`` are copies for display and reports.
    ``description`` is the rich-text JSON document as a string (``""`` when empty);
    dates are ``YYYY-MM-DD`` or ``""``; ``deleted_at`` is set only in the trash."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    number = serializers.IntegerField()
    display_id = serializers.CharField()
    title = serializers.CharField()
    description = serializers.CharField()
    status = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()
    priority = serializers.CharField()
    start_date = serializers.CharField()
    due_date = serializers.CharField()
    assignee_ids = serializers.ListField(child=serializers.CharField())
    parent_id = serializers.CharField()
    depth = serializers.IntegerField()
    progress_done = serializers.IntegerField()
    progress_total = serializers.IntegerField()
    created_by = serializers.CharField()
    version = serializers.IntegerField()
    position = serializers.CharField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()
    deleted_at = serializers.CharField()
