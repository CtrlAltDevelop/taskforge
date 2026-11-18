import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Where a task opens: its project with the task's detail on top.
String taskLocation(HomeTask t) => '/projects/${t.projectId}?task=${t.taskId}';

TfStatusKind statusKindOf(String category) => switch (StatusCategory.values
    .where((c) => c.wire == category)
    .firstOrNull) {
  StatusCategory.active => TfStatusKind.active,
  StatusCategory.done => TfStatusKind.done,
  StatusCategory.cancelled => TfStatusKind.cancelled,
  _ => TfStatusKind.todo,
};

/// One task line: `KEY-N`, title, due date and a status pill ([status] lets
/// a card swap the pill for a menu).
class HomeTaskRow extends StatelessWidget {
  const HomeTaskRow({
    super.key,
    required this.task,
    this.today = '',
    this.status,
    this.notes = const [],
    this.onTap,
  });

  final HomeTask task;

  /// Today's ISO date, to mark an open task past due.
  final String today;
  final Widget? status;

  /// Short words after the id in the subtitle (Assigned, Watching).
  final List<String> notes;
  final VoidCallback? onTap;

  bool get _overdue =>
      task.dueDate.isNotEmpty &&
      today.isNotEmpty &&
      task.dueDate.compareTo(today) < 0 &&
      !task.isDone;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final due = parseDay(task.dueDate);
    final dueText = due == null ? '' : context.localIso(due);
    return TfRow(
      key: Key('home-task-${task.taskId}'),
      title: task.title,
      subtitle: [
        task.displayId,
        ...notes,
        if (_overdue) context.l10n.homeOverdueOn(dueText) else dueText,
      ].where((t) => t.isNotEmpty).join(' · '),
      leading: _overdue
          ? TfIcon(TfIcons.warning, size: 16, color: c.danger.fg)
          : null,
      onTap: onTap ?? () => context.go(taskLocation(task)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: TfSpace.sm,
        children: [
          Flexible(
            child:
                status ??
                TfStatusPill(
                  label: task.statusName,
                  kind: statusKindOf(task.statusCategory),
                ),
          ),
        ],
      ),
    );
  }
}
