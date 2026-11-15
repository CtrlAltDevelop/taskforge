import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a merge note says; the words come from [MergeNote.text].
enum MergeNoteKind {
  added,
  keptDeleted,
  deleted,
  deletedEdited,
  fieldAdopted,
  fieldDropped,
  switchAdopted,
  switchDropped,
  orderDropped,
  reordered,
  migrationLost,
  moveAllowed,
  moveRemoved,
  conditionsAdopted,
  conditionsDropped,
  movesDropped,
}

/// The status field a field note is about.
enum MergeField { name, colour, category, isDefault }

/// The workflow switch a switch note is about.
enum MergeSwitch { restrict, creation }

/// One thing the merge did, as data: the sentence is built at display time in
/// the language on screen, so nothing English is stored in the editor state.
@immutable
class MergeNote {
  const MergeNote(
    this.kind, {
    this.name = '',
    this.field,
    this.toggle,
    this.value,
    this.mine,
    this.count = 0,
  });

  final MergeNoteKind kind;

  /// The status (or the move, "A → B") the note is about.
  final String name;
  final MergeField? field;
  final MergeSwitch? toggle;

  /// The value now (a String, a [StatusCategory] or a bool) and mine before.
  final Object? value;
  final Object? mine;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is MergeNote &&
      other.kind == kind &&
      other.name == name &&
      other.field == field &&
      other.toggle == toggle &&
      other.value == value &&
      other.mine == mine &&
      other.count == count;

  @override
  int get hashCode =>
      Object.hash(kind, name, field, toggle, value, mine, count);

  String _show(AppLocalizations l, Object? v) => switch (v) {
    StatusCategory c => c.labelIn(l),
    bool b => b ? l.grpRMnIsDefault : l.grpRMnNotDefault,
    String t when field == MergeField.name => '"$t"',
    String t when t.isEmpty => l.grpRMnNone,
    _ => '$v',
  };

  String _what(AppLocalizations l) => switch (field) {
    MergeField.colour => l.grpRMnWhatColour,
    MergeField.category => l.grpRMnWhatCategory,
    MergeField.isDefault => l.grpRMnWhatDefault,
    _ => l.grpRMnWhatName,
  };

  String _switchName(AppLocalizations l) => toggle == MergeSwitch.creation
      ? l.grpIRestrictCreation
      : l.grpIRestrictTransitions;

  /// The sentence in the language of [l].
  String text(AppLocalizations l) => switch (kind) {
    MergeNoteKind.added => l.grpRMnAdded(name),
    MergeNoteKind.keptDeleted => l.grpRMnKept(name),
    MergeNoteKind.deleted => l.grpRMnDeleted(name),
    MergeNoteKind.deletedEdited => l.grpRMnDeletedEdited(name),
    MergeNoteKind.fieldAdopted => l.grpRMnFieldAdopted(
      _what(l),
      name,
      _show(l, value),
    ),
    MergeNoteKind.fieldDropped => l.grpRMnFieldDropped(
      _what(l),
      name,
      _show(l, mine),
      _show(l, value),
    ),
    MergeNoteKind.switchAdopted => l.grpRMnSwitchAdopted(
      _switchName(l),
      value == true ? l.grpRMnOn : l.grpRMnOff,
    ),
    MergeNoteKind.switchDropped => l.grpRMnSwitchDropped(
      _switchName(l),
      value == true ? l.grpRMnOn : l.grpRMnOff,
    ),
    MergeNoteKind.orderDropped => l.grpRMnOrderDropped,
    MergeNoteKind.reordered => l.grpRMnReordered,
    MergeNoteKind.migrationLost => l.grpRMnMigrationLost(
      name.isEmpty ? l.grpRMnDeletedStatus : name,
    ),
    MergeNoteKind.moveAllowed => l.grpRMnMoveAllowed(name),
    MergeNoteKind.moveRemoved => l.grpRMnMoveRemoved(name),
    MergeNoteKind.conditionsAdopted => l.grpRMnConditionsAdopted(name),
    MergeNoteKind.conditionsDropped => l.grpRMnConditionsDropped(name),
    MergeNoteKind.movesDropped => l.grpRMnMovesDropped(count),
  };
}

