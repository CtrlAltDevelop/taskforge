import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/audit/data/audit_client.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show TaskRef;
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final auditClientProvider = Provider<AuditClient>(
  (ref) => GrpcAuditClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Entries read so far, newest first, with names for their ids.
@immutable
class AuditListState {
  const AuditListState({
    this.entries = const [],
    this.labels = const {},
    this.nextBefore = 0,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<AuditEntry> entries;
  final Map<String, String> labels;
  final int nextBefore;
  final bool loading;
  final bool loadingMore;
  final Object? error;
  bool get hasMore => nextBefore != 0;

  AuditListState copyWith({
    List<AuditEntry>? entries,
    Map<String, String>? labels,
    int? nextBefore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) => AuditListState(
    entries: entries ?? this.entries,
    labels: labels ?? this.labels,
    nextBefore: nextBefore ?? this.nextBefore,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
  );
}

/// The paged admin log: the first page on creation, `more()` for the next.
/// Pages are asked for by entry id, so a page never shifts while new entries
/// arrive.
class AuditListNotifier extends Notifier<AuditListState> {
  AuditListNotifier(this.filters);

  final AuditFilters filters;
  var _generation = 0;

  @override
  AuditListState build() {
    final ws = ref.watch(workspaceScopeProvider);
    Future.microtask(() => _first(ws));
    return const AuditListState();
  }

  Future<AuditPage> _read(String ws, int before) =>
      ref.read(auditClientProvider).list(ws, filters, before: before);

  Future<void> _first(String? ws) async {
    final generation = ++_generation;
    if (ws == null) {
      state = const AuditListState(loading: false);
      return;
    }
    try {
      final page = await _read(ws, 0);
      if (generation != _generation) return;
      state = AuditListState(
        entries: page.entries,
        labels: page.labels,
        nextBefore: page.nextBefore,
        loading: false,
      );
    } on Object catch (e) {
      if (generation != _generation) return;
      state = AuditListState(loading: false, error: e);
    }
  }

  Future<void> refresh() => _first(ref.read(workspaceScopeProvider));

  Future<void> more() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null || !state.hasMore || state.loadingMore) return;
    final generation = _generation;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final page = await _read(ws, state.nextBefore);
      if (generation != _generation) return;
      state = state.copyWith(
        entries: [...state.entries, ...page.entries],
        labels: {...state.labels, ...page.labels},
        nextBefore: page.nextBefore,
        loadingMore: false,
      );
    } on Object catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(loadingMore: false, error: e);
    }
  }
}

final auditListProvider = NotifierProvider.autoDispose
    .family<AuditListNotifier, AuditListState, AuditFilters>(
      AuditListNotifier.new,
    );

/// One task's history, newest first.
class TaskActivityNotifier extends Notifier<AuditListState> {
  TaskActivityNotifier(this.task);

  final TaskRef task;
  var _generation = 0;

  @override
  AuditListState build() {
    final ws = ref.watch(workspaceScopeProvider);
    // Any save of this task (here, or another device's reaching the list)
    // adds a line: read the history again when its version moves.
    ref.listen<int?>(
      taskListProvider(task.project).select(
        (s) => s.tasks.where((t) => t.id == task.task).firstOrNull?.version,
      ),
      (previous, next) {
        if (previous != null && next != previous) unawaited(refresh());
      },
    );
    Future.microtask(() => _first(ws));
    return const AuditListState();
  }

  Future<AuditPage> _read(String ws, int before) => ref
      .read(auditClientProvider)
      .forTask(ws, task.project, task.task, before: before);

  Future<void> _first(String? ws) async {
    final generation = ++_generation;
    if (ws == null) {
      state = const AuditListState(loading: false);
      return;
    }
    try {
      final page = await _read(ws, 0);
      if (generation != _generation) return;
      state = AuditListState(
        entries: page.entries,
        labels: page.labels,
        nextBefore: page.nextBefore,
        loading: false,
      );
    } on Object catch (e) {
      if (generation != _generation) return;
      // Keep what is on screen when a re-read fails.
      state = state.copyWith(loading: false, loadingMore: false, error: e);
    }
  }

  Future<void> refresh() => _first(ref.read(workspaceScopeProvider));

  Future<void> more() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null || !state.hasMore || state.loadingMore) return;
    final generation = _generation;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final page = await _read(ws, state.nextBefore);
      if (generation != _generation) return;
      state = state.copyWith(
        entries: [...state.entries, ...page.entries],
        labels: {...state.labels, ...page.labels},
        nextBefore: page.nextBefore,
        loadingMore: false,
      );
    } on Object catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(loadingMore: false, error: e);
    }
  }
}

final taskActivityProvider = NotifierProvider.autoDispose
    .family<TaskActivityNotifier, AuditListState, TaskRef>(
      TaskActivityNotifier.new,
    );

/// The export button: the filtered log as CSV text.
final auditExportProvider = Provider<Future<String> Function(AuditFilters)>((
  ref,
) {
  return (filters) {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return Future.value('');
    return ref.read(auditClientProvider).exportCsv(ws, filters);
  };
});

/// "Now" for the relative times (tests bring their own).
final auditNowProvider = Provider<DateTime Function()>((_) => DateTime.now);
