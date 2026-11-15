import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart'
    show mapTaskError;
import 'package:taskforge/features/tasks/domain/tasks.dart' show TaskFailure;
import 'package:taskforge/gen/infrastructure/comments/grpc/comments.pbgrpc.dart'
    as pb;

abstract interface class CommentsClient {
  /// The newest comments of [taskId] (or those before [before]), oldest first.
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  });

  Future<Comment> create(
    String workspaceId,
    String projectId,
    String taskId,
    String body, {
    String parentId = '',
    bool grantAccess = false,

    /// An id the caller chose for the comment and a name for the change (see
    /// the tasks client).
    String clientId = '',
    String mutationId = '',
  });

  Future<Comment> edit(
    String workspaceId,
    String projectId,
    Comment comment,
    String body, {
    bool grantAccess = false,
  });

  Future<Comment> delete(String workspaceId, String projectId, Comment comment);

  /// Gives (or takes back) [emoji] as this person's reaction.
  Future<Comment> react(
    String workspaceId,
    String projectId,
    Comment comment,
    String emoji, {
    required bool on,
  });

  Future<Comment> pin(
    String workspaceId,
    String projectId,
    Comment comment, {
    required bool pinned,
  });

  Future<List<Revision>> history(
    String workspaceId,
    String projectId,
    Comment comment,
  );

  /// Makes the comment a subtask of its task; returns the new task's id.
  Future<String> toSubtask(
    String workspaceId,
    String projectId,
    Comment comment,
  );

  /// People who can see the task and match [query] (name or email).
  Future<List<Person>> mentionable(
    String workspaceId,
    String projectId,
    String taskId, {
    String query = '',
  });
}

/// Maps whatever a call threw to what the screens understand.
CommentException mapCommentError(Object error) {
  if (error is CommentException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    if (error.code == StatusCode.invalidArgument && title == 'COMMENT_LOCKED') {
      return const CommentException(CommentFailure.locked);
    }
    if (error.code == StatusCode.invalidArgument &&
        title == 'MENTION_NO_ACCESS') {
      final users = errorTrailer(error, 'x-error-users-bin');
      return CommentException(
        CommentFailure.mentionNoAccess,
        people: users.isEmpty ? const [] : users.split(','),
      );
    }
  }
  final task = mapTaskError(error);
  return CommentException(switch (task.failure) {
    TaskFailure.conflict => CommentFailure.conflict,
    TaskFailure.denied => CommentFailure.denied,
    TaskFailure.forbidden => CommentFailure.forbidden,
    TaskFailure.invalid => CommentFailure.invalid,
    TaskFailure.archived => CommentFailure.archived,
    TaskFailure.notFound => CommentFailure.notFound,
    TaskFailure.network => CommentFailure.network,
    _ => CommentFailure.other,
  }, detail: task.detail);
}

Comment commentFromPb(pb.Comment c) => Comment(
  id: c.id,
  taskId: c.taskId,
  authorId: c.authorId,
  parentId: c.parentId,
  body: c.body,
  createdAt: DateTime.tryParse(c.createdAt) ?? DateTime.now(),
  editedAt: c.editedAt.isEmpty ? null : DateTime.tryParse(c.editedAt),
  deleted: c.deleted,
  pinned: c.pinned,
  version: c.version,
  mentionIds: List.unmodifiable(c.mentionIds),
  reactions: {
    for (final r in c.reactions) r.emoji: List.unmodifiable(r.userIds),
  },
  editCount: c.editCount,
  kind: c.kind == 'system' ? 'system' : 'user',
  event: ChatEvent.tryParse(c.event),
);

class GrpcCommentsClient implements CommentsClient {
  GrpcCommentsClient(ClientChannelBase channel, this._session)
    : _stub = pb.CommentControllerClient(channel);

  final pb.CommentControllerClient _stub;
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
      throw mapCommentError(e);
    }
  }

  @override
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  }) => _run(() async {
    final page = await _stub.list(
      pb.CommentListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        before: before,
      ),
      options: _options,
    );
    return CommentPage(
      List.unmodifiable(page.comments.map(commentFromPb)),
      page.cursor,
    );
  });

  @override
  Future<Comment> create(
    String workspaceId,
    String projectId,
    String taskId,
    String body, {
    String parentId = '',
    bool grantAccess = false,
    String clientId = '',
    String mutationId = '',
  }) => _run(
    () async => commentFromPb(
      await _stub.create(
        pb.CommentCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
          body: body,
          parentId: parentId,
          grantAccess: grantAccess,
          clientId: clientId,
          clientMutationId: mutationId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Comment> edit(
    String workspaceId,
    String projectId,
    Comment comment,
    String body, {
    bool grantAccess = false,
  }) => _run(
    () async => commentFromPb(
      await _stub.edit(
        pb.CommentEditRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: comment.id,
          expectedVersion: comment.version,
          body: body,
          grantAccess: grantAccess,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Comment> delete(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _run(
    () async => commentFromPb(
      await _stub.delete(
        pb.CommentDeleteRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: comment.id,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Comment> react(
    String workspaceId,
    String projectId,
    Comment comment,
    String emoji, {
    required bool on,
  }) => _run(
    () async => commentFromPb(
      await _stub.react(
        pb.CommentReactRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: comment.id,
          emoji: emoji,
          on: on,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Comment> pin(
    String workspaceId,
    String projectId,
    Comment comment, {
    required bool pinned,
  }) => _run(
    () async => commentFromPb(
      await _stub.pin(
        pb.CommentPinRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: comment.id,
          pinned: pinned,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<Revision>> history(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _run(() async {
    final reply = await _stub.history(
      pb.CommentHistoryRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        id: comment.id,
      ),
      options: _options,
    );
    return [
      for (final r in reply.revisions)
        Revision(
          r.body,
          DateTime.tryParse(r.at) ?? DateTime.now(),
          current: r.current,
        ),
    ];
  });

  @override
  Future<String> toSubtask(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _run(() async {
    final reply = await _stub.toSubtask(
      pb.CommentToSubtaskRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        id: comment.id,
      ),
      options: _options,
    );
    return reply.taskId;
  });

  @override
  Future<List<Person>> mentionable(
    String workspaceId,
    String projectId,
    String taskId, {
    String query = '',
  }) => _run(() async {
    final reply = await _stub.mentionable(
      pb.CommentMentionableRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        taskId: taskId,
        query: query,
      ),
      options: _options,
    );
    return [for (final p in reply.people) Person(p.userId, p.displayName)];
  });
}
