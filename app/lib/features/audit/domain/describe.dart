import 'dart:ui' show Locale;

import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/features/audit/domain/describe_workspace.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What an entry says happened, as a phrase that follows the actor's name
/// ("Ali" + "changed status To do → Done"). [labels] names the ids in it. In
/// the language of [l10n] (English when null).
String describeEntry(
  AuditEntry e,
  Map<String, String> labels, [
  AppLocalizations? l10n,
]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  String shown(Object? v) => _shown(v, l);
  String name(Object? id) {
    final key = id?.toString() ?? '';
    if (key.isEmpty) return l.grpRMnNone;
    return labels[key] ?? shown(id);
  }

  Object? after(String field) {
    final c = e.changes[field];
    return c is List && c.length == 2 ? c[1] : c;
  }

  List<String> names(Object? list) => [
    if (list is List)
      for (final id in list) name(id),
  ];

  switch (e.action) {
    case 'task.created':
      return l.grpRAuCreated;
    case 'task.deleted':
      return l.grpRAuTrashed;
    case 'task.restored':
      return l.grpRAuRestored;
    case 'task.status_changed':
      final c = e.changes['status_id'];
      if (c is List && c.length == 2) {
        return l.grpRAuStatus(name(c[0]), name(c[1]));
      }
    case 'task.assignees_changed':
      final c = e.changes['assignees'];
      if (c is List && c.length == 2) {
        final was = names(c[0]);
        final now = names(c[1]);
        final added = [
          for (final n in now)
            if (!was.contains(n)) n,
        ];
        final removed = [
          for (final n in was)
            if (!now.contains(n)) n,
        ];
        final parts = [
          if (added.isNotEmpty) l.grpRAuAssigned(added.join(', ')),
          if (removed.isNotEmpty) l.grpRAuUnassigned(removed.join(', ')),
        ];
        return parts.length == 2
            ? l.grpRAuAnd(parts[0], parts[1])
            : parts.join();
      }
    case 'task.updated':
      return _edited(e, name, l);
    case 'comment.created':
      return l.grpRAuCommented;
    case 'comment.updated':
      return l.grpRAuCommentEdited;
    case 'comment.deleted':
      return l.grpRAuCommentDeleted;
    case 'comment.reacted':
      return l.grpRAuReacted(shown(after('emoji')));
    case 'comment.unreacted':
      return l.grpRAuUnreacted(shown(after('emoji')));
    case 'attachment.created':
      return l.grpRAuAttached(shown(after('filename')));
    case 'attachment.deleted':
      return l.grpRAuFileRemoved(shown(after('filename')));
    case 'time.created':
      return l.grpRAuTimeLogged;
    case 'time.updated':
      return l.grpRAuTimeUpdated;
    case 'time.deleted':
      return l.grpRAuTimeDeleted;
    case 'link.created':
      return l.grpRAuLinked(shown(after('type')), name(after('to_task_id')));
    case 'link.deleted':
      return l.grpRAuLinkRemoved;
    case 'field_value.created' || 'field_value.updated':
      return l.grpRAuFieldSet;
    case 'doc_link.created':
      return l.grpRAuDocLinked;
    case 'doc_link.deleted':
      return l.grpRAuDocUnlinked;
  }
  return describeWorkspaceAction(e.action, after, shown, l) ??
      _humanize(e.action, l);
}

String _edited(
  AuditEntry e,
  String Function(Object?) name,
  AppLocalizations l,
) {
  final parts = <String>[];
  for (final c in fieldChanges(e)) {
    final label = fieldLabel(c.name, l);
    final from = _value(c.name, c.before, name, l);
    final to = _value(c.name, c.after, name, l);
    parts.add(
      c.hasBefore && !c.name.endsWith('_id') && c.name != 'description'
          ? l.grpRAuPart(label, from, to)
          : label,
    );
  }
  return parts.isEmpty ? l.grpRAuEdited : l.grpRAuChanged(parts.join(', '));
}

String _value(
  String field,
  Object? v,
  String Function(Object?) name,
  AppLocalizations l,
) => field.endsWith('_id') ? name(v) : _shown(v, l);

/// The audit's word for a changed field, in the language of [l10n] (English
/// when null).
String fieldLabel(String field, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (field) {
    'status_id' => l.grpRAuFStatus,
    'sprint_id' => l.grpRAuFSprint,
    'parent_id' => l.grpRAuFParent,
    'due_date' => l.grpRAuFDueDate,
    'due_time' => l.grpRAuFDueTime,
    'start_date' => l.grpRAuFStartDate,
    'estimate_sec' => l.grpRAuFEstimate,
    _ => field.replaceAll('_id', '').replaceAll('_', ' '),
  };
}

/// A value as a reader wants it: quoted text, "none", or the size marker the
/// server leaves for a body it did not copy.
String _shown(Object? v, AppLocalizations l) {
  if (v == null || v == '') return l.grpRMnNone;
  if (v is Map && v.containsKey('size')) {
    return l.grpBCharacters('${v['size']}');
  }
  if (v is String) return '“$v”';
  return v.toString();
}

String _humanize(String action, AppLocalizations l) {
  final spaced = action.replaceAll('_', ' ').replaceAll('.', ' ');
  return spaced.isEmpty ? l.grpRAuSomething : spaced;
}
