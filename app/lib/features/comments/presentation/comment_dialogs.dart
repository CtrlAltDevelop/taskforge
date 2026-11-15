import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

Future<bool> confirmDeleteComment(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('delete-comment-dialog'),
        title: Text(ctx.l10n.grpIDeleteCommentTitle),
        content: Text(ctx.l10n.grpIDeleteCommentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ctx.l10n.grpICancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-comment'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(ctx.l10n.grpIDelete),
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
  builder: (ctx) => AlertDialog(
    key: const Key('grant-dialog'),
    title: Text(ctx.l10n.grpICannotSeeTask),
    content: Text(
      canGrant
          ? ctx.l10n.grpICannotSeeGrant(names)
          : ctx.l10n.grpICannotSeeRefuse(names),
    ),
    actions: [
      TextButton(
        key: const Key('grant-cancel'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(canGrant ? ctx.l10n.grpICancel : ctx.l10n.grpIOk),
      ),
      if (canGrant)
        FilledButton(
          key: const Key('grant-add'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(ctx.l10n.grpIAddThemAndSend),
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
  builder: (ctx) => AlertDialog(
    key: const Key('history-dialog'),
    title: Text(ctx.l10n.grpIEditHistory(author)),
    content: SizedBox(
      width: 420,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final r in revisions)
            ListTile(
              dense: true,
              title: Text(plainTextOf(r.body)),
              subtitle: Text(() {
                final stamp = r.at
                    .toLocal()
                    .toIso8601String()
                    .substring(0, 16)
                    .replaceFirst('T', ' ');
                return r.current ? ctx.l10n.grpIRevisionCurrent(stamp) : stamp;
              }()),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(ctx.l10n.grpIClose),
      ),
    ],
  ),
);
