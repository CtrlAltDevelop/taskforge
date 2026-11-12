"""Write the entries for a tracked row. The signal receivers call these; so do the places that
change rows without signals (``queryset.update``, ``bulk_create``, ``bulk_update``):

    before = changes.snapshot(project)
    Project.objects.filter(pk=project.pk).update(name="New")
    changes.updated(Project.objects.get(pk=project.pk), before)
"""

from typing import Any

from infrastructure.audit import recorder
from infrastructure.audit.redact import plain
from infrastructure.audit.tracking import TRACKED, Track

_EMPTY: tuple[Any, ...] = (None, "", [], {})


def _track(instance: Any) -> Track:
    return TRACKED[instance._meta.label]


def snapshot(instance: Any) -> dict[str, Any]:
    """The watched fields of ``instance`` as they are now."""
    return {f: getattr(instance, f, None) for f in _track(instance).fields}


def _name_update(track: Track, changed: dict[str, Any]) -> str:
    for name, (on, off) in track.states.items():
        if name in changed:
            return f"{track.prefix}.{on if changed[name][1] is not None else off}"
    if len(changed) == 1:
        (only,) = changed
        if only in track.single:
            return f"{track.prefix}.{track.single[only]}"
    return f"{track.prefix}.updated"


def _write(instance: Any, track: Track, action: str, changes: dict[str, Any]) -> None:
    if not track.when(instance):
        return
    workspace_id = track.workspace(instance)
    if workspace_id is None:  # a built-in role belongs to no workspace
        return
    recorder.record(
        workspace_id=workspace_id,
        action=action,
        target_type=track.target_type,
        target_id=track.target(instance),
        project_id=track.project(instance),
        changes={**changes, **track.extra(instance)},
    )


def created(instance: Any, *, action: str = "") -> None:
    track = _track(instance)
    if not track.record_create:
        return
    now = {f: v for f, v in snapshot(instance).items() if v not in _EMPTY}
    _write(instance, track, action or f"{track.prefix}.created", now)


def updated(instance: Any, before: dict[str, Any] | None) -> None:
    """Record what differs between ``before`` (a ``snapshot``) and ``instance`` now."""
    if before is None:
        return
    track = _track(instance)
    after = snapshot(instance)
    changed = {
        f: [before.get(f), after[f]]
        for f in track.fields
        if plain(before.get(f)) != plain(after[f])
    }
    if changed:
        _write(instance, track, _name_update(track, changed), changed)


def deleted(instance: Any) -> None:
    track = _track(instance)
    now = {f: v for f, v in snapshot(instance).items() if v not in _EMPTY}
    _write(instance, track, f"{track.prefix}.deleted", now)


def update_rows(queryset: Any, **values: Any) -> int:
    """``queryset.update(**values)`` that records an entry per row changed (one ``batch_id`` when
    there are several). Rows are read before and after; the queryset may stop matching."""
    from infrastructure.audit import context

    model = queryset.model
    before = {row.pk: snapshot(row) for row in queryset}
    if not before:
        return 0
    count = queryset.update(**values)
    with context.batch() if len(before) > 1 else _nothing():
        for row in model._base_manager.filter(pk__in=list(before)):
            updated(row, before[row.pk])
    return count


class _nothing:
    def __enter__(self) -> None:
        return None

    def __exit__(self, *_: Any) -> None:
        return None
