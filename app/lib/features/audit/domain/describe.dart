import 'package:taskforge/features/audit/domain/audit.dart';

/// What an entry says happened, as a phrase that follows the actor's name
/// ("Ali" + "changed status To do → Done"). [labels] names the ids in it.
String describeEntry(AuditEntry e, Map<String, String> labels) {
  String name(Object? id) {
    final key = id?.toString() ?? '';
    if (key.isEmpty) return 'none';
    return labels[key] ?? _shown(id);
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
      return 'created this task';
    case 'task.deleted':
      return 'moved this task to the trash';
    case 'task.restored':
      return 'restored this task';
    case 'task.status_changed':
      final c = e.changes['status_id'];
      if (c is List && c.length == 2) {
        return 'changed status ${name(c[0])} → ${name(c[1])}';
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
        return [
          if (added.isNotEmpty) 'assigned ${added.join(', ')}',
          if (removed.isNotEmpty) 'unassigned ${removed.join(', ')}',
        ].join(' and ');
      }
    case 'task.updated':
      return _edited(e, name);
    case 'comment.created':
      return 'commented';
    case 'comment.updated':
      return 'edited a comment';
    case 'comment.deleted':
      return 'deleted a comment';
    case 'comment.reacted':
      return 'reacted ${_shown(after('emoji'))} to a comment';
    case 'comment.unreacted':
      return 'took back ${_shown(after('emoji'))} on a comment';
    case 'attachment.created':
      return 'attached ${_shown(after('filename'))}';
    case 'attachment.deleted':
      return 'removed the file ${_shown(after('filename'))}';
    case 'time.created':
      return 'logged time';
    case 'time.updated':
      return 'updated a time entry';
    case 'time.deleted':
      return 'deleted a time entry';
    case 'link.created':
      return 'linked ${_shown(after('type'))} ${name(after('to_task_id'))}';
    case 'link.deleted':
      return 'removed a link';
    case 'field_value.created' || 'field_value.updated':
      return 'set a custom field';
    case 'doc_link.created':
      return 'linked a page';
    case 'doc_link.deleted':
      return 'unlinked a page';
  }
  return _humanize(e.action);
}

String _edited(AuditEntry e, String Function(Object?) name) {
  final parts = <String>[];
  for (final c in fieldChanges(e)) {
    final label = fieldLabel(c.name);
    final from = _value(c.name, c.before, name);
    final to = _value(c.name, c.after, name);
    parts.add(
      c.hasBefore && !c.name.endsWith('_id') && c.name != 'description'
          ? '$label $from → $to'
          : label,
    );
  }
  return parts.isEmpty ? 'edited this task' : 'changed ${parts.join(', ')}';
}

String _value(String field, Object? v, String Function(Object?) name) =>
    field.endsWith('_id') ? name(v) : _shown(v);

String fieldLabel(String field) => switch (field) {
  'status_id' => 'status',
  'sprint_id' => 'sprint',
  'parent_id' => 'parent task',
  'due_date' => 'due date',
  'due_time' => 'due time',
  'start_date' => 'start date',
  'estimate_sec' => 'estimate',
  _ => field.replaceAll('_id', '').replaceAll('_', ' '),
};

/// A value as a reader wants it: quoted text, "none", or the size marker the
/// server leaves for a body it did not copy.
String _shown(Object? v) {
  if (v == null || v == '') return 'none';
  if (v is Map && v.containsKey('size')) return '(${v['size']} characters)';
  if (v is String) return '“$v”';
  return v.toString();
}

String _humanize(String action) {
  final spaced = action.replaceAll('_', ' ').replaceAll('.', ' ');
  return spaced.isEmpty ? 'did something' : spaced;
}
