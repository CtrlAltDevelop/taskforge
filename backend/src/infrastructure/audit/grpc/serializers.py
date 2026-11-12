"""The messages the audit controllers speak. Times are ISO 8601. ``changes_json`` is
``{field: [before, after]}`` (or ``{field: value}`` where a field has no "before")."""

from rest_framework import serializers

_INT64 = {"min_value": -(2**63), "max_value": 2**63 - 1}  # DSG reads these limits as int64


class AuditEntry(serializers.Serializer[dict[str, object]]):
    id = serializers.IntegerField(**_INT64)
    at = serializers.CharField()
    actor = serializers.CharField()
    actor_name = serializers.CharField()
    actor_type = serializers.CharField()
    action = serializers.CharField()
    target_type = serializers.CharField()
    target_id = serializers.CharField()
    project_id = serializers.CharField()
    batch_id = serializers.CharField()
    ip = serializers.CharField()
    user_agent = serializers.CharField()
    changes_json = serializers.CharField()


class Label(serializers.Serializer[dict[str, object]]):
    """A name for an id that appears in ``changes_json`` (a status, a person, a sprint)."""

    id = serializers.CharField()
    name = serializers.CharField()
