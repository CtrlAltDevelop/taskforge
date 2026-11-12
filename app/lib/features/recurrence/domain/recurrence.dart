import 'package:flutter/foundation.dart';

/// Limits mirror the server (`rules.py`, `schedule.py`); the server stays the
/// authority.
const maxRepeatInterval = 366;
const maxRepeatCount = 1000;
const maxLeadDays = 30;
const previewCount = 5;

/// Zones offered in the editor (the server accepts any IANA name).
const repeatZones = [
  'UTC',
  'Europe/London',
  'Europe/Berlin',
  'Europe/Istanbul',
  'Asia/Dubai',
  'Asia/Tehran',
  'Asia/Kolkata',
  'Asia/Singapore',
  'Asia/Tokyo',
  'Australia/Sydney',
  'America/New_York',
  'America/Chicago',
  'America/Los_Angeles',
];

enum RepeatKind {
  schedule('schedule', 'On a schedule'),
  afterCompletion('after_completion', 'After it is completed');

  const RepeatKind(this.wire, this.label);

  final String wire;
  final String label;

  static RepeatKind parse(String wire) =>
      values.where((m) => m.wire == wire).firstOrNull ?? schedule;
}

enum RepeatFreq {
  daily('DAILY', 'day'),
  weekly('WEEKLY', 'week'),
  monthly('MONTHLY', 'month'),
  yearly('YEARLY', 'year');

  const RepeatFreq(this.wire, this.unit);

  final String wire;
  final String unit;

  static RepeatFreq? tryParse(String wire) =>
      values.where((f) => f.wire == wire).firstOrNull;
}

enum RepeatEnd { never, count, until }

/// How a monthly repeat picks its day.
enum MonthlyBy { dayOfMonth, nthWeekday }

const weekdayCodes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// What the editor holds: a rule a person can write, turned to and from the
/// RRULE text the server keeps (`FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH`).
@immutable
class RepeatDraft {
  const RepeatDraft({
    this.freq = RepeatFreq.weekly,
    this.interval = 1,
    this.weekdays = const {},
    this.monthlyBy = MonthlyBy.dayOfMonth,
    this.monthDay = 1,
    this.nth = 1,
    this.nthWeekday = 0,
    this.end = RepeatEnd.never,
    this.count = 10,
    this.until = '',
    this.mode = RepeatKind.schedule,
    this.zone = 'UTC',
    this.atTime = '09:00',
    this.leadDays = 0,
    this.skipWeekends = false,
  });

  final RepeatFreq freq;
  final int interval;

  /// 0 = Monday … 6 = Sunday.
  final Set<int> weekdays;
  final MonthlyBy monthlyBy;
  final int monthDay;

  /// 1..5, or -1 for the last.
  final int nth;
  final int nthWeekday;
  final RepeatEnd end;
  final int count;

  /// `YYYY-MM-DD`.
  final String until;
  final RepeatKind mode;
  final String zone;
  final String atTime;
  final int leadDays;
  final bool skipWeekends;

  RepeatDraft copyWith({
    RepeatFreq? freq,
    int? interval,
    Set<int>? weekdays,
    MonthlyBy? monthlyBy,
    int? monthDay,
    int? nth,
    int? nthWeekday,
    RepeatEnd? end,
    int? count,
    String? until,
    RepeatKind? mode,
    String? zone,
    String? atTime,
    int? leadDays,
    bool? skipWeekends,
  }) => RepeatDraft(
    freq: freq ?? this.freq,
    interval: interval ?? this.interval,
    weekdays: weekdays ?? this.weekdays,
    monthlyBy: monthlyBy ?? this.monthlyBy,
    monthDay: monthDay ?? this.monthDay,
    nth: nth ?? this.nth,
    nthWeekday: nthWeekday ?? this.nthWeekday,
    end: end ?? this.end,
    count: count ?? this.count,
    until: until ?? this.until,
    mode: mode ?? this.mode,
    zone: zone ?? this.zone,
    atTime: atTime ?? this.atTime,
    leadDays: leadDays ?? this.leadDays,
    skipWeekends: skipWeekends ?? this.skipWeekends,
  );

