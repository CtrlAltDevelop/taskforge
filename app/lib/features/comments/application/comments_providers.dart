import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart'
    show UploadSource;
import 'package:taskforge/features/comments/data/comments_client.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final commentsClientProvider = Provider<CommentsClient>(
  (ref) => GrpcCommentsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// Who this person is, as the server names them in comments and reactions
/// (empty until the account is read).
final currentUserIdProvider = Provider<String>(
  (ref) => ref.watch(accountProvider).value?.id ?? '',
);

/// One task's comments.
typedef TaskRef = ({String project, String task});

@immutable
class CommentsState {
  const CommentsState({
    this.comments = const [],
    this.cursor = '',
    this.loading = true,
    this.loadingEarlier = false,
    this.error,
  });

  /// Oldest first, replies after the comment they answer is the screen's job.
  final List<Comment> comments;
  final String cursor;
  final bool loading;
  final bool loadingEarlier;
  final CommentException? error;

  bool get hasEarlier => cursor.isNotEmpty;

  CommentsState copyWith({
    List<Comment>? comments,
    String? cursor,
    bool? loading,
    bool? loadingEarlier,
    CommentException? Function()? error,
  }) => CommentsState(
    comments: comments ?? this.comments,
    cursor: cursor ?? this.cursor,
    loading: loading ?? this.loading,
    loadingEarlier: loadingEarlier ?? this.loadingEarlier,
    error: error == null ? this.error : error(),
  );
}

/// The comments of one task: the newest page first, earlier ones on request,
/// and optimistic: what is sent shows at once as "sending", and stays (as
/// "failed", with retry) when the server refuses it.
final commentsProvider = NotifierProvider.autoDispose
    .family<CommentsNotifier, CommentsState, TaskRef>(CommentsNotifier.new);

class CommentsNotifier extends Notifier<CommentsState> {
  CommentsNotifier(this.ref0);

  final TaskRef ref0;
  var _generation = 0;
  var _localCounter = 0;

  /// The local id of the comment whose send failed last (see [discard]).
  String? lastFailedId;

  /// What a failed or sending comment was meant to be, to send again.
  final _pending =
      <
        String,
        ({String body, String parentId, bool grant, List<UploadSource> files})
      >{};

