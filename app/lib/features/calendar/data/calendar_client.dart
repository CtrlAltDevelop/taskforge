import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/gen/infrastructure/tasks/grpc/tasks.pbgrpc.dart'
    as pb;

abstract interface class CalendarClient {
  /// The tasks that fall on any day from [first] to [last] (inclusive).
  Future<List<Task>> listRange(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
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

  @override
  Future<List<Task>> listRange(
    String workspaceId,
    String projectId, {
    required Day first,
    required Day last,
    bool includeDone = true,
  }) => _run(() async {
    final seen = <String>{};
    return [
      await for (final t in _stub.listRange(
        pb.CalendarRangeRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          rangeStart: formatDay(first),
          rangeEnd: formatDay(last),
          includeDone: includeDone,
        ),
        options: _options,
      ))
        // A task edited between two chunks can come twice: show it once.
        if (seen.add(t.id)) taskFromPb(t),
    ];
  });

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