  /// Why the draft cannot be saved, or null.
  String? get problem {
    if (interval < 1 || interval > maxRepeatInterval) {
      return 'Repeat every 1 to $maxRepeatInterval.';
    }
    if (end == RepeatEnd.count && (count < 1 || count > maxRepeatCount)) {
      return 'The number of times is 1 to $maxRepeatCount.';
    }
    if (end == RepeatEnd.until && until.isEmpty) return 'Pick an end date.';
    if (freq == RepeatFreq.weekly &&
        mode == RepeatKind.schedule &&
        weekdays.isEmpty) {
      return 'Pick at least one weekday.';
    }
    if (leadDays < 0 || leadDays > maxLeadDays) {
      return 'Lead days are 0 to $maxLeadDays.';
    }
    return null;
  }

  /// The RRULE text for the server. An after-completion repeat only says how
  /// long to wait, so it carries no weekdays or month days.
  String toRrule() {
    final parts = ['FREQ=${freq.wire}'];
    if (interval != 1) parts.add('INTERVAL=$interval');
    final schedule = mode == RepeatKind.schedule;
    if (schedule && freq == RepeatFreq.weekly && weekdays.isNotEmpty) {
      final days = weekdays.toList()..sort();
      parts.add('BYDAY=${days.map((d) => weekdayCodes[d]).join(',')}');
    }
    if (schedule && freq == RepeatFreq.monthly) {
      if (monthlyBy == MonthlyBy.dayOfMonth) {
        parts.add('BYMONTHDAY=$monthDay');
      } else {
        parts.add('BYDAY=$nth${weekdayCodes[nthWeekday]}');
      }
    }
    switch (end) {
      case RepeatEnd.never:
        break;
      case RepeatEnd.count:
        parts.add('COUNT=$count');
      case RepeatEnd.until:
        parts.add('UNTIL=${until.replaceAll('-', '')}');
    }
    return parts.join(';');
  }

  /// The draft a stored [rrule] says, or null when it is a rule the editor
  /// cannot show faithfully (the server accepts more than the editor writes:
  /// saving such a rule from the editor would silently change it).
  static RepeatDraft? fromRrule(
    String rrule, {
    RepeatKind mode = RepeatKind.schedule,
    String zone = 'UTC',
    String atTime = '09:00',
    int leadDays = 0,
    bool skipWeekends = false,
    String endsOn = '',
  }) {
    const known = {'FREQ', 'INTERVAL', 'BYDAY', 'BYMONTHDAY', 'COUNT', 'UNTIL'};
    final parts = <String, String>{};
    for (final piece in rrule.split(';')) {
      final at = piece.indexOf('=');
      if (at < 1) return null;
      final name = piece.substring(0, at).toUpperCase();
      if (!known.contains(name)) return null;
      parts[name] = piece.substring(at + 1);
    }
    final freq = RepeatFreq.tryParse(parts['FREQ'] ?? '');
    final interval = int.tryParse(parts['INTERVAL'] ?? '1');
    if (freq == null || interval == null) return null;
    if (interval < 1 || interval > maxRepeatInterval) return null;
    var draft = RepeatDraft(
      freq: freq,
      interval: interval,
      mode: mode,
      zone: zone,
      atTime: atTime,
      leadDays: leadDays,
      skipWeekends: skipWeekends,
    );
    final byday = parts['BYDAY'];
    final monthday = parts['BYMONTHDAY'];
    if (byday != null && monthday != null) return null;
    if (byday != null) {
      final shown = _byday(byday, freq);
      if (shown == null) return null;
      draft = shown(draft);
    }
    if (monthday != null) {
      final d = int.tryParse(monthday);
      if (freq != RepeatFreq.monthly || d == null || d < 1 || d > 31) {
        return null;
      }
      draft = draft.copyWith(monthlyBy: MonthlyBy.dayOfMonth, monthDay: d);
    }
    final count = parts['COUNT'];
    final until = parts['UNTIL'];
    if (count != null && until != null) return null;
    if (count != null) {
      final n = int.tryParse(count);
      if (n == null || n < 1 || n > maxRepeatCount) return null;
      draft = draft.copyWith(end: RepeatEnd.count, count: n);
    }
    if (until != null) {
      if (until.length != 8 || int.tryParse(until) == null) return null;
      draft = draft.copyWith(
        end: RepeatEnd.until,
        until:
            '${until.substring(0, 4)}-${until.substring(4, 6)}-'
            '${until.substring(6, 8)}',
      );
    } else if (count == null && endsOn.isNotEmpty) {
      draft = draft.copyWith(end: RepeatEnd.until, until: endsOn);
    }
    return draft;
  }

