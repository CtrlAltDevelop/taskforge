import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/features/comments/data/comments_client.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart'
    show OfflineEnv;

/// Comments that can be written without a connection.
///
/// A task's comments are copied into the local database as they are read and
/// answered from there when the server cannot be reached. A comment written
/// offline is shown at once (marked as sending) and sent when the connection is
/// back; the rest of the calls (editing, reacting, pinning, history ...) need
/// the server and fail with [CommentFailure.network] meanwhile.
class OfflineCommentsClient implements CommentsClient {
  OfflineCommentsClient(this._inner, this._env);

  final CommentsClient _inner;
  final OfflineEnv _env;

  static const _offline = CommentException(CommentFailure.network);

  Future<T> _call<T>(Future<T> Function() call) async {
    if (!_env.online()) throw _offline;
    try {
      final result = await call();
      _env.worked();
      return result;
    } on CommentException catch (e) {
      if (e.failure == CommentFailure.network) _env.failed();
      rethrow;
    }
  }

  Future<List<Comment>> _waiting(
    OfflineStore store,
    String workspaceId,
    String taskId,
  ) async => [
    for (final e in await store.queue(workspaceId))
      if (e.entity == OutboxEntity.comment &&
          e.op == OutboxOp.create &&
          e.payload['taskId'] == taskId)
        _local(e),
  ];

  Comment _local(OutboxEntry e) => Comment(
    id: e.entityId,
    taskId: '${e.payload['taskId']}',
    authorId: '${e.payload['authorId'] ?? ''}',
    parentId: '${e.payload['parentId'] ?? ''}',
    body: '${e.payload['body'] ?? ''}',
    createdAt: e.createdAt,
    version: 0,
    sendState: e.state.needsAttention ? SendState.failed : SendState.sending,
  );

  @override
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  }) async {
    final store = await _env.store();
    if (_env.online()) {
      try {
        final page = await _call(
          () => _inner.list(workspaceId, projectId, taskId, before: before),
        );
        if (store != null) {
          await store.putAll(workspaceId, Kinds.comment, [
            for (final c in page.comments)
              (id: c.id, json: commentToJson(c), version: c.version),
          ], scope: taskId);
          if (before.isEmpty) {
            await store.sweep(
              workspaceId,
              Kinds.comment,
              taskId,
              {for (final c in page.comments) c.id},
              protect: {
                for (final c in await _waiting(store, workspaceId, taskId))
                  c.id,
              },
            );
          }
        }
        return CommentPage([
          ...page.comments,
          if (store != null && before.isEmpty)
            ...await _waiting(store, workspaceId, taskId),
        ], page.cursor);
      } on CommentException catch (e) {
        if (e.failure != CommentFailure.network || store == null) rethrow;
      }
    }
    if (store == null) throw _offline;
    final cached = [
      for (final j in await store.list(
        workspaceId,
        Kinds.comment,
        scope: taskId,
      ))
        commentFromJson(j),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sent = {for (final c in cached) c.id};
    return CommentPage([
      ...cached,
      for (final c in await _waiting(store, workspaceId, taskId))
        if (!sent.contains(c.id)) c,
    ], '');
  }

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
  }) async {
    final id = clientId.isEmpty ? _env.newId() : clientId;
    final mutation = mutationId.isEmpty ? _env.newId() : mutationId;
    final store = await _env.store();
    final waitingTask =
        store != null && await _taskWaiting(store, workspaceId, taskId);
    if (_env.online() && !waitingTask) {
      try {
        final made = await _call(
          () => _inner.create(
            workspaceId,
            projectId,
            taskId,
            body,
            parentId: parentId,
            grantAccess: grantAccess,
            clientId: id,
            mutationId: mutation,
          ),
        );
        await store?.put(
          workspaceId,
          Kinds.comment,
          made.id,
          commentToJson(made),
          scope: taskId,
          version: made.version,
        );
        return made;
      } on CommentException catch (e) {
        if (e.failure != CommentFailure.network || store == null) rethrow;
      }
    }
    if (store == null) throw _offline;
    final entry = OutboxEntry(
      workspaceId: workspaceId,
      projectId: projectId,
      entity: OutboxEntity.comment,
      entityId: id,
      op: OutboxOp.create,
      mutationId: mutation,
      createdAt: _env.now(),
      payload: {
        'taskId': taskId,
        'body': body,
        'parentId': parentId,
        'grantAccess': grantAccess,
        'authorId': _env.me(),
      },
    );
    await store.enqueue(entry);
    return _local(entry);
  }

  /// Whether the task itself still waits in the outbox (a comment on it must
  /// follow it, so it is queued too).
  Future<bool> _taskWaiting(
    OfflineStore store,
    String workspaceId,
    String taskId,
  ) async =>
      (await store.queue(workspaceId))
          .any((e) => e.entity == OutboxEntity.task && e.entityId == taskId);

  @override
  Future<Comment> edit(
    String workspaceId,
    String projectId,
    Comment comment,
    String body, {
    bool grantAccess = false,
  }) => _call(
    () => _inner.edit(
      workspaceId,
      projectId,
      comment,
      body,
      grantAccess: grantAccess,
    ),
  );

  @override
  Future<Comment> delete(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _call(() => _inner.delete(workspaceId, projectId, comment));

  @override
  Future<Comment> react(
    String workspaceId,
    String projectId,
    Comment comment,
    String emoji, {
    required bool on,
  }) =>
      _call(() => _inner.react(workspaceId, projectId, comment, emoji, on: on));

  @override
  Future<Comment> pin(
    String workspaceId,
    String projectId,
    Comment comment, {
    required bool pinned,
  }) =>
      _call(() => _inner.pin(workspaceId, projectId, comment, pinned: pinned));

  @override
  Future<List<Revision>> history(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _call(() => _inner.history(workspaceId, projectId, comment));

  @override
  Future<String> toSubtask(
    String workspaceId,
    String projectId,
    Comment comment,
  ) => _call(() => _inner.toSubtask(workspaceId, projectId, comment));

  @override
  Future<List<Person>> mentionable(
    String workspaceId,
    String projectId,
    String taskId, {
    String query = '',
  }) => _call(
    () => _inner.mentionable(workspaceId, projectId, taskId, query: query),
  );
}
