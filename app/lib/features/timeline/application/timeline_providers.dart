import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart'
    show todayProvider;
import 'package:taskforge/features/calendar/data/calendar_client.dart'
    show CancelToken;
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/views/application/personal_layout.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/list_layout.dart'
    show personalLayoutName;
import 'package:taskforge/features/views/domain/timeline_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final timelineClientProvider = Provider<TimelineClient>(
  (ref) => GrpcTimelineClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

// --------------------------------------------------------------------- layout

typedef TimelineLayoutState = PersonalLayoutState<TimelineLayout>;

final timelineLayoutProvider = NotifierProvider.autoDispose
    .family<TimelineLayoutNotifier, TimelineLayoutState, String>(
      TimelineLayoutNotifier.new,
    );

class TimelineLayoutNotifier extends PersonalLayoutNotifier<TimelineLayout> {
  TimelineLayoutNotifier(String projectId)
    : super(projectId, const TimelineLayout());

  @override
  Future<StoredLayout<TimelineLayout>?> findMine(
    ViewsClient client,
    String workspace,
  ) async {
    final all = await client.listTimelines(workspace, projectId);
    final mine = all
        .where((c) => !c.isShared && c.name == personalLayoutName)
        .firstOrNull;
    return mine == null
        ? null
        : (id: mine.id, version: mine.version, layout: mine.layout);
  }

