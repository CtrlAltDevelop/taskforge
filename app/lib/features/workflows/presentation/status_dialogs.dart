import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Asks where the tasks of [status] go before it is deleted. Returns the key of
/// the chosen status, or null when cancelled.
Future<String?> askMigrationTarget(
  BuildContext context,
  DraftStatus status,
  List<DraftStatus> others, {
  String? message,
}) => showDialog<String>(
  context: context,
  builder: (context) =>
      _MigrationDialog(status: status, others: others, message: message),
);

class _MigrationDialog extends StatefulWidget {
  const _MigrationDialog({
    required this.status,
    required this.others,
    this.message,
  });

  final DraftStatus status;
  final List<DraftStatus> others;

  /// Replaces the usual "N tasks are in this status" sentence.
  final String? message;

  @override
  State<_MigrationDialog> createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<_MigrationDialog> {
  late String _target = widget.others
      .firstWhere((s) => s.isDefault, orElse: () => widget.others.first)
      .key;

  @override
  Widget build(BuildContext context) {
    final count = widget.status.taskCount;
    return TfDialogFrame(
      title: context.l10n.grpIDeleteStatusTitle(widget.status.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message ?? context.l10n.grpITasksInStatus(count),
            key: const Key('migration-explain'),
          ),
          const SizedBox(height: TfSpace.lg),
          TfSelectField(
            key: const Key('migrate-target'),
            options: {
              for (final s in widget.others)
                s.key: s.name.isEmpty ? context.l10n.grpIUnnamed : s.name,
            },
            value: _target,
            onChanged: (v) => setState(() => _target = v),
            label: context.l10n.grpIMoveTasksTo,
            expand: true,
          ),
        ],
      ),
      actions: [
        TfButton(
          key: const Key('cancel-delete-status'),
          label: context.l10n.grpICancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
        TfButton(
          key: const Key('confirm-delete-status'),
          label: context.l10n.grpIMoveTasksAndDelete,
          variant: TfButtonVariant.primary,
          onPressed: () => Navigator.pop(context, _target),
        ),
      ],
    );
  }
}

/// The conditions chosen for one transition.
class TransitionConditions {
  const TransitionConditions({
    required this.requiredRoleId,
    required this.requireAssignee,
    required this.requireSubtasksDone,
  });

  final String requiredRoleId;
  final bool requireAssignee;
  final bool requireSubtasksDone;
}

/// Edits when a move [from] -> [to] is allowed: only some role, and/or only
/// once the task has an assignee.
Future<TransitionConditions?> editConditions(
  BuildContext context, {
  required WorkflowTransition transition,
  required String title,
  required List<Role> roles,
}) => showDialog<TransitionConditions>(
  context: context,
  builder: (context) =>
      _ConditionsDialog(transition: transition, title: title, roles: roles),
);

class _ConditionsDialog extends StatefulWidget {
  const _ConditionsDialog({
    required this.transition,
    required this.title,
    required this.roles,
  });

  final WorkflowTransition transition;
  final String title;
  final List<Role> roles;

  @override
  State<_ConditionsDialog> createState() => _ConditionsDialogState();
}

class _ConditionsDialogState extends State<_ConditionsDialog> {
  late String _role =
      widget.roles.any((r) => r.id == widget.transition.requiredRoleId)
      ? widget.transition.requiredRoleId
      : '';
  late bool _assignee = widget.transition.requireAssignee;
  late bool _subtasks = widget.transition.requireSubtasksDone;

  @override
  Widget build(BuildContext context) => TfDialogFrame(
    title: widget.title,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TfSelectField(
          key: const Key('condition-role'),
          options: {
            '': context.l10n.grpIAnyRole,
            for (final r in widget.roles)
              r.id: context.l10n.grpIOnlyRole(r.name),
          },
          value: _role,
          onChanged: (v) => setState(() => _role = v),
          label: context.l10n.grpIWhoMayMove,
          expand: true,
        ),
        const SizedBox(height: TfSpace.md),
        TfToggle(
          key: const Key('condition-assignee'),
          value: _assignee,
          onChanged: (v) => setState(() => _assignee = v),
          label: context.l10n.grpITaskNeedsAssignee,
        ),
        TfToggleTile(
          key: const Key('condition-subtasks'),
          value: _subtasks,
          onChanged: (v) => setState(() => _subtasks = v),
          title: context.l10n.grpIAllSubtasksDone,
          subtitle: context.l10n.grpIDoneOrCancelledDepth,
        ),
      ],
    ),
    actions: [
      TfButton(
        label: context.l10n.grpICancel,
        variant: TfButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      TfButton(
        key: const Key('save-conditions'),
        label: context.l10n.grpIDone,
        variant: TfButtonVariant.primary,
        onPressed: () => Navigator.pop(
          context,
          TransitionConditions(
            requiredRoleId: _role,
            requireAssignee: _assignee,
            requireSubtasksDone: _subtasks,
          ),
        ),
      ),
    ],
  );
}
