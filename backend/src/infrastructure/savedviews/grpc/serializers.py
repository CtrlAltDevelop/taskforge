"""The messages the view controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class LayoutSort(serializers.Serializer[dict[str, object]]):
    """One sort key of a layout: a task column or ``field:<id>``, and the direction."""

    key = serializers.CharField()
    desc = serializers.BooleanField()


class LayoutWidth(serializers.Serializer[dict[str, object]]):
    """The width in pixels of a column (``title`` or one of the layout's columns)."""

    column = serializers.CharField()
    width = serializers.IntegerField()


class Layout(serializers.Serializer[dict[str, object]]):
    """What a list view shows: ``columns`` besides the always-present title (``status``,
    ``assignee``, ``priority``, ``start_date``, ``due_date``, ``created_at``, ``updated_at`` or
    ``field:<custom field id>``) in order, their ``widths``, the ``sort`` (at most three keys) and
    ``group_by`` (``status``, ``assignee``, ``priority``, ``field:<select field id>`` or empty)."""

    columns = serializers.ListField(child=serializers.CharField())
    widths = LayoutWidth(many=True)
    sort = LayoutSort(many=True)
    group_by = serializers.CharField()


class BoardLimit(serializers.Serializer[dict[str, object]]):
    """The work-in-progress limit of one column, named by its key (``""``: the column of tasks
    with no value)."""

    column = serializers.CharField()
    limit = serializers.IntegerField()


class BoardLayout(serializers.Serializer[dict[str, object]]):
    """What a board shows: the field its columns come from (``group_by``: ``status``,
    ``priority``, ``assignee`` or ``field:<select field id>``), an optional ``swimlane``
    (``assignee`` or empty), the ``card_fields`` on a card besides its title and id
    (``assignee``, ``due_date``, ``priority``, ``progress`` or ``field:<id>``) and the column
    ``limits``."""

    group_by = serializers.CharField()
    swimlane = serializers.CharField()
    card_fields = serializers.ListField(child=serializers.CharField())
    limits = BoardLimit(many=True)


class SavedView(serializers.Serializer[dict[str, object]]):
    """A saved layout. ``owner_id`` is empty for a shared one (``is_shared``); ``version`` is the
    optimistic lock to send back when saving it again."""

    id = serializers.CharField()
    project_id = serializers.CharField()
    owner_id = serializers.CharField()
    name = serializers.CharField()
    kind = serializers.CharField()
    is_shared = serializers.BooleanField()
    layout = Layout()
    board = BoardLayout()  # set instead of ``layout`` for a ``board`` view
    version = serializers.IntegerField()
    updated_at = serializers.CharField()
