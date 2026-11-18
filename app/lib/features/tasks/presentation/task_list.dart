import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_list_motion.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_section.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/list_drop.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/bulk_bar.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/row_drop_target.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_table.dart';
import 'package:taskforge/features/tasks/presentation/work/add_task.dart';
import 'package:taskforge/features/tasks/presentation/work/layouts_menu.dart';
import 'package:taskforge/features/tasks/presentation/work/list_controls.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';
import 'package:taskforge/features/tasks/presentation/work/view_toolbar.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/tasks/presentation/task_tile.dart';
import 'package:taskforge/features/tasks/presentation/quick_add.dart';
import 'package:taskforge/features/tasks/presentation/table_group_header.dart';
import 'package:taskforge/features/tasks/presentation/work/work_states.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';

part 'task_list_phone.dart';
part 'task_list_drag.dart';
part 'task_list_ops.dart';

/// The List view: toolbar, quick add, the table (wide) or cards (phone) and the
/// bulk bar, with the loading, empty and error states.
class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({
    super.key,
    required this.project,
    required this.wide,
    required this.selected,
    required this.onOpen,
  });

  final Project project;
  final bool wide;
  final String? selected;
  final void Function(Task) onOpen;

  @override
  ConsumerState<TaskListView> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<TaskListView>
    with _TaskListOps, _TaskListDrag, _TaskListPhone {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListProvider(project.id));
    final flow = ref.watch(workflowProvider(project.id)).value;
    final permissions = ref.watch(permissionSetProvider);
    final canCreate = !project.isArchived && permissions.can(Perm.taskCreate);
    final lookups = _lookups(flow);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewToolbar(
          key: const Key('list-toolbar'),
          projectId: project.id,
          canShare: !project.isArchived && permissions.can(Perm.projectUpdate),
          group: ListGroupMenu(projectId: project.id, lookups: lookups),
          sort: ListSortMenu(projectId: project.id, lookups: lookups),
          fields: ListFieldsMenu(projectId: project.id, lookups: lookups),
          specific: [
            LayoutsMenu(
              projectId: project.id,
              canShare:
                  !project.isArchived && permissions.can(Perm.projectUpdate),
            ),
            ToolbarIcon(
              key: const Key('refresh-tasks'),
              icon: TfIcons.refresh,
              tooltip: context.l10n.grpDRefresh,
              onPressed: () =>
                  ref.read(taskListProvider(project.id).notifier).refresh(),
            ),
            if (ref.watch(listLayoutProvider(project.id)).saveFailed)
              SaveFailedMark(
                message: context.l10n.grpDLayoutNotSaved,
                markKey: const Key('layout-not-saved'),
              ),
          ],
          onAddTask: canCreate ? () => runNewTask(context, ref) : null,
        ),
        if (canCreate) QuickAdd(projectId: project.id),
        Expanded(child: _body(context, state, lookups, permissions)),
        BulkBar(
          projectId: project.id,
          lookups: lookups,
          canUpdate: !project.isArchived && permissions.can(Perm.taskUpdate),
          canDelete: !project.isArchived && permissions.can(Perm.taskDelete),
        ),
      ],
    );
  }

  ListLookups _lookups(Workflow? flow) => ListLookups(
    flow: flow,
    members: ref.watch(membersProvider).value ?? const <Member>[],
    fields:
        ref.watch(fieldsProvider(project.id)).value ?? const <CustomField>[],
  );

  Widget _body(
    BuildContext context,
    TaskListState state,
    ListLookups lookups,
    Permissions permissions,
  ) {
    if (state.error != null && state.tasks.isEmpty) {
      return WorkError(
        error: state.error!,
        retryKey: const Key('retry-tasks'),
        onRetry: () => ref.read(taskListProvider(project.id).notifier).load(),
      );
    }
    if (state.loading && state.tasks.isEmpty) {
      _resetMotion();
      return WorkSkeleton(cards: !widget.wide);
    }
    final canCreate = !project.isArchived && permissions.can(Perm.taskCreate);
    final empty = WorkEmpty(
      projectId: project.id,
      onAddTask: canCreate ? () => runNewTask(context, ref) : null,
    );
    if (state.tasks.isEmpty) {
      _resetMotion();
      return empty;
    }
    final layout = ref.watch(listLayoutProvider(project.id)).layout;
    final tree = ref.watch(taskTreeProvider(project.id));
    final entries = listEntries(
      searched(state.tasks, ref.watch(viewSearchProvider(project.id))),
      layout.query,
      collapsedTasks: ref.watch(collapsedTasksProvider(project.id)),
      collapsedGroups: ref.watch(collapsedGroupsProvider(project.id)),
      loading: state.loading,
      serverCounts:
          ref.watch(groupCountsProvider(project.id)).value ?? const {},
    );
    if (entries.isEmpty && !state.loading) {
      _resetMotion();
      return empty;
    }
    final editable = !project.isArchived;
    final canUpdate = editable && permissions.can(Perm.taskUpdate);
    final canDelete = editable && permissions.can(Perm.taskDelete);
    List<TaskAction> actionsFor(Task task) => [
      if (canCreate && task.depth + 1 < softDepthLimit) TaskAction.addSubtask,
      if (canUpdate) TaskAction.moveUnder,
      if (canUpdate && task.parentId.isNotEmpty) TaskAction.makeTopLevel,
      if (canDelete) TaskAction.delete,
    ];
    if (widget.wide) {
      final table = TaskTable(
        projectId: project.id,
        entries: entries,
        layout: layout,
        lookups: lookups,
        loading: state.loading,
        canUpdate: canUpdate,
        openTaskId: widget.selected,
        onOpen: widget.onOpen,
        actionsFor: actionsFor,
        onAction: (action, task) => _act(action, tree, task),
        progressOf: tree.progressOf,
        wrapRow: canUpdate
            ? (task, row) => _dropTarget(
                tree,
                task,
                layout.query,
                _canDrag(task, layout.query) ? _draggable(task, row) : row,
              )
            : null,
        wrapGroup: canUpdate && layout.groupBy.isNotEmpty
            ? (group, header) => _groupDrop(tree, layout, group, header)
            : null,
      );
      return Column(
        children: [
          if (_draggingSub != null) _topLevelDrop(_draggingSub!),
          Expanded(child: table),
        ],
      );
    }
    final cards = _cards(
      context,
      state,
      entries,
      tree,
      lookups,
      layout,
      actionsFor,
      (canUpdate: canUpdate, canDelete: canDelete),
      canDrag: canUpdate,
    );
    return Column(
      children: [
        if (_draggingSub != null) _topLevelDrop(_draggingSub!),
        Expanded(child: cards),
      ],
    );
  }
}
