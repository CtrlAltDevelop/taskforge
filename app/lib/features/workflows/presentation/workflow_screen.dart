import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/projects/application/project_access.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workflows/application/workflow_editor.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/features/workflows/presentation/merge_banner.dart';
import 'package:taskforge/features/workflows/presentation/status_card.dart';
import 'package:taskforge/features/workflows/presentation/status_dialogs.dart';
import 'package:taskforge/features/workflows/presentation/validation_panel.dart';
import 'package:taskforge/features/workflows/presentation/workflow_graph.dart';

/// Width from which the problems and the graph sit beside the status list.
const wideWorkflowBreakpoint = 900.0;

/// Project settings → Workflow: the statuses of a project, which statuses may
/// move to which, and what is wrong with the draft. Nothing is saved until Save.
class WorkflowScreen extends ConsumerWidget {
  const WorkflowScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.watch(workflowEditorProvider(projectId));
    final project = ref.watch(projectProvider(projectId));
    final permissions = ref.watch(permissionSetProvider);
    final canEdit =
        project != null &&
        !project.isArchived &&
        canManageProject(permissions, Perm.projectUpdate);
    final notifier = ref.read(workflowEditorProvider(projectId).notifier);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-to-settings'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects/$projectId/settings'),
        ),
        title: const Text('Workflow'),
        actions: [
          if (canEdit) ...[
            TextButton(
              key: const Key('workflow-discard'),
              onPressed: editor.dirty && !editor.saving
                  ? notifier.discard
                  : null,
              child: const Text('Discard'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton(
                key: const Key('workflow-save'),
                onPressed: editor.canSave
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (await notifier.save()) {
                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(content: Text('Workflow saved')),
                            );
                        }
                      }
                    : null,
                child: Text(editor.saving ? 'Saving…' : 'Save'),
              ),
            ),
          ],
        ],
      ),
      body: _body(context, ref, editor, notifier, canEdit),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    WorkflowEditorState editor,
    WorkflowEditor notifier,
    bool canEdit,
  ) {
    final draft = editor.draft;
    if (editor.loadError != null) {
      return Center(
        child: TextButton(
          key: const Key('retry-workflow'),
          onPressed: notifier.load,
          child: Text('${workflowErrorMessage(editor.loadError!)} Retry'),
        ),
      );
    }
    if (editor.loading || draft == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final roles = ref.watch(rolesProvider).value?.roles ?? const <Role>[];
    final problems = editor.problems;
    final list = _StatusList(
      editor: editor,
      notifier: notifier,
      roles: roles,
      canEdit: canEdit,
    );
    final side = Column(
      children: [
        if (editor.needsReview) ...[
          MergeBanner(
            notes: editor.mergeNotes,
            onKeep: notifier.acknowledgeMerge,
            onReload: notifier.load,
          ),
          const SizedBox(height: 12),
        ],
        ValidationPanel(problems: problems),
        if (editor.saveError != null &&
            editor.saveError!.failure != WorkflowFailure.invalid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              workflowErrorMessage(editor.saveError!),
              key: const Key('save-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        WorkflowGraph(draft: draft),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= wideWorkflowBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: list),
              SizedBox(
                width: 380,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [side],
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            side,
            const SizedBox(height: 12),
            ..._listChildren(context, editor, notifier, roles, canEdit),
          ],
        );
      },
    );
  }
}

/// Everything of the status list, for the narrow layout where it scrolls with
/// the problems above it.
List<Widget> _listChildren(
  BuildContext context,
  WorkflowEditorState editor,
  WorkflowEditor notifier,
  List<Role> roles,
  bool canEdit,
) => [
  SwitchListTile(
    key: const Key('restrict-switch'),
    contentPadding: EdgeInsets.zero,
    title: const Text('Restrict transitions'),
    subtitle: const Text(
      'Off: any status can move to any other. On: only the arrows you allow.',
    ),
    value: editor.draft!.restrict,
    onChanged: canEdit ? (v) => notifier.edit((d) => d.setRestrict(v)) : null,
  ),
  SwitchListTile(
    key: const Key('restrict-creation-switch'),
    contentPadding: EdgeInsets.zero,
    title: const Text('New tasks start in the default status only'),
    subtitle: const Text(
      'Off: a task can be created in any status. On: it starts in the status '
      'marked with the star and reaches the others by being moved.',
    ),
    value: editor.draft!.restrictCreation,
    onChanged: canEdit
        ? (v) => notifier.edit((d) => d.setRestrictCreation(v))
        : null,
  ),
  ReorderableListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    buildDefaultDragHandles: false,
    onReorderItem: (from, to) => notifier.edit((d) => d.moveTo(from, to)),
    children: [
      for (final (i, s) in editor.draft!.statuses.indexed)
        StatusCard(
          key: ValueKey(s.key),
          index: i,
          status: s,
          draft: editor.draft!,
          roles: roles,
          canEdit: canEdit,
          problems: [
            for (final p in editor.problems)
              if (p.statusKey == s.key) p,
          ],
          onRename: (v) => notifier.edit((d) => d.rename(s.key, v)),
          onRecolor: (v) => notifier.edit((d) => d.recolor(s.key, v)),
          onCategory: (v) => notifier.edit((d) => d.recategorize(s.key, v)),
          onDefault: () => notifier.edit((d) => d.makeDefault(s.key)),
          onDelete: () => _delete(context, editor, notifier, s),
          onToggleMove: (to) =>
              notifier.edit((d) => d.toggleTransition(s.key, to.key)),
          onConditions: (to) =>
              _conditions(context, editor, notifier, roles, s, to),
        ),
    ],
  ),
  for (final gone in editor.draft!.needMigration)
    _NeedsTarget(
      gone: gone,
      others: editor.draft!.statuses,
      canEdit: canEdit,
      onPick: (to) => notifier.edit((d) => d.setMigration(gone.key, to)),
    ),
  if (canEdit)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: const Key('add-status'),
          icon: const Icon(Icons.add),
          label: const Text('Add status'),
          onPressed: () => notifier.edit(
            (d) => d.add(
              notifier.newKey(),
              name: 'New status',
              color: statusColors[d.statuses.length % statusColors.length],
            ),
          ),
        ),
      ),
    ),
];

