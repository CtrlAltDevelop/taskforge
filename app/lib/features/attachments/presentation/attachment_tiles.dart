import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/attachments/presentation/signed_image.dart';

TfIconData iconFor(Attachment a) {
  if (a.isImage) return TfIcons.image;
  if (a.isVideo) return TfIcons.video;
  if (a.isPdf) return TfIcons.fileText;
  if (a.isText) return TfIcons.fileText;
  return TfIcons.file;
}

/// The thumbnail of [file], or an icon for its kind.
Widget thumbnailOf(Attachment file, {double iconSize = 36}) {
  final icon = Center(child: TfIcon(iconFor(file), size: iconSize));
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
            label: context.l10n.grpHOpenFile(file.filename),
            excludeSemantics: true,
            child: InkWell(
              key: Key('open-${file.id}'),
              onTap: onOpen,
              borderRadius: TfRadius.panel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: TfRadius.panel,
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
                    context.localDigits(formatBytes(file.size, context.l10n)),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          if (onDelete != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton(
                key: Key('attachment-delete-${file.id}'),
                tooltip: context.l10n.grpHDeleteFile(file.filename),
                onPressed: onDelete,
                icon: const TfIcon(TfIcons.trash, size: 18),
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
        borderRadius: TfRadius.panel,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: context.l10n.grpHOpenFile(file.filename),
            excludeSemantics: true,
            child: InkWell(
              key: Key('open-${file.id}'),
              onTap: onOpen,
              borderRadius: TfRadius.panel,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, maxWidth: 220),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: TfRadius.control,
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
                              context.localDigits(
                                formatBytes(file.size, context.l10n),
                              ),
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
              tooltip: context.l10n.grpHDeleteFile(file.filename),
              onPressed: onDelete,
              icon: const TfIcon(TfIcons.trash, size: 18),
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

  String _status(AppLocalizations l10n) => switch (item.state) {
    UploadState.queued =>
      item.kept ? l10n.grpHWaitingConnection : l10n.grpHWaiting,
    UploadState.uploading => '${(item.progress * 100).floor()}%',
    UploadState.done => l10n.grpHUploadDone,
    UploadState.cancelled => l10n.grpHUploadCancelled,
    UploadState.failed => attachmentErrorMessage(
      AttachmentException(
        item.error ?? AttachmentFailure.other,
        detail: item.errorDetail,
      ),
      l10n,
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
                  '${item.filename} · ${context.localDigits(formatBytes(item.size, context.l10n))}',
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.active && !item.kept)
                  LinearProgressIndicator(
                    key: Key('upload-progress-$id'),
                    semanticsLabel: context.l10n.grpHPercentUploaded(
                      item.filename,
                      (item.progress * 100).floor(),
                    ),
                    value: item.state == UploadState.queued ? 0 : item.progress,
                  ),
                Semantics(
                  liveRegion: failed,
                  child: Text(
                    _status(context.l10n),
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
          if (item.kept)
            TfIcon(
              TfIcons.clock,
              key: Key('upload-pending-$id'),
              size: 18,
              semanticLabel: context.l10n.grpHWaitingToBeSent,
            )
          else if (item.active)
            IconButton(
              key: Key('upload-cancel-$id'),
              tooltip: context.l10n.grpHCancelFile(item.filename),
              onPressed: onCancel,
              icon: const TfIcon(TfIcons.close, size: 18),
            ),
          if (item.canRetry)
            IconButton(
              key: Key('upload-retry-$id'),
              tooltip: context.l10n.grpHTryFileAgain(item.filename),
              onPressed: onRetry,
              icon: const TfIcon(TfIcons.refresh, size: 18),
            ),
          if (!item.active)
            IconButton(
              key: Key('upload-dismiss-$id'),
              tooltip: context.l10n.grpHDismissFile(item.filename),
              onPressed: onDismiss,
              icon: const TfIcon(TfIcons.trash, size: 18),
            ),
        ],
      ),
    );
  }
}
