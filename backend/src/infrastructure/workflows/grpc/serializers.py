"""The messages the workflow controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class Status(serializers.Serializer[dict[str, object]]):
    """A status as saved. ``task_count`` counts every task in it (trashed ones too), which is how
    many a delete would have to move."""

    id = serializers.CharField()
    name = serializers.CharField()
    color = serializers.CharField()
    category = serializers.CharField()
    position = serializers.IntegerField()
    is_default = serializers.BooleanField()
    task_count = serializers.IntegerField()


class Transition(serializers.Serializer[dict[str, object]]):
    """An allowed move. ``required_role_id`` empty means any role."""

    from_status = serializers.CharField()
    to_status = serializers.CharField()
    required_role_id = serializers.CharField()
    require_assignee = serializers.BooleanField()
    require_subtasks_done = serializers.BooleanField()


class Workflow(serializers.Serializer[dict[str, object]]):
    project_id = serializers.CharField()
    restrict_transitions = serializers.BooleanField()
    restrict_creation = serializers.BooleanField()
    version = serializers.IntegerField()
    statuses = Status(many=True)
    transitions = Transition(many=True)


class StatusInput(serializers.Serializer[dict[str, object]]):
    """A status in a save, in display order. ``key`` is the id of an existing status, or any text
    the client invents for a new one (transitions and migrations refer to statuses by ``key``)."""

    key = serializers.CharField()
    name = serializers.CharField()
    color = serializers.CharField()
    category = serializers.CharField()
    is_default = serializers.BooleanField()


class TransitionInput(serializers.Serializer[dict[str, object]]):
    from_key = serializers.CharField()
    to_key = serializers.CharField()
    required_role_id = serializers.CharField()
    require_assignee = serializers.BooleanField()
    require_subtasks_done = serializers.BooleanField()


class MigrationInput(serializers.Serializer[dict[str, object]]):
    """Where the tasks of a deleted status go: ``from_key`` is the deleted status id,
    ``to_key`` a status that stays (or a new one)."""

    from_key = serializers.CharField()
    to_key = serializers.CharField()


class WorkflowProblem(serializers.Serializer[dict[str, object]]):
    """One thing wrong with a draft; ``code`` is stable, ``status_key`` empty for the whole."""

    code = serializers.CharField()
    message = serializers.CharField()
    status_key = serializers.CharField()