Future<void> _delete(
  BuildContext context,
  WorkflowEditorState editor,
  WorkflowEditor notifier,
  DraftStatus status,
) async {
  final others = [
    for (final s in editor.draft!.statuses)
      if (s.key != status.key) s,
  ];
  final draft = editor.draft!;
  final receivesTasks = draft.isMigrationTarget(status.key);
  if (others.isEmpty ||
      (!receivesTasks && (status.isNew || status.taskCount == 0))) {
    notifier.edit((d) => d.remove(status.key));
    return;
  }
  final target = await askMigrationTarget(
    context,
    status,
    others,
    message: status.taskCount == 0 || status.isNew
        ? 'Tasks you chose to move here need a new place.'
        : null,
  );
  if (target == null) return;
  notifier.edit((d) => d.remove(status.key, moveTasksTo: target));
}

Future<void> _conditions(
  BuildContext context,
  WorkflowEditorState editor,
  WorkflowEditor notifier,
  List<Role> roles,
  DraftStatus from,
  DraftStatus to,
) async {
  final transition = editor.draft!.transitions.firstWhere(
    (t) => t.from == from.key && t.to == to.key,
  );
  final result = await editConditions(
    context,
    transition: transition,
    title: '${from.name} → ${to.name}',
    roles: roles,
  );
  if (result == null) return;
  notifier.edit(
    (d) => d.setConditions(
      from.key,
      to.key,
      requiredRoleId: result.requiredRoleId,
      requireAssignee: result.requireAssignee,
      requireSubtasksDone: result.requireSubtasksDone,
    ),
  );
}

/// A deleted status whose tasks still need a place (shown where its card was).
class _NeedsTarget extends StatelessWidget {
  const _NeedsTarget({
    required this.gone,
    required this.others,
    required this.canEdit,
    required this.onPick,
  });

  final DraftStatus gone;
  final List<DraftStatus> others;
  final bool canEdit;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) => Card(
    key: Key('needs-target-${gone.key}'),
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${gone.name} was deleted but still has tasks.'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: Key('migrate-${gone.key}'),
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Move its tasks to'),
            items: [
              for (final s in others)
                DropdownMenuItem(
                  value: s.key,
                  child: Text(s.name.isEmpty ? '(unnamed)' : s.name),
                ),
            ],
            onChanged: canEdit
                ? (v) {
                    if (v != null) onPick(v);
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

/// The status list on its own (the wide layout scrolls it beside the panel).
class _StatusList extends StatelessWidget {
  const _StatusList({
    required this.editor,
    required this.notifier,
    required this.roles,
    required this.canEdit,
  });

  final WorkflowEditorState editor;
  final WorkflowEditor notifier;
  final List<Role> roles;
  final bool canEdit;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: _listChildren(context, editor, notifier, roles, canEdit),
  );
}
