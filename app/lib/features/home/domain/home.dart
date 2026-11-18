import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

/// A task as Home and My work list it: just enough to show a row and open it.
@immutable
class HomeTask {
  const HomeTask({
    required this.taskId,
    required this.projectId,
    required this.projectKey,
    required this.number,
    required this.title,
    this.statusName = '',
    this.statusCategory = '',
    this.priority = '',
    this.dueDate = '',
  });

  final String taskId;
  final String projectId;
  final String projectKey;
  final int number;
  final String title;
  final String statusName;

  /// `not_started`, `active` or `done` (the workflow category).
  final String statusCategory;
  final String priority;

  /// ISO date, '' when none.
  final String dueDate;

  /// `KEY-N`.
  String get displayId => '$projectKey-$number';

  bool get isDone => statusCategory == 'done';
}

@immutable
class HomeMention {
  const HomeMention({
    required this.id,
    required this.type,
    required this.taskId,
    required this.createdAt,
    required this.read,
    this.actorId = '',
    this.payloadJson = '',
  });

  final String id;
  final String type;
  final String taskId;
  final String actorId;
  final String createdAt;
  final bool read;
  final String payloadJson;
}

@immutable
class HomePin {
  const HomePin({
    required this.dashboardId,
    required this.name,
    required this.projectId,
  });

  final String dashboardId;
  final String name;
  final String projectId;
}

/// Seconds logged on one day of the week.
@immutable
class HomeDay {
  const HomeDay({required this.date, required this.seconds});

  final String date;
  final int seconds;
}

/// The whole Home screen in one answer.
@immutable
class HomeSummary {
  const HomeSummary({
    this.todayCount = 0,
    this.overdueCount = 0,
    this.inProgressCount = 0,
    this.dueItems = const [],
    this.inProgressItems = const [],
    this.recent = const [],
    this.mentions = const [],
    this.unreadNotifications = 0,
    this.unreadChat = 0,
    this.week = const [],
    this.pinned = const [],
    this.computedAt = '',
  });

  final int todayCount;
  final int overdueCount;
  final int inProgressCount;
  final List<HomeTask> dueItems;
  final List<HomeTask> inProgressItems;
  final List<HomeTask> recent;
  final List<HomeMention> mentions;
  final int unreadNotifications;
  final int unreadChat;
  final List<HomeDay> week;
  final List<HomePin> pinned;
  final String computedAt;

  int get weekSeconds => week.fold(0, (n, d) => n + d.seconds);
}

/// Who a My work row is mine through.
enum MyWorkRelation {
  both(''),
  assigned('assigned'),
  watching('watching');

  const MyWorkRelation(this.wire);

  final String wire;
}

@immutable
class MyWorkItem {
  const MyWorkItem({
    required this.task,
    required this.assigned,
    required this.watching,
  });

  final HomeTask task;
  final bool assigned;
  final bool watching;
}

@immutable
class MyWorkPage {
  const MyWorkPage(this.items, {this.nextCursor = ''});

  static const empty = MyWorkPage([]);

  final List<MyWorkItem> items;

  /// '' on the last page.
  final String nextCursor;

  bool get hasMore => nextCursor.isNotEmpty;

  MyWorkPage plus(MyWorkPage next) =>
      MyWorkPage([...items, ...next.items], nextCursor: next.nextCursor);
}

/// What My work asks for; a new value starts the list again.
@immutable
class MyWorkQuery {
  const MyWorkQuery({
    this.relation = MyWorkRelation.both,
    this.includeDone = false,
    this.filterAst = '',
  });

  final MyWorkRelation relation;
  final bool includeDone;
  final String filterAst;

  @override
  bool operator ==(Object other) =>
      other is MyWorkQuery &&
      other.relation == relation &&
      other.includeDone == includeDone &&
      other.filterAst == filterAst;

  @override
  int get hashCode => Object.hash(relation, includeDone, filterAst);
}

/// The four first-run checklist steps, in the order shown.
const checklistSteps = [
  'create_task',
  'invite_member',
  'try_board',
  'open_palette',
];

@immutable
class OnboardingStarter {
  const OnboardingStarter({
    required this.key,
    required this.name,
    this.description = '',
  });

  final String key;
  final String name;
  final String description;
}

@immutable
class OnboardingState {
  const OnboardingState({
    this.steps = const {},
    this.dismissed = false,
    this.complete = false,
    this.visible = false,
    this.sampleProjectId = '',
    this.sampleCount = 0,
    this.starters = const [],
  });

  /// Step name -> done.
  final Map<String, bool> steps;
  final bool dismissed;
  final bool complete;

  /// The checklist card shows only while this is true.
  final bool visible;
  final String sampleProjectId;
  final int sampleCount;
  final List<OnboardingStarter> starters;

  bool done(String step) => steps[step] ?? false;
  int get doneCount => steps.values.where((v) => v).length;
}

enum HomeFailure { network, denied, invalid, notFound, other }

class HomeException implements Exception {
  const HomeException(this.failure, {this.detail});

  final HomeFailure failure;
  final String? detail;

  @override
  String toString() => 'HomeException($failure)';
}

String homeErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! HomeException) return t.homeCardFailed;
  return switch (error.failure) {
    HomeFailure.network => t.grpLNetCheckShort,
    HomeFailure.denied => t.sysNoAccessTitle,
    HomeFailure.invalid =>
      error.detail != null && error.detail!.isNotEmpty
          ? error.detail!
          : t.grpLNotValid,
    HomeFailure.notFound || HomeFailure.other => t.homeCardFailed,
  };
}
