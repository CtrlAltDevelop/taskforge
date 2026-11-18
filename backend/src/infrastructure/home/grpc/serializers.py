"""The messages the Home and Onboarding controllers speak. Times are ISO 8601; dates are
``YYYY-MM-DD``."""

from rest_framework import serializers


class HomeTask(serializers.Serializer[dict[str, object]]):
    """A task as a Home card shows it (``due_date`` is empty when it has none)."""

    task_id = serializers.CharField()
    project_id = serializers.CharField()
    project_key = serializers.CharField()
    number = serializers.IntegerField()
    title = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()
    priority = serializers.CharField()
    due_date = serializers.CharField()


class MyWorkTask(serializers.Serializer[dict[str, object]]):
    task = HomeTask()
    assigned = serializers.BooleanField()
    watching = serializers.BooleanField()


class HomeMention(serializers.Serializer[dict[str, object]]):
    """A mention in the inbox (``payload_json`` is the notification's payload)."""

    id = serializers.CharField()
    type = serializers.CharField()
    task_id = serializers.CharField()
    actor_id = serializers.CharField()
    created_at = serializers.CharField()
    read = serializers.BooleanField()
    payload_json = serializers.CharField()


class HomeDay(serializers.Serializer[dict[str, object]]):
    date = serializers.CharField()
    seconds = serializers.IntegerField()


class HomePin(serializers.Serializer[dict[str, object]]):
    dashboard_id = serializers.CharField()
    name = serializers.CharField()
    project_id = serializers.CharField()


class OnboardingStep(serializers.Serializer[dict[str, object]]):
    step = serializers.CharField()
    done = serializers.BooleanField()


class OnboardingStarter(serializers.Serializer[dict[str, object]]):
    key = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
