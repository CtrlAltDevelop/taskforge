import 'package:flutter/material.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart'
    show ProgressRing;

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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selected ? scheme.secondaryContainer : null,
      child: InkWell(
        key: Key('card-${task.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    task.displayId,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (task.isBlocked) ...[
                    const SizedBox(width: 4),
                    BlockedBadge(blockedBy: task.blockedBy),
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
                padding: const EdgeInsetsDirectional.only(end: 6, bottom: 4),
                child: Text(
                  task.title,
                  key: Key('card-title-${task.id}'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _details(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    final chips = <Widget>[
      if (cardFields.contains('priority') && task.priority != TaskPriority.none)
        _Chip(
          icon: priorityIcon(task.priority),
          color: priorityColor(task.priority),
          label: task.priority.label,
        ),
      if (cardFields.contains('due_date') && task.dueDate.isNotEmpty)
        _Chip(icon: Icons.event_outlined, label: task.dueDate),
      for (final column in cardFields)
        if (lookups.field(column) case final field?)
          if (fieldDisplay(
                field,
                task.fieldValues[field.id] ?? '',
                userLabel: lookups.person,
              )
              case final text when text.isNotEmpty)
            _Chip(label: '${field.name}: $text'),
    ];
    final assignees =
        cardFields.contains('assignee') && task.assigneeIds.isNotEmpty;
    final progress = cardFields.contains('progress') && task.progressTotal > 0;
    if (chips.isEmpty && !assignees && !progress) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(child: Wrap(spacing: 4, runSpacing: 4, children: chips)),
        if (progress)
          ProgressRing(
            key: Key('card-progress-${task.id}'),
            progress: Progress(task.progressDone, task.progressTotal),
          ),
        if (assignees)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
            child: _Avatars(
              key: Key('card-assignees-${task.id}'),
              names: [for (final id in task.assigneeIds) lookups.person(id)],
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
      tooltip: 'Move to…',
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final c in choices)
          PopupMenuItem(
            key: Key('move-to-$taskId-${c.key}'),
            value: c.key,
            child: Text('Move to ${c.label}'),
          ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) Icon(icon, size: 14, color: color),
      if (icon != null) const SizedBox(width: 2),
      Flexible(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _Avatars extends StatelessWidget {
  const _Avatars({super.key, required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: names.join(', '),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final name in names.take(3))
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: CircleAvatar(
              radius: 11,
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        if (names.length > 3) Text('+${names.length - 3}'),
      ],
    ),
  );
}