/// What a three-way merge produced: the draft to keep editing, and one
/// sentence for everything that was taken from the other person, kept from the
/// draft, or given up. Nothing is ever merged without being listed here.
@immutable
class MergeResult {
  const MergeResult(this.draft, this.notes);

  final WorkflowDraft draft;
  final List<MergeNote> notes;

  /// The notes as English sentences (what the tests read).
  List<String> get english {
    final l = lookupAppLocalizations(const Locale('en'));
    return [for (final n in notes) n.text(l)];
  }
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
  final notes = <MergeNote>[];
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
      notes.add(MergeNote(MergeNoteKind.added, name: n.name));
    } else if (m == null) {
      if (_attrsOf(n) == _attrsOf(o)) {
        removed.add(DraftStatus.of(n));
      } else {
        kept[n.id] = DraftStatus.of(n);
        notes.add(MergeNote(MergeNoteKind.keptDeleted, name: n.name));
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
      MergeNote(
        edited ? MergeNoteKind.deletedEdited : MergeNoteKind.deleted,
        name: o.name,
      ),
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
  _noteSwitch(notes, restrict, MergeSwitch.restrict);
  final creation = _pick(
    base.restrictCreation,
    mine.restrictCreation,
    theirs.restrictCreation,
  );
  _noteSwitch(notes, creation, MergeSwitch.creation);

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
        MergeNote(MergeNoteKind.migrationLost, name: names[e.key] ?? ''),
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
  List<MergeNote> notes,
) {
  final name = _pick(o.name, m.name, n.name);
  final color = _pick(o.color, m.color, n.color);
  final category = _pick(o.category, m.category, n.category);
  final isDefault = _pick(o.isDefault, m.isDefault, n.isDefault);
  void say<T>(
    ({T value, bool adopted, bool conflict}) r,
    MergeField f,
    T mine,
  ) {
    if (r.adopted) {
      notes.add(
        MergeNote(
          MergeNoteKind.fieldAdopted,
          name: n.name,
          field: f,
          value: r.value,
        ),
      );
    } else if (r.conflict) {
      notes.add(
        MergeNote(
          MergeNoteKind.fieldDropped,
          name: n.name,
          field: f,
          value: r.value,
          mine: mine,
        ),
      );
    }
  }

  say(name, MergeField.name, m.name);
  say(color, MergeField.colour, m.color);
  say(category, MergeField.category, m.category);
  say(isDefault, MergeField.isDefault, m.isDefault);
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
  List<MergeNote> notes,
  ({bool value, bool adopted, bool conflict}) r,
  MergeSwitch which,
) {
  if (r.adopted) {
    notes.add(
      MergeNote(MergeNoteKind.switchAdopted, toggle: which, value: r.value),
    );
  } else if (r.conflict) {
    notes.add(
      MergeNote(MergeNoteKind.switchDropped, toggle: which, value: r.value),
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
  List<MergeNote> notes,
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
    notes.add(const MergeNote(MergeNoteKind.orderDropped));
  } else if (theyMoved && !iMoved) {
    notes.add(const MergeNote(MergeNoteKind.reordered));
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
  List<MergeNote> notes,
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
        MergeNote(
          presence.value
              ? MergeNoteKind.moveAllowed
              : MergeNoteKind.moveRemoved,
          name: arrow,
        ),
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
    final subtasks = _pick(
      base0?.requireSubtasksDone ?? false,
      mine0.requireSubtasksDone,
      theirs0.requireSubtasksDone,
    );
    if (role.adopted || assignee.adopted || subtasks.adopted) {
      notes.add(MergeNote(MergeNoteKind.conditionsAdopted, name: arrow));
    }
    if (role.conflict || assignee.conflict || subtasks.conflict) {
      notes.add(MergeNote(MergeNoteKind.conditionsDropped, name: arrow));
    }
    out.add(
      WorkflowTransition(
        from: any.from,
        to: any.to,
        requiredRoleId: role.value,
        requireAssignee: assignee.value,
        requireSubtasksDone: subtasks.value,
      ),
    );
  }
  if (dropped > 0) {
    notes.add(MergeNote(MergeNoteKind.movesDropped, count: dropped));
  }
  return out;
}
