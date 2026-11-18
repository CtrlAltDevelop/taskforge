import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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

  String _summary(BuildContext context, WorkflowTransition t) => [
    if (t.requireAssignee) context.l10n.grpINeedsAssignee,
    if (t.requireSubtasksDone) context.l10n.grpINeedsSubtasksDone,
    if (t.requiredRoleId.isNotEmpty)
      context.l10n.grpIOnlyRoleLower(
        roles.where((r) => r.id == t.requiredRoleId).firstOrNull?.name ??
            context.l10n.grpIOneRole,
      ),
  ].join(', ');

  @override
  Widget build(BuildContext context) {
    final key = status.key;
    final theme = Theme.of(context);
    final others = [
      for (final s in draft.statuses)
        if (s.key != key) s,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TfPanel(
        key: Key('status-$key'),
        padding: EdgeInsets.zero,
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
                      child: TfIcon(
                        TfIcons.grip,
                        key: Key('status-handle-$key'),
                        semanticLabel: context.l10n.grpIDragToReorder,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    key: Key('status-color-$key'),
                    enabled: canEdit,
                    tooltip: context.l10n.grpIColour,
                    onSelected: onRecolor,
                    itemBuilder: (_) => [
                      for (final c in statusColors)
                        PopupMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              TfIcon(
                                TfIcons.circle,
                                color: parseStatusColor(c),
                              ),
                              const SizedBox(width: 12),
                              Text(c),
                            ],
                          ),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TfIcon(
                        TfIcons.circle,
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
                  TfIconButton(
                    key: Key('status-default-$key'),
                    icon: TfIcons.star,
                    selected: status.isDefault,
                    tooltip: status.isDefault
                        ? context.l10n.grpINewTasksStartHere
                        : context.l10n.grpIMakeDefaultStatus,
                    onPressed: canEdit && !status.isDefault ? onDefault : null,
                  ),
                  TfIconButton(
                    key: Key('status-delete-$key'),
                    icon: TfIcons.trash,
                    tooltip: context.l10n.grpIDeleteStatus,
                    onPressed: canEdit ? onDelete : null,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: TfSelectField<StatusCategory>(
                  key: Key('status-category-$key'),
                  options: {
                    for (final c in StatusCategory.values)
                      c: c.labelIn(context.l10n),
                  },
                  value: status.category,
                  onChanged: canEdit
                      ? (c) {
                          onCategory(c);
                        }
                      : null,
                ),
              ),
              if (status.taskCount > 0 && !status.isNew)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8, top: 4),
                  child: Text(
                    context.l10n.grpITaskCount(status.taskCount),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              for (final p in problems)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8, top: 4),
                  child: Text(
                    p.message,
                    key: Key('problem-${p.code}-$key'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              if (draft.restrict) ...[
                const Divider(),
                Text(
                  context.l10n.grpICanMoveTo,
                  style: theme.textTheme.labelMedium,
                ),
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
                                context,
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
          label: Text(() {
            final name = to.name.isEmpty ? context.l10n.grpIUnnamed : to.name;
            return summary.isEmpty ? name : '$name · $summary';
          }()),
          selected: allowed,
          onSelected: canEdit ? (_) => onToggle() : null,
        ),
        if (allowed && canEdit)
          TfIconButton(
            key: Key('conditions-${from.key}-${to.key}'),
            icon: TfIcons.tune,
            tooltip: context.l10n.grpIConditionsForMove,
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
    decoration: InputDecoration(
      labelText: context.l10n.grpIName,
      counterText: '',
      isDense: true,
    ),
    onChanged: (text) {
      _typed = text;
      widget.onChanged(text);
    },
  );
}
