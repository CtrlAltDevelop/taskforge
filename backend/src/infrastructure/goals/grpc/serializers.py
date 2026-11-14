"""The messages the goal controllers speak. Decimals travel as text (``"12.5"``) so no client
rounds them; progress is a double from 0 to 1; dates are ``YYYY-MM-DD``; times are ISO 8601."""

from rest_framework import serializers


class KeyResult(serializers.Serializer[dict[str, object]]):
    """``type``: number | percentage | boolean | linked. For a linked one ``linked_done`` of
    ``linked_total`` tasks are done; ``task_ids`` are the hand-picked ones and ``filter_text`` a
    TFQL filter over the workspace (both count). ``current_value`` is the last check-in."""

    id = serializers.CharField()
    goal_id = serializers.CharField()
    name = serializers.CharField()
    type = serializers.CharField()
    start_value = serializers.CharField()
    target_value = serializers.CharField()
    current_value = serializers.CharField()
    filter_text = serializers.CharField()
    task_ids = serializers.ListField(child=serializers.CharField())
    weight = serializers.CharField()
    linked_done = serializers.IntegerField()
    linked_total = serializers.IntegerField()
    progress = serializers.FloatField()
    position = serializers.IntegerField()
    version = serializers.IntegerField()


class Goal(serializers.Serializer[dict[str, object]]):
    """``status`` is what to show: ``status_override`` when set, else ``status_hint`` (computed
    from progress against the elapsed share of the period). ``progress`` rolls up child goals."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    parent_id = serializers.CharField()
    folder_id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
    owner_id = serializers.CharField()
    private = serializers.BooleanField()
    period_start = serializers.CharField()
    period_end = serializers.CharField()
    status_override = serializers.CharField()
    status = serializers.CharField()
    status_hint = serializers.CharField()
    weight = serializers.CharField()
    progress = serializers.FloatField()
    version = serializers.IntegerField()
    can_edit = serializers.BooleanField()
    can_check_in = serializers.BooleanField()
    contributor_ids = serializers.ListField(child=serializers.CharField())
    child_ids = serializers.ListField(child=serializers.CharField())
    key_results = KeyResult(many=True)
    created_at = serializers.CharField()


class Folder(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    name = serializers.CharField()
    position = serializers.IntegerField()


class CheckIn(serializers.Serializer[dict[str, object]]):
    """``user_id`` is empty for a reading the system took when linked tasks changed."""

    id = serializers.CharField()
    kr_id = serializers.CharField()
    user_id = serializers.CharField()
    value = serializers.CharField()
    previous_value = serializers.CharField()
    progress = serializers.FloatField()
    note = serializers.CharField()
    at = serializers.CharField()


class Contribution(serializers.Serializer[dict[str, object]]):
    goal_id = serializers.CharField()
    goal_name = serializers.CharField()
    kr_id = serializers.CharField()
    kr_name = serializers.CharField()
