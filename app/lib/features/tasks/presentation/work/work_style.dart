import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Row heights of the work views: 36 px compact, 44 px comfortable.
const workRowCompact = 36.0;
const workRowComfortable = 44.0;

/// A phone card in the list (a skeleton card matches it).
const phoneCardHeight = 80.0;

double workRowHeight(BuildContext context) =>
    context.tf.density == TfDensity.compact
    ? workRowCompact
    : workRowComfortable;

TfPriority tfPriorityOf(TaskPriority p) => switch (p) {
  TaskPriority.urgent => TfPriority.urgent,
  TaskPriority.high => TfPriority.high,
  TaskPriority.normal => TfPriority.normal,
  TaskPriority.low => TfPriority.low,
  TaskPriority.none => TfPriority.none,
};

TfStatusKind tfStatusKindOf(StatusCategory c) => switch (c) {
  StatusCategory.notStarted => TfStatusKind.todo,
  StatusCategory.active => TfStatusKind.active,
  StatusCategory.done => TfStatusKind.done,
  StatusCategory.cancelled => TfStatusKind.cancelled,
};

/// Whether [task] is past its due date and still open.
bool isOverdue(Task task, Day today) {
  final due = parseDay(task.dueDate);
  if (due == null || !due.isBefore(today)) return false;
  return task.statusCategory != StatusCategory.done &&
      task.statusCategory != StatusCategory.cancelled;
}

/// A due date; past due and open it turns red with a warning icon (never
/// colour alone).
class DueText extends ConsumerWidget {
  const DueText(this.task, {super.key});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    if (task.dueDate.isEmpty) {
      return Text('—', style: TextStyle(color: tf.colors.textSubtle));
    }
    final late = isOverdue(task, ref.watch(todayProvider));
    final text = Text(
      task.dueDate,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: late ? tf.colors.danger.fg : null),
    );
    if (!late) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TfIcon(
          TfIcons.warning,
          size: 14,
          color: tf.colors.danger.fg,
          semanticLabel: context.l10n.wvOverdue,
        ),
        const SizedBox(width: TfSpace.xs),
        Flexible(child: text),
      ],
    );
  }
}

/// A bordered card on the canvas that lets its child (a `ListTile`) paint
/// ink: the phone agenda and the timeline list use it.
class WorkCard extends StatelessWidget {
  const WorkCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TfSpace.md,
        vertical: TfSpace.xs,
      ),
      child: Material(
        color: c.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: TfRadius.panel,
          side: BorderSide(color: c.border, width: tfHairline),
        ),
        child: child,
      ),
    );
  }
}
