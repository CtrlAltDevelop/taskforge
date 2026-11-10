import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/calendar/data/calendar_client.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/personal_layout.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/calendar_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final calendarClientProvider = Provider<CalendarClient>(
  (ref) => GrpcCalendarClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Today, as a calendar day (overridden in tests).
final todayProvider = Provider<Day>((ref) => dayOf(DateTime.now()));

/// The weekday (ISO) the viewer's locale starts its weeks on; the screen sets it
/// from the locale, the layout can override it.
final localeWeekStartProvider = NotifierProvider<LocaleWeekStart, int>(
  LocaleWeekStart.new,
);

class LocaleWeekStart extends Notifier<int> {
  @override
  int build() => DateTime.monday;

  void set(int isoWeekday) => state = isoWeekday;
}

// --------------------------------------------------------------------- layout

typedef CalendarLayoutState = PersonalLayoutState<CalendarLayout>;

final calendarLayoutProvider = NotifierProvider.autoDispose
    .family<CalendarLayoutNotifier, CalendarLayoutState, String>(
      CalendarLayoutNotifier.new,
    );

class CalendarLayoutNotifier extends PersonalLayoutNotifier<CalendarLayout> {
  CalendarLayoutNotifier(String projectId)
    : super(
        projectId,
        // The calendar of every project starts by colouring per project.
        projectId.isEmpty
            ? const CalendarLayout(colorBy: 'project')
            : const CalendarLayout(),
      );

  /// The workspace-wide calendar (no project) keeps its choices for the
  /// session only: there is no project to store a layout under.
  bool get _sessionOnly => projectId.isEmpty;

  @override
  bool get keepAlive => _sessionOnly;

  @override
  bool get persists => !_sessionOnly;

  @override
  Future<StoredLayout<CalendarLayout>?> findMine(
    ViewsClient client,
    String workspace,
  ) async {
    if (_sessionOnly) return null;
    final all = await client.listCalendars(workspace, projectId);
    final mine = all
        .where((c) => !c.isShared && c.name == personalLayoutName)
        .firstOrNull;
    return mine == null
        ? null
        : (id: mine.id, version: mine.version, layout: mine.layout);
  }

  @override
  Future<StoredLayout<CalendarLayout>> store(
    ViewsClient client,
    String workspace,
    CalendarLayout layout, {
    required String id,
    required int version,
  }) async {
    if (_sessionOnly) return (id: '', version: 0, layout: layout);
    final saved = await client.saveCalendar(
      workspace,
      projectId,
      name: personalLayoutName,
      layout: layout,
      id: id,
      expectedVersion: version,
    );
    return (id: saved.id, version: saved.version, layout: saved.layout);
  }
}

/// The weekday a week begins on for this project's calendar.
final weekStartProvider = Provider.autoDispose.family<int, String>((
  ref,
  projectId,
) {
  final chosen = ref.watch(
    calendarLayoutProvider(projectId).select((s) => s.layout.weekStart),
  );
  return chosen == 0 ? ref.watch(localeWeekStartProvider) : chosen;
});

CalendarMode modeOf(CalendarLayout layout) =>
    CalendarMode.values.asNameMap()[layout.mode] ?? CalendarMode.month;

/// Whether the screen is a phone: its agenda always reads a whole month, whatever
/// mode the person picked on a bigger screen. Set by the calendar screen.
final compactCalendarProvider = NotifierProvider<CompactCalendar, bool>(
  CompactCalendar.new,
);

class CompactCalendar extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool compact) {
    if (compact != state) state = compact;
  }
}

/// The mode the screen really shows.
CalendarMode shownMode(CalendarLayout layout, {required bool compact}) =>
    compact ? CalendarMode.month : modeOf(layout);

// -------------------------------------------------------------------- cursor

/// The day the calendar is looking at (any day of the month or week shown).
final calendarAnchorProvider = NotifierProvider.autoDispose
    .family<CalendarAnchor, Day, String>(CalendarAnchor.new);

