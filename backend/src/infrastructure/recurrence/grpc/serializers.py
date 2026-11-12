"""The messages the recurrence controller speaks. Dates are ``YYYY-MM-DD``, moments ISO 8601 (UTC);
empty when unset."""

from rest_framework import serializers


class Series(serializers.Serializer[dict[str, object]]):
    """A task's repeat rule. ``summary`` is the rule in words; ``next_dates`` the next few the
    clock will make (schedule mode); ``index`` the number of the task asked about (0: the first)
    and ``is_template`` whether it is the task the next instances are copied from. ``pause_reason``
    is why the system paused it (empty when a person did, or it is running)."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    task_id = serializers.CharField()
    rrule = serializers.CharField()
    mode = serializers.CharField()
    timezone = serializers.CharField()
    at_time = serializers.CharField()
    lead_days = serializers.IntegerField()
    starts_on = serializers.CharField()
    ends_on = serializers.CharField()
    skip_weekends = serializers.BooleanField()
    paused = serializers.BooleanField()
    pause_reason = serializers.CharField()
    summary = serializers.CharField()
    next_due_on = serializers.CharField()
    next_run_at = serializers.CharField()
    next_dates = serializers.ListField(child=serializers.CharField())
    instance_count = serializers.IntegerField()
    index = serializers.IntegerField()
    is_template = serializers.BooleanField()
    template_missing = serializers.BooleanField()
    owner_id = serializers.CharField()
    version = serializers.IntegerField()


class Ghost(serializers.Serializer[dict[str, object]]):
    """An instance the clock has not made yet: show it on the calendar, faded."""

    series_id = serializers.CharField()
    project_id = serializers.CharField()
    title = serializers.CharField()
    due_date = serializers.CharField()
