"""The messages the workload controllers speak. Dates are ``YYYY-MM-DD``; load and capacity are
whole seconds; hours per day is text (``"7.5"``). Weekdays are 0 Monday ... 6 Sunday."""

from rest_framework import serializers


class Capacity(serializers.Serializer[dict[str, object]]):
    """``is_set`` is false while nobody chose it: the defaults are shown and used."""

    user_id = serializers.CharField()
    hours_per_day = serializers.CharField()
    working_days = serializers.ListField(child=serializers.IntegerField())
    is_set = serializers.BooleanField()


class TimeOff(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    user_id = serializers.CharField()
    start_date = serializers.CharField()
    end_date = serializers.CharField()
    kind = serializers.CharField()
    note = serializers.CharField()


class Holiday(serializers.Serializer[dict[str, object]]):
    id = serializers.CharField()
    date = serializers.CharField()
    name = serializers.CharField()


class Contribution(serializers.Serializer[dict[str, object]]):
    """One task's share of one person's day; ``warning`` when the task had no working day and
    its whole estimate was put on its due date."""

    task_id = serializers.CharField()
    seconds = serializers.IntegerField()
    warning = serializers.BooleanField()


class DayCell(serializers.Serializer[dict[str, object]]):
    date = serializers.CharField()
    load_sec = serializers.IntegerField()
    capacity_sec = serializers.IntegerField()
    over = serializers.BooleanField()
    contributions = serializers.ListField(child=Contribution())


class OffRange(serializers.Serializer[dict[str, object]]):
    start_date = serializers.CharField()
    end_date = serializers.CharField()
    kind = serializers.CharField()


class PersonLoad(serializers.Serializer[dict[str, object]]):
    user_id = serializers.CharField()
    capacity = Capacity()
    time_off = serializers.ListField(child=OffRange())
    days = serializers.ListField(child=DayCell())
    total_load_sec = serializers.IntegerField()


class AssigneeSeconds(serializers.Serializer[dict[str, object]]):
    user_id = serializers.CharField()
    seconds = serializers.IntegerField()


class LoadTask(serializers.Serializer[dict[str, object]]):
    """A task behind the grid (or one that cannot be placed: ``reason`` is ``no_estimate`` or
    ``no_dates``). ``own`` holds per-person estimates, which replace the equal split."""

    task_id = serializers.CharField()
    project_id = serializers.CharField()
    display_id = serializers.CharField()
    title = serializers.CharField()
    version = serializers.IntegerField()
    start_date = serializers.CharField()
    due_date = serializers.CharField()
    estimate_sec = serializers.IntegerField()
    assignee_ids = serializers.ListField(child=serializers.CharField())
    own = serializers.ListField(child=AssigneeSeconds())
    reason = serializers.CharField()
