import 'package:flutter/foundation.dart';

import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

/// What a three-way merge produced: the draft to keep editing, and one
/// sentence for everything that was taken from the other person, kept from the
/// draft, or given up. Nothing is ever merged without being listed here.
@immutable
class MergeResult {
  const MergeResult(this.draft, this.notes);

  final WorkflowDraft draft;
  final List<String> notes;
}

typedef _Attrs = (String, String, StatusCategory, bool);

_Attrs _attrsOf(WorkflowStatus s) => (s.name, s.color, s.category, s.isDefault);

_Attrs _attrsOfDraft(DraftStatus s) =>
    (s.name, s.color, s.category, s.isDefault);

/// One value changed by up to two people: [base] is what both started from,
/// [mine] my edit, [theirs] the saved one now. Mine stands when only I changed
/// it, theirs when only they did or when we disagree (their work is never
/// overwritten). [conflict] says we disagreed.
({T value, bool adopted, bool conflict}) _pick<T>(T base, T mine, T theirs) {
  if (mine == base) {
    return (value: theirs, adopted: theirs != base, conflict: false);
  }
  if (theirs == base || mine == theirs) {
    return (value: mine, adopted: false, conflict: false);
  }
  return (value: theirs, adopted: false, conflict: true);
}

/// Merges [mine] (the draft I was editing, started from [base]) with [theirs]
/// (the workflow as saved now, after someone else saved first).
///
/// Per status, field by field: a field only I changed stays mine; a field only
/// they changed becomes theirs; a field we both changed becomes theirs (my edit
/// is named in the notes so it can be redone). A status they added is added; a
/// status they deleted is deleted (never brought back); a status I deleted that
/// they also edited is kept. Order, the two restriction switches and the
/// allowed moves follow the same rule.
MergeResult mergeWorkflows({
  required Workflow base,
  required Workflow theirs,
  required WorkflowDraft mine,
}) {
  final notes = <String>[];
  final oldById = {for (final s in base.statuses) s.id: s};
  final newById = {for (final s in theirs.statuses) s.id: s};
  final mineByKey = {for (final s in mine.statuses) s.key: s};

  final kept = <String, DraftStatus>{};
  final removed = <DraftStatus>[];
  final addedByOthers = <String>[];

  for (final n in theirs.statuses) {
    final o = oldById[n.id];
    final m = mineByKey[n.id];
    if (o == null) {
      kept[n.id] = DraftStatus.of(n);
      addedByOthers.add(n.id);
      notes.add('Added by someone else: ${n.name}.');
    } else if (m == null) {
      if (_attrsOf(n) == _attrsOf(o)) {
        removed.add(DraftStatus.of(n));
      } else {
        kept[n.id] = DraftStatus.of(n);
        notes.add(
          'Kept ${n.name}: you deleted it, but someone else changed it first. '
          'Delete it again if you still want to.',
        );
      }
    } else {
      kept[n.id] = _mergeStatus(o, m, n, notes);
    }
  }
  for (final o in base.statuses) {
    if (newById.containsKey(o.id)) continue;
    final m = mineByKey[o.id];
    final edited = m != null && _attrsOfDraft(m) != _attrsOf(o);
    notes.add(
      edited
          ? 'Deleted by someone else: ${o.name}. Your changes to it were dropped.'
          : 'Deleted by someone else: ${o.name}.',
    );
  }
  for (final m in mine.statuses) {
    if (!oldById.containsKey(m.key)) kept[m.key] = m;
  }

  final order = _order(
    base,
    theirs,
    mine,
    kept.keys.toSet(),
    addedByOthers,
    notes,
  );
  final statuses = [for (final k in order) kept[k]!];
  final names = {
    for (final s in base.statuses) s.id: s.name,
    for (final s in theirs.statuses) s.id: s.name,
    for (final s in mine.statuses) s.key: s.name,
  };

  final restrict = _pick(base.restrict, mine.restrict, theirs.restrict);
  _noteSwitch(notes, restrict, 'Restrict transitions');
  final creation = _pick(
    base.restrictCreation,
    mine.restrictCreation,
    theirs.restrictCreation,
  );
  _noteSwitch(notes, creation, 'New tasks start in the default status only');

  final transitions = _mergeTransitions(
    base,
    theirs,
    mine,
    kept.keys.toSet(),
    names,
    notes,
  );

  final removedKeys = {for (final s in removed) s.key};
  final migrations = <String, String>{};
  for (final e in mine.migrations.entries) {
    if (!removedKeys.contains(e.key)) continue;
    if (kept.containsKey(e.value)) {
      migrations[e.key] = e.value;
    } else {
      notes.add(
        'The status you chose for the tasks of ${names[e.key] ?? 'a deleted status'} '
        'was deleted by someone else: choose another place for them.',
      );
    }
  }

  return MergeResult(
    WorkflowDraft(
      statuses: statuses,
      transitions: transitions,
      restrict: restrict.value,
      restrictCreation: creation.value,
      migrations: migrations,
      removed: removed,
    ),
    notes,
  );
}

