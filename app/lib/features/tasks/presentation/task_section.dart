import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/board/presentation/board_view.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/presentation/calendar_view.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/filters/presentation/filter_bar.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/core/sync/presentation/connection_status.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_section.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/presentation/timeline_view.dart';
import 'package:taskforge/features/tasks/presentation/bulk_bar.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/list_toolbar.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

export 'package:taskforge/features/tasks/presentation/task_actions.dart'
    show TaskAction;
import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_detail.dart';
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_table.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';

/// Width from which the detail opens as a side panel instead of a page.
const wideBreakpoint = 900.0;

/// A project's tasks: quick-add bar, the list, and the detail of the selected one.
class TaskSection extends ConsumerStatefulWidget {
  const TaskSection({
    super.key,
    required this.project,
    this.initialTask,
    this.initialView,
  });

  final Project project;

  /// Open this task's detail beside the list (wide screens) from the start.
  final String? initialTask;

  /// The view to start in (`list`, `board`, `calendar`, `timeline`); the list
  /// when it is null or unknown.
  final String? initialView;

  @override
  ConsumerState<TaskSection> createState() => _TaskSectionState();
}

/// The two ways to look at a project's tasks.
enum _TaskView { list, board, calendar, timeline }

class _TaskSectionState extends ConsumerState<TaskSection> {
  late String? _selected = widget.initialTask;
  late var _view =
      _TaskView.values.where((v) => v.name == widget.initialView).firstOrNull ??
      _TaskView.list;

  var _wide = false;

  _TaskView? _viewNamed(String? name) =>
      _TaskView.values.where((v) => v.name == name).firstOrNull;

  /// The route says which view and task are on screen (the palette's actions
  /// read it there): keep it in step with what was picked. Skipped on a
  /// narrow screen, where a task opens as a page of its own.
  void _syncUrl() {
    if (!_wide) return;
    final query = {
      'task': ?_selected,
      if (_view != _TaskView.list) 'view': _view.name,
    };
    GoRouter.maybeOf(context)?.replace(
      Uri(
        path: '/projects/${widget.project.id}',
        queryParameters: query.isEmpty ? null : query,
      ).toString(),
    );
  }

  @override
  void didUpdateWidget(TaskSection old) {
    super.didUpdateWidget(old);
    // The route changed under us (an action, a search hit, a link).
    if (widget.initialView != old.initialView) {
      final view = _viewNamed(widget.initialView) ?? _TaskView.list;
      if (view != _view) setState(() => _view = view);
    }
    if (widget.initialTask != old.initialTask &&
        widget.initialTask != _selected) {
      if (_wide) {
        setState(() => _selected = widget.initialTask);
      } else {
        _pending = widget.initialTask;
      }
    }
  }

  /// A card shows what the detail may have just changed: read the board again
  /// when the detail closes or another task opens.
  void _refreshView() {
    switch (_view) {
      case _TaskView.board:
        ref.read(boardProvider(widget.project.id).notifier).refresh();
      case _TaskView.calendar:
        ref.read(calendarProvider(widget.project.id).notifier).refresh();
      case _TaskView.timeline:
        ref.read(timelineProvider(widget.project.id).notifier).refresh();
      case _TaskView.list:
        break;
    }
  }

  /// On a narrow screen the task to open as a page once the list has it.
  late String? _pending = widget.initialTask;

