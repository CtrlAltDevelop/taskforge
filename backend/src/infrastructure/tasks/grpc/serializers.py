"""The messages the task controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class TaskFieldValue(serializers.Serializer[dict[str, object]]):
    """A custom field's value on a task, in its wire form (see ``infrastructure.customfields``);
    only fields that have a value are listed. As input, ``value`` empty clears the field."""

    field_id = serializers.CharField()
    value = serializers.CharField()


class SortKey(serializers.Serializer[dict[str, object]]):
    """One key of a list's order: ``title``, ``status`` (workflow order), ``priority`` (urgent
    first), ``start_date``, ``due_date``, ``created_at``, ``updated_at``, ``number`` or
    ``field:<custom field id>``. Empty values come last in both directions."""

    key = serializers.CharField()
    desc = serializers.BooleanField()


class Task(serializers.Serializer[dict[str, object]]):
    """A task. ``parent_id`` is the task it is a subtask of (``""`` at the top) and ``depth`` how
    far down it is; ``progress_done`` of ``progress_total`` count everything under it (live
    subtasks at any depth, and the ones in a done status). ``status`` is the id of one of the
    project's statuses (see the workflow);
    ``status_name`` and ``status_category`` are copies for display and reports.
    ``description`` is the rich-text JSON document as a string (``""`` when empty);
    dates are ``YYYY-MM-DD`` or ``""``; ``deleted_at`` is set only in the trash. ``is_blocked`` says
    a blocker is still open; ``blocked_by`` names them as the caller may see them
    (``WEB-4 (In progress)``, or ``Restricted task``). ``fields`` are the task's custom field
    values. ``group_key`` is set only on a task of a grouped list: the group it falls under (see
    ``GroupCount``)."""

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
    is_blocked = serializers.BooleanField()
    blocked_by = serializers.ListField(child=serializers.CharField())
    fields = TaskFieldValue(many=True)
    group_key = serializers.CharField()


class Link(serializers.Serializer[dict[str, object]]):
    """One link of a task, seen from that task. ``kind`` is ``blocks``, ``blocked_by``,
    ``relates``, ``duplicates`` or ``duplicated_by``. When the caller cannot open the other task
    ``restricted`` is true and every ``other_*`` field is empty (a title or id never leaks)."""

    id = serializers.CharField()
    kind = serializers.CharField()
    restricted = serializers.BooleanField()
    other_id = serializers.CharField()
    other_project_id = serializers.CharField()
    other_display_id = serializers.CharField()
    other_title = serializers.CharField()
    other_status_name = serializers.CharField()
    other_status_category = serializers.CharField()


class LinkCandidate(serializers.Serializer[dict[str, object]]):
    """A task the caller may link to: enough to recognise it in a picker."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    display_id = serializers.CharField()
    title = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()


class GroupCount(serializers.Serializer[dict[str, object]]):
    """How many tasks one group of a grouped list holds. ``key`` names the group: a status id, a
    priority, a user id (the task's first assignee) or a select option id; empty is the group of
    tasks that have none."""

    key = serializers.CharField()
    count = serializers.IntegerField()


class BulkResult(serializers.Serializer[dict[str, object]]):
    """What a bulk edit did to one task. ``ok`` with the task as it is now (a deleted task, for a
    delete), or ``code`` (the refusal's title, ``NOT_FOUND`` for a task that is gone or not in the
    project), ``message`` and ``detail`` (the refusal's JSON detail, ``""`` if none)."""

    id = serializers.CharField()
    ok = serializers.BooleanField()
    code = serializers.CharField()
    message = serializers.CharField()
    detail = serializers.CharField()
    task = Task()


class BoardColumn(serializers.Serializer[dict[str, object]]):
    """One column of a board: ``key`` is what its cards hold (a status id, a priority, a user id,
    an option id; empty: tasks with no value), ``name`` is empty for people (the client names
    them), ``count`` all its cards, ``tasks`` the first of them and ``cursor`` where
    ``ListColumn`` goes on (empty: that was all of them)."""

    key = serializers.CharField()
    name = serializers.CharField()
    count = serializers.IntegerField()
    tasks = Task(many=True)
    cursor = serializers.CharField()


class BoardLane(serializers.Serializer[dict[str, object]]):
    """A row of the board (the assignee ``key`` with swimlanes, empty for the only row without)."""

    key = serializers.CharField()
    columns = BoardColumn(many=True)