  /// What `BYDAY` means for [freq] if the editor can show it: weekdays for a
  /// weekly rule, one "nth weekday" (1st to 4th, or last) for a monthly one.
  static RepeatDraft Function(RepeatDraft)? _byday(
    String byday,
    RepeatFreq freq,
  ) {
    final days = <int>{};
    final nths = <(int, int)>[];
    for (final item in byday.split(',')) {
      if (item.length < 2) return null;
      final day = weekdayCodes.indexOf(item.substring(item.length - 2));
      if (day < 0) return null;
      final head = item.substring(0, item.length - 2);
      if (head.isNotEmpty) {
        final nth = int.tryParse(head);
        if (nth == null || nth == 0 || nth > 4 || nth < -1) return null;
        nths.add((nth, day));
      }
      days.add(day);
    }
    if (nths.isEmpty) {
      return freq == RepeatFreq.weekly
          ? (d) => d.copyWith(weekdays: days)
          : null;
    }
    if (freq != RepeatFreq.monthly || nths.length != 1 || days.length != 1) {
      return null;
    }
    final (nth, day) = nths.single;
    return (d) =>
        d.copyWith(monthlyBy: MonthlyBy.nthWeekday, nth: nth, nthWeekday: day);
  }

  @override
  bool operator ==(Object other) =>
      other is RepeatDraft && other.toRrule() == toRrule() && _same(other);

  bool _same(RepeatDraft o) =>
      o.mode == mode &&
      o.zone == zone &&
      o.atTime == atTime &&
      o.leadDays == leadDays &&
      o.skipWeekends == skipWeekends;

  @override
  int get hashCode =>
      Object.hash(toRrule(), mode, zone, atTime, leadDays, skipWeekends);
}

/// A task's repeat rule as the server reports it.
@immutable
class RepeatSeries {
  const RepeatSeries({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.rrule,
    required this.mode,
    this.zone = 'UTC',
    this.atTime = '09:00',
    this.leadDays = 0,
    this.startsOn = '',
    this.endsOn = '',
    this.skipWeekends = false,
    this.paused = false,
    this.pauseReason = '',
    this.summary = '',
    this.nextDueOn = '',
    this.nextDates = const [],
    this.instanceCount = 1,
    this.index = 0,
    this.isTemplate = false,
    this.templateMissing = false,
    this.version = 1,
  });

  final String id;
  final String projectId;
  final String taskId;
  final String rrule;
  final RepeatKind mode;
  final String zone;
  final String atTime;
  final int leadDays;
  final String startsOn;
  final String endsOn;
  final bool skipWeekends;
  final bool paused;

  /// Why the system paused it (empty when a person did).
  final String pauseReason;

  /// The rule in words ("Every 2 weeks on Mon, Thu").
  final String summary;
  final String nextDueOn;

  /// `YYYY-MM-DD`, the next few the clock will make.
  final List<String> nextDates;
  final int instanceCount;

  /// The number of the task asked about (0: the first).
  final int index;
  final bool isTemplate;
  final bool templateMissing;
  final int version;

  RepeatDraft? get draft => RepeatDraft.fromRrule(
    rrule,
    mode: mode,
    zone: zone,
    atTime: atTime,
    leadDays: leadDays,
    skipWeekends: skipWeekends,
    endsOn: endsOn,
  );
}

/// The sentence and next dates of a draft, before it is saved.
@immutable
class RepeatPreview {
  const RepeatPreview({required this.summary, required this.dates});

  final String summary;
  final List<String> dates;
}

/// A date the clock has not made yet, shown faded on the calendar.
@immutable
class RepeatGhost {
  const RepeatGhost({
    required this.seriesId,
    required this.projectId,
    required this.title,
    required this.dueDate,
  });

  final String seriesId;
  final String projectId;
  final String title;
  final String dueDate;
}

enum RepeatFailure { network, denied, invalid, notFound, other }

class RepeatException implements Exception {
  const RepeatException(this.failure, {this.detail});

  final RepeatFailure failure;
  final String? detail;

  @override
  String toString() => 'RepeatException($failure)';
}

String repeatErrorMessage(Object error) {
  if (error is! RepeatException) return 'Something went wrong. Try again.';
  final detail = error.detail;
  return switch (error.failure) {
    RepeatFailure.invalid =>
      detail == null || detail.isEmpty ? 'That repeat is not valid.' : detail,
    RepeatFailure.denied => 'You are not allowed to change how this repeats.',
    RepeatFailure.notFound => 'That task no longer exists.',
    RepeatFailure.network => 'Could not reach the server. Try again.',
    RepeatFailure.other => 'Something went wrong. Try again.',
  };
}
