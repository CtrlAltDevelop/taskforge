"""The messages the sprint controllers speak. Points are doubles (two decimals at most), dates
are ``YYYY-MM-DD`` in the workspace calendar, times ISO 8601 with offset (empty when unset)."""

from rest_framework import serializers


class Sprint(serializers.Serializer[dict[str, object]]):
    """``state``: planned | active | completed. ``baseline_*`` is the scope when it started;
    ``completed_*`` / ``unfinished_tasks`` its outcome (zero until completed); the rest are live
    counts of the tasks in it now (``open_*``: not done and not cancelled). ``capacity_*`` is what
    the team said it can take on (points, seconds of work), meaningful only when
    ``has_capacity_*``."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    name = serializers.CharField()
    goal = serializers.CharField()
    start_date = serializers.CharField()
    end_date = serializers.CharField()
    state = serializers.CharField()
    started_at = serializers.CharField()
    completed_at = serializers.CharField()
    baseline_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    baseline_tasks = serializers.IntegerField()
    completed_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    completed_tasks = serializers.IntegerField()
    unfinished_tasks = serializers.IntegerField()
    version = serializers.IntegerField()
    task_count = serializers.IntegerField()
    points_total = serializers.DecimalField(max_digits=12, decimal_places=2)
    open_tasks = serializers.IntegerField()
    open_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    done_tasks = serializers.IntegerField()
    done_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    estimate_sec_total = serializers.IntegerField()
    capacity_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    has_capacity_points = serializers.BooleanField()
    capacity_sec = serializers.IntegerField()
    has_capacity_sec = serializers.BooleanField()


class SprintTask(serializers.Serializer[dict[str, object]]):
    """A task as the planning lists need it. ``late``: added after the sprint started."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    key = serializers.CharField()
    title = serializers.CharField()
    status_id = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()
    priority = serializers.CharField()
    points = serializers.DecimalField(max_digits=12, decimal_places=2)
    has_points = serializers.BooleanField()
    estimate_sec = serializers.IntegerField()
    sprint_id = serializers.CharField()
    version = serializers.IntegerField()
    position = serializers.CharField()
    late = serializers.BooleanField()


class BurndownDay(serializers.Serializer[dict[str, object]]):
    """One calendar day. ``ideal_*`` is the straight line from the baseline to zero at the end of
    the last planned day. Actual values are meaningful only when ``has_actual`` (a day still ahead
    has none); ``live``: today, read now, not yet a snapshot; ``backfilled``: a snapshot written
    late (its scope is exact, its remaining count is as of the late run)."""

    date = serializers.CharField()
    ideal_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    ideal_tasks = serializers.DecimalField(max_digits=12, decimal_places=2)
    has_actual = serializers.BooleanField()
    live = serializers.BooleanField()
    backfilled = serializers.BooleanField()
    remaining_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    remaining_tasks = serializers.IntegerField()
    scope_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    scope_tasks = serializers.IntegerField()


class ScopeChange(serializers.Serializer[dict[str, object]]):
    """Net scope added (positive) or removed after the start, on one day: a step in the chart."""

    date = serializers.CharField()
    points = serializers.DecimalField(max_digits=12, decimal_places=2)
    tasks = serializers.IntegerField()


class VelocityItem(serializers.Serializer[dict[str, object]]):
    sprint_id = serializers.CharField()
    name = serializers.CharField()
    start_date = serializers.CharField()
    end_date = serializers.CharField()
    committed_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    completed_points = serializers.DecimalField(max_digits=12, decimal_places=2)
    committed_tasks = serializers.IntegerField()
    completed_tasks = serializers.IntegerField()
