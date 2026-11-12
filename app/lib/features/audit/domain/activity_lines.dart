import 'package:flutter/foundation.dart';

import 'package:taskforge/features/audit/domain/audit.dart';

/// Edits by one person this close together read as one line, not five.
const Duration quietWindow = Duration(minutes: 10);

/// One line of a task's history: usually one entry, or several plain edits
/// folded together.
@immutable
class ActivityLine {
  const ActivityLine(this.entry, {this.merged = 1});

  /// What to describe (for a folded line, the edits combined).
  final AuditEntry entry;

  /// How many entries it stands for.
  final int merged;
}

AuditEntry _fold(AuditEntry newer, AuditEntry older) {
  final changes = {...older.changes};
  for (final e in newer.changes.entries) {
    final was = older.changes[e.key];
    final newest = e.value is List && (e.value as List).length == 2
        ? (e.value as List)[1]
        : e.value;
    final oldest = was is List && was.length == 2 ? was[0] : null;
    changes[e.key] = was is List && was.length == 2
        ? [oldest, newest]
        : e.value;
  }
  return AuditEntry(
    id: newer.id,
    at: newer.at,
    actor: newer.actor,
    actorName: newer.actorName,
    actorType: newer.actorType,
    action: 'task.updated',
    targetType: newer.targetType,
    targetId: newer.targetId,
    projectId: newer.projectId,
    changes: changes,
  );
}

/// Newest-first [entries] as lines: consecutive plain edits (`task.updated`)
/// by the same actor within [quietWindow] fold into one.
List<ActivityLine> activityLines(List<AuditEntry> entries) {
  final out = <ActivityLine>[];
  for (final e in entries) {
    final last = out.isEmpty ? null : out.last;
    if (last != null &&
        e.action == 'task.updated' &&
        last.entry.action == 'task.updated' &&
        e.actor == last.entry.actor &&
        e.actorType == last.entry.actorType &&
        last.entry.at.difference(e.at).abs() <= quietWindow) {
      out[out.length - 1] = ActivityLine(
        _fold(last.entry, e),
        merged: last.merged + 1,
      );
    } else {
      out.add(ActivityLine(e));
    }
  }
  return out;
}

/// "just now", "5 min ago", "2 h ago", "3 d ago", then the date.
String relativeTime(DateTime now, DateTime at) {
  final d = now.difference(at);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays < 7) return '${d.inDays} d ago';
  final l = at.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-'
      '${l.day.toString().padLeft(2, '0')}';
}

/// A heading for the day [at] falls on.
String dayHeading(DateTime now, DateTime at) {
  final a = at.toLocal();
  final n = now.toLocal();
  final days = DateTime(
    n.year,
    n.month,
    n.day,
  ).difference(DateTime(a.year, a.month, a.day)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return '${a.year}-${a.month.toString().padLeft(2, '0')}-'
      '${a.day.toString().padLeft(2, '0')}';
}
