import 'dart:async';

import 'package:taskforge/features/comments/data/comments_client.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

/// An in-memory server for comments. [me] is who the calls are made by.
class FakeCommentsClient implements CommentsClient {
  FakeCommentsClient({this.me = 'u1', List<Comment> initial = const []})
    : comments = [...initial];

  final String me;
  final List<Comment> comments;
  final people = <Person>[
    const Person('u2', 'Hank Hill'),
    const Person('u-ana', 'Ana Silva'),
  ];
  final revisions = <String, List<Revision>>{};

  var _next = 1;
  var pageSize = 50;

  final lists = <String>[]; // the `before` cursor of every list call
  final created = <({String body, String parentId, bool grant})>[];
  final edits = <String>[];
  final subtasks = <String>[];
  final queries = <String>[];

  /// The next call that changes something fails with this.
  CommentException? failNext;

  /// When set, [create] waits for it (to see "sending").
  Completer<void>? gate;

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  }) async {
    lists.add(before);
    final all = [
      for (final c in comments)
        if (c.taskId == taskId) c,
    ];
    final end = before.isEmpty ? all.length : int.parse(before);
    final start = (end - pageSize).clamp(0, end);
    return CommentPage(all.sublist(start, end), start > 0 ? '$start' : '');
  }

  Comment _replace(Comment old, Comment Function(Comment) change) {
    final next = change(old);
    final i = comments.indexWhere((c) => c.id == old.id);
    comments[i] = next;
    return next;
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
    await gate?.future;
    created.add((body: body, parentId: parentId, grant: grantAccess));
    _maybeFail();
    final made = Comment(
      id: 'n${_next++}',
      taskId: taskId,
      authorId: me,
      parentId: parentId,
      body: body,
      createdAt: DateTime.now(),
      mentionIds: [for (final p in picksOf(body)) p.userId],
    );
    comments.add(made);
    return made;
  }

  Comment _full(
    Comment c, {
    String? body,
    int? version,
    Map<String, List<String>>? reactions,
    bool? pinned,
    bool? deleted,
    DateTime? editedAt,
    int? editCount,
  }) => Comment(
    id: c.id,
    taskId: c.taskId,
    authorId: c.authorId,
    parentId: c.parentId,
    body: body ?? c.body,
    createdAt: c.createdAt,
    editedAt: editedAt ?? c.editedAt,
    deleted: deleted ?? c.deleted,
    pinned: pinned ?? c.pinned,
    version: version ?? c.version,
    mentionIds: c.mentionIds,
    reactions: reactions ?? c.reactions,
    editCount: editCount ?? c.editCount,
  );

  @override
  Future<Comment> edit(
    String workspaceId,
    String projectId,
    Comment comment,
    String body, {
    bool grantAccess = false,
  }) async {
    _maybeFail();
    edits.add(body);
    revisions
        .putIfAbsent(comment.id, () => [])
        .add(Revision(comment.body, comment.createdAt, current: false));
    final now = comments.firstWhere((c) => c.id == comment.id);
    return _replace(
      now,
      (c) => _full(
        c,
        body: body,
        version: c.version + 1,
        editedAt: DateTime.now(),
        editCount: c.editCount + 1,
      ),
    );
  }

  @override
  Future<Comment> delete(
    String workspaceId,
    String projectId,
    Comment comment,
  ) async {
    _maybeFail();
    return _replace(
      comments.firstWhere((c) => c.id == comment.id),
      (c) => _full(c, body: '', deleted: true, pinned: false),
    );
  }

  @override
  Future<Comment> react(
    String workspaceId,
    String projectId,
    Comment comment,
    String emoji, {
    required bool on,
  }) async {
    _maybeFail();
    final now = comments.firstWhere((c) => c.id == comment.id);
    final next = {
      for (final e in now.reactions.entries) e.key: [...e.value],
    };
    final users = next.putIfAbsent(emoji, () => []);
    if (on && !users.contains(me)) users.add(me);
    if (!on) users.remove(me);
    if (users.isEmpty) next.remove(emoji);
    return _replace(now, (c) => _full(c, reactions: next));
  }

  @override
  Future<Comment> pin(
    String workspaceId,
    String projectId,
    Comment comment, {
    required bool pinned,
  }) async {
    _maybeFail();
    return _replace(
      comments.firstWhere((c) => c.id == comment.id),
      (c) => _full(c, pinned: pinned),
    );
  }

  @override
  Future<List<Revision>> history(
    String workspaceId,
    String projectId,
    Comment comment,
  ) async {
    final now = comments.firstWhere((c) => c.id == comment.id);
    return [
      ...?revisions[comment.id],
      Revision(now.body, now.editedAt ?? now.createdAt, current: true),
    ];
  }

  @override
  Future<String> toSubtask(
    String workspaceId,
    String projectId,
    Comment comment,
  ) async {
    _maybeFail();
    subtasks.add(comment.id);
    return 'subtask-${subtasks.length}';
  }

  @override
  Future<List<Person>> mentionable(
    String workspaceId,
    String projectId,
    String taskId, {
    String query = '',
  }) async {
    queries.add(query);
    return [
      for (final p in people)
        if (p.displayName.toLowerCase().contains(query.toLowerCase())) p,
    ];
  }
}
