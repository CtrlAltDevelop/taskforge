import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachment_access.dart';
import 'package:taskforge/features/attachments/presentation/attachment_tiles.dart';
import 'package:taskforge/features/attachments/presentation/attachment_viewer.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show TaskRef;

/// The files that belong to one comment: chips that open the same viewer as
/// the task's files, and the uploads still on their way (with progress,
/// cancel and retry). Nothing at all when there are none.
class CommentAttachments extends ConsumerWidget {
  const CommentAttachments({
    super.key,
    required this.task,
    required this.commentId,
    this.archived = false,
  });

  final TaskRef task;
  final String commentId;
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attachmentsProvider(task));
    final notifier = ref.read(attachmentsProvider(task).notifier);
    final files = [
      for (final a in state.attachments)
        if (a.commentId == commentId) a,
    ];
    final uploads = [
      for (final u in state.uploads)
        if (u.commentId == commentId) u,
    ];
    if (files.isEmpty && uploads.isEmpty) return const SizedBox.shrink();

    Future<void> confirmAndDelete(Attachment a) async {
      if (await confirmDeleteAttachment(context, a.filename) &&
          context.mounted) {
        await notifier.delete(a);
      }
    }

    return Padding(
      key: Key('comment-files-$commentId'),
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (files.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in files)
                  Builder(
                    builder: (context) {
                      final deletable = canDeleteFile(
                        ref,
                        a,
                        archived: archived,
                      );
                      return AttachmentChip(
                        key: Key('attachment-${a.id}'),
                        file: a,
                        onOpen: () => showAttachmentViewer(
                          context,
                          file: a,
                          onDelete: deletable ? () => notifier.delete(a) : null,
                        ),
                        onDelete: deletable ? () => confirmAndDelete(a) : null,
                      );
                    },
                  ),
              ],
            ),
          for (final u in uploads)
            UploadRow(
              key: Key('upload-${u.localId}'),
              item: u,
              onCancel: () => notifier.cancel(u.localId),
              onRetry: () => notifier.retry(u.localId),
              onDismiss: () => notifier.dismiss(u.localId),
            ),
        ],
      ),
    );
  }
}
