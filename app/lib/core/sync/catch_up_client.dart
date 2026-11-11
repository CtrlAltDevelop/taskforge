import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/sync/sync_client.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/gen/infrastructure/sync/grpc/sync.pbgrpc.dart' as pb;

/// Reads the change log: where it is now, and what happened after a cursor.
abstract interface class CatchUpClient {
  Future<int> head(String workspaceId);

  /// Everything after [cursor] this person may see. A cursor older than the
  /// log comes back as a gap.
  Future<CatchUp> since(String workspaceId, int cursor);
}

class GrpcCatchUpClient implements CatchUpClient {
  GrpcCatchUpClient(ClientChannelBase channel, this._session)
    : _stub = pb.SyncControllerClient(channel);

  final pb.SyncControllerClient _stub;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      if (e.code != StatusCode.unauthenticated) rethrow;
      if (await _session.forceRefresh() == null) rethrow;
      return call();
    }
  }

  @override
  Future<int> head(String workspaceId) => _run(() async {
    final reply = await _stub.head(
      pb.SyncHeadRequest(workspaceId: workspaceId),
      options: _options,
    );
    return int.tryParse(reply.cursor) ?? 0;
  });

  /// A read that is still going on after this many pages is a lot to replay:
  /// say so as a gap and let the screens read themselves again.
  static const _maxPages = 10;

  /// How far before the cursor the first read starts again: ids can land a little out of
  /// commit order, and entries are idempotent hints, so reading a few dozen twice costs nothing.
  static const overlap = 50;

  @override
  Future<CatchUp> since(String workspaceId, int cursor) async {
    final events = <SyncEvent>[];
    var head = cursor;
    for (var page = 0; page < _maxPages; page++) {
      final read = await _page(workspaceId, head, page == 0 ? overlap : 0);
      events.addAll(read.events);
      head = read.head;
      if (read.gap) return CatchUp(head: head, gap: true);
      if (!read.more) return CatchUp(events: events, head: head);
    }
    return CatchUp(head: head, gap: true);
  }

  Future<({List<SyncEvent> events, int head, bool gap, bool more})> _page(
    String workspaceId,
    int cursor,
    int overlap,
  ) => _run(() async {
    final events = <SyncEvent>[];
    var head = cursor;
    var gap = false;
    var more = false;
    await for (final e in _stub.since(
      pb.SyncSinceRequest(
        workspaceId: workspaceId,
        cursor: '$cursor',
        limit: 5000,
        overlap: overlap,
      ),
      options: _options,
    )) {
      final at = int.tryParse(e.cursor) ?? 0;
      if (e.type == SyncEvent.gapType) {
        gap = true;
        head = at;
      } else if (e.type == 'sync.more') {
        more = true;
        head = at;
      } else {
        if (at > head) head = at;
        events.add(
          SyncEvent(
            type: e.type,
            workspace: workspaceId,
            project: e.projectId,
            entityId: e.entityId,
            version: e.version,
            actor: e.actor,
            cursor: at,
          ),
        );
      }
    }
    return (events: events, head: head, gap: gap, more: more);
  });
}
