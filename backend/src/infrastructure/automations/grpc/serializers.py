"""The messages the automation controllers speak. ``trigger_json`` and ``actions_json`` hold the
rule as ``infrastructure.automations.spec`` defines it; times are ISO 8601, empty when unset."""

from rest_framework import serializers


class Automation(serializers.Serializer[dict[str, object]]):
    """``condition_tfql`` is the condition as text (``condition_json`` its AST); ``disabled_reason``
    is why the system switched the rule off (empty when it did not)."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    name = serializers.CharField()
    enabled = serializers.BooleanField()
    trigger_json = serializers.CharField()
    condition_tfql = serializers.CharField()
    condition_json = serializers.CharField()
    actions_json = serializers.CharField()
    owner_id = serializers.CharField()
    disabled_reason = serializers.CharField()
    version = serializers.IntegerField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()
    last_run_at = serializers.CharField()
    last_run_status = serializers.CharField()


class AutomationRun(serializers.Serializer[dict[str, object]]):
    """``status``: succeeded | failed | skipped_condition | skipped_loop | skipped_rate.
    ``explanation`` is the plain "why didn't this run" answer;
    ``steps_json`` what each action did."""

    id = serializers.CharField()
    automation_id = serializers.CharField()
    automation_name = serializers.CharField()
    task_id = serializers.CharField()
    task_key = serializers.CharField()
    status = serializers.CharField()
    depth = serializers.IntegerField()
    event_key = serializers.CharField()
    input_json = serializers.CharField()
    steps_json = serializers.CharField()
    error = serializers.CharField()
    explanation = serializers.CharField()
    started_at = serializers.CharField()
    finished_at = serializers.CharField()
