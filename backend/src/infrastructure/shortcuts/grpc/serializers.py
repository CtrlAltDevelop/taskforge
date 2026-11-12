"""The messages the shortcut controller speaks."""

from rest_framework import serializers


class Shortcut(serializers.Serializer[dict[str, object]]):
    """One override: the ``action_id`` from the client's registry and its ``keys`` chord
    (``mod+shift+k``; empty: unbound on purpose)."""

    action_id = serializers.CharField()
    keys = serializers.CharField()
