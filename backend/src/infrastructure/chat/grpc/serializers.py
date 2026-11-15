"""The messages the chat controller speaks. Named for the message, not the class."""

from rest_framework import serializers


class Reaction(serializers.Serializer[dict[str, object]]):
    """One emoji and everyone who gave it (user ids, oldest first)."""

    emoji = serializers.CharField()
    user_ids = serializers.ListField(child=serializers.CharField())


class Space(serializers.Serializer[dict[str, object]]):
    """A channel, group or direct message as the caller sees it. ``kind`` is ``channel``,
    ``group`` or ``dm``; ``name`` is the other person's name for a ``dm`` ("Former member" once
    they left). ``project_id`` is set for a project's channel; ``is_default`` marks ``#general``.
    ``joined`` is false for a channel the caller may read but has not joined. ``unread_count``
    counts other people's messages after the caller's read mark. ``muted_until`` is ISO 8601 or
    empty; ``muted_completely`` also silences @mentions. ``read_only``: archived, or a dm whose
    other person left. ``peer_id`` is the other person of a ``dm``. ``member_count`` is what
    ``@channel`` would reach (confirm above 50). Times are ISO 8601."""

    id = serializers.CharField()
    kind = serializers.CharField()
    name = serializers.CharField()
    project_id = serializers.CharField()
    is_default = serializers.BooleanField()
    archived = serializers.BooleanField()
    joined = serializers.BooleanField()
    role = serializers.CharField()
    unread_count = serializers.IntegerField()
    last_message_at = serializers.CharField()
    last_read_at = serializers.CharField()
    member_count = serializers.IntegerField()
    muted_until = serializers.CharField()
    muted_completely = serializers.BooleanField()
    notify_all = serializers.BooleanField()
    read_only = serializers.BooleanField()
    peer_id = serializers.CharField()
    version = serializers.IntegerField()
    created_at = serializers.CharField()
    created_by = serializers.CharField()


class TaskChat(serializers.Serializer[dict[str, object]]):
    """A task whose chat (phase 42) the caller can open: listed beside the spaces, no unread."""

    task_id = serializers.CharField()
    project_id = serializers.CharField()
    display_id = serializers.CharField()
    title = serializers.CharField()
    last_message_at = serializers.CharField()


class Message(serializers.Serializer[dict[str, object]]):
    """A message. ``body`` is the rich-text document as JSON (empty once removed: ``deleted``);
    @channel / @here are ``mention`` nodes with id ``channel`` / ``here``. ``parent_id`` is empty
    for a top-level message; threads are one level deep. ``author_name`` is "Former member" once
    the author left. ``version`` is the lock to send back with ``Edit``."""

    id = serializers.CharField()
    space_id = serializers.CharField()
    author_id = serializers.CharField()
    author_name = serializers.CharField()
    parent_id = serializers.CharField()
    body = serializers.CharField()
    created_at = serializers.CharField()
    edited_at = serializers.CharField()
    deleted = serializers.BooleanField()
    version = serializers.IntegerField()
    reactions = Reaction(many=True)


class Person(serializers.Serializer[dict[str, object]]):
    """A person who can see the space and so may be mentioned."""

    user_id = serializers.CharField()
    display_name = serializers.CharField()
