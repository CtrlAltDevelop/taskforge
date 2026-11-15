import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachment_access.dart';
import 'package:taskforge/features/attachments/presentation/attachment_tiles.dart';
import 'package:taskforge/features/attachments/presentation/attach_buttons.dart';
import 'package:taskforge/features/attachments/presentation/attachment_viewer.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// "12 MB of 10 GB used" (or "12 MB used" when the workspace has no limit).
String usageLine(StorageUsage usage, AppLocalizations l10n) => usage.limited
    ? l10n.grpRStorageOf(
        formatBytes(usage.usedBytes, l10n),
        formatBytes(usage.quotaBytes, l10n),
      )
    : l10n.grpRStorageUsed(formatBytes(usage.usedBytes, l10n));

/// The files of a task: a drop zone and buttons to add more, the uploads on
/// their way with progress, cancel and retry, and a grid of what is there.
/// Files that belong to a comment are shown under that comment instead, so
/// this grid lists only what was attached to the task itself.
class AttachmentsSection extends ConsumerStatefulWidget {
  const AttachmentsSection({
    super.key,
    required this.projectId,
    required this.taskId,
    this.archived = false,
  });

  final String projectId;
  final String taskId;
  final bool archived;

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  var _dragging = false;
  final _focus = FocusNode();

  TaskRef get _ref => (project: widget.projectId, task: widget.taskId);

  AttachmentsNotifier get _notifier =>
      ref.read(attachmentsProvider(_ref).notifier);

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _say(String Function(AppLocalizations l10n) text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text(context.l10n))));
  }

  /// Runs [action], saying so rather than throwing when a dialog, the
  /// clipboard or a file that was picked cannot be used.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      _say((l10n) => l10n.grpHCouldNotReadFile);
    }
  }

  Future<void> _paste() => _guard(() async {
    final image = await ref.read(clipboardImageProvider)();
    if (!mounted || image == null) return;
    await _notifier.add([image]);
  });

  Future<void> _confirmDelete(Attachment file) => _guard(() async {
    if (!await confirmDeleteAttachment(context, file.filename)) return;
    if (mounted) await _notifier.delete(file);
  });

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attachmentsProvider(_ref));
    final permissions = ref.watch(permissionSetProvider);
    final usage = ref.watch(storageUsageProvider).value;
    final canAdd = !widget.archived && permissions.can(Perm.taskUpdate);
    final files = [
      for (final a in state.attachments)
        if (a.commentId.isEmpty) a,
    ];
    final uploads = [
      for (final u in state.uploads)
        if (u.commentId.isEmpty) u,
    ];

    return Column(
      key: const Key('attachments'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                files.isEmpty
                    ? context.l10n.grpHAttachments
                    : context.l10n.grpHAttachmentsCount(files.length),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (canAdd)
              AttachButtons(
                keyPrefix: 'attachment',
                onPicked: _notifier.add,
                onError: () => _say((l10n) => l10n.grpHCouldNotReadFile),
              ),
          ],
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              key: const Key('attachment-error'),
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      attachmentErrorMessage(state.error!, context.l10n),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('attachment-error-dismiss'),
                  tooltip: context.l10n.grpHDismiss,
                  onPressed: _notifier.clearError,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
        if (canAdd) _dropZone(context),
        for (final u in uploads)
          UploadRow(
            key: Key('upload-${u.localId}'),
            item: u,
            onCancel: () => _notifier.cancel(u.localId),
            onRetry: () => _notifier.retry(u.localId),
            onDismiss: () => _notifier.dismiss(u.localId),
          ),
        if (files.isEmpty && uploads.isEmpty && !state.loading && !canAdd)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.l10n.grpHNoAttachments,
              key: const Key('no-attachments'),
            ),
          ),
        if (files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              key: const Key('attachment-grid'),
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in files)
                  Builder(
                    builder: (context) {
                      final deletable = canDeleteFile(
                        ref,
                        a,
                        archived: widget.archived,
                      );
                      return AttachmentTile(
                        key: Key('attachment-${a.id}'),
                        file: a,
                        onOpen: () => showAttachmentViewer(
                          context,
                          file: a,
                          onDelete: deletable
                              ? () => _notifier.delete(a)
                              : null,
                        ),
                        onDelete: deletable ? () => _confirmDelete(a) : null,
                      );
                    },
                  ),
              ],
            ),
          ),
        if (usage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.localDigits(usageLine(usage, context.l10n)),
              key: const Key('storage-usage'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }

  Widget _dropZone(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    // Ctrl/Cmd+V pastes an image once the zone has been clicked.
    return CallbackShortcuts(
      bindings: {
        if (canReadClipboardImage) ...{
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
              unawaited(_paste()),
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): () =>
              unawaited(_paste()),
        },
      },
      child: Focus(
        focusNode: _focus,
        child: DropTarget(
          onDragEntered: (_) => setState(() => _dragging = true),
          onDragExited: (_) => setState(() => _dragging = false),
          onDragDone: (details) {
            setState(() => _dragging = false);
            unawaited(
              _guard(
                () => _notifier.add([
                  for (final f in details.files) XFileSource(f),
                ]),
              ),
            );
          },
          child: Semantics(
            button: true,
            label: context.l10n.grpHDropZoneLabel,
            excludeSemantics: true,
            child: InkWell(
              key: const Key('drop-zone'),
              onTap: _focus.requestFocus,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _dragging ? color.primary : color.outlineVariant,
                    width: _dragging ? 2 : 1,
                  ),
                  color: _dragging
                      ? color.primaryContainer.withValues(alpha: 0.3)
                      : null,
                ),
                child: Text(
                  _dragging
                      ? context.l10n.grpHDropToAttach
                      : context.l10n.grpHDropFilesHere,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