DraftStatus _mergeStatus(
  WorkflowStatus o,
  DraftStatus m,
  WorkflowStatus n,
  List<String> notes,
) {
  final name = _pick(o.name, m.name, n.name);
  final color = _pick(o.color, m.color, n.color);
  final category = _pick(o.category, m.category, n.category);
  final isDefault = _pick(o.isDefault, m.isDefault, n.isDefault);
  void say<T>(
    ({T value, bool adopted, bool conflict}) r,
    String what,
    T mine,
    String Function(T) show,
  ) {
    if (r.adopted) {
      notes.add(
        'Someone else changed the $what of ${n.name} to ${show(r.value)}.',
      );
    } else if (r.conflict) {
      notes.add(
        'Your change to the $what of ${n.name} (${show(mine)}) was dropped: '
        'someone else changed it to ${show(r.value)}.',
      );
    }
  }

  say(name, 'name', m.name, (v) => '"$v"');
  say(color, 'colour', m.color, (v) => v.isEmpty ? 'none' : v);
  say(category, 'category', m.category, (v) => v.label);
  say(
    isDefault,
    'default',
    m.isDefault,
    (v) => v ? 'the default' : 'not the default',
  );
  return DraftStatus(
    key: o.id,
    name: name.value,
    color: color.value,
    category: category.value,
    isDefault: isDefault.value,
    taskCount: n.taskCount,
  );
}

void _noteSwitch(
  List<String> notes,
  ({bool value, bool adopted, bool conflict}) r,
  String what,
) {
  String state(bool v) => v ? 'on' : 'off';
  if (r.adopted) {
    notes.add('Someone else turned "$what" ${state(r.value)}.');
  } else if (r.conflict) {
    notes.add(
      'Your change to "$what" was dropped: someone else turned it '
      '${state(r.value)}.',
    );
  }
}

/// The order of the merged statuses: mine if only I reordered, theirs
/// otherwise; statuses others added keep their place relative to each other.
List<String> _order(
  Workflow base,
  Workflow theirs,
  WorkflowDraft mine,
  Set<String> present,
  List<String> addedByOthers,
  List<String> notes,
) {
  final common = {
    for (final s in base.statuses)
      if (present.contains(s.id) &&
          theirs.statuses.any((t) => t.id == s.id) &&
          mine.statuses.any((m) => m.key == s.id))
        s.id,
  };
  List<String> only(Iterable<String> ids) => [
    for (final id in ids)
      if (common.contains(id)) id,
  ];
  final oldOrder = only(base.statuses.map((s) => s.id));
  final theirOrder = only(theirs.statuses.map((s) => s.id));
  final myOrder = only(mine.statuses.map((s) => s.key));
  final iMoved = !listEquals(myOrder, oldOrder);
  final theyMoved = !listEquals(theirOrder, oldOrder);

  if (iMoved && !theyMoved) {
    // My arrangement, with what others added after it.
    return [
      for (final s in mine.statuses)
        if (present.contains(s.key)) s.key,
      for (final id in addedByOthers) id,
    ];
  }
  if (iMoved && theyMoved && !listEquals(myOrder, theirOrder)) {
    notes.add(
      'Your new order of the statuses was dropped: someone else reordered '
      'them too.',
    );
  } else if (theyMoved && !iMoved) {
    notes.add('Someone else reordered the statuses.');
  }
  return [
    for (final s in theirs.statuses)
      if (present.contains(s.id)) s.id,
    for (final s in mine.statuses)
      if (present.contains(s.key) && !theirs.statuses.any((t) => t.id == s.key))
        s.key,
  ];
}

List<WorkflowTransition> _mergeTransitions(
  Workflow base,
  Workflow theirs,
  WorkflowDraft mine,
  Set<String> present,
  Map<String, String> names,
  List<String> notes,
) {
  String key(WorkflowTransition t) => '${t.from}>${t.to}';
  final o = {for (final t in base.transitions) key(t): t};
  final n = {for (final t in theirs.transitions) key(t): t};
  final m = {for (final t in mine.transitions) key(t): t};
  final out = <WorkflowTransition>[];
  var dropped = 0;
  for (final k in {...n.keys, ...m.keys, ...o.keys}) {
    final any = n[k] ?? m[k] ?? o[k]!;
    if (!present.contains(any.from) || !present.contains(any.to)) {
      if (m.containsKey(k)) dropped++;
      continue;
    }
    final arrow = '${names[any.from] ?? '?'} → ${names[any.to] ?? '?'}';
    final presence = _pick(
      o.containsKey(k),
      m.containsKey(k),
      n.containsKey(k),
    );
    if (presence.adopted) {
      notes.add(
        presence.value
            ? 'Someone else allowed the move $arrow.'
            : 'Someone else removed the move $arrow.',
      );
    }
    if (!presence.value) continue;
    final base0 = o[k];
    final mine0 = m[k];
    final theirs0 = n[k];
    if (mine0 == null || theirs0 == null) {
      out.add(mine0 ?? theirs0!);
      continue;
    }
    final role = _pick(
      base0?.requiredRoleId ?? '',
      mine0.requiredRoleId,
      theirs0.requiredRoleId,
    );
    final assignee = _pick(
      base0?.requireAssignee ?? false,
      mine0.requireAssignee,
      theirs0.requireAssignee,
    );
    if (role.adopted || assignee.adopted) {
      notes.add('Someone else changed the conditions of the move $arrow.');
    }
    if (role.conflict || assignee.conflict) {
      notes.add(
        'Your change to the conditions of the move $arrow was dropped: '
        'someone else changed them too.',
      );
    }
    out.add(
      WorkflowTransition(
        from: any.from,
        to: any.to,
        requiredRoleId: role.value,
        requireAssignee: assignee.value,
      ),
    );
  }
  if (dropped > 0) {
    notes.add(
      dropped == 1
          ? 'One of your moves was dropped because a status it used is gone.'
          : '$dropped of your moves were dropped because a status they used '
                'is gone.',
    );
  }
  return out;
}
