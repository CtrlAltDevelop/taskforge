import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/presentation/live_flash.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart'
    show ProgressRing;
import 'package:taskforge/features/home/presentation/sample_badge.dart';

/// What is being dragged: a card and the lane it came from (a card only
/// drops inside its own lane).
class BoardDrag {
  const BoardDrag(this.task, this.laneKey);

  final Task task;
  final String laneKey;
}

/// A column to offer in a card's "Move to…" menu.
typedef MoveChoice = ({String key, String label});

/// One task on the board: its id and title, a lock when blocked, and the
/// fields the layout chose. A menu moves it without dragging.
class BoardCard extends StatelessWidget {
  const BoardCard({
    super.key,
    required this.task,
    required this.lookups,
    required this.cardFields,
    required this.onTap,
    this.selected = false,
    this.moveChoices = const [],
    this.onMoveTo,
  });

  final Task task;
  final ListLookups lookups;
  final List<String> cardFields;
  final VoidCallback onTap;
  final bool selected;

  /// The columns the "Move to…" menu offers (empty: the card cannot move).
  final List<MoveChoice> moveChoices;
  final void Function(String column)? onMoveTo;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return LiveFlash(
      taskId: task.id,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TfSpace.sm,
          vertical: TfSpace.xs,
        ),
        child: Material(
          color: selected ? c.selected : c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: TfRadius.panel,
            side: BorderSide(
              color: selected ? c.accent : c.border,
              width: tfHairline,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('card-${task.id}'),
            onTap: onTap,
            hoverColor: c.hover,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                TfSpace.md,
                TfSpace.sm,
                TfSpace.xs,
                TfSpace.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        task.displayId,
                        style: tf.typography.mono.copyWith(
                          color: c.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (task.isBlocked) ...[
                        const SizedBox(width: TfSpace.xs),
                        BlockedBadge(blockedBy: task.blockedBy),
                      ],
                      if (task.isSample) ...[
                        const SizedBox(width: TfSpace.xs),
                        const SampleBadge(),
                      ],
                      const Spacer(),
                      if (onMoveTo != null && moveChoices.isNotEmpty)
                        _MoveMenu(
                          taskId: task.id,
                          choices: moveChoices,
                          onSelected: onMoveTo!,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: TfSpace.sm,
                      bottom: TfSpace.xs,
                    ),
                    child: Tooltip(
                      message: task.title,
                      child: Text(
                        task.title,
                        key: Key('card-title-${task.id}'),
                        style: tf.typography.bodyStrong.copyWith(color: c.text),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  _details(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    final c = context.tf.colors;
    final chips = <Widget>[
      if (cardFields.contains('priority') && task.priority != TaskPriority.none)
        TfPriorityIcon(
          priority: tfPriorityOf(task.priority),
          label: task.priority.labelIn(context.l10n),
          showLabel: true,
        ),
      if (cardFields.contains('due_date') && task.dueDate.isNotEmpty)
        TfChip(icon: TfIcons.calendar, label: task.dueDate, tone: c.neutral),
      for (final column in cardFields)
        if (lookups.field(column) case final field?)
          if (fieldDisplay(
                field,
                task.fieldValues[field.id] ?? '',
                userLabel: lookups.person,
                l10n: context.l10n,
              )
              case final text when text.isNotEmpty)
            TfChip(label: '${field.name}: $text'),
    ];
    final assignees =
        cardFields.contains('assignee') && task.assigneeIds.isNotEmpty;
    final progress = cardFields.contains('progress') && task.progressTotal > 0;
    if (chips.isEmpty && !assignees && !progress) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          // Chips are not controls here: a tap on them opens the card.
          child: IgnorePointer(
            child: Wrap(
              spacing: TfSpace.xs,
              runSpacing: TfSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: chips,
            ),
          ),
        ),
        if (progress)
          ProgressRing(
            key: Key('card-progress-${task.id}'),
            progress: Progress(task.progressDone, task.progressTotal),
          ),
        if (assignees)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: TfSpace.xs),
            child: Tooltip(
              message: [for (final id in task.assigneeIds) lookups.person(id)]
                  .join(', '),
              child: TfAvatarStack(
                key: Key('card-assignees-${task.id}'),
                names: [for (final id in task.assigneeIds) lookups.person(id)],
                max: 3,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}

class _MoveMenu extends StatelessWidget {
  const _MoveMenu({
    required this.taskId,
    required this.choices,
    required this.onSelected,
  });

  final String taskId;
  final List<MoveChoice> choices;
  final void Function(String column) onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 28,
    child: PopupMenuButton<String>(
      key: Key('card-menu-$taskId'),
      tooltip: context.l10n.grpFMoveTo,
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: TfIcon(TfIcons.moreVertical, size: TfIconSize.control),
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final c in choices)
          PopupMenuItem(
            key: Key('move-to-$taskId-${c.key}'),
            value: c.key,
            child: Text(context.l10n.grpFMoveToColumn(c.label)),
          ),
      ],
    ),
  );
}
