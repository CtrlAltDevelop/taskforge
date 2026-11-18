import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/features/home/presentation/sample_badge.dart';

/// One task on the phone: a card with a status stripe, the title, its id,
/// status, due date and people, and a menu. Long press starts picking.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    this.selected = false,
    this.statusColor,
    this.depth = 0,
    this.hasChildren = false,
    this.expanded = true,
    this.progress = Progress.none,
    this.onToggle,
    this.actions = const [],
    this.onAction,
    this.fieldSummary = '',
    this.onLongPress,
    this.picked,
    this.onPick,
    this.dragHandle,
  });

  final Task task;

  /// Grip that starts dragging the task onto another.
  final Widget? dragHandle;

  /// The task's custom field values for the List view (see [fieldSummary]).
  final String fieldSummary;

  /// The colour of the task's status (grey until the workflow has loaded).
  final Color? statusColor;
  final VoidCallback onTap;
  final bool selected;

  /// How far the row is indented, whether it has a chevron, and the ring of
  /// how much of its subtasks is done.
  final int depth;
  final bool hasChildren;
  final bool expanded;
  final Progress progress;
  final VoidCallback? onToggle;

  /// The row menu: shown when there is something in it.
  final List<TaskAction> actions;
  final void Function(TaskAction)? onAction;

  /// Long press starts picking tasks for a bulk edit; once any is picked
  /// [picked] is non-null (whether this one is) and a checkbox shows.
  final VoidCallback? onLongPress;
  final bool? picked;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    final done = task.statusCategory == StatusCategory.done;
    final accent = statusColor ?? c.borderStrong;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TfSpace.md,
        vertical: TfSpace.xs,
      ),
      child: Material(
        color: selected || picked == true
            ? c.selected
            : done
            ? c.sunken
            : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: TfRadius.panel,
          side: BorderSide(color: c.border, width: tfHairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status colour stripe: the card's state at a glance.
              Container(key: Key('stripe-${task.id}'), width: 4, color: accent),
              Expanded(child: _body(context)),
              if (dragHandle != null) Center(child: dragHandle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final done = task.statusCategory == StatusCategory.done;
    return InkWell(
      key: Key('task-${task.id}'),
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: phoneCardHeight - 8),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: TfSpace.sm + depth * TfSpace.lg,
            end: TfSpace.xs,
            top: TfSpace.xs,
            bottom: TfSpace.xs,
          ),
          child: Row(
            spacing: TfSpace.xs,
            children: [
              if (picked != null)
                TfCheckbox(
                  key: Key('check-${task.id}'),
                  value: picked,
                  onChanged: (_) => onPick?.call(),
                ),
              if (hasChildren)
                TfIconButton(
                  key: Key('toggle-${task.id}'),
                  icon: expanded ? TfIcons.chevronDown : TfIcons.chevronEnd,
                  tooltip: expanded
                      ? context.l10n.grpBCollapse
                      : context.l10n.grpBExpand,
                  size: TfButtonSize.small,
                  onPressed: onToggle,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      spacing: TfSpace.xs,
                      children: [
                        PendingMark(id: task.id),
                        if (task.isBlocked)
                          BlockedBadge(blockedBy: task.blockedBy),
                        if (task.isSample) const SampleBadge(),
                        if (task.priority != TaskPriority.none)
                          TfPriorityIcon(
                            priority: tfPriorityOf(task.priority),
                            label: task.priority.labelIn(context.l10n),
                          ),
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tf.typography.bodyStrong.copyWith(
                              color: done ? c.textMuted : c.text,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TfSpace.xs),
                    Row(
                      spacing: TfSpace.sm,
                      children: [
                        Text(
                          isolateLtr(task.displayId),
                          style: tf.typography.mono.copyWith(
                            color: c.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Flexible(
                          // Not a control here: a tap on it opens the card.
                          child: IgnorePointer(
                            child: TfStatusPill(
                              label: task.statusName,
                              kind: tfStatusKindOf(task.statusCategory),
                            ),
                          ),
                        ),
                        if (task.dueDate.isNotEmpty)
                          Flexible(child: DueText(task)),
                        if (fieldSummary.isNotEmpty)
                          Flexible(
                            child: Text(
                              fieldSummary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tf.typography.small.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!progress.isEmpty)
                KeyedSubtree(
                  key: Key('progress-${task.id}'),
                  child: ProgressRing(progress: progress),
                ),
              if (task.assigneeIds.isNotEmpty)
                IgnorePointer(
                  child: TfChip(
                    key: Key('assignees-${task.id}'),
                    icon: TfIcons.users,
                    label: '${task.assigneeIds.length}',
                  ),
                ),
              if (actions.isNotEmpty)
                PopupMenuButton<TaskAction>(
                  key: Key('task-menu-${task.id}'),
                  tooltip: context.l10n.grpFMore,
                  icon: TfIcon(
                    TfIcons.moreVertical,
                    size: TfIconSize.control,
                    color: c.textMuted,
                  ),
                  onSelected: onAction,
                  itemBuilder: (_) => [
                    for (final a in actions)
                      PopupMenuItem(
                        key: Key('${a.name}-${task.id}'),
                        value: a,
                        child: Text(a.labelIn(context.l10n)),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What shows behind a card while it is swiped to complete or delete.
class TaskSwipeBackground extends StatelessWidget {
  const TaskSwipeBackground({
    super.key,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final TfIconData icon;
  final String label;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(
      horizontal: TfSpace.md,
      vertical: TfSpace.xs,
    ),
    decoration: BoxDecoration(
      color: context.tf.colors.accentTone.bg,
      borderRadius: TfRadius.panel,
    ),
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: TfSpace.xl),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: TfSpace.sm,
      children: [
        TfIcon(icon, color: context.tf.colors.accentTone.fg),
        Text(label),
      ],
    ),
  );
}
