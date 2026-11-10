import 'dart:async';

import 'package:grpc/grpc.dart' show GrpcError, ResponseStream, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/gen/infrastructure/tasks/grpc/tasks.pbgrpc.dart'
    as pb;

/// Lets the caller stop a read that is no longer wanted (a month flipped past):
/// the call is cancelled, so the server stops streaming.
class CancelToken {
  final _done = Completer<void>();

  bool get isCancelled => _done.isCompleted;
  Future<void> get whenCancelled => _done.future;

  void cancel() {
    if (!_done.isCompleted) _done.complete();
  }
}

abstract interface class CalendarClient {
  /// The tasks that fall on any day from [first] to [last] (inclusive).
  Future<List<Task>> listRange(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    CancelToken? cancel,
  });

  /// The same across every project the viewer can open (archived ones left
  /// out), narrowed to [projectIds] when given.
  Future<List<Task>> listWorkspaceRange(
    String workspaceId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    List<String> projectIds = const [],
    CancelToken? cancel,
  });

  /// A page of the open tasks that have no dates (the tray).
  Future<({List<Task> tasks, String cursor})> listUnscheduled(
    String workspaceId,
    String projectId, {
    String cursor = '',
  });
}

class GrpcCalendarClient implements CalendarClient {
  GrpcCalendarClient(ClientChannelBase channel, this._session)
    : _stub = pb.CalendarControllerClient(channel);

  final pb.CalendarControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapTaskError(e);
    }
  }

  Future<List<Task>> _read(
    ResponseStream<pb.Task> call,
    CancelToken? cancel,
  ) async {
    final seen = <String>{};
    unawaited(cancel?.whenCancelled.then((_) => call.cancel()));
    try {
      return [
        await for (final t in call)
          // A task edited between two chunks can come twice: show it once.
          if (seen.add(t.id)) taskFromPb(t),
      ];
    } on GrpcError {
      if (cancel?.isCancelled ?? false) return const <Task>[]; // wanted no more
      rethrow;
    }
  }

  @override
  Future<List<Task>> listRange(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    CancelToken? cancel,
  }) => _run(
    () => _read(
      _stub.listRange(
        pb.CalendarRangeRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          rangeStart: formatDay(first),
          rangeEnd: formatDay(last),
          includeDone: includeDone,
        ),
        options: _options,
      ),
      cancel,
    ),
  );

  @override
  Future<List<Task>> listWorkspaceRange(
    String workspaceId, {
    required Day first,
    required Day last,
    bool includeDone = true,
    List<String> projectIds = const [],
    CancelToken? cancel,
  }) => _run(
    () => _read(
      _stub.listWorkspaceRange(
        pb.CalendarWorkspaceRangeRequest(
          workspaceId: workspaceId,
          rangeStart: formatDay(first),
          rangeEnd: formatDay(last),
          includeDone: includeDone,
          projectIds: projectIds,
        ),
        options: _options,
      ),
      cancel,
    ),
  );

  @override
  Future<({List<Task> tasks, String cursor})> listUnscheduled(
    String workspaceId,
    String projectId, {
    String cursor = '',
  }) => _run(() async {
    final page = await _stub.listUnscheduled(
      pb.CalendarTrayRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        cursor: cursor,
      ),
      options: _options,
    );
    return (
      tasks: List<Task>.unmodifiable(page.tasks.map(taskFromPb)),
      cursor: page.cursor,
    );
  });
}
