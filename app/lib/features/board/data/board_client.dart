import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/gen/infrastructure/tasks/grpc/tasks.pbgrpc.dart'
    as pb;

/// How many cards a column is asked for at a time.
const boardPageSize = 30;

abstract interface class BoardClient {
  /// Every lane (one, with an empty key, without swimlanes) with its columns,
  /// their counts and their first cards.
  Future<List<BoardLane>> get(
    String workspaceId,
    String projectId, {
    required String groupBy,
    String swimlane = '',
  });

  /// The cards of [column] after [cursor] (of [lane]'s cell with swimlanes).
  Future<({List<Task> tasks, String cursor})> listColumn(
    String workspaceId,
    String projectId, {
    required String groupBy,
    required String column,
    String swimlane = '',
    String lane = '',
    String cursor = '',
  });

  /// Drops [task] in [column]: right before [beforeId], else right after
  /// [afterId], else last. A different column changes the task's field like
  /// any edit (a refusal is a [TaskException]).
  Future<Task> move(
    String workspaceId,
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  });
}

class GrpcBoardClient implements BoardClient {
  GrpcBoardClient(ClientChannelBase channel, this._session, {this.onRefusal})
    : _stub = pb.BoardControllerClient(channel);

  final pb.BoardControllerClient _stub;
  final AuthSession _session;

  /// Called when a move is refused (permissions may be stale).
  final void Function()? onRefusal;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapTaskError(e);
      if (!isRead &&
          (mapped.failure == TaskFailure.denied ||
              mapped.failure == TaskFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Future<List<BoardLane>> get(
    String workspaceId,
    String projectId, {
    required String groupBy,
    String swimlane = '',
  }) => _run(() async {
    final view = await _stub.get(
      pb.BoardGetRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        groupBy: groupBy,
        swimlane: swimlane,
        pageSize: boardPageSize,
      ),
      options: _options,
    );
    return [
      for (final lane in view.lanes)
        BoardLane(
          key: lane.key,
          columns: [
            for (final c in lane.columns)
              BoardColumn(
                key: c.key,
                name: c.name,
                count: c.count,
                tasks: List.unmodifiable(c.tasks.map(taskFromPb)),
                cursor: c.cursor,
              ),
          ],
        ),
    ];
  }, isRead: true);

  @override
  Future<({List<Task> tasks, String cursor})> listColumn(
    String workspaceId,
    String projectId, {
    required String groupBy,
    required String column,
    String swimlane = '',
    String lane = '',
    String cursor = '',
  }) => _run(() async {
    final page = await _stub.listColumn(
      pb.BoardListColumnRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        groupBy: groupBy,
        column: column,
        swimlane: swimlane,
        lane: lane,
        cursor: cursor,
        pageSize: boardPageSize,
      ),
      options: _options,
    );
    return (
      tasks: List<Task>.unmodifiable(page.tasks.map(taskFromPb)),
      cursor: page.cursor,
    );
  }, isRead: true);

  @override
  Future<Task> move(
    String workspaceId,
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async => taskFromPb(
    await _run(
      () => _stub.move(
        pb.BoardMoveRequest(
          workspaceId: workspaceId,
          projectId: task.projectId,
          id: task.id,
          expectedVersion: task.version,
          groupBy: groupBy,
          column: column,
          beforeId: beforeId,
          afterId: afterId,
          includeSubtasks: includeSubtasks,
          overrideBlocked: overrideBlocked,
        ),
        options: _options,
      ),
    ),
  );
}
