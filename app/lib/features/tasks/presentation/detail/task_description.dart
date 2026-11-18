import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/commit_text.dart';
import 'package:taskforge/features/tasks/presentation/presence_strip.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

/// The description, edited in place. What is typed is kept as a draft until
/// it is saved: moving to another task or closing this one never loses it,
/// and if saving failed the draft is still there, marked, to try again.
class TaskDescription extends ConsumerStatefulWidget {
  const TaskDescription({
    super.key,
    required this.task,
    required this.readOnlyReason,
  });

  final Task task;
  final String? readOnlyReason;

  @override
  ConsumerState<TaskDescription> createState() => _TaskDescriptionState();
}

class _TaskDescriptionState extends ConsumerState<TaskDescription> {
  late final _container = ProviderScope.containerOf(context, listen: false);

  Task get _task => widget.task;
  String get _saved => docToMarkdown(_task.description);

  Future<void> _save(String text) async {
    await saveTask(
      context,
      ref,
      _task,
      TaskPatch(description: markdownToDoc(text)),
    );
    if (!mounted) return;
    final now = ref
        .read(taskListProvider(_task.projectId))
        .tasks
        .where((t) => t.id == _task.id)
        .firstOrNull;
    if (now != null && docToMarkdown(now.description) == text) {
      ref.read(taskDraftsProvider.notifier).drop(_task.id);
    }
  }

  /// The box went away with text in it (another task, a closed window):
  /// send it from here, no screen needed. A failure leaves the draft.
  void _flush(String text) {
    final task = _task;
    _container
        .read(taskListProvider(task.projectId).notifier)
        .update(task, TaskPatch(description: markdownToDoc(text)))
        .then<void>(
          (_) => _container.read(taskDraftsProvider.notifier).drop(task.id),
          onError: (Object _) {},
        );
  }

  void _edited(String text) {
    final drafts = ref.read(taskDraftsProvider.notifier);
    if (text == _saved) {
      drafts.drop(_task.id);
    } else {
      drafts.keep(_task.id, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(taskDraftsProvider.select((d) => d[_task.id]));
    final field = CommitTextField(
      fieldKey: const Key('detail-description'),
      value: _saved,
      initialText: draft,
      enabled: widget.readOnlyReason == null,
      multiline: true,
      hint: context.l10n.tdDescriptionHint,
      semanticLabel: context.l10n.grpDDescription,
      style: context.tf.typography.body,
      onCommit: _save,
      onEdited: _edited,
      onLeftDirty: _flush,
      onFocusChanged: (focused) =>
          ref.read(presenceReporterProvider).setEditing(focused),
    );
    final reason = widget.readOnlyReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        reason == null ? field : TfTooltip(message: reason, child: field),
        EditingHint(taskId: _task.id),
        if (draft != null && draft != _saved)
          Padding(
            padding: const EdgeInsets.only(top: TfSpace.xs),
            child: Row(
              spacing: TfSpace.sm,
              children: [
                TfChip(
                  key: const Key('draft-banner'),
                  label: context.l10n.tdUnsavedDraft,
                  icon: TfIcons.warning,
                  tone: context.tf.colors.warning,
                ),
                if (reason == null)
                  TfButton(
                    key: const Key('save-draft'),
                    label: context.l10n.save,
                    variant: TfButtonVariant.ghost,
                    size: TfButtonSize.small,
                    onPressed: () => _save(draft),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