class CalendarAnchor extends Notifier<Day> {
  CalendarAnchor(this.projectId);

  final String projectId;

  @override
  Day build() {
    // The all-projects calendar remembers where it was.
    if (projectId.isEmpty) ref.keepAlive();
    return ref.read(todayProvider);
  }

  void goTo(Day day) => state = day;

  void today() => state = ref.read(todayProvider);

  void shift(CalendarMode mode, int steps) => state = step(mode, state, steps);
}

/// The projects hidden from the workspace calendar (their ids).
final hiddenProjectsProvider = NotifierProvider<HiddenProjects, Set<String>>(
  HiddenProjects.new,
);

class HiddenProjects extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

// --------------------------------------------------------------------- tasks

@immutable
class CalendarState {
  const CalendarState({this.tasks = const [], this.loading = true, this.error});

  final List<Task> tasks;
  final bool loading;
  final TaskException? error;

  CalendarState copyWith({
    List<Task>? tasks,
    bool? loading,
    TaskException? Function()? error,
  }) => CalendarState(
    tasks: tasks ?? this.tasks,
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// The tasks on the days the calendar shows (the project's, or every visible
/// project's for the workspace calendar, whose scope is the empty string). Only that range is asked for, and
/// an answer for a range that was flipped past is thrown away.
final calendarProvider = NotifierProvider.autoDispose
    .family<CalendarNotifier, CalendarState, String>(CalendarNotifier.new);

class CalendarNotifier extends Notifier<CalendarState> {
  CalendarNotifier(this.projectId);

  final String projectId;
  var _generation = 0;
  CancelToken? _reading;

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const TaskException(TaskFailure.other);
    return id;
  }

  @override
  CalendarState build() {
    ref.onDispose(() => _reading?.cancel());
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    // Only what changes the days asked for (not the colours, not a save).
    final (loaded, mode, hideDone) = ref.watch(
      calendarLayoutProvider(projectId)
          .select((s) => (s.loaded, s.layout.mode, s.layout.hideDone)),
    );
    final compact = ref.watch(compactCalendarProvider);
    final filter = ref.watch(filterJsonProvider(projectId));
    final anchor = ref.watch(calendarAnchorProvider(projectId));
    final weekStart = ref.watch(weekStartProvider(projectId));
    if (loaded && ref.watch(filterReadyProvider(projectId))) {
      final range = visibleRange(
        shownMode(CalendarLayout(mode: mode), compact: compact),
        anchor,
        weekStart,
      );
      Future.microtask(() => _load(range.first, range.last, hideDone, filter));
    }
    // The tasks on screen stay while the next range is read.
    return stateOrNull?.copyWith(loading: true) ?? const CalendarState();
  }

  Future<void> _load(Day first, Day last, bool hideDone, String filter) async {
    final generation = ++_generation;
    if (!ref.mounted) return;
    _reading?.cancel(); // the range before this one is no longer wanted
    final token = _reading = CancelToken();
    state = state.copyWith(loading: true, error: () => null);
    try {
      final client = ref.read(calendarClientProvider);
      final tasks = projectId.isEmpty
          ? await client.listWorkspaceRange(
              _workspace,
              first: first,
              last: last,
              includeDone: !hideDone,
              filterAst: filter,
              cancel: token,
            )
          : await client.listRange(
              _workspace,
              projectId,
              first: first,
              last: last,
              includeDone: !hideDone,
              filterAst: filter,
              cancel: token,
            );
      if (generation != _generation || !ref.mounted) return;
      state = CalendarState(tasks: List.unmodifiable(tasks), loading: false);
    } on TaskException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Reads the days on screen again.
  void refresh() {
    final layout = ref.read(calendarLayoutProvider(projectId)).layout;
    final range = visibleRange(
      shownMode(layout, compact: ref.read(compactCalendarProvider)),
      ref.read(calendarAnchorProvider(projectId)),
      ref.read(weekStartProvider(projectId)),
    );
    unawaited(
      _load(
        range.first,
        range.last,
        layout.hideDone,
        ref.read(filterJsonProvider(projectId)),
      ),
    );
  }

  /// Gives [task] [dates]. The calendar shows it at once; a refusal puts that
  /// task back and throws the [TaskException]. Returns the saved task.
  Future<Task> reschedule(Task task, Dates dates) async {
    final patch = TaskPatch(
      startDate: dates.startIso == task.startDate ? null : dates.startIso,
      dueDate: dates.dueIso == task.dueDate ? null : dates.dueIso,
    );
    state = state.copyWith(tasks: _swap(task.id, task.apply(patch), add: true));
    try {
      final saved = await ref
          .read(tasksClientProvider)
          .update(_workspace, task, patch);
      if (ref.mounted) {
        state = state.copyWith(tasks: _swap(task.id, saved, add: true));
      }
      return saved;
    } on Object catch (e) {
      final mapped = mapTaskError(e);
      if (ref.mounted) {
        state = state.copyWith(tasks: _swap(task.id, task, add: true));
      }
      throw mapped;
    }
  }

  /// [state]'s tasks with [id] swapped for [task] (or added when absent).
  List<Task> _swap(String id, Task task, {required bool add}) {
    final found = state.tasks.any((t) => t.id == id);
    if (!found) return add ? [...state.tasks, task] : state.tasks;
    return [for (final t in state.tasks) t.id == id ? task : t];
  }
}

// ---------------------------------------------------------------------- tray

@immutable
class TrayState {
  const TrayState({
    this.tasks = const [],
    this.cursor = '',
    this.loading = true,
    this.error,
  });

  final List<Task> tasks;
  final String cursor;
  final bool loading;
  final TaskException? error;

  bool get hasMore => cursor.isNotEmpty;
}

/// Open tasks with no dates, a page at a time, to be dragged onto a day.
final trayProvider = NotifierProvider.autoDispose
    .family<TrayNotifier, TrayState, String>(TrayNotifier.new);

class TrayNotifier extends Notifier<TrayState> {
  TrayNotifier(this.projectId);

  final String projectId;
  var _generation = 0;
  var _paging = false;

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const TaskException(TaskFailure.other);
    return id;
  }

  @override
  TrayState build() {
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    Future.microtask(load);
    return const TrayState();
  }

  Future<void> load() async {
    final generation = ++_generation;
    try {
      final page = await ref
          .read(calendarClientProvider)
          .listUnscheduled(_workspace, projectId);
      if (generation != _generation || !ref.mounted) return;
      state = TrayState(
        tasks: List.unmodifiable(page.tasks),
        cursor: page.cursor,
        loading: false,
      );
    } on TaskException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = TrayState(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || _paging) return;
    _paging = true;
    final generation = _generation;
    try {
      final page = await ref
          .read(calendarClientProvider)
          .listUnscheduled(_workspace, projectId, cursor: state.cursor);
      if (generation != _generation || !ref.mounted) return;
      final shown = {for (final t in state.tasks) t.id};
      state = TrayState(
        tasks: List.unmodifiable([
          ...state.tasks,
          for (final t in page.tasks)
            if (!shown.contains(t.id)) t,
        ]),
        cursor: page.cursor,
        loading: false,
      );
    } on TaskException {
      // The next scroll tries again.
    } finally {
      _paging = false;
    }
  }

  void remove(String taskId) {
    state = TrayState(
      tasks: List.unmodifiable([
        for (final t in state.tasks)
          if (t.id != taskId) t,
      ]),
      cursor: state.cursor,
      loading: false,
    );
  }

  /// Puts [task] back (a scheduling that failed), first in the tray.
  void restore(Task task) {
    if (state.tasks.any((t) => t.id == task.id)) return;
    state = TrayState(
      tasks: List.unmodifiable([task, ...state.tasks]),
      cursor: state.cursor,
      loading: false,
    );
  }
}
