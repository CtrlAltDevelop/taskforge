import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show IconData, Icons;

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The kinds of notification the server sends (its `type` and `event_type`).
enum NotificationKind {
  assigned('task.assigned', 'Assigned to you', Icons.assignment_ind_outlined),
  mentioned('user.mentioned', 'Mentions', Icons.alternate_email),
  commented('comment.added', 'Comments', Icons.chat_bubble_outline),
  statusChanged('status.changed', 'Status changes', Icons.swap_horiz),
  dueSoon('task.due_soon', 'Due soon', Icons.schedule),
  timerLong('timer.long', 'Long timers', Icons.timer_outlined),
  unknown('', 'Notification', Icons.notifications_none);

  const NotificationKind(this.wire, this.label, this.icon);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    assigned => l.grpMNkAssigned,
    mentioned => l.grpMNkMentioned,
    commented => l.grpMNkCommented,
    statusChanged => l.grpMNkStatusChanged,
    dueSoon => l.grpMNkDueSoon,
    timerLong => l.grpMNkTimerLong,
    unknown => l.grpMNkUnknown,
  };
  final IconData icon;

  static NotificationKind of(String type) => values.firstWhere(
    (k) => k.wire == type && k != unknown,
    orElse: () => unknown,
  );
}

/// What the inbox shows; [wire] is what the server calls it.
enum InboxFilter {
  all('all', 'All'),
  unread('unread', 'Unread'),
  mentions('mentions', 'Mentions'),
  assigned('assigned', 'Assigned'),
  snoozed('snoozed', 'Snoozed'),
  archived('archived', 'Archived');

  const InboxFilter(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    all => l.grpMIfAll,
    unread => l.grpMIfUnread,
    mentions => l.grpMIfMentions,
    assigned => l.grpMIfAssigned,
    snoozed => l.grpMIfSnoozed,
    archived => l.grpMIfArchived,
  };
}

