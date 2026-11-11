"""The messages the docs controller speaks. Times are ISO 8601; ``blocks_json`` is the page body
as JSON text (schema version in ``schema_version``)."""

from rest_framework import serializers


class DocNode(serializers.Serializer[dict[str, object]]):
    """A page in the tree (no body). ``project_id`` is empty for a workspace page."""

    id = serializers.CharField()
    workspace_id = serializers.CharField()
    project_id = serializers.CharField()
    parent_id = serializers.CharField()
    title = serializers.CharField()
    icon = serializers.CharField()
    position = serializers.IntegerField()
    restricted = serializers.BooleanField()
    archived = serializers.BooleanField()
    created_by = serializers.CharField()
    created_at = serializers.CharField()
    updated_at = serializers.CharField()


class Editor(serializers.Serializer[dict[str, object]]):
    """Someone on the page now; ``editing`` false means only viewing."""

    user_id = serializers.CharField()
    editing = serializers.BooleanField()


class TaskCard(serializers.Serializer[dict[str, object]]):
    """A task card as the caller sees it. ``hidden``: they may not open the task (nothing else is
    filled in); the card stays in the body so saving never drops it."""

    task_id = serializers.CharField()
    hidden = serializers.BooleanField()
    project_id = serializers.CharField()
    key = serializers.CharField()
    title = serializers.CharField()
    status_name = serializers.CharField()
    status_category = serializers.CharField()
    priority = serializers.CharField()


class RevisionInfo(serializers.Serializer[dict[str, object]]):
    id = serializers.IntegerField()
    version = serializers.IntegerField()
    title = serializers.CharField()
    author_id = serializers.CharField()
    at = serializers.CharField()
    saved_at = serializers.CharField()


class RelatedDoc(serializers.Serializer[dict[str, object]]):
    """A page related to a task: ``kind`` is ``embedded`` (a task card in it) or ``related``
    (linked by hand)."""

    doc = DocNode()
    kind = serializers.CharField()
