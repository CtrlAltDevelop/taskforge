import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/table_cell_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

export 'package:taskforge/features/tasks/presentation/table_cell_dialogs.dart';

/// A column's cell for [task]: shows the value and, when [canEdit], changes it
/// in place (a menu, a picker or a small dialog) through [saveTask], so
/// conflicts, blocked tasks and refusals behave as everywhere else.
class TaskCell extends ConsumerWidget {
  const TaskCell({
    super.key,
    required this.column,
    required this.task,
    required this.lookups,
    required this.canEdit,
  });

  final String column;
  final Task task;
  final ListLookups lookups;
  final bool canEdit;

  void _save(BuildContext context, WidgetRef ref, TaskPatch patch) =>
      saveTask(context, ref, task, patch);

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (column) {
    'status' => _status(context, ref),
    'priority' => _priority(context, ref),
    'assignee' => _assignee(context, ref),
    'start_date' => _date(context, ref, task.startDate, start: true),
    'due_date' => _date(context, ref, task.dueDate, start: false),
    'created_at' => _text(context, _day(task.createdAt)),
    'updated_at' => _text(context, _day(task.updatedAt)),
    _ => _custom(context, ref),
  };

  static String _day(String iso) =>
      iso.length >= 10 ? iso.substring(0, 10) : '';

  /// A cell's text, at the start of the cell.
  static Widget _text(BuildContext context, String value) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      value,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: context.tf.typography.body.copyWith(color: context.tf.colors.text),
    ),
  );

  /// [shown] as a target that runs [onTap] (the cell is edited by a click).
  Widget _tappable(Key key, Widget shown, VoidCallback onTap) => TfInteractive(
    key: key,
    onTap: onTap,
    button: false,
    builder: (context, states) => DecoratedBox(
      decoration: BoxDecoration(
        color: states.contains(WidgetState.hovered)
            ? context.tf.colors.hover
            : null,
      ),
      child: SizedBox(width: double.infinity, child: shown),
    ),
  );

  Widget _status(BuildContext context, WidgetRef ref) {
    final pill = Align(
      alignment: AlignmentDirectional.centerStart,
      child: TfStatusPill(
        label: task.statusName,
        kind: tfStatusKindOf(task.statusCategory),
      ),
    );
    final statuses = lookups.flow?.statuses ?? const <WorkflowStatus>[];
    if (!canEdit || statuses.isEmpty) return pill;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TfMenu(
        key: Key('cell-status-${task.id}'),
        items: [
          for (final s in statuses)
            TfMenuItem(
              key: Key('status-${s.id}-${task.id}'),
              label: s.name,
              selected: s.id == task.statusId,
              onSelected: () {
                if (s.id != task.statusId) {
                  _save(context, ref, TaskPatch(status: s));
                }
              },
            ),
        ],
        builder: (context, toggle) => TfStatusPill(
          label: task.statusName,
          kind: tfStatusKindOf(task.statusCategory),
          onTap: toggle,
        ),
      ),
    );
  }

  Widget _priority(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    Widget shown(VoidCallback? onTap) => TfInteractive(
      onTap: onTap,
      button: onTap != null,
      builder: (context, _) => DefaultTextStyle(
        style: tf.typography.body.copyWith(color: tf.colors.text),
        child: TfPriorityIcon(
          priority: tfPriorityOf(task.priority),
          label: task.priority.labelIn(context.l10n),
          showLabel: true,
        ),
      ),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: !canEdit
          ? shown(null)
          : TfMenu(
              key: Key('cell-priority-${task.id}'),
              items: [
                for (final p in TaskPriority.values)
                  TfMenuItem(
                    key: Key('priority-${p.wire}-${task.id}'),
                    icon: tfPriorityOf(p).icon,
                    label: p.labelIn(context.l10n),
                    selected: p == task.priority,
                    onSelected: () {
                      if (p != task.priority) {
                        _save(context, ref, TaskPatch(priority: p));
                      }
                    },
                  ),
              ],
              builder: (context, toggle) => shown(toggle),
            ),
    );
  }

  Widget _assignee(BuildContext context, WidgetRef ref) {
    final tf = context.tf;
    final names = [for (final id in task.assigneeIds) lookups.person(id)];
    final shown = Row(
      children: [
        if (names.isNotEmpty) ...[
          TfAvatarStack(names: names, max: 2, size: 20),
          const SizedBox(width: TfSpace.sm),
        ],
        Expanded(
          child: Text(
            names.isEmpty ? '—' : names.join(', '),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: tf.typography.body.copyWith(
              color: names.isEmpty ? tf.colors.textSubtle : tf.colors.text,
            ),
          ),
        ),
      ],
    );
    if (!canEdit) return shown;
    return _tappable(Key('cell-assignee-${task.id}'), shown, () async {
      final picked = await showDialog<List<String>>(
        context: context,
        builder: (_) => AssigneeDialog(
          members: lookups.members,
          selected: task.assigneeIds,
        ),
      );
      if (picked != null && context.mounted) {
        _save(context, ref, TaskPatch(assigneeIds: picked));
      }
    });
  }

  Widget _date(
    BuildContext context,
    WidgetRef ref,
    String value, {
    required bool start,
  }) {
    final shown = Align(
      alignment: AlignmentDirectional.centerStart,
      child: start
          ? Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              style: context.tf.typography.body.copyWith(
                color: value.isEmpty
                    ? context.tf.colors.textSubtle
                    : context.tf.colors.text,
              ),
            )
          : DefaultTextStyle(
              style: context.tf.typography.body.copyWith(
                color: context.tf.colors.text,
              ),
              child: DueText(task),
            ),
    );
    if (!canEdit) return shown;
    return _tappable(
      Key('cell-${start ? 'start' : 'due'}-${task.id}'),
      shown,
      () async {
        final picked = await pickTaskDate(context, value);
        if (picked == null || !context.mounted) return;
        _save(
          context,
          ref,
          start ? TaskPatch(startDate: picked) : TaskPatch(dueDate: picked),
        );
      },
    );
  }

  Widget _custom(BuildContext context, WidgetRef ref) {
    final field = lookups.field(column);
    if (field == null) return const SizedBox.shrink();
    final value = task.fieldValues[field.id] ?? '';
    final shown = _text(
      context,
      fieldDisplay(field, value, userLabel: lookups.person, l10n: context.l10n),
    );
    if (!canEdit) return shown;
    return _tappable(Key('cell-$column-${task.id}'), shown, () async {
      if (field.type == FieldType.checkbox) {
        _save(
          context,
          ref,
          TaskPatch(
            fieldValues: {field.id: value == 'true' ? 'false' : 'true'},
          ),
        );
        return;
      }
      final picked = await showDialog<String>(
        context: context,
        builder: (_) => FieldValueDialog(
          field: field,
          value: value,
          members: lookups.members,
        ),
      );
      if (picked != null && context.mounted) {
        _save(context, ref, TaskPatch(fieldValues: {field.id: picked}));
      }
    });
  }
}