/// One notification. [count] is how many events were folded into it. Times
/// are null when not set.
@immutable
class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.workspaceId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.taskId = '',
    this.projectId = '',
    this.actorId = '',
    this.actorName = '',
    this.payload = const {},
    this.count = 1,
    this.readAt,
    this.snoozedUntil,
    this.archivedAt,
  });

  final String id;
  final String workspaceId;
  final String type;
  final String taskId;
  final String projectId;
  final String actorId;
  final String actorName;
  final Map<String, dynamic> payload;
  final int count;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? readAt;
  final DateTime? snoozedUntil;
  final DateTime? archivedAt;

  NotificationKind get kind => NotificationKind.of(type);
  bool get isRead => readAt != null;
  bool get isArchived => archivedAt != null;
  bool isSnoozed(DateTime now) =>
      snoozedUntil != null && snoozedUntil!.isAfter(now);

  /// The task's key and title as they were when this happened.
  String get key => _text('key');
  String get title => _text('title');
  String get from => _text('from');
  String get to => _text('to');
  String get excerpt => _text('excerpt');
  String get dueDate => _text('due_date');

  String _text(String name) => payload[name]?.toString() ?? '';

  /// Who did it, in a sentence ("Hank assigned you ...").
  String get who => actorName.isEmpty ? 'Someone' : actorName;

  /// What happened, without the task.
  String get what => switch (kind) {
    NotificationKind.assigned => '$who assigned you',
    NotificationKind.mentioned => '$who mentioned you in',
    NotificationKind.commented => '$who commented on',
    NotificationKind.statusChanged =>
      from.isEmpty || to.isEmpty
          ? '$who changed the status of'
          : '$who moved from $from to $to',
    NotificationKind.dueSoon => 'Due soon:',
    NotificationKind.timerLong => 'Your timer is still running on',
    NotificationKind.unknown => 'New activity on',
  };

  /// [who] in the language of [l].
  String whoIn(AppLocalizations l) =>
      actorName.isEmpty ? l.grpMNotifSomeone : actorName;

  /// [what] in the language of [l].
  String whatIn(AppLocalizations l) {
    final w = whoIn(l);
    return switch (kind) {
      NotificationKind.assigned => l.grpMNotifAssigned(w),
      NotificationKind.mentioned => l.grpMNotifMentioned(w),
      NotificationKind.commented => l.grpMNotifCommented(w),
      NotificationKind.statusChanged =>
        from.isEmpty || to.isEmpty
            ? l.grpMNotifStatusChanged(w)
            : l.grpMNotifMoved(w, from, to),
      NotificationKind.dueSoon => l.grpMNotifDueSoon,
      NotificationKind.timerLong => l.grpMNotifTimer,
      NotificationKind.unknown => l.grpMNotifNew,
    };
  }

  /// The task as the row names it ("WEB-12 Fix login").
  String get taskLabel => [key, title].where((s) => s.isNotEmpty).join(' ');

  /// Whether the user can open the task from here.
  bool get canOpen => taskId.isNotEmpty && projectId.isNotEmpty;

  /// Whether this notification belongs in [filter] at [now].
  bool belongsTo(InboxFilter filter, DateTime now) => switch (filter) {
    InboxFilter.archived => isArchived,
    InboxFilter.snoozed => !isArchived && isSnoozed(now),
    _ =>
      !isArchived &&
          !isSnoozed(now) &&
          switch (filter) {
            InboxFilter.unread => !isRead,
            InboxFilter.mentions => kind == NotificationKind.mentioned,
            InboxFilter.assigned => kind == NotificationKind.assigned,
            _ => true,
          },
  };

  InboxNotification copyWith({
    DateTime? Function()? readAt,
    DateTime? Function()? snoozedUntil,
    DateTime? Function()? archivedAt,
  }) => InboxNotification(
    id: id,
    workspaceId: workspaceId,
    type: type,
    createdAt: createdAt,
    updatedAt: updatedAt,
    taskId: taskId,
    projectId: projectId,
    actorId: actorId,
    actorName: actorName,
    payload: payload,
    count: count,
    readAt: readAt == null ? this.readAt : readAt(),
    snoozedUntil: snoozedUntil == null ? this.snoozedUntil : snoozedUntil(),
    archivedAt: archivedAt == null ? this.archivedAt : archivedAt(),
  );

  @override
  bool operator ==(Object other) =>
      other is InboxNotification &&
      other.id == id &&
      other.count == count &&
      other.readAt == readAt &&
      other.snoozedUntil == snoozedUntil &&
      other.archivedAt == archivedAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, count, readAt, snoozedUntil, archivedAt);
}

/// The payload JSON of a notification; anything unreadable is empty.
Map<String, dynamic> parsePayload(String json) {
  if (json.isEmpty) return const {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } on FormatException {
    return const {};
  }
}

DateTime? parseTime(String iso) => iso.isEmpty ? null : DateTime.tryParse(iso);

@immutable
class InboxPage {
  const InboxPage(this.notifications, this.cursor, this.unread);

  final List<InboxNotification> notifications;

  /// What to pass as `before` for the next page; empty at the end.
  final String cursor;
  final int unread;
}

enum EmailMode {
  off('off', 'Off'),
  instant('instant', 'Instant'),
  digest('digest', 'Daily digest');

  const EmailMode(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    off => l.grpMEmOff,
    instant => l.grpMEmInstant,
    digest => l.grpMEmDigest,
  };

  static EmailMode of(String wire) =>
      values.firstWhere((m) => m.wire == wire, orElse: () => off);
}

/// What one kind of event does for this person.
@immutable
class PrefRow {
  const PrefRow({
    required this.eventType,
    required this.label,
    required this.inbox,
    required this.push,
    required this.email,
  });

  final String eventType;
  final String label;
  final bool inbox;
  final bool push;
  final EmailMode email;

  NotificationKind get kind => NotificationKind.of(eventType);

  PrefRow copyWith({bool? inbox, bool? push, EmailMode? email}) => PrefRow(
    eventType: eventType,
    label: label,
    inbox: inbox ?? this.inbox,
    push: push ?? this.push,
    email: email ?? this.email,
  );

  @override
  bool operator ==(Object other) =>
      other is PrefRow &&
      other.eventType == eventType &&
      other.inbox == inbox &&
      other.push == push &&
      other.email == email;