  @override
  Future<StoredLayout<TimelineLayout>> store(
    ViewsClient client,
    String workspace,
    TimelineLayout layout, {
    required String id,
    required int version,
  }) async {
    final saved = await client.saveTimeline(
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

TimelineZoom zoomOf(TimelineLayout layout) =>
    TimelineZoom.values.asNameMap()[layout.zoom] ?? TimelineZoom.week;

// -------------------------------------------------------------------- cursor

/// The day the chart is centred on when it reads.
final timelineAnchorProvider = NotifierProvider.autoDispose
    .family<TimelineAnchor, Day, String>(TimelineAnchor.new);

class TimelineAnchor extends Notifier<Day> {
  TimelineAnchor(this.projectId);

  final String projectId;

  @override
  Day build() => ref.read(todayProvider);

  void goTo(Day day) => state = day;

  void today() => state = ref.read(todayProvider);

  /// Half a read further on (or back with a negative [steps]).
  void shift(TimelineZoom zoom, int steps) =>
      state = addDays(state, steps * zoom.readDays ~/ 2);
}

// --------------------------------------------------------------------- tasks

@immutable
class TimelineState {
  const TimelineState({
    this.tasks = const [],
    this.links = const [],
    this.loading = true,
    this.error,
  });

  final List<Task> tasks;
  final List<TimelineLink> links;
  final bool loading;
  final TaskException? error;

  TimelineState copyWith({
    List<Task>? tasks,
    List<TimelineLink>? links,
    bool? loading,
    TaskException? Function()? error,
  }) => TimelineState(
    tasks: tasks ?? this.tasks,
    links: links ?? this.links,
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// A move whose dependents would have to move too, waiting for the person to
/// choose: shift them, or keep them where they are (and show the conflict).
@immutable
class ShiftPlan {
  const ShiftPlan(this.task, this.dates, this.shifts);

  final Task task;
  final Dates dates;
  final List<ShiftPreview> shifts;
}

/// The chart's tasks and links for the days around the anchor. An answer for a
/// range that was moved past is thrown away.
final timelineProvider = NotifierProvider.autoDispose
    .family<TimelineNotifier, TimelineState, String>(TimelineNotifier.new);

class TimelineNotifier extends Notifier<TimelineState> {
  TimelineNotifier(this.projectId);

  final String projectId;
  var _generation = 0;
  CancelToken? _reading;

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const TaskException(TaskFailure.other);
    return id;
  }

  @override
  TimelineState build() {
    ref.onDispose(() => _reading?.cancel());
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    final (loaded, zoom, hideDone) = ref.watch(
      timelineLayoutProvider(projectId)
          .select((s) => (s.loaded, zoomOf(s.layout), s.layout.hideDone)),
    );
    final filter = ref.watch(filterJsonProvider(projectId));
    final anchor = ref.watch(timelineAnchorProvider(projectId));
    if (loaded && ref.watch(filterReadyProvider(projectId))) {
      final range = readRange(zoom, anchor);
      Future.microtask(() => _load(range.first, range.last, hideDone, filter));
    }
    return stateOrNull?.copyWith(loading: true) ?? const TimelineState();
  }

  Future<void> _load(Day first, Day last, bool hideDone, String filter) async {
    final generation = ++_generation;
    if (!ref.mounted) return;
    _reading?.cancel();
    final token = _reading = CancelToken();
    state = state.copyWith(loading: true, error: () => null);
    try {
      final read = await ref
          .read(timelineClientProvider)
          .read(
            _workspace,
            projectId,
            first: first,
            last: last,
            includeDone: !hideDone,
            filterAst: filter,
            cancel: token,
          );
      if (generation != _generation || !ref.mounted) return;
      state = TimelineState(
        tasks: read.tasks,
        links: read.links,
        loading: false,
      );
    } on TaskException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Reads the chart again.
  void refresh() {
    final layout = ref.read(timelineLayoutProvider(projectId)).layout;
    final range = readRange(
      zoomOf(layout),
      ref.read(timelineAnchorProvider(projectId)),
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

  /// [state]'s tasks with each of [changed] swapped in. A task the chart does
  /// not show stays out (a dependent in another project, or outside the range)
  /// unless [add] and it belongs to this project (one scheduled from the tray).
  List<Task> _swap(Iterable<Task> changed, {bool add = false}) {
    final by = {for (final t in changed) t.id: t};
    final shown = {for (final t in state.tasks) t.id};
    return [
      for (final t in state.tasks) by[t.id] ?? t,
      if (add)
        for (final t in changed)
          if (!shown.contains(t.id) && t.projectId == projectId) t,
    ];
  }

  /// [task] back as it was: a task that had no dates leaves the chart again.
  List<Task> _restored(Task task) =>
      task.startDate.isEmpty && task.dueDate.isEmpty
      ? [
          for (final t in state.tasks)
            if (t.id != task.id) t,
        ]
      : _swap([task]);

  Task _dated(Task task, Dates dates) =>
      task.apply(TaskPatch(startDate: dates.startIso, dueDate: dates.dueIso));

  /// Gives [task] [dates]: the bar moves at once. When no dependent has to move
  /// it is saved and null comes back; else nothing is saved yet and the
  /// returned plan asks the person what to do. A refusal puts the task back and
  /// throws the [TaskException].
  Future<ShiftPlan?> propose(Task task, Dates dates) async {
    state = state.copyWith(tasks: _swap([_dated(task, dates)], add: true));
    try {
      final client = ref.read(timelineClientProvider);
      final shifts = await client.previewShift(_workspace, task, dates);
      if (shifts.isNotEmpty) return ShiftPlan(task, dates, shifts);
      final saved = await client.applyShift(_workspace, task, dates, const []);
      if (ref.mounted) state = state.copyWith(tasks: _swap(saved));
      return null;
    } on Object catch (e) {
      if (ref.mounted) state = state.copyWith(tasks: _restored(task));
      throw mapTaskError(e);
    }
  }

  /// Moves the planned task and its dependents together.
  Future<void> shiftDependents(ShiftPlan plan) async {
    state = state.copyWith(
      tasks: _swap([
        _dated(plan.task, plan.dates),
        for (final s in plan.shifts)
          _dated(
            s.task,
            Dates(start: parseDay(s.newStart), due: parseDay(s.newDue)),
          ),
      ]),
    );
    try {
      final saved = await ref.read(timelineClientProvider).applyShift(
        _workspace,
        plan.task,
        plan.dates,
        [for (final s in plan.shifts) s.task.id],
      );
      if (ref.mounted) state = state.copyWith(tasks: _swap(saved));
    } on Object catch (e) {
      if (ref.mounted) refresh(); // the preview may be stale: read it again
      throw mapTaskError(e);
    }
  }

  /// Moves only the planned task; its dependents keep their dates and the
  /// links they break show in red.
  Future<void> keepDependents(ShiftPlan plan) async {
    final patch = TaskPatch(
      startDate: plan.dates.startIso == plan.task.startDate
          ? null
          : plan.dates.startIso,
      dueDate: plan.dates.dueIso == plan.task.dueDate
          ? null
          : plan.dates.dueIso,
    );
    try {
      final saved = await ref
          .read(tasksClientProvider)
          .update(_workspace, plan.task, patch);
      if (ref.mounted) state = state.copyWith(tasks: _swap([saved]));
    } on Object catch (e) {
      if (ref.mounted) state = state.copyWith(tasks: _restored(plan.task));
      throw mapTaskError(e);
    }
  }

  /// Drops a plan: the bar goes back where it was.
  void discard(ShiftPlan plan) {
    state = state.copyWith(tasks: _restored(plan.task));
  }
}

// ------------------------------------------------------------- critical path

/// Ids of the tasks on the project's critical path, read when the layout
/// lights it and again after the chart changes.
final criticalPathProvider = FutureProvider.autoDispose
    .family<Set<String>, String>((ref, projectId) async {
      final on = ref.watch(
        timelineLayoutProvider(projectId).select((s) => s.layout.criticalPath),
      );
      final workspace = ref.watch(workspaceScopeProvider);
      ref.watch(timelineProvider(projectId).select((s) => s.tasks));
      if (!on || workspace == null) return const <String>{};
      final ids = await ref
          .read(timelineClientProvider)
          .criticalPath(workspace, projectId);
      return Set.unmodifiable(ids);
    });

// ------------------------------------------------------------- working days

final workingDaysProvider = FutureProvider.autoDispose<WorkingDays>((
  ref,
) async {
  final workspace = ref.watch(workspaceScopeProvider);
  if (workspace == null) return const WorkingDays();
  return ref.read(timelineClientProvider).workingDays(workspace);
});
