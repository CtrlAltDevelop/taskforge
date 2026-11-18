import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart'
    show UploadSource;
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/comment_dialogs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/message_bubble.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// What the activity does for the person: send, reply, edit, pin, delete,
/// react, and the dialogs and messages around them. It belongs to one
/// panel's state; [setReplying] and [setEditing] hand back which message the
/// panel should show a box under.
class ActivityActions {
  ActivityActions({
    required this.context,
    required this.ref,
    required this.task,
    required this.projectId,
    required this.isPrivate,
    required this.mounted,
    required this.setReplying,
    required this.setEditing,
  });

  /// Read at call time: the panel's context may have changed since.
  final BuildContext Function() context;
  final WidgetRef ref;
  final TaskRef task;
  final String projectId;
  final bool isPrivate;
  final bool Function() mounted;
  final void Function(String? id) setReplying;
  final void Function(String? id) setEditing;

  CommentsNotifier get notifier => ref.read(commentsProvider(task).notifier);

  void say(String text) {
    if (!mounted()) return;
    ScaffoldMessenger.of(context())
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String nameOf(String id) {
    final l10n = context().l10n;
    if (id == ref.read(currentUserIdProvider)) return l10n.grpBYou;
    final members = ref.read(membersProvider).value ?? const [];
    for (final m in members) {
      if (m.userId == id) {
        return m.displayName.isEmpty ? m.email : m.displayName;
      }
    }
    return l10n.grpBSomeone;
  }

  String statusName(String id) {
    final workflow = ref.read(workflowProvider(projectId)).value;
    for (final s in workflow?.statuses ?? const []) {
      if (s.id == id) return s.name;
    }
    return context().l10n.grpRMnDeletedStatus;
  }

  /// Sends and says what went wrong. A mention of somebody who cannot see
  /// the task is the one failure with a way forward: add them (if allowed).
  Future<void> send(
    String body, {
    String parentId = '',
    List<UploadSource> files = const [],
  }) async {
    try {
      await notifier.send(body, parentId: parentId, files: files);
      if (mounted() && parentId.isNotEmpty) setReplying(null);
    } on CommentException catch (e) {
      if (e.failure == CommentFailure.mentionNoAccess) {
        final failed = notifier.lastFailedId;
        if (failed != null) notifier.discard(failed);
        if (await _offerGrant(body, parentId, e.people, files)) return;
      } else if (mounted()) {
        say(commentErrorMessage(e, context().l10n));
      }
      rethrow;
    }
  }

  /// True when the comment went out after adding the people mentioned.
  Future<bool> _offerGrant(
    String body,
    String parentId,
    List<String> people,
    List<UploadSource> files,
  ) async {
    final grant = await askGrantAccess(
      context(),
      names: people.map(nameOf).join(', '),
      // The server decides who may add people; the client only knows it is a
      // private project, so it offers and shows the answer.
      canGrant: isPrivate,
    );
    if (grant != true || !mounted()) return false;
    try {
      await notifier.send(
        body,
        parentId: parentId,
        grantAccess: true,
        files: files,
      );
      if (mounted() && parentId.isNotEmpty) setReplying(null);
      return true;
    } on CommentException catch (e) {
      if (mounted()) say(commentErrorMessage(e, context().l10n));
      return false;
    }
  }

  Future<void> act(MessageAction action, Comment c) async {
    try {
      switch (action) {
        case MessageAction.reply:
          setReplying(c.id);
        case MessageAction.edit:
          setEditing(c.id);
        case MessageAction.delete:
          if (await confirmDeleteComment(context())) await notifier.delete(c);
        case MessageAction.pin:
          await notifier.pin(c, pinned: !c.pinned);
        case MessageAction.subtask:
          await notifier.toSubtask(c);
          if (mounted()) say(context().l10n.grpBSubtaskCreated);
        case MessageAction.history:
          final revisions = await notifier.history(c);
          if (mounted()) {
            await showHistory(context(), revisions, nameOf(c.authorId));
          }
      }
    } on CommentException catch (e) {
      if (mounted()) say(commentErrorMessage(e, context().l10n));
    }
  }

  Future<void> guard(Future<void> Function() call) async {
    try {
      await call();
    } on CommentException catch (e) {
      if (mounted()) say(commentErrorMessage(e, context().l10n));
    }
  }

  Future<void> saveEdit(Comment c, String body) async {
    final l10n = context().l10n;
    try {
      await notifier.edit(c, body);
      if (mounted()) setEditing(null);
    } on CommentException catch (e) {
      if (mounted()) say(commentErrorMessage(e, l10n));
      rethrow;
    }
  }
}
