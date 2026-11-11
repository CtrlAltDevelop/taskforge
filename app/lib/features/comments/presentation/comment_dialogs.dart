import 'package:flutter/material.dart';

import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

Future<bool> confirmDeleteComment(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        key: const Key('delete-comment-dialog'),
        title: const Text('Delete this comment?'),
        content: const Text(
          'It will show as "Comment removed". Its content and edit history are deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete-comment'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;

/// Somebody mentioned cannot see the task. Those who may manage the project's
/// members can add them and send; for everyone else it is a refusal.
Future<bool?> askGrantAccess(
  BuildContext context, {
  required String names,
  required bool canGrant,
}) => showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    key: const Key('grant-dialog'),
    title: const Text('They cannot see this task'),
    content: Text(
      canGrant
          ? '$names cannot see this task. Add them to the project and send the comment, or take the mention out.'
          : '$names cannot see this task, so they cannot be mentioned. Take the mention out, or ask someone who manages the project to add them.',
    ),
    actions: [
      TextButton(
        key: const Key('grant-cancel'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(canGrant ? 'Cancel' : 'OK'),
      ),
      if (canGrant)
        FilledButton(
          key: const Key('grant-add'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add them and send'),
        ),
    ],
  ),
);

/// Every body the comment has had, oldest first.
Future<void> showHistory(
  BuildContext context,
  List<Revision> revisions,
  String author,
) => showDialog<void>(
  context: context,
  builder: (_) => AlertDialog(
    key: const Key('history-dialog'),
    title: Text('Edit history · $author'),
    content: SizedBox(
      width: 420,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final r in revisions)
            ListTile(
              dense: true,
              title: Text(plainTextOf(r.body)),
              subtitle: Text(
                '${r.at.toLocal().toIso8601String().substring(0, 16).replaceFirst('T', ' ')}'
                '${r.current ? ' · current' : ''}',
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);
