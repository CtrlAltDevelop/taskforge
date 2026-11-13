import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

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
String relativeTime(
  DateTime now,
  DateTime at, [
  AppLocalizations? l10n,
  LocalePrefs? prefs,
]) {
  final loc = l10n ?? lookupAppLocalizations(const Locale('en'));
  final d = now.difference(at);
  if (d.inSeconds < 60) return loc.grpMRelJustNow;
  if (d.inMinutes < 60) return loc.grpMRelMin(d.inMinutes);
  if (d.inHours < 24) return loc.grpMRelHour(d.inHours);
  if (d.inDays < 7) return loc.grpMRelDay(d.inDays);
  return dateOrIso(at.toLocal(), prefs: prefs, l10n: l10n);
}

/// A heading for the day [at] falls on.
String dayHeading(
  DateTime now,
  DateTime at, [
  AppLocalizations? l10n,
  LocalePrefs? prefs,
]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  final a = at.toLocal();
  final n = now.toLocal();
  final days = DateTime(
    n.year,
    n.month,
    n.day,
  ).difference(DateTime(a.year, a.month, a.day)).inDays;
  if (days == 0) return t.grpBToday;
  if (days == 1) return t.grpBYesterday;
  return dateOrIso(a, prefs: prefs, l10n: l10n);
}
