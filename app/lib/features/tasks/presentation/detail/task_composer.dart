import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart'
    show UploadSource;
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/presentation/comment_composer.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';

/// The message box pinned to the bottom of the activity. It says when
/// messages will wait (offline), and tells a person who may only read why
/// there is no box. Cmd/Ctrl+Enter sends (from the registry too).
class TaskComposer extends ConsumerStatefulWidget {
  const TaskComposer({
    super.key,
    required this.task,
    required this.canComment,
    required this.archived,
    required this.onSend,
  });

  final TaskRef task;
  final bool canComment;
  final bool archived;
  final Future<void> Function(String body, List<UploadSource> files) onSend;

  @override
  ConsumerState<TaskComposer> createState() => _TaskComposerState();
}

class _TaskComposerState extends ConsumerState<TaskComposer> {
  final _handle = ComposerHandle();
  late final _commands = ref.read(taskCommandsProvider);

  @override
  void initState() {
    super.initState();
    _commands.send = _handle.send;
  }

  @override
  void dispose() {
    if (_commands.send == _handle.send) _commands.send = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final l10n = context.l10n;
    if (!widget.canComment) {
      return Padding(
        padding: const EdgeInsets.all(TfSpace.md),
        child: Text(
          widget.archived
              ? l10n.grpBArchivedReadOnly
              : l10n.grpBReadOnlyComments,
          key: const Key('comments-readonly'),
          style: tf.typography.small.copyWith(color: c.textMuted),
        ),
      );
    }
    final online = ref.watch(networkProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          top: BorderSide(color: c.border, width: tfHairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TfSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!online)
              Padding(
                padding: const EdgeInsets.only(bottom: TfSpace.sm),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TfChip(
                    key: const Key('composer-queued'),
                    label: l10n.tdComposerOffline,
                    icon: TfIcons.cloudOff,
                    tone: c.warning,
                  ),
                ),
              ),
            CommentComposer(
              key: const Key('main-composer'),
              task: widget.task,
              allowFiles: true,
              handle: _handle,
              onSend: (body, _, files) => widget.onSend(body, files),
            ),
          ],
        ),
      ),
    );
  }
}
