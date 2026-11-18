import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/commit_text.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

/// The big editable title: plain text until pointed at; Enter or leaving the
/// field saves just the title. A blank title puts the old one back.
class TaskTitle extends ConsumerWidget {
  const TaskTitle({
    super.key,
    required this.task,
    required this.readOnlyReason,
    this.compact = false,
  });

  final Task task;

  /// Null when the person may edit; else why not.
  final String? readOnlyReason;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.tf.typography;
    final field = CommitTextField(
      fieldKey: const Key('detail-title'),
      value: task.title,
      enabled: readOnlyReason == null,
      wrap: true,
      allowEmpty: false,
      maxLength: maxTitleLength,
      hint: context.l10n.grpDTitle,
      semanticLabel: context.l10n.grpDTitle,
      style: compact ? type.title : type.display,
      onCommit: (text) {
        final title = text.trim();
        if (title == task.title) return;
        saveTask(context, ref, task, TaskPatch(title: title));
      },
    );
    final reason = readOnlyReason;
    return reason == null ? field : TfTooltip(message: reason, child: field);
  }
}
