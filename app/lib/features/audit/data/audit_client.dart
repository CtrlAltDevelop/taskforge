import 'package:fixnum/fixnum.dart' show Int64;
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/gen/infrastructure/audit/grpc/audit.pbgrpc.dart'
    as pb;

abstract interface class AuditClient {
  /// The workspace's log (needs `audit.view`), newest first; [before] is the
  /// last id of the previous page.
  Future<AuditPage> list(
    String workspaceId,
    AuditFilters filters, {
    int before = 0,
    int limit = 0,
  });

  /// The filtered log as CSV text, assembled from the server's stream.
  Future<String> exportCsv(String workspaceId, AuditFilters filters);

  /// A task's history, for anyone who can open it.
  Future<AuditPage> forTask(
    String workspaceId,
    String projectId,
    String taskId, {
    int before = 0,
    int limit = 0,
  });
}

AuditException mapAuditError(Object error) {
  if (error is AuditException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.permissionDenied => const AuditException(AuditFailure.denied),
      StatusCode.notFound => const AuditException(AuditFailure.notFound),
      StatusCode.invalidArgument => AuditException(
        AuditFailure.invalid,
        detail: message,
      ),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const AuditException(AuditFailure.network),
      _ => const AuditException(AuditFailure.other),
    };
  }
  return const AuditException(AuditFailure.network);
}

AuditPage pageFromPb(pb.AuditPage p) => AuditPage(
  entries: List.unmodifiable([
    for (final e in p.entries)
      AuditEntry(
        id: e.id.toInt(),
        at: DateTime.tryParse(e.at) ?? DateTime.fromMillisecondsSinceEpoch(0),
        actor: e.actor,
        actorName: e.actorName,
        actorType: e.actorType,
        action: e.action,
        targetType: e.targetType,
        targetId: e.targetId,
        projectId: e.projectId,
        batchId: e.batchId,
        ip: e.ip,
        userAgent: e.userAgent,
        changes: AuditEntry.decodeChanges(e.changesJson),
      ),
  ]),
  labels: Map.unmodifiable({for (final l in p.labels) l.id: l.name}),
  nextBefore: p.nextBefore.toInt(),
);

class GrpcAuditClient implements AuditClient {
  GrpcAuditClient(ClientChannelBase channel, this._session)
    : _audit = pb.AuditControllerClient(channel),
      _activity = pb.ActivityControllerClient(channel);

  final pb.AuditControllerClient _audit;
  final pb.ActivityControllerClient _activity;
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
      throw mapAuditError(e);
    }
  }

  @override
  Future<AuditPage> list(
    String workspaceId,
    AuditFilters filters, {
    int before = 0,
    int limit = 0,
  }) => _run(() async {
    final page = await _audit.list(
      pb.AuditListRequest(
        workspaceId: workspaceId,
        actor: filters.actor,
        action: filters.action,
        targetType: filters.targetType,
        projectId: filters.projectId,
        since: filters.since?.toUtc().toIso8601String() ?? '',
        until: filters.until?.toUtc().toIso8601String() ?? '',
        before: _long(before),
        limit: limit,
      ),
      options: _options,
    );
    return pageFromPb(page);
  });

  @override
  Future<String> exportCsv(String workspaceId, AuditFilters filters) =>
      _run(() async {
        final out = StringBuffer();
        await for (final chunk in _audit.export(
          pb.AuditExportRequest(
            workspaceId: workspaceId,
            actor: filters.actor,
            action: filters.action,
            targetType: filters.targetType,
            projectId: filters.projectId,
            since: filters.since?.toUtc().toIso8601String() ?? '',
            until: filters.until?.toUtc().toIso8601String() ?? '',
          ),
          options: _options,
        )) {
          out.write(chunk.csv);
        }
        return out.toString();
      });

  @override
  Future<AuditPage> forTask(
    String workspaceId,
    String projectId,
    String taskId, {
    int before = 0,
    int limit = 0,
  }) => _run(() async {
    final page = await _activity.forTask(
      pb.ActivityForTaskRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        before: _long(before),
        limit: limit,
      ),
      options: _options,
    );
    return pageFromPb(page);
  });
}

Int64 _long(int v) => Int64(v);
