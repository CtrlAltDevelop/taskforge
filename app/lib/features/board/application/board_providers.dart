import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/board/data/board_client.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/application/personal_layout.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final boardClientProvider = Provider<BoardClient>(
  (ref) => GrpcBoardClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

// --------------------------------------------------------------------- layout

typedef BoardLayoutState = PersonalLayoutState<BoardLayout>;

/// The board layout of one project for this person: every change shows at once
/// and is saved a moment later as their own board layout.
final boardLayoutProvider = NotifierProvider.autoDispose
    .family<BoardLayoutNotifier, BoardLayoutState, String>(
      BoardLayoutNotifier.new,
    );

class BoardLayoutNotifier extends PersonalLayoutNotifier<BoardLayout> {
  BoardLayoutNotifier(String projectId) : super(projectId, const BoardLayout());

  @override
  Future<StoredLayout<BoardLayout>?> findMine(
    ViewsClient client,
    String workspace,
  ) async {
    final all = await client.listBoards(workspace, projectId);
    final mine = all
        .where((b) => !b.isShared && b.name == personalLayoutName)
        .firstOrNull;
    return mine == null
        ? null
        : (id: mine.id, version: mine.version, layout: mine.layout);
  }

  @override
  Future<StoredLayout<BoardLayout>> store(
    ViewsClient client,
    String workspace,
    BoardLayout layout, {
    required String id,
    required int version,
  }) async {
    final saved = await client.saveBoard(
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

// ---------------------------------------------------------------------- cards

@immutable
class BoardState {
  const BoardState({this.lanes = const [], this.loading = true, this.error});

  final List<BoardLane> lanes;
  final bool loading;
  final TaskException? error;

  BoardState copyWith({
    List<BoardLane>? lanes,
    bool? loading,
    TaskException? Function()? error,
  }) => BoardState(
    lanes: lanes ?? this.lanes,
    loading: loading ?? this.loading,
    error: error == null ? this.error : error(),
  );
}

/// The board of one project: its columns, their counts and the cards loaded so
/// far. A drop shows at once and is put back if the server refuses.
final boardProvider = NotifierProvider.autoDispose
    .family<BoardNotifier, BoardState, String>(BoardNotifier.new);

class BoardNotifier extends Notifier<BoardState> {
  BoardNotifier(this.projectId);

  final String projectId;
  var _generation = 0;
  var _moving = 0;

  /// A read finished while a drop was in flight: it may predate the drop, so
  /// it is not shown; the board is read again once the drops are done.
  var _readAfterMoves = false;
  final _paging = <String>{};

  BoardClient get _client => ref.read(boardClientProvider);

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const TaskException(TaskFailure.other);
    return id;
  }

  ({String groupBy, String swimlane}) get _query =>
      ref.read(boardLayoutProvider(projectId)).layout.query;

  @override
  BoardState build() {
    ref.watch(workspaceScopeProvider);
    ref.watch(refusalCountProvider);
    ref.watch(
      filterJsonProvider(projectId),
    ); // a new filter reads the board again
    ref.watch(boardLayoutProvider(projectId).select((s) => s.layout.query));
    if (ref.watch(boardLayoutProvider(projectId).select((s) => s.loaded))) {
      Future.microtask(load);
    }
    return const BoardState();
  }

  /// Reads the whole board again (the cards on screen stay until it is here).
  Future<void> load() async {
    final generation = ++_generation;
    state = state.copyWith(loading: true, error: () => null);
    try {
      final query = _query;
      final lanes = await _client.get(
        _workspace,
        projectId,
        groupBy: query.groupBy,
        swimlane: query.swimlane,
        filterAst: ref.read(filterJsonProvider(projectId)),
      );
      if (generation != _generation || !ref.mounted) return;
      if (_moving > 0) {
        _readAfterMoves = true;
        return;
      }
      state = BoardState(lanes: List.unmodifiable(lanes), loading: false);
    } on TaskException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  Future<void> refresh() => load();

  /// Loads the next page of one column.
  Future<void> loadMore(String laneKey, String columnKey) async {
    final id = '$laneKey|$columnKey';
    final column = state.lanes
        .where((l) => l.key == laneKey)
        .expand((l) => l.columns)
        .where((c) => c.key == columnKey)
        .firstOrNull;
    if (column == null || !column.hasMore || !_paging.add(id)) return;
    final generation = _generation;
    try {
      final query = _query;
      final page = await _client.listColumn(
        _workspace,
        projectId,
        groupBy: query.groupBy,
        column: columnKey,
        swimlane: query.swimlane,
        lane: laneKey,
        cursor: column.cursor,
        filterAst: ref.read(filterJsonProvider(projectId)),
      );
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(
        lanes: appendPage(
          state.lanes,
          laneKey: laneKey,
          columnKey: columnKey,
          tasks: page.tasks,
          cursor: page.cursor,
        ),
      );
    } on TaskException {
      // The next scroll tries again.
    } finally {
      _paging.remove(id);
    }
  }

  /// Drops [task] in [column] of lane [laneKey]: right before [beforeId], else
  /// right after [afterId], else last. The board changes at once; a refusal
  /// puts it back and throws the [TaskException].
  Future<Task> move(
    Task task, {
    required String laneKey,
    required String column,
    String beforeId = '',
    String afterId = '',
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async {
    final before = state.lanes;
    state = state.copyWith(
      lanes: dropCard(
        state.lanes,
        task,
        laneKey: laneKey,
        toColumn: column,
        beforeId: beforeId,
        afterId: afterId,
      ),
    );
    _moving++;
    try {
      final saved = await _client.move(
        _workspace,
        task,
        groupBy: _query.groupBy,
        column: column,
        beforeId: beforeId,
        afterId: afterId,
        includeSubtasks: includeSubtasks,
        overrideBlocked: overrideBlocked,
      );
      if (ref.mounted) {
        state = state.copyWith(lanes: replaceCard(state.lanes, saved));
      }
      return saved;
    } on Object catch (e) {
      final mapped = mapTaskError(e);
      if (ref.mounted) {
        // Alone in flight: the board as it was. Otherwise another drop would
        // be undone with it, so read the truth again.
        if (_moving == 1) {
          state = state.copyWith(lanes: before);
        } else {
          unawaited(load());
        }
      }
      throw mapped;
    } finally {
      _moving--;
      if (_moving == 0 && _readAfterMoves && ref.mounted) {
        _readAfterMoves = false;
        unawaited(load());
      }
    }
  }

  /// Adds a task to the end of [column] (of lane [laneKey]) with that column's
  /// value, and shows it there.
  Future<Task> add(
    String title, {
    required String laneKey,
    required String column,
  }) async {
    final query = _query;
    final field = query.groupBy.startsWith(fieldColumnPrefix)
        ? query.groupBy.substring(fieldColumnPrefix.length)
        : '';
    final assignee = query.groupBy == 'assignee' ? column : laneKey;
    final created = await ref
        .read(tasksClientProvider)
        .create(
          _workspace,
          projectId,
          title: title,
          priority: query.groupBy == 'priority'
              ? TaskPriority.parse(column)
              : TaskPriority.none,
          assigneeIds: assignee.isEmpty ? const [] : [assignee],
          statusId: query.groupBy == 'status' ? column : '',
          fieldValues: field.isEmpty || column.isEmpty
              ? const {}
              : {field: column},
        );
    if (ref.mounted) {
      state = state.copyWith(
        lanes: dropCard(
          state.lanes,
          created,
          laneKey: laneKey,
          toColumn: column,
        ),
      );
    }
    return created;
  }
}

/// The columns folded shut on one project's board (column keys).
final collapsedColumnsProvider = NotifierProvider.autoDispose
    .family<CollapsedColumns, Set<String>, String>(CollapsedColumns.new);

class CollapsedColumns extends Notifier<Set<String>> {
  CollapsedColumns(this.projectId);

  final String projectId;

  @override
  Set<String> build() => const {};

  void toggle(String key) =>
      state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
}
