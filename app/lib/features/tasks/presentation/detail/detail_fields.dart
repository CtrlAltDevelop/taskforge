import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/detail_cells.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// The status, as a pill that opens the moves the workflow allows (the
/// current one is always there). Until the workflow has loaded it is read-only.
class StatusField extends StatelessWidget {
  const StatusField({
    super.key,
    required this.task,
    required this.workflow,
    required this.roleId,
    required this.reason,
    required this.onPick,
  });

  final Task task;
  final Workflow? workflow;
  final String roleId;

  /// Null when the person may edit; else why they may not.
  final String? reason;
  final void Function(WorkflowStatus) onPick;

  @override
  Widget build(BuildContext context) {
    final flow = workflow;
    final options = flow == null
        ? [
            WorkflowStatus(
              id: task.statusId,
              name: task.statusName,
              category: task.statusCategory,
            ),
          ]
        : flow.targets(
            from: task.statusId,
            hasAssignee: task.assigneeIds.isNotEmpty,
            roleId: roleId,
          );
    final editable = reason == null && flow != null;
    return TfMenu(
      items: [
        for (final s in options)
          TfMenuItem(
            label: s.name,
            selected: s.id == task.statusId,
            onSelected: () {
              if (s.id != task.statusId) onPick(s);
            },
          ),
      ],
      builder: (context, toggle) => ValueButton(
        key: const Key('detail-status'),
        onTap: editable ? toggle : null,
        readOnlyReason: reason,
        semanticLabel: '${context.l10n.grpDStatus}: ${task.statusName}',
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: TfStatusPill(
              label: task.statusName,
              kind: tfStatusKindOf(task.statusCategory),
            ),
          ),
        ),
      ),
    );
  }
}

/// The priority: an icon and its name; opens the five levels.
class PriorityField extends StatelessWidget {
  const PriorityField({
    super.key,
    required this.task,
    required this.reason,
    required this.onPick,
  });

  final Task task;
  final String? reason;
  final void Function(TaskPriority) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TfMenu(
      items: [
        for (final p in TaskPriority.values)
          TfMenuItem(
            label: p.labelIn(l10n),
            icon: tfPriorityOf(p).icon,
            selected: p == task.priority,
            onSelected: () {
              if (p != task.priority) onPick(p);
            },
          ),
      ],
      builder: (context, toggle) => ValueButton(
        key: const Key('detail-priority'),
        onTap: reason == null ? toggle : null,
        readOnlyReason: reason,
        semanticLabel: '${l10n.grpDPriority}: ${task.priority.labelIn(l10n)}',
        child: ExcludeSemantics(
          child: TfPriorityIcon(
            priority: tfPriorityOf(task.priority),
            label: task.priority.labelIn(l10n),
            showLabel: true,
          ),
        ),
      ),
    );
  }
}

/// A date: the value opens the picker, the x clears it.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.fieldKey,
    required this.clearKey,
    required this.label,
    required this.value,
    required this.reason,
    required this.onPicked,
  });

  final Key fieldKey;
  final Key clearKey;
  final String label;
  final String value;
  final String? reason;
  final void Function(String) onPicked;

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: DateTime.tryParse(value) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    onPicked(picked.toIso8601String().substring(0, 10));
  }

  @override
  Widget build(BuildContext context) {
    final shown = context.localDateOrEmpty(DateTime.tryParse(value));
    return Row(
      children: [
        Flexible(
          child: ValueButton(
            key: fieldKey,
            onTap: reason == null ? () => _pick(context) : null,
            readOnlyReason: reason,
            semanticLabel: '$label: ${shown.isEmpty ? '' : shown}',
            child: shown.isEmpty
                ? EmptyValue(context.l10n.tdNotSet)
                : Text(
                    shown,
                    style: context.tf.typography.body.copyWith(
                      color: context.tf.colors.text,
                    ),
                  ),
          ),
        ),
        if (value.isNotEmpty && reason == null)
          TfIconButton(
            key: clearKey,
            icon: TfIcons.close,
            tooltip: context.l10n.grpDClearField(label),
            size: TfButtonSize.small,
            onPressed: () => onPicked(''),
          ),
      ],
    );
  }
}

/// The optional time of day a task is due, read and picked on the viewer's
/// clock and stored in UTC (the due date never moves with it).
class DueTimeField extends StatelessWidget {
  const DueTimeField({
    super.key,
    required this.task,
    required this.reason,
    required this.onPicked,
  });

  final Task task;
  final String? reason;
  final void Function(String utc) onPicked;

  Future<void> _pick(BuildContext context, String local) async {
    final initial = local.isEmpty
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: int.parse(local.substring(0, 2)),
            minute: int.parse(local.substring(3)),
          );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    onPicked(utcClock(task.dueDate, picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final local = dueTimeLocal(task);
    return Row(
      children: [
        Flexible(
          child: ValueButton(
            key: const Key('detail-due-time'),
            onTap: reason == null ? () => _pick(context, local) : null,
            readOnlyReason: reason,
            semanticLabel: context.l10n.grpDDueTime,
            child: local.isEmpty
                ? EmptyValue(context.l10n.tdNotSet)
                : Text(
                    context.localDigits(local),
                    style: context.tf.typography.body.copyWith(
                      color: context.tf.colors.text,
                    ),
                  ),
          ),
        ),
        if (local.isNotEmpty && reason == null)
          TfIconButton(
            key: const Key('clear-due-time'),
            icon: TfIcons.close,
            tooltip: context.l10n.grpDClearDueTime,
            size: TfButtonSize.small,
            onPressed: () => onPicked(''),
          ),
      ],
    );
  }
}

/// Who the task is assigned to: every candidate as a chip, tap to toggle.
class AssigneesField extends StatelessWidget {
  const AssigneesField({
    super.key,
    required this.task,
    required this.members,
    required this.reason,
    required this.onToggle,
  });

  final Task task;
  final List<Member> members;
  final String? reason;
  final void Function(String userId, {required bool on}) onToggle;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return EmptyValue(context.l10n.tdUnassigned);
    final chips = Wrap(
      spacing: TfSpace.xs,
      runSpacing: TfSpace.xs,
      children: [
        for (final m in members)
          TfChip(
            key: Key('assignee-${m.userId}'),
            label: m.label,
            icon: task.assigneeIds.contains(m.userId) ? TfIcons.check : null,
            selected: task.assigneeIds.contains(m.userId),
            onTap: reason == null
                ? () => onToggle(
                    m.userId,
                    on: !task.assigneeIds.contains(m.userId),
                  )
                : null,
          ),
      ],
    );
    final avatars = task.assigneeIds.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: TfSpace.xs),
            child: TfAvatarStack(
              names: [
                for (final m in members)
                  if (task.assigneeIds.contains(m.userId)) m.label,
              ],
            ),
          );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [?avatars, chips],
    );
    return reason == null ? body : TfTooltip(message: reason!, child: body);
  }
}
