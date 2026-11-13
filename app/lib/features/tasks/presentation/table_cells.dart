import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

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
    'created_at' => _text(_day(task.createdAt)),
    'updated_at' => _text(_day(task.updatedAt)),
    _ => _custom(context, ref),
  };

  static String _day(String iso) =>
      iso.length >= 10 ? iso.substring(0, 10) : '';

  Widget _text(String value) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1),
  );

  Widget _status(BuildContext context, WidgetRef ref) {
    final status = lookups.flow?.statusById(task.statusId);
    final chip = Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: status?.swatch ?? Colors.grey,
          semanticLabel: task.statusName,
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(task.statusName, overflow: TextOverflow.ellipsis)),
      ],
    );
    final statuses = lookups.flow?.statuses ?? const <WorkflowStatus>[];
    if (!canEdit || statuses.isEmpty) return chip;
    return PopupMenuButton<WorkflowStatus>(
      key: Key('cell-status-${task.id}'),
      tooltip: context.l10n.grpFChangeStatus,
      onSelected: (s) {
        if (s.id != task.statusId) _save(context, ref, TaskPatch(status: s));
      },
      itemBuilder: (_) => [
        for (final s in statuses)
          PopupMenuItem(
            key: Key('status-${s.id}-${task.id}'),
            value: s,
            child: Text(s.name),
          ),
      ],
      child: chip,
    );
  }

  Widget _priority(BuildContext context, WidgetRef ref) {
    final shown = Row(
      children: [
        Icon(
          priorityIcon(task.priority),
          size: 18,
          color: priorityColor(task.priority),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            task.priority.labelIn(context.l10n),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    if (!canEdit) return shown;
    return PopupMenuButton<TaskPriority>(
      key: Key('cell-priority-${task.id}'),
      tooltip: context.l10n.grpFChangePriority,
      onSelected: (p) {
        if (p != task.priority) _save(context, ref, TaskPatch(priority: p));
      },
      itemBuilder: (_) => [
        for (final p in TaskPriority.values)
          PopupMenuItem(
            key: Key('priority-${p.wire}-${task.id}'),
            value: p,
            child: Text(p.labelIn(context.l10n)),
          ),
      ],
      child: shown,
    );
  }

  Widget _assignee(BuildContext context, WidgetRef ref) {
    final names = [for (final id in task.assigneeIds) lookups.person(id)];
    final shown = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        names.isEmpty ? '—' : names.join(', '),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
    if (!canEdit) return shown;
    return InkWell(
      key: Key('cell-assignee-${task.id}'),
      onTap: () async {
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
      },
      child: shown,
    );
  }

  Widget _date(
    BuildContext context,
    WidgetRef ref,
    String value, {
    required bool start,
  }) {
    final shown = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(value.isEmpty ? '—' : value, maxLines: 1),
    );
    if (!canEdit) return shown;
    return InkWell(
      key: Key('cell-${start ? 'start' : 'due'}-${task.id}'),
      onTap: () async {
        final picked = await pickTaskDate(context, value);
        if (picked == null || !context.mounted) return;
        final iso = picked.isEmpty ? '' : picked;
        _save(
          context,
          ref,
          start ? TaskPatch(startDate: iso) : TaskPatch(dueDate: iso),
        );
      },
      child: shown,
    );
  }

  Widget _custom(BuildContext context, WidgetRef ref) {
    final field = lookups.field(column);
    if (field == null) return const SizedBox.shrink();
    final value = task.fieldValues[field.id] ?? '';
    final shown = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        fieldDisplay(
          field,
          value,
          userLabel: lookups.person,
          l10n: context.l10n,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
    if (!canEdit) return shown;
    return InkWell(
      key: Key('cell-$column-${task.id}'),
      onTap: () async {
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
      },
      child: shown,
    );
  }
}

/// A date for a task: the picked day as `YYYY-MM-DD`, an empty string to clear
/// it, null when cancelled.
Future<String?> pickTaskDate(BuildContext context, String current) async {
  final now = DateTime.now();
  final initial = DateTime.tryParse(current) ?? now;
  final choice = await showDialog<String>(
    context: context,
    builder: (dialog) => SimpleDialog(
      title: Text(dialog.l10n.grpFDate),
      children: [
        SimpleDialogOption(
          key: const Key('date-pick'),
          onPressed: () async {
            final day = await showAppDatePicker(
              context: dialog,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (!dialog.mounted) return;
            Navigator.pop(dialog, day?.toIso8601String().substring(0, 10));
          },
          child: Text(dialog.l10n.grpFPickDay),
        ),
        if (current.isNotEmpty)
          SimpleDialogOption(
            key: const Key('date-clear'),
            onPressed: () => Navigator.pop(dialog, ''),
            child: Text(dialog.l10n.grpFClear),
          ),
      ],
    ),
  );
  return choice;
}

/// Several members to assign: the chosen user ids when confirmed.
class AssigneeDialog extends StatefulWidget {
  const AssigneeDialog({
    super.key,
    required this.members,
    required this.selected,
  });

  final List<Member> members;
  final List<String> selected;

  @override
  State<AssigneeDialog> createState() => _AssigneeDialogState();
}

class _AssigneeDialogState extends State<AssigneeDialog> {
  late final _picked = {...widget.selected};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpFAssignees),
    content: SizedBox(
      width: 320,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final m in widget.members)
            CheckboxListTile(
              key: Key('assign-${m.userId}'),
              value: _picked.contains(m.userId),
              title: Text(m.label),
              onChanged: (on) => setState(
                () => on == true
                    ? _picked.add(m.userId)
                    : _picked.remove(m.userId),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const Key('assign-save'),
        onPressed: () => Navigator.pop(context, _picked.toList()),
        child: Text(context.l10n.save),
      ),
    ],
  );
}

/// One custom field's value in a small dialog: the new value when saved.
class FieldValueDialog extends StatefulWidget {
  const FieldValueDialog({
    super.key,
    required this.field,
    required this.value,
    required this.members,
  });

  final CustomField field;
  final String value;
  final List<Member> members;

  @override
  State<FieldValueDialog> createState() => _FieldValueDialogState();
}

class _FieldValueDialogState extends State<FieldValueDialog> {
  late String _value = widget.value;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.field.name),
    content: SizedBox(
      width: 320,
      child: FieldInput(
        field: widget.field,
        value: _value,
        members: widget.members,
        onChanged: (v) => setState(() => _value = v),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const Key('field-value-save'),
        onPressed: () => Navigator.pop(context, _value),
        child: Text(context.l10n.save),
      ),
    ],
  );
}
