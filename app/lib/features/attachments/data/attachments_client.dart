import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart'
    show mapTaskError;
import 'package:taskforge/features/tasks/domain/tasks.dart' show TaskFailure;
import 'package:taskforge/gen/infrastructure/attachments/grpc/attachments.pbgrpc.dart'
    as pb;

/// The list, delete and usage side of attachments (gRPC). The bytes go
/// through `UploadsClient` (REST).
abstract interface class AttachmentsClient {
  Future<List<Attachment>> list(
    String workspaceId,
    String projectId,
    String taskId,
  );

  Future<void> delete(String workspaceId, String projectId, Attachment file);

  Future<StorageUsage> usage(String workspaceId);
}

/// Maps whatever a call threw to what the screens understand.
AttachmentException mapAttachmentError(Object error) {
  if (error is AttachmentException) return error;
  final task = mapTaskError(error);
  return AttachmentException(switch (task.failure) {
    TaskFailure.denied => AttachmentFailure.denied,
    TaskFailure.forbidden => AttachmentFailure.forbidden,
    TaskFailure.archived => AttachmentFailure.archived,
    TaskFailure.notFound => AttachmentFailure.notFound,
    TaskFailure.network => AttachmentFailure.network,
    _ => AttachmentFailure.other,
  }, detail: task.detail);
}

Attachment attachmentFromPb(pb.Attachment a) => Attachment(
  id: a.id,
  taskId: a.taskId,
  commentId: a.commentId,
  uploaderId: a.uploaderId,
  filename: a.filename,
  mime: a.mime,
  size: a.size.toInt(),
  hasThumb: a.hasThumb,
  createdAt: DateTime.tryParse(a.createdAt) ?? DateTime.now(),
);

class GrpcAttachmentsClient implements AttachmentsClient {
  GrpcAttachmentsClient(ClientChannelBase channel, this._session)
    : _stub = pb.AttachmentControllerClient(channel);

  final pb.AttachmentControllerClient _stub;
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
      throw mapAttachmentError(e);
    }
  }

  @override
  Future<List<Attachment>> list(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(() async {
    final reply = await _stub.list(
      pb.AttachmentListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
      ),
      options: _options,
    );
    return List.unmodifiable(reply.attachments.map(attachmentFromPb));
  });

  @override
  Future<void> delete(String workspaceId, String projectId, Attachment file) =>
      _run(
        () => _stub.delete(
          pb.AttachmentDeleteRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            id: file.id,
          ),
          options: _options,
        ),
      );

  @override
  Future<StorageUsage> usage(String workspaceId) => _run(() async {
    final u = await _stub.usage(
      pb.UsageRequest(workspaceId: workspaceId),
      options: _options,
    );
    return StorageUsage(
      usedBytes: u.usedBytes.toInt(),
      quotaBytes: u.quotaBytes.toInt(),
      fileCount: u.fileCount,
      maxFileBytes: u.maxFileBytes.toInt(),
    );
  });
}
