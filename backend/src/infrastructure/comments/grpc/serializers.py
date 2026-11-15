"""The messages the comment controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class Reaction(serializers.Serializer[dict[str, object]]):
    """One emoji and everyone who gave it (user ids, oldest first)."""

    emoji = serializers.CharField()
    user_ids = serializers.ListField(child=serializers.CharField())


class Comment(serializers.Serializer[dict[str, object]]):
    """A comment. ``body`` is the rich-text document as JSON (empty once removed: ``deleted``).
    ``parent_id`` is empty for a top-level comment; replies go one level deep. ``mention_ids`` are
    the people the current version mentions. ``edit_count`` is how many earlier bodies exist
    (see ``History``); ``version`` is the lock to send back with ``Edit``. Times are ISO 8601."""

    id = serializers.CharField()
    task_id = serializers.CharField()
    author_id = serializers.CharField()
    parent_id = serializers.CharField()
    body = serializers.CharField()
    created_at = serializers.CharField()
    edited_at = serializers.CharField()
    deleted = serializers.BooleanField()
    pinned = serializers.BooleanField()
    version = serializers.IntegerField()
    mention_ids = serializers.ListField(child=serializers.CharField())
    reactions = Reaction(many=True)
    edit_count = serializers.IntegerField()
    kind = serializers.CharField()  # "user" or "system" (a change message; ``body`` is empty)
    event = serializers.CharField()  # JSON {actor_type, actor_id, field, from, to}; "" for user


class CommentRevision(serializers.Serializer[dict[str, object]]):
    """One body the comment has had; ``current`` marks the one it has now."""

    body = serializers.CharField()
    at = serializers.CharField()
    current = serializers.BooleanField()


class Mentionable(serializers.Serializer[dict[str, object]]):
    """A person who can see the task and so may be mentioned."""

    user_id = serializers.CharField()
    display_name = serializers.CharField()