  CommentsClient get _client => ref.read(commentsClientProvider);

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const CommentException(CommentFailure.other);
    return id;
  }

  @override
  CommentsState build() {
    ref.watch(workspaceScopeProvider);
    Future.microtask(load);
    return const CommentsState();
  }

  /// Reads the newest page again (what is on screen stays until it is here).
  Future<void> load() async {
    final generation = ++_generation;
    try {
      final page = await _client.list(_workspace, ref0.project, ref0.task);
      if (generation != _generation || !ref.mounted) return;
      state = CommentsState(
        comments: _merged(page.comments, kept: _olderThan(page)),
        cursor:
            state.cursor.isNotEmpty &&
                state.comments.length > page.comments.length
            ? state.cursor
            : page.cursor,
        loading: false,
      );
    } on CommentException catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => e);
    }
  }

  /// Reads again quietly, e.g. when somebody else commented.
  Future<void> refresh() => load();

  /// Comments already loaded that are older than the page just read.
  List<Comment> _olderThan(CommentPage page) {
    if (page.comments.isEmpty) return const [];
    final first = page.comments.first.createdAt;
    return [
      for (final c in state.comments)
        if (!c.isLocal && c.createdAt.isBefore(first)) c,
    ];
  }

  /// [page] after [kept] (older ones), then what is still on its way.
  List<Comment> _merged(List<Comment> page, {List<Comment> kept = const []}) {
    final known = {for (final c in page) c.id};
    return List.unmodifiable([
      ...kept,
      ...page,
      for (final c in state.comments)
        if (c.isLocal && !known.contains(c.id)) c,
    ]);
  }

  Future<void> loadEarlier() async {
    if (!state.hasEarlier || state.loadingEarlier) return;
    state = state.copyWith(loadingEarlier: true);
    final generation = _generation;
    try {
      final page = await _client.list(
        _workspace,
        ref0.project,
        ref0.task,
        before: state.cursor,
      );
      if (generation != _generation || !ref.mounted) return;
      final have = {for (final c in state.comments) c.id};
      state = state.copyWith(
        comments: List.unmodifiable([
          for (final c in page.comments)
            if (!have.contains(c.id)) c,
          ...state.comments,
        ]),
        cursor: page.cursor,
        loadingEarlier: false,
      );
    } on CommentException {
      if (ref.mounted) state = state.copyWith(loadingEarlier: false);
    }
  }

  // ---------------------------------------------------------------- sending

  /// Sends a comment (or a reply to [parentId]). It shows at once; the
  /// returned future ends when the server has answered, throwing the
  /// [CommentException] a failed send leaves on the comment too. [files] are
  /// uploaded to the comment once it exists (the comment comes first, so a
  /// failed upload never loses it; the upload shows its own retry).
  Future<void> send(
    String body, {
    String parentId = '',
    bool grantAccess = false,
    List<UploadSource> files = const [],
  }) async {
    final localId = 'local-${++_localCounter}';
    _pending[localId] = (
      body: body,
      parentId: parentId,
      grant: grantAccess,
      files: List.unmodifiable(files),
    );
    final draft = Comment(
      id: localId,
      taskId: ref0.task,
      authorId: ref.read(currentUserIdProvider),
      parentId: parentId,
      body: body,
      createdAt: DateTime.now(),
      sendState: SendState.sending,
    );
    state = state.copyWith(comments: [...state.comments, draft]);
    await _transmit(localId);
  }

  /// Sends a failed comment again.
  Future<void> retry(String localId) async {
    if (!_pending.containsKey(localId)) return;
    _swap(localId, (c) => c.copyWith(sendState: SendState.sending));
    await _transmit(localId);
  }

  /// Gives up on a failed comment.
  void discard(String localId) {
    _pending.remove(localId);
    state = state.copyWith(
      comments: [
        for (final c in state.comments)
          if (c.id != localId) c,
      ],
    );
  }

  Future<void> _transmit(String localId) async {
    final job = _pending[localId];
    if (job == null) return;
    try {
      final saved = await _client.create(
        _workspace,
        ref0.project,
        ref0.task,
        job.body,
        parentId: job.parentId,
        grantAccess: job.grant,
      );
      _pending.remove(localId);
      if (!ref.mounted) return;
      // The live feed may have brought the same comment in already.
      final have = state.comments.any((c) => c.id == saved.id);
      state = state.copyWith(
        comments: [
          for (final c in state.comments)
            if (c.id != localId) c else if (!have) saved,
        ],
      );
      if (job.files.isNotEmpty) await _attach(saved.id, job.files);
    } on CommentException {
      lastFailedId = localId;
      if (ref.mounted) {
        _swap(localId, (c) => c.copyWith(sendState: SendState.failed));
      }
      rethrow;
    }
  }

  /// Uploads [files] to the comment [commentId]. The task's file list keeps
  /// the notifier alive from here on (it holds itself alive while any upload
  /// runs), so this only has to make sure it exists until it has taken them.
  Future<void> _attach(String commentId, List<UploadSource> files) async {
    final hold = ref.listen(attachmentsProvider(ref0), (_, _) {});
    try {
      await ref
          .read(attachmentsProvider(ref0).notifier)
          .add(files, commentId: commentId);
    } finally {
      hold.close();
    }
  }

  void _swap(String id, Comment Function(Comment) change) {
    state = state.copyWith(
      comments: [for (final c in state.comments) c.id == id ? change(c) : c],
    );
  }

  void _replace(Comment saved) => _swap(saved.id, (_) => saved);

  // ---------------------------------------------------------------- changing

  Future<void> edit(
    Comment comment,
    String body, {
    bool grantAccess = false,
  }) async {
    final saved = await _client.edit(
      _workspace,
      ref0.project,
      comment,
      body,
      grantAccess: grantAccess,
    );
    if (ref.mounted) _replace(saved);
  }

  Future<void> delete(Comment comment) async {
    final before = comment;
    _swap(
      comment.id,
      (c) => c.copyWith(deleted: true, body: '', pinned: false),
    );
    try {
      final saved = await _client.delete(_workspace, ref0.project, comment);
      if (ref.mounted) _replace(saved);
    } on CommentException {
      if (ref.mounted) _replace(before);
      rethrow;
    }
  }

  /// Gives or takes back this person's [emoji]; shows at once.
  Future<void> react(Comment comment, String emoji) async {
    final me = ref.read(currentUserIdProvider);
    final on = !comment.reactedBy(emoji, me);
    _swap(comment.id, (c) => _withReaction(c, emoji, me, on: on));
    try {
      final saved = await _client.react(
        _workspace,
        ref0.project,
        comment,
        emoji,
        on: on,
      );
      if (ref.mounted) _replace(saved);
    } on CommentException {
      if (ref.mounted) _replace(comment);
      rethrow;
    }
  }

  Comment _withReaction(
    Comment c,
    String emoji,
    String me, {
    required bool on,
  }) {
    final next = {
      for (final e in c.reactions.entries) e.key: [...e.value],
    };
    final users = next.putIfAbsent(emoji, () => []);
    if (on) {
      if (!users.contains(me)) users.add(me);
    } else {
      users.remove(me);
      if (users.isEmpty) next.remove(emoji);
    }
    return Comment(
      id: c.id,
      taskId: c.taskId,
      authorId: c.authorId,
      parentId: c.parentId,
      body: c.body,
      createdAt: c.createdAt,
      editedAt: c.editedAt,
      deleted: c.deleted,
      pinned: c.pinned,
      version: c.version,
      mentionIds: c.mentionIds,
      reactions: next,
      editCount: c.editCount,
    );
  }

  Future<void> pin(Comment comment, {required bool pinned}) async {
    final saved = await _client.pin(
      _workspace,
      ref0.project,
      comment,
      pinned: pinned,
    );
    if (ref.mounted) _replace(saved);
  }

  /// Makes [comment] a subtask; the task list reads itself again.
  Future<void> toSubtask(Comment comment) async {
    await _client.toSubtask(_workspace, ref0.project, comment);
    if (ref.mounted) {
      unawaited(ref.read(taskListProvider(ref0.project).notifier).refresh());
    }
  }

  Future<List<Revision>> history(Comment comment) =>
      _client.history(_workspace, ref0.project, comment);
}

/// People who can see a task and match a query, for the mention picker.
final mentionableProvider = FutureProvider.autoDispose
    .family<List<Person>, ({TaskRef task, String query})>((ref, key) async {
      final workspace = ref.watch(workspaceScopeProvider);
      if (workspace == null) return const [];
      try {
        return await ref
            .watch(commentsClientProvider)
            .mentionable(
              workspace,
              key.task.project,
              key.task.task,
              query: key.query,
            );
      } on CommentException {
        return const [];
      }
    });
