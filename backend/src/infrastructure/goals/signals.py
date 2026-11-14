"""``goal_progress_changed``: sent after commit when a goal's rolled-up progress changed.

kwargs: ``workspace_id``, ``goal_id`` (str), ``previous`` and ``progress`` (0-1 floats), ``status``,
``actor_id`` (str, empty when the system recounted linked tasks).
"""

from django.dispatch import Signal

goal_progress_changed = Signal()
