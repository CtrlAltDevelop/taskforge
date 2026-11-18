import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_status.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_section.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/detail_cells.dart';
import 'package:taskforge/features/tasks/presentation/detail/detail_fields.dart';
import 'package:taskforge/features/tasks/presentation/detail/status_flow.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// The Details grid: every field in a labelled two-column grid, each value
/// click-to-edit with an optimistic save (a clash opens the conflict dialog).
/// On a phone it folds into one card that opens on tap.
class DetailsPanel extends ConsumerStatefulWidget {
  const DetailsPanel({
    super.key,
    required this.project,
    required this.task,
    required this.members,
    required this.readOnlyReason,
    this.collapsible = false,
  });

  final Project project;
  final Task task;
  final List<Member> members;

  /// Null when the person may edit tasks; else why not (shown as a tooltip).
  final String? readOnlyReason;

  /// A phone: folded to a summary until tapped.
  final bool collapsible;

  @override
  ConsumerState<DetailsPanel> createState() => _DetailsPanelState();
}

class _DetailsPanelState extends ConsumerState<DetailsPanel> {
  var _open = true;

  Task get _task => widget.task;

  void _save(TaskPatch patch) => saveTask(context, ref, _task, patch);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reason = widget.readOnlyReason;
    final flow = ref.watch(workflowProvider(widget.project.id)).value;
    final tree = ref.watch(taskTreeProvider(widget.project.id));
    final roleId = ref.watch(permissionSetProvider).roleId;
    final needsAssignee =
        flow != null &&
        _task.assigneeIds.isEmpty &&
        flow.restrict &&
        flow.transitions.any(
          (t) => t.from == _task.statusId && t.requireAssignee,
        );
    final grid = Column(
      key: const Key('details-grid'),
      children: [
        DetailRow(
          label: l10n.grpDStatus,
          icon: TfIcons.active,
          hint: needsAssignee ? l10n.tdNeedsAssignee : null,
          child: StatusField(
            task: _task,
            workflow: flow,
            roleId: roleId,
            reason: reason,
            onPick: (s) => pickStatus(context, ref, tree, _task, s),
          ),
        ),
        DetailRow(
          label: l10n.grpDPriority,
          icon: TfIcons.flag,
          child: PriorityField(
            task: _task,
            reason: reason,
            onPick: (p) => _save(TaskPatch(priority: p)),
          ),
        ),
        DetailRow(
          label: l10n.grpDAssignees,
          icon: TfIcons.users,
          child: AssigneesField(
            task: _task,
            members: widget.members,
            reason: reason,
            onToggle: (id, {required on}) =>
                toggleAssignee(context, ref, _task, id, on: on),
          ),
        ),
        DetailRow(
          label: l10n.grpDStart,
          icon: TfIcons.calendar,
          child: DateField(
            fieldKey: const Key('detail-start'),
            clearKey: const Key('clear-start'),
            label: l10n.grpDStart,
            value: _task.startDate,
            reason: reason,
            onPicked: (v) => _save(TaskPatch(startDate: v)),
          ),
        ),
        DetailRow(
          label: l10n.grpDDue,
          icon: TfIcons.calendarCheck,
          child: DateField(
            fieldKey: const Key('detail-due'),
            clearKey: const Key('clear-due'),
            label: l10n.grpDDue,
            value: _task.dueDate,
            reason: reason,
            onPicked: (v) => _save(TaskPatch(dueDate: v)),
          ),
        ),
        if (_task.dueDate.isNotEmpty)
          DetailRow(
            label: l10n.tdDueTimeShort,
            icon: TfIcons.clock,
            child: DueTimeField(
              task: _task,
              reason: reason,
              onPicked: (utc) => _save(TaskPatch(dueTime: utc)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: TfSpace.xs),
          child: RepeatSection(task: _task, canEdit: reason == null),
        ),
      ],
    );
    if (!widget.collapsible) return TfPanel(child: grid);
    return TfPanel(
      padding: const EdgeInsets.all(TfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FoldHeader(
            open: _open,
            task: _task,
            onToggle: () => setState(() => _open = !_open),
          ),
          if (_open) ...[const SizedBox(height: TfSpace.sm), grid],
        ],
      ),
    );
  }
}

/// The phone's fold: "Details" with status, priority and due as chips.
class _FoldHeader extends StatelessWidget {
  const _FoldHeader({
    required this.open,
    required this.task,
    required this.onToggle,
  });

  final bool open;
  final Task task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      onTap: onToggle,
      semanticLabel: context.l10n.tdDetails,
      builder: (context, states) => Row(
        spacing: TfSpace.sm,
        children: [
          TfIcon(
            open ? TfIcons.chevronDown : TfIcons.chevronEnd,
            color: c.textMuted,
          ),
          Text(context.l10n.tdDetails, style: tf.typography.bodyStrong),
          if (!open)
            Expanded(
              child: Wrap(
                spacing: TfSpace.xs,
                runSpacing: TfSpace.xs,
                children: [
                  TfStatusPill(
                    label: task.statusName,
                    kind: tfStatusKindOf(task.statusCategory),
                  ),
                  if (task.dueDate.isNotEmpty)
                    TfChip(label: task.dueDate, icon: TfIcons.calendar),
                ],
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}