  Future<void> _open(Task task, bool wide) async {
    if (wide) {
      setState(() => _selected = task.id);
      _syncUrl();
      _refreshView();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(isolateLtr(task.displayId))),
          body: TaskDetail(
            project: widget.project,
            taskId: task.id,
            onOpen: (t) => _open(t, false),
          ),
        ),
      ),
    );
  }

  /// Opens [TaskSection.initialTask] as a page on a narrow screen as soon as the
  /// list holds it (or gives up once the list has finished loading without it).
  void _openPending(bool wide) {
    final pending = _pending;
    if (pending == null || wide) return;
    final state = ref.watch(taskListProvider(widget.project.id));
    final found = state.tasks.where((t) => t.id == pending).firstOrNull;
    if (found == null && state.loading) return;
    _pending = null;
    if (found == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _open(found, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(
      liveProjectProvider(widget.project.id),
    ); // this project's changes arrive live
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= wideBreakpoint;
        _wide = wide;
        _openPending(wide);
        Future<void> openFromView(Task t) async {
          await _open(t, wide);
          if (!wide) _refreshView();
        }

        final body = _view == _TaskView.board
            ? BoardView(
                project: widget.project,
                openTaskId: wide ? _selected : null,
                onOpen: openFromView,
              )
            : _view == _TaskView.timeline
            ? TimelineView(
                project: widget.project,
                openTaskId: wide ? _selected : null,
                onOpen: openFromView,
              )
            : _view == _TaskView.calendar
            ? CalendarView(
                scope: widget.project.id,
                archived: widget.project.isArchived,
                openTaskId: wide ? _selected : null,
                onOpen: openFromView,
              )
            : _TaskList(
                project: widget.project,
                wide: wide,
                selected: wide ? _selected : null,
                onOpen: (t) => _open(t, wide),
              );
        final switcher = Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<_TaskView>(
                key: const Key('view-switch'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _TaskView.list,
                    icon: const Icon(Icons.table_rows_outlined),
                    label: Text(context.l10n.grpFViewList),
                  ),
                  ButtonSegment(
                    value: _TaskView.board,
                    icon: const Icon(Icons.view_kanban_outlined),
                    label: Text(context.l10n.grpFViewBoard),
                  ),
                  ButtonSegment(
                    value: _TaskView.calendar,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(context.l10n.calendar),
                  ),
                  ButtonSegment(
                    value: _TaskView.timeline,
                    icon: const Icon(Icons.stacked_bar_chart),
                    label: Text(context.l10n.grpFViewTimeline),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (v) {
                  setState(() => _view = v.first);
                  _syncUrl();
                },
              ),
              const LiveIndicator(),
              FilterBar(
                projectId: widget.project.id,
                canShare:
                    !widget.project.isArchived &&
                    ref.watch(permissionSetProvider).can(Perm.projectUpdate),
              ),
            ],
          ),
        );
        // Always a Row on a wide screen, so opening or closing the detail keeps
        // the view (its scroll position, focus and picked rows) where it is.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ConnectionBanner(),
            const OfflineBanner(),
            switcher,
            Expanded(
              child: !wide
                  ? body
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: body),
                        if (_selected != null) ...[
                          const VerticalDivider(width: 1),
                          SizedBox(
                            width: 420,
                            child: TaskDetail(
                              key: ValueKey(_selected),
                              project: widget.project,
                              taskId: _selected!,
                              onClose: () {
                                setState(() => _selected = null);
                                _syncUrl();
                                _refreshView();
                              },
                              onOpen: (t) => _open(t, true),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskList extends ConsumerStatefulWidget {
  const _TaskList({
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
  ConsumerState<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<_TaskList> {
  /// The task whose inline "add subtask" field is open.
  String? _addingUnder;

  Project get project => widget.project;

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
        ListToolbar(
          projectId: project.id,
          lookups: lookups,
          canShare: !project.isArchived && permissions.can(Perm.projectUpdate),
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
      return Center(
        child: TextButton(
          key: const Key('retry-tasks'),
          onPressed: () =>
              ref.read(taskListProvider(project.id).notifier).load(),
          child: Text(
            context.l10n.grpFErrorRetry(
              taskErrorMessage(state.error!, context.l10n),
            ),
          ),
        ),
      );
    }
    if (state.loading && state.tasks.isEmpty) return const _Skeleton();
    if (state.tasks.isEmpty) {
      return Center(
        child: Text(context.l10n.grpFNoTasksYet, key: const Key('no-tasks')),
      );
    }
    final layout = ref.watch(listLayoutProvider(project.id)).layout;
    final tree = ref.watch(taskTreeProvider(project.id));
    final entries = listEntries(
      state.tasks,
      layout.query,
      collapsedTasks: ref.watch(collapsedTasksProvider(project.id)),
      collapsedGroups: ref.watch(collapsedGroupsProvider(project.id)),
      loading: state.loading,
      serverCounts:
          ref.watch(groupCountsProvider(project.id)).value ?? const {},
    );
    final editable = !project.isArchived;
    final canUpdate = editable && permissions.can(Perm.taskUpdate);
    final canCreate = editable && permissions.can(Perm.taskCreate);
    final canDelete = editable && permissions.can(Perm.taskDelete);
    List<TaskAction> actionsFor(Task task) => [
      if (canCreate && task.depth + 1 < softDepthLimit) TaskAction.addSubtask,
      if (canUpdate) TaskAction.moveUnder,
      if (canUpdate && task.parentId.isNotEmpty) TaskAction.makeTopLevel,
      if (canDelete) TaskAction.delete,
    ];
    if (widget.wide) {
      return TaskTable(
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
        wrapRow: canUpdate && layout.query.isDefault
            ? (task, row) => _dropTarget(tree, task, _draggable(task, row))
            : null,
      );
    }
    return _cards(context, state, entries, tree, lookups, layout, actionsFor, (
      canUpdate: canUpdate,
      canDelete: canDelete,
    ));
  }

  /// The phone list: one card per task, long-press to start picking, swipe to
  /// complete or delete, pull to refresh.
  Widget _cards(
    BuildContext context,
    TaskListState state,
    List<ListEntry> entries,
    TaskTree tree,
    ListLookups lookups,
    ListLayout layout,
    List<TaskAction> Function(Task) actionsFor,
    ({bool canUpdate, bool canDelete}) can,
  ) {
    final picked = ref.watch(taskSelectionProvider(project.id));
    final selection = ref.read(taskSelectionProvider(project.id).notifier);
    final doneStatus = lookups.flow?.statuses
        .where((s) => s.category == StatusCategory.done)
        .firstOrNull;
    String summarize(Task t) => fieldSummary(
      t,
      lookups.fields,
      userLabel: lookups.person,
      l10n: context.l10n,
    );
    // Rows are built lazily (a list of thousands only builds what is on screen);
    // the inline add field counts as one more entry under its parent.
    final items = <Object>[
      for (final entry in entries) ...[
        entry,
        if (entry is TaskEntry && _addingUnder == entry.task.id) entry.task.id,
      ],
    ];
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(taskListProvider(project.id).notifier).refresh(),
      child: ListView.builder(
        key: const Key('task-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + (state.loading ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == items.length) {
            return const LinearProgressIndicator(key: Key('tasks-streaming'));
          }
          final item = items[i];
          if (item is String) return _inlineAdd(tree, item);
          if (item is GroupEntry) return _groupTile(lookups, layout, item);
          final entry = item as TaskEntry;
          final task = entry.task;
          final actions = actionsFor(task);
          final tile = TaskTile(
            task: task,
            statusColor: lookups.flow?.statusById(task.statusId)?.swatch,
            selected: task.id == widget.selected,
            onTap: () => picked.isEmpty
                ? widget.onOpen(task)
                : selection.toggle(task.id),
            onLongPress: () => selection.toggle(task.id),
            picked: picked.isEmpty ? null : picked.contains(task.id),
            onPick: () => selection.toggle(task.id),
            depth: entry.depth,
            hasChildren: entry.hasChildren,
            expanded: entry.expanded,
            progress: tree.progressOf(task.id),
            onToggle: () => ref
                .read(collapsedTasksProvider(project.id).notifier)
                .toggle(task.id),
            actions: actions,
            onAction: (action) => _act(action, tree, task),
            fieldSummary: summarize(task),
          );
          return _swipeable(task, tile, doneStatus, tree, can);
        },
      ),
    );
  }

  Widget _groupTile(ListLookups lookups, ListLayout layout, GroupEntry group) {
    final color = lookups.groupColor(layout.groupBy, group.key);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        key: Key('group-${group.key}'),
        onTap: () => ref
            .read(collapsedGroupsProvider(project.id).notifier)
            .toggle(group.key),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              DirectionalIcon(
                group.collapsed ? Icons.chevron_right : Icons.expand_more,
              ),
              if (color != null) ...[
                Icon(Icons.circle, size: 10, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                lookups.groupLabel(layout.groupBy, group.key, context.l10n),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Text(
                '${group.count}',
                key: Key('group-count-${group.key}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Swipe right completes a task, swipe left deletes it (when allowed). The
  /// row is never dismissed by the swipe itself: the list changes as the
  /// server answers.
  Widget _swipeable(
    Task task,
    Widget tile,
    WorkflowStatus? doneStatus,
    TaskTree tree,
    ({bool canUpdate, bool canDelete}) can,
  ) {
    final complete =
        can.canUpdate &&
        doneStatus != null &&
        task.statusCategory != StatusCategory.done;
    if (!complete && !can.canDelete) return tile;
    return Dismissible(
      key: ValueKey('swipe-${task.id}'),
      direction: complete && can.canDelete
          ? DismissDirection.horizontal
          : complete
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      background: _SwipeBackground(
        icon: Icons.check,
        label: context.l10n.grpFSwipeComplete,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: _SwipeBackground(
        icon: Icons.delete_outline,
        label: context.l10n.grpFDelete,
        alignment: AlignmentDirectional.centerEnd,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await saveTask(context, ref, task, TaskPatch(status: doneStatus));
        } else {
          await _delete(tree, task);
        }
        return false;
      },
      child: tile,
    );
  }

  Widget _inlineAdd(TaskTree tree, String parentId) {
    final parent = tree.task(parentId);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        56.0 + ((parent?.depth ?? 0) + 1) * 20,
        0,
        12,
        8,
      ),
      child: AddSubtaskField(
        projectId: project.id,
        parentId: parentId,
        autofocus: true,
        onDone: () => setState(() => _addingUnder = null),
      ),
    );
  }

  /// Wide screens: press and hold a row, then drag it onto another to nest it
  /// there. (Holding first keeps an ordinary drag free to scroll the list.)
  Widget _draggable(Task task, Widget tile) => LongPressDraggable<String>(
    key: Key('drag-${task.id}'),
    data: task.id,
    feedback: Material(
      elevation: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: ListTile(
          title: Text(task.title, overflow: TextOverflow.ellipsis),
          subtitle: Text(isolateLtr(task.displayId)),
        ),
      ),
    ),
    childWhenDragging: Opacity(opacity: 0.4, child: tile),
    child: tile,
  );

  Widget _dropTarget(TaskTree tree, Task target, Widget child) =>
      DragTarget<String>(
        key: Key('drop-${target.id}'),
        onWillAcceptWithDetails: (d) {
          final dragged = tree.task(d.data);
          return dragged != null &&
              dragged.parentId != target.id &&
              !tree.wouldCycle(dragged.id, target.id) &&
              target.depth + 1 + tree.levelsBelow(dragged.id) < softDepthLimit;
        },
        onAcceptWithDetails: (d) {
          final dragged = tree.task(d.data);
          if (dragged != null) _reparent(dragged, target.id);
        },
        builder: (context, candidates, _) => DecoratedBox(
          decoration: BoxDecoration(
            border: candidates.isEmpty
                ? null
                : Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: child,
        ),
      );

  Future<void> _act(TaskAction action, TaskTree tree, Task task) async {
    switch (action) {
      case TaskAction.addSubtask:
        ref.read(collapsedTasksProvider(project.id).notifier).expand(task.id);
        if (widget.wide) {
          // Table rows have a fixed height: the field opens in a dialog.
          await showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: Text(dialog.l10n.grpFAddSubtaskTo(task.displayId)),
              content: SizedBox(
                width: 360,
                child: AddSubtaskField(
                  projectId: project.id,
                  parentId: task.id,
                  autofocus: true,
                  onDone: () => Navigator.pop(dialog),
                ),
              ),
            ),
          );
        } else {
          setState(() => _addingUnder = task.id);
        }
      case TaskAction.moveUnder:
        final parent = await pickParent(context, tree, task);
        if (parent != null) await _reparent(task, parent);
      case TaskAction.makeTopLevel:
        await _reparent(task, '');
      case TaskAction.delete:
        await _delete(tree, task);
    }
  }

  Future<void> _reparent(Task task, String parentId) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(taskListProvider(project.id).notifier)
          .setParent(task, parentId);
      if (parentId.isNotEmpty) {
        ref.read(collapsedTasksProvider(project.id).notifier).expand(parentId);
      }
    } on TaskException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
    }
  }

  Future<void> _delete(TaskTree tree, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final list = ref.read(taskListProvider(project.id).notifier);
    final below = tree.subtreeIds(task.id).length - 1;
    DeleteMode? mode;
    if (below > 0) {
      mode = await askDeleteMode(context, task, below);
      if (mode == null || !mounted) return;
    }
    // Last, so cancelling an earlier question never stops a series.
    if (!await confirmDeleteTemplate(context, ref, task) || !mounted) return;
    try {
      final moved = await list.delete(task, mode: mode);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.grpFTaskDeleted(task.displayId)),
            action: SnackBarAction(
              label: l10n.grpFUndo,
              onPressed: () async {
                try {
                  await list.restore(task, adopt: moved);
                } on TaskException catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(taskErrorMessage(e, l10n))),
                  );
                }
              },
            ),
          ),
        );
    } on TaskException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
    }
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    this.selected = false,
    this.statusColor,
    this.depth = 0,
    this.hasChildren = false,
    this.expanded = true,
    this.progress = Progress.none,
    this.onToggle,
    this.actions = const [],
    this.onAction,
    this.fieldSummary = '',
    this.onLongPress,
    this.picked,
    this.onPick,
  });

  final Task task;

  /// The task's custom field values for the List view (see [fieldSummary]).
  final String fieldSummary;

  /// The colour of the task's status (grey until the workflow has loaded).
  final Color? statusColor;
  final VoidCallback onTap;
  final bool selected;

  /// How far the row is indented, whether it has a chevron, and the ring of
  /// how much of its subtasks is done.
  final int depth;
  final bool hasChildren;
  final bool expanded;
  final Progress progress;
  final VoidCallback? onToggle;

  /// The row menu: shown when there is something in it.
  final List<TaskAction> actions;
  final void Function(TaskAction)? onAction;

  /// Long press starts picking tasks for a bulk edit; once any is picked
  /// [picked] is non-null (whether this one is) and a checkbox shows.
  final VoidCallback? onLongPress;
  final bool? picked;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('task-${task.id}'),
    selected: selected || picked == true,
    onTap: onTap,
    onLongPress: onLongPress,
    contentPadding: EdgeInsetsDirectional.only(start: 8.0 + depth * 20, end: 8),
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (picked != null)
          Checkbox(
            key: Key('check-${task.id}'),
            value: picked,
            onChanged: (_) => onPick?.call(),
          ),
        SizedBox(
          width: 32,
          child: hasChildren
              ? IconButton(
                  key: Key('toggle-${task.id}'),
                  padding: EdgeInsets.zero,
                  tooltip: expanded
                      ? context.l10n.grpBCollapse
                      : context.l10n.grpBExpand,
                  icon: DirectionalIcon(
                    expanded ? Icons.expand_more : Icons.chevron_right,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
        if (task.isBlocked) ...[
          BlockedBadge(blockedBy: task.blockedBy),
          const SizedBox(width: 4),
        ],
        Icon(
          priorityIcon(task.priority),
          color: priorityColor(task.priority),
          semanticLabel: task.priority.labelIn(context.l10n),
        ),
      ],
    ),
    title: Text(
      task.title,
      style: task.statusCategory == StatusCategory.done
          ? const TextStyle(decoration: TextDecoration.lineThrough)
          : null,
    ),
    subtitle: Row(
      children: [
        PendingMark(id: task.id),
        Icon(
          Icons.circle,
          size: 10,
          color: statusColor ?? Colors.grey,
          semanticLabel: task.statusName,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            [
              task.displayId,
              task.statusName,
              if (task.dueDate.isNotEmpty) 'due ${task.dueDate}',
              if (fieldSummary.isNotEmpty) fieldSummary,
            ].join(' \u00b7 '),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!progress.isEmpty)
          KeyedSubtree(
            key: Key('progress-${task.id}'),
            child: ProgressRing(progress: progress),
          ),
        if (task.assigneeIds.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Chip(label: Text('${task.assigneeIds.length}')),
          ),
        if (actions.isNotEmpty)
          PopupMenuButton<TaskAction>(
            key: Key('task-menu-${task.id}'),
            tooltip: context.l10n.grpFMore,
            onSelected: onAction,
            itemBuilder: (_) => [
              for (final a in actions)
                PopupMenuItem(
                  key: Key('${a.name}-${task.id}'),
                  value: a,
                  child: Text(a.labelIn(context.l10n)),
                ),
            ],
          ),
      ],
    ),
  );
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.secondaryContainer,
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon), const SizedBox(width: 8), Text(label)],
    ),
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      key: const Key('tasks-skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 6; i++)
          ListTile(
            leading: CircleAvatar(backgroundColor: color, radius: 10),
            title: Container(height: 12, color: color),
            subtitle: Container(height: 8, width: 120, color: color),
          ),
      ],
    );
  }
}

