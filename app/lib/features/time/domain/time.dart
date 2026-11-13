import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The project feature switch for time tracking.
const timeFeature = 'time_tracking';

/// One logged stretch of time. [durationSec] of a running entry is what had
/// passed at the moment the answer was made.
@immutable
class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.key,
    required this.title,
    required this.userId,
    required this.userName,
    required this.startedAt,
    required this.durationSec,
    this.endedAt,
    this.note = '',
    this.billable = false,
    this.source = 'timer',
    this.flags = const [],
  });

  final String id;
  final String taskId;
  final String projectId;
  final String key;
  final String title;
  final String userId;
  final String userName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final String note;
  final bool billable;
  final String source;

  /// `running`, `long` (over 24 h, for review) or `overlap`.
  final List<String> flags;

  bool get running => endedAt == null;
  bool get isLong => flags.contains('long');
  bool get overlaps => flags.contains('overlap');
}

/// The caller's timer. [receivedAt] is the device clock when the answer
/// arrived: the elapsed time is the server's figure plus what has passed
/// since, so a wrong device clock changes nothing.
@immutable
class TimerState {
  const TimerState({this.entry, required this.receivedAt});

  final TimeEntry? entry;
  final DateTime receivedAt;

  bool get running => entry != null;

  int elapsedAt(DateTime now) {
    final e = entry;
    if (e == null) return 0;
    final extra = now.difference(receivedAt).inSeconds;
    return e.durationSec + (extra < 0 ? 0 : extra);
  }
}

@immutable
class TimeSummary {
  const TimeSummary({
    this.estimateSec = 0,
    this.loggedSec = 0,
    this.billableSec = 0,
    this.running = false,
  });

  final int estimateSec;
  final int loggedSec;
  final int billableSec;
  final bool running;

  bool get hasEstimate => estimateSec > 0;
  bool get over => hasEstimate && loggedSec > estimateSec;
}

@immutable
class SheetRow {
  const SheetRow({
    required this.taskId,
    required this.projectId,
    required this.key,
    required this.title,
    required this.seconds,
    required this.total,
    this.billable = 0,
  });

  final String taskId;
  final String projectId;
  final String key;
  final String title;
  final List<int> seconds; // seven days
  final int total;
  final int billable;
}

@immutable
class Timesheet {
  const Timesheet({
    required this.weekStart,
    required this.rows,
    required this.dayTotals,
    required this.total,
  });

  final DateTime weekStart;
  final List<SheetRow> rows;
  final List<int> dayTotals;
  final int total;
}

/// One person's time in a project, over a stretch of days.
@immutable
class PersonTotal {
  const PersonTotal({
    required this.userId,
    required this.name,
    required this.seconds,
    required this.billable,
  });

  final String userId;
  final String name;
  final int seconds;
  final int billable;
}

enum TimeFailure { network, denied, invalid, notFound, other }

class TimeException implements Exception {
  const TimeException(this.failure, {this.detail});

  final TimeFailure failure;
  final String? detail;

  @override
  String toString() => 'TimeException($failure)';
}

String timeErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! TimeException) return t.grpLGeneric;
  return switch (error.failure) {
    TimeFailure.network => t.grpLNetCheckShort,
    TimeFailure.denied => t.grpLNoAccess,
    TimeFailure.notFound => t.grpLGone,
    TimeFailure.invalid =>
      error.detail == null || error.detail!.isEmpty
          ? t.grpLNotValid
          : error.detail!,
    TimeFailure.other => t.grpLGeneric,
  };
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `1:05:09`, the way a running clock reads.
String clockText(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  return '${s ~/ 3600}:${_two(s % 3600 ~/ 60)}:${_two(s % 60)}';
}

/// `2h 05m`, `45m`, `0m`: for totals.
String durationText(int seconds) {
  final minutes = (seconds < 0 ? 0 : seconds) ~/ 60;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${_two(m)}m';
}

/// Longer than any entry or estimate the server accepts (100 days).
const _maxMinutes = 100 * 24 * 60;

final _hm = RegExp(r'^(?:(\d+(?:\.\d+)?)\s*h)?\s*(?:(\d+)\s*m)?$');
final _colon = RegExp(r'^(\d+):([0-5]?\d)$');

/// Reads "1h 30m", "90m", "1.5h", "1:30" or a bare number of minutes; null
/// when it is none of those or not above zero.
int? parseDuration(String text) {
  final t = text.trim().toLowerCase();
  if (t.isEmpty) return null;
  final colon = _colon.firstMatch(t);
  if (colon != null) {
    final hours = int.tryParse(colon[1]!);
    if (hours == null || hours > _maxMinutes ~/ 60) return null;
    final s = hours * 3600 + int.parse(colon[2]!) * 60;
    return s > 0 ? s : null;
  }
  final minutesOnly = int.tryParse(t);
  if (minutesOnly != null) {
    return minutesOnly > 0 && minutesOnly <= _maxMinutes
        ? minutesOnly * 60
        : null;
  }
  final m = _hm.firstMatch(t);
  if (m == null || (m[1] == null && m[2] == null)) return null;
  final hours = m[1] == null ? 0.0 : double.tryParse(m[1]!);
  final mins = m[2] == null ? 0 : int.tryParse(m[2]!);
  if (hours == null || mins == null) return null;
  if (hours > _maxMinutes / 60 || mins > _maxMinutes) return null;
  final s = (hours * 3600).round() + mins * 60;
  return s > 0 ? s : null;
}

/// [d] moved by [n] calendar days: local midnight stays midnight across a
/// daylight-saving change (adding a Duration would not).
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// The Monday on or before [day] (a date, no time).
DateTime weekStartOf(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return addDays(d, -(d.weekday - DateTime.monday));
}

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${_two(d.month)}-${_two(d.day)}';
