import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

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
    return AlertDialog(
      title: Text(context.l10n.grpIDeleteStatusTitle(widget.status.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message ?? context.l10n.grpITasksInStatus(count),
            key: const Key('migration-explain'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('migrate-target'),
            initialValue: _target,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.grpIMoveTasksTo,
            ),
            items: [
              for (final s in widget.others)
                DropdownMenuItem(
                  value: s.key,
                  child: Text(
                    s.name.isEmpty ? context.l10n.grpIUnnamed : s.name,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _target = v ?? _target),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('cancel-delete-status'),
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpICancel),
        ),
        FilledButton(
          key: const Key('confirm-delete-status'),
          onPressed: () => Navigator.pop(context, _target),
          child: Text(context.l10n.grpIMoveTasksAndDelete),
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
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          key: const Key('condition-role'),
          initialValue: _role,
          isExpanded: true,
          decoration: InputDecoration(labelText: context.l10n.grpIWhoMayMove),
          items: [
            DropdownMenuItem(value: '', child: Text(context.l10n.grpIAnyRole)),
            for (final r in widget.roles)
              DropdownMenuItem(
                value: r.id,
                child: Text(context.l10n.grpIOnlyRole(r.name)),
              ),
          ],
          onChanged: (v) => setState(() => _role = v ?? ''),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          key: const Key('condition-assignee'),
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.grpITaskNeedsAssignee),
          value: _assignee,
          onChanged: (v) => setState(() => _assignee = v),
        ),
        SwitchListTile(
          key: const Key('condition-subtasks'),
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.grpIAllSubtasksDone),
          subtitle: Text(context.l10n.grpIDoneOrCancelledDepth),
          value: _subtasks,
          onChanged: (v) => setState(() => _subtasks = v),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpICancel),
      ),
      FilledButton(
        key: const Key('save-conditions'),
        onPressed: () => Navigator.pop(
          context,
          TransitionConditions(
            requiredRoleId: _role,
            requireAssignee: _assignee,
            requireSubtasksDone: _subtasks,
          ),
        ),
        child: Text(context.l10n.grpIDone),
      ),
    ],
  );
}