/// One field, Enter adds a task: no dialog, no required fields beyond the title.
class QuickAdd extends ConsumerStatefulWidget {
  const QuickAdd({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<QuickAdd> createState() => _QuickAddState();
}

class _QuickAddState extends ConsumerState<QuickAdd> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    final title = value.trim();
    if (title.isEmpty || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final values = await _requiredValues(title);
      if (values == null) return; // cancelled
      await ref
          .read(taskListProvider(widget.projectId).notifier)
          .create(title, fieldValues: values);
      _controller.clear();
    } on TaskException catch (e) {
      if (e.failure == TaskFailure.fieldRequired) {
        // The field list we hold is stale: read it again and ask next time.
        ref.invalidate(fieldsProvider(widget.projectId));
      }
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Values for the required fields that nothing fills in (none when there are
  /// no such fields); null when the user cancelled the dialog.
  Future<Map<String, String>?> _requiredValues(String title) async {
    final List<CustomField> fields;
    try {
      fields = await ref.read(fieldsProvider(widget.projectId).future);
    } on FieldException {
      return const {}; // cannot tell: the server decides (FIELD_REQUIRED)
    }
    if (!mounted) return null;
    final needed = [
      for (final f in fields)
        if (f.needsValueOnCreate) f,
    ];
    if (needed.isEmpty) return const {};
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => RequiredFieldsDialog(
        title: title,
        fields: needed,
        members: ref.read(membersProvider).value ?? const <Member>[],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kept loaded, so submitting does not wait for the field list.
    ref.watch(fieldsProvider(widget.projectId));
    return _field();
  }

  Widget _field() => Padding(
    padding: const EdgeInsets.all(12),
    child: TextField(
      key: const Key('quick-add'),
      controller: _controller,
      enabled: !_busy,
      maxLength: maxTitleLength,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: withShortcut(ref, 'Add a task and press Enter', 'task.new'),
        prefixIcon: const Icon(Icons.add),
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      onSubmitted: _submit,
    ),
  );
}
