import 'package:flutter/material.dart';

import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

/// One status in the editor: look, name, category, default, delete, and (when
/// transitions are restricted) which statuses it may move to.
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.index,
    required this.status,
    required this.draft,
    required this.roles,
    required this.canEdit,
    required this.problems,
    required this.onRename,
    required this.onRecolor,
    required this.onCategory,
    required this.onDefault,
    required this.onDelete,
    required this.onToggleMove,
    required this.onConditions,
  });

  final int index;
  final DraftStatus status;
  final WorkflowDraft draft;
  final List<Role> roles;
  final bool canEdit;

  /// The problems that are about this status.
  final List<WorkflowProblem> problems;
  final void Function(String) onRename;
  final void Function(String) onRecolor;
  final void Function(StatusCategory) onCategory;
  final VoidCallback onDefault;
  final VoidCallback onDelete;
  final void Function(DraftStatus target) onToggleMove;
  final void Function(DraftStatus target) onConditions;

  String _summary(WorkflowTransition t) => [
    if (t.requireAssignee) 'needs an assignee',
    if (t.requireSubtasksDone) 'needs all subtasks done',
    if (t.requiredRoleId.isNotEmpty)
      'only ${roles.where((r) => r.id == t.requiredRoleId).firstOrNull?.name ?? 'one role'}',
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final key = status.key;
    final theme = Theme.of(context);
    final others = [
      for (final s in draft.statuses)
        if (s.key != key) s,
    ];
    return Card(
      key: Key('status-$key'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  enabled: canEdit,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle,
                      key: Key('status-handle-$key'),
                      semanticLabel: 'Drag to reorder',
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  key: Key('status-color-$key'),
                  enabled: canEdit,
                  tooltip: 'Colour',
                  onSelected: onRecolor,
                  itemBuilder: (_) => [
                    for (final c in statusColors)
                      PopupMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: parseStatusColor(c)),
                            const SizedBox(width: 12),
                            Text(c),
                          ],
                        ),
                      ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.circle,
                      color: parseStatusColor(status.color),
                    ),
                  ),
                ),
                Expanded(
                  child: _NameField(
                    key: Key('status-name-$key'),
                    value: status.name,
                    enabled: canEdit,
                    onChanged: onRename,
                  ),
                ),
                IconButton(
                  key: Key('status-default-$key'),
                  tooltip: status.isDefault
                      ? 'New tasks start here'
                      : 'Make this the status new tasks start in',
                  icon: Icon(status.isDefault ? Icons.star : Icons.star_border),
                  onPressed: canEdit && !status.isDefault ? onDefault : null,
                ),
                IconButton(
                  key: Key('status-delete-$key'),
                  tooltip: 'Delete status',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: canEdit ? onDelete : null,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: DropdownButton<StatusCategory>(
                key: Key('status-category-$key'),
                value: status.category,
                items: [
                  for (final c in StatusCategory.values)
                    DropdownMenuItem(value: c, child: Text(c.label)),
                ],
                onChanged: canEdit
                    ? (c) {
                        if (c != null) onCategory(c);
                      }
                    : null,
              ),
            ),
            if (status.taskCount > 0 && !status.isNew)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  status.taskCount == 1
                      ? '1 task'
                      : '${status.taskCount} tasks',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            for (final p in problems)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  p.message,
                  key: Key('problem-${p.code}-$key'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (draft.restrict) ...[
              const Divider(),
              Text('Can move to', style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final other in others)
                    _MoveChip(
                      from: status,
                      to: other,
                      draft: draft,
                      canEdit: canEdit,
                      summary: draft.allows(key, other.key)
                          ? _summary(
                              draft.transitions.firstWhere(
                                (t) => t.from == key && t.to == other.key,
                              ),
                            )
                          : '',
                      onToggle: () => onToggleMove(other),
                      onConditions: () => onConditions(other),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.from,
    required this.to,
    required this.draft,
    required this.canEdit,
    required this.summary,
    required this.onToggle,
    required this.onConditions,
  });

  final DraftStatus from;
  final DraftStatus to;
  final WorkflowDraft draft;
  final bool canEdit;
  final String summary;
  final VoidCallback onToggle;
  final VoidCallback onConditions;

  @override
  Widget build(BuildContext context) {
    final allowed = draft.allows(from.key, to.key);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          key: Key('move-${from.key}-${to.key}'),
          label: Text(
            summary.isEmpty
                ? (to.name.isEmpty ? '(unnamed)' : to.name)
                : '${to.name.isEmpty ? '(unnamed)' : to.name} · $summary',
          ),
          selected: allowed,
          onSelected: canEdit ? (_) => onToggle() : null,
        ),
        if (allowed && canEdit)
          IconButton(
            key: Key('conditions-${from.key}-${to.key}'),
            tooltip: 'Conditions for this move',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.tune, size: 18),
            onPressed: onConditions,
          ),
      ],
    );
  }
}

/// A one-line text field that tells its owner about every change, and takes a
/// different value from outside (Discard, a reload) even while it has focus.
class _NameField extends StatefulWidget {
  const _NameField({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final void Function(String) onChanged;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _controller = TextEditingController(text: widget.value);

  /// The last text this field reported, so that its own echo coming back is not
  /// mistaken for a change from outside (Discard, a reload).
  late var _typed = widget.value;

  @override
  void didUpdateWidget(_NameField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text && widget.value != _typed) {
      _controller.text = widget.value;
      _typed = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    enabled: widget.enabled,
    maxLength: maxStatusNameLength,
    decoration: const InputDecoration(
      labelText: 'Name',
      counterText: '',
      isDense: true,
    ),
    onChanged: (text) {
      _typed = text;
      widget.onChanged(text);
    },
  );
}
