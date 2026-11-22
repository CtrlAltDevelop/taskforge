import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';

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
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-to-settings'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpIBack,
          onPressed: () => context.go('/projects/$projectId/settings'),
        ),
        title: Text(context.l10n.grpIWorkflow),
        actions: [
          if (canEdit) ...[
            TfButton(
              key: const Key('workflow-discard'),
              label: context.l10n.grpIDiscard,
              variant: TfButtonVariant.ghost,
              size: TfButtonSize.small,
              onPressed: editor.dirty && !editor.saving
                  ? notifier.discard
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TfSpace.xs),
              child: TfButton(
                key: const Key('workflow-save'),
                label: editor.saving
                    ? context.l10n.grpISaving
                    : context.l10n.grpISave,
                variant: TfButtonVariant.primary,
                size: TfButtonSize.small,
                onPressed: editor.canSave
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final saved = context.l10n.grpIWorkflowSaved;
                        if (await notifier.save()) {
                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text(saved)));
                        }
                      }
                    : null,
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
      return TfError(
        message: workflowErrorMessage(editor.loadError!, context.l10n),
        details: '${editor.loadError}',
        retryKey: const Key('retry-workflow'),
        onRetry: notifier.load,
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
          const SizedBox(height: TfSpace.md),
        ],
        ValidationPanel(problems: problems),
        if (editor.saveError != null &&
            editor.saveError!.failure != WorkflowFailure.invalid)
          Padding(
            padding: const EdgeInsets.only(top: TfSpace.sm),
            child: Text(
              workflowErrorMessage(editor.saveError!, context.l10n),
              key: const Key('save-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: TfSpace.md),
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
                  padding: const EdgeInsets.all(TfSpace.lg),
                  children: [side],
                ),
              ),
            ],
          );
        }
        return TfPage(
          children: [
            side,
            const SizedBox(height: TfSpace.md),
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
  TfPanel(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        TfToggleTile(
          key: const Key('restrict-switch'),
          value: editor.draft!.restrict,
          onChanged: canEdit
              ? (v) => notifier.edit((d) => d.setRestrict(v))
              : null,
          title: context.l10n.grpIRestrictTransitions,
          subtitle: context.l10n.grpIRestrictTransitionsHint,
        ),
        TfToggleTile(
          key: const Key('restrict-creation-switch'),
          value: editor.draft!.restrictCreation,
          onChanged: canEdit
              ? (v) => notifier.edit((d) => d.setRestrictCreation(v))
              : null,
          title: context.l10n.grpIRestrictCreation,
          subtitle: context.l10n.grpIRestrictCreationHint,
        ),
      ],
    ),
  ),
  const SizedBox(height: TfSpace.lg),
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
      padding: const EdgeInsets.symmetric(vertical: TfSpace.sm),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TfButton(
          key: const Key('add-status'),
          label: context.l10n.grpIAddStatus,
          icon: TfIcons.plus,
          onPressed: () => notifier.edit(
            (d) => d.add(
              notifier.newKey(),
              name: context.l10n.grpINewStatus,
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
        ? context.l10n.grpIMigrationNeedsPlace
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
    title: context.l10n.grpIMoveArrow(from.name, to.name),
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
      padding: const EdgeInsets.all(TfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.grpIDeletedStillHasTasks(gone.name)),
          const SizedBox(height: TfSpace.sm),
          TfSelectField<String>(
            key: Key('migrate-${gone.key}'),
            options: {
              for (final s in others)
                s.key: s.name.isEmpty ? context.l10n.grpIUnnamed : s.name,
            },
            value: null,
            onChanged: canEdit
                ? (v) {
                    onPick(v);
                  }
                : null,
            label: context.l10n.grpIMoveItsTasksTo,
            expand: true,
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
    padding: const EdgeInsets.all(TfSpace.lg),
    children: _listChildren(context, editor, notifier, roles, canEdit),
  );
}
