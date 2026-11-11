import 'package:flutter/material.dart';

import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/signed_image.dart';

IconData iconFor(Attachment a) {
  if (a.isImage) return Icons.image_outlined;
  if (a.isVideo) return Icons.movie_outlined;
  if (a.isPdf) return Icons.picture_as_pdf_outlined;
  if (a.isText) return Icons.description_outlined;
  return Icons.insert_drive_file_outlined;
}

/// The thumbnail of [file], or an icon for its kind.
Widget thumbnailOf(Attachment file, {double iconSize = 36}) {
  final icon = Center(child: Icon(iconFor(file), size: iconSize));
  if (!file.hasThumb) return icon;
  return SignedImage(
    key: Key('thumb-${file.id}'),
    fileId: file.id,
    thumb: true,
    semanticLabel: file.filename,
    fallback: icon,
  );
}

/// A file in the task's grid: a picture, its name and size, and a delete
/// button when [onDelete] is given.
class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.file,
    required this.onOpen,
    required this.onDelete,
  });

  final Attachment file;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 112,
      child: Stack(
        children: [
          Semantics(
            button: true,
            label: 'Open ${file.filename}',
            excludeSemantics: true,
            child: InkWell(
              key: Key('open-${file.id}'),
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 84,
                      width: 112,
                      color: scheme.surfaceContainerHighest,
                      child: thumbnailOf(file),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    formatBytes(file.size),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                key: Key('attachment-delete-${file.id}'),
                tooltip: 'Delete ${file.filename}',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

/// A file under a comment: a small thumbnail beside its name.
class AttachmentChip extends StatelessWidget {
  const AttachmentChip({
    super.key,
    required this.file,
    required this.onOpen,
    required this.onDelete,
  });

  final Attachment file;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Open ${file.filename}',
            excludeSemantics: true,
            child: InkWell(
              key: Key('open-${file.id}'),
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, maxWidth: 220),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: thumbnailOf(file, iconSize: 22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.filename,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              formatBytes(file.size),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              key: Key('attachment-delete-${file.id}'),
              tooltip: 'Delete ${file.filename}',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
            ),
        ],
      ),
    );
  }
}

/// A file on its way up: name, progress, and cancel / try again / dismiss.
class UploadRow extends StatelessWidget {
  const UploadRow({
    super.key,
    required this.item,
    required this.onCancel,
    required this.onRetry,
    required this.onDismiss,
  });

  final UploadItem item;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  String get _status => switch (item.state) {
    UploadState.queued => 'Waiting…',
    UploadState.uploading => '${(item.progress * 100).floor()}%',
    UploadState.done => 'Done',
    UploadState.cancelled => 'Cancelled',
    UploadState.failed => attachmentErrorMessage(
      AttachmentException(
        item.error ?? AttachmentFailure.other,
        detail: item.errorDetail,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final id = item.localId;
    final failed = item.state == UploadState.failed;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.filename} · ${formatBytes(item.size)}',
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.active)
                  LinearProgressIndicator(
                    key: Key('upload-progress-$id'),
                    semanticsLabel:
                        '${item.filename}, ${(item.progress * 100).floor()} percent uploaded',
                    value: item.state == UploadState.queued ? 0 : item.progress,
                  ),
                Semantics(
                  liveRegion: failed,
                  child: Text(
                    _status,
                    key: Key('upload-status-$id'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: failed
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.active)
            IconButton(
              key: Key('upload-cancel-$id'),
              tooltip: 'Cancel ${item.filename}',
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 18),
            ),
          if (item.canRetry)
            IconButton(
              key: Key('upload-retry-$id'),
              tooltip: 'Try ${item.filename} again',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
            ),
          if (!item.active)
            IconButton(
              key: Key('upload-dismiss-$id'),
              tooltip: 'Dismiss ${item.filename}',
              onPressed: onDismiss,
              icon: const Icon(Icons.delete_outline, size: 18),
            ),
        ],
      ),
    );
  }
}