  @override
  int get hashCode => Object.hash(eventType, inbox, push, email);
}

/// When this person may be disturbed. Quiet hours are `HH:MM` in [timezone].
@immutable
class InboxSettings {
  const InboxSettings({
    this.timezone = 'UTC',
    this.quietStart = '',
    this.quietEnd = '',
    this.digestHour = 8,
  });

  final String timezone;
  final String quietStart;
  final String quietEnd;
  final int digestHour;

  bool get quietOn => quietStart.isNotEmpty && quietEnd.isNotEmpty;

  InboxSettings copyWith({
    String? timezone,
    String? quietStart,
    String? quietEnd,
    int? digestHour,
  }) => InboxSettings(
    timezone: timezone ?? this.timezone,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    digestHour: digestHour ?? this.digestHour,
  );

  @override
  bool operator ==(Object other) =>
      other is InboxSettings &&
      other.timezone == timezone &&
      other.quietStart == quietStart &&
      other.quietEnd == quietEnd &&
      other.digestHour == digestHour;

  @override
  int get hashCode => Object.hash(timezone, quietStart, quietEnd, digestHour);
}

@immutable
class Prefs {
  const Prefs(this.rows, this.settings);

  final List<PrefRow> rows;
  final InboxSettings settings;

  PrefRow? of(String eventType) =>
      rows.where((r) => r.eventType == eventType).firstOrNull;
}

@immutable
class WatchState {
  const WatchState({this.watching = false, this.watcherCount = 0});

  final bool watching;
  final int watcherCount;
}

enum InboxFailure { network, denied, forbidden, invalid, notFound, other }

class InboxException implements Exception {
  const InboxException(this.failure, {this.detail});

  final InboxFailure failure;
  final String? detail;

  @override
  String toString() => 'InboxException($failure)';
}

String inboxErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! InboxException) return t.grpLGeneric;
  return switch (error.failure) {
    InboxFailure.network => t.grpLNetCheckShort,
    InboxFailure.denied || InboxFailure.forbidden => t.grpLNoAccess,
    InboxFailure.invalid =>
      error.detail == null || error.detail!.isEmpty
          ? t.grpLNotValid
          : error.detail!,
    InboxFailure.notFound => t.grpLNotifGone,
    InboxFailure.other => t.grpLGeneric,
  };
}

/// "now", "5 min ago", "3 h ago", "yesterday", "4 d ago", then the date.
String relativeTime(
  DateTime then,
  DateTime now, [
  AppLocalizations? l10n,
  LocalePrefs? prefs,
]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final diff = now.difference(then);
  if (diff.isNegative || diff.inSeconds < 45) return l.grpMRelNow;
  if (diff.inMinutes < 60) {
    return l.grpMRelMin(diff.inMinutes.clamp(1, 59));
  }
  if (diff.inHours < 24) return l.grpMRelHour(diff.inHours);
  if (diff.inDays == 1) return l.grpMRelYesterday;
  if (diff.inDays < 7) return l.grpMRelDay(diff.inDays);
  return dateOrIso(then.toLocal(), prefs: prefs, l10n: l10n);
}

/// "Later today" (18:00, or 2 h on when that is under half an hour away),
/// "Tomorrow" 09:00, "Next week" Monday 09:00 — all in local time.
List<({String label, DateTime at})> snoozePresets(
  DateTime now, {
  AppLocalizations? l10n,
}) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final today18 = DateTime(now.year, now.month, now.day, 18);
  final later = now.isBefore(today18.subtract(const Duration(minutes: 30)))
      ? today18
      : now.add(const Duration(hours: 2));
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
  final toMonday = DateTime.monday - now.weekday;
  final monday = DateTime(
    now.year,
    now.month,
    now.day + (toMonday <= 0 ? toMonday + 7 : toMonday),
    9,
  );
  return [
    (label: l.grpHSnoozeLaterToday, at: later),
    (label: l.grpHSnoozeTomorrow, at: tomorrow),
    (label: l.grpHSnoozeNextWeek, at: monday),
  ];
}
