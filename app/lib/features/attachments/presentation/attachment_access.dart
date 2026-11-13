import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// May this person delete [file]? Its uploader may, and anyone holding
/// `task.attachment_manage`; nobody in an archived project.
bool canDeleteFile(WidgetRef ref, Attachment file, {required bool archived}) {
  final permissions = ref.watch(permissionSetProvider);
  final me = ref.watch(currentUserIdProvider);
  return !archived &&
      (file.uploaderId == me || permissions.can(Perm.taskAttachmentManage));
}

/// Asks before a file is deleted (from the grid, a comment or the viewer).
Future<bool> confirmDeleteAttachment(
  BuildContext context,
  String filename,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('delete-attachment-dialog'),
      title: Text(dialog.l10n.grpHDeleteFileQ),
      content: Text(dialog.l10n.grpHFileWillBeRemoved(filename)),
      actions: [
        TextButton(
          key: const Key('delete-attachment-cancel'),
          onPressed: () => Navigator.pop(dialog, false),
          child: Text(dialog.l10n.grpHCancel),
        ),
        FilledButton(
          key: const Key('delete-attachment-confirm'),
          onPressed: () => Navigator.pop(dialog, true),
          child: Text(dialog.l10n.grpHDelete),
        ),
      ],
    ),
  );
  return ok == true;
}
