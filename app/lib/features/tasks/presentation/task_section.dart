import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/app_theme.dart' show radiusMedium;
import 'package:taskforge/core/ui/breakpoints.dart';
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
import 'package:taskforge/features/tasks/domain/list_drop.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/presentation/timeline_view.dart';
import 'package:taskforge/features/tasks/presentation/bulk_bar.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/list_toolbar.dart';
import 'package:taskforge/features/tasks/presentation/row_drop_target.dart';
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

/// The detail pane beside a wide list: 38% of the width, within these bounds.
const _paneMinWidth = 380.0;
const _paneMaxWidth = 560.0;

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
          appBar: TfAppBar(title: Text(isolateLtr(task.displayId))),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: contentMaxWidth),
              child: TaskDetail(
                project: widget.project,
                taskId: task.id,
                onOpen: (t) => _open(t, false),
              ),
            ),
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
        final compact = ScreenSize.of(context).isCompact;
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
                    tooltip: context.l10n.grpFViewList,
                    label: compact ? null : Text(context.l10n.grpFViewList),
                  ),
                  ButtonSegment(
                    value: _TaskView.board,
                    icon: const Icon(Icons.view_kanban_outlined),
                    tooltip: context.l10n.grpFViewBoard,
                    label: compact ? null : Text(context.l10n.grpFViewBoard),
                  ),
                  ButtonSegment(
                    value: _TaskView.calendar,
                    icon: const Icon(Icons.calendar_month_outlined),
                    tooltip: context.l10n.calendar,
                    label: compact ? null : Text(context.l10n.calendar),
                  ),
                  ButtonSegment(
                    value: _TaskView.timeline,
                    icon: const Icon(Icons.stacked_bar_chart),
                    tooltip: context.l10n.grpFViewTimeline,
                    label: compact ? null : Text(context.l10n.grpFViewTimeline),
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
                            width: (box.maxWidth * 0.38).clamp(
                              _paneMinWidth,
                              _paneMaxWidth,
                            ),
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

  /// The subtask being dragged now (a drop bar to make it a main task shows).
  Task? _draggingSub;

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
    ({bool canUpdate, bool canDelete}) can, {
    required bool canDrag,
  }) {
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
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + (state.loading ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == items.length) {
            return const LinearProgressIndicator(key: Key('tasks-streaming'));
          }
          final item = items[i];
          if (item is String) return _inlineAdd(tree, item);
          if (item is GroupEntry) {
            final header = _groupTile(lookups, layout, item);
            return canDrag && layout.groupBy.isNotEmpty
                ? _groupDrop(tree, layout, item, header)
                : header;
          }
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
            dragHandle: canDrag && _canDrag(task, layout.query)
                ? _dragHandle(task)
                : null,
          );
          final row = _swipeable(task, tile, doneStatus, tree, can);
          return canDrag ? _dropTarget(tree, task, layout.query, row) : row;
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
    dragAnchorStrategy: pointerDragAnchorStrategy,
    feedback: _dragFeedback(task),
    childWhenDragging: Opacity(opacity: 0.4, child: tile),
    onDragStarted: () => _dragStarted(task),
    onDragEnd: (_) => _dragEnded(),
    child: tile,
  );

  /// Phone cards: long press already picks, so a handle starts the drag at once
  /// (mouse or finger; it wins over the list's scroll and the card's swipe).
  Widget _dragHandle(Task task) => Draggable<String>(
    key: Key('drag-${task.id}'),
    data: task.id,
    feedback: _dragFeedback(task),
    dragAnchorStrategy: pointerDragAnchorStrategy,
    onDragStarted: () => _dragStarted(task),
    onDragEnd: (_) => _dragEnded(),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Icon(Icons.drag_indicator),
    ),
  );

  Widget _dragFeedback(Task task) => Material(
    elevation: 4,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: ListTile(
        title: Text(task.title, overflow: TextOverflow.ellipsis),
        subtitle: Text(isolateLtr(task.displayId)),
      ),
    ),
  );

  void _dragStarted(Task task) {
    if (task.parentId.isNotEmpty) setState(() => _draggingSub = task);
  }

  void _dragEnded() {
    if (_draggingSub != null) setState(() => _draggingSub = null);
  }

  /// Shown while a subtask is dragged: dropping it here makes it a main task.
  Widget _topLevelDrop(Task dragged) => DragTarget<String>(
    key: const Key('drop-top-level'),
    onWillAcceptWithDetails: (d) => d.data == dragged.id,
    onAcceptWithDetails: (_) => _reparent(dragged, ''),
    builder: (context, candidates, _) {
      final scheme = Theme.of(context).colorScheme;
      final hot = candidates.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hot ? scheme.primaryContainer : null,
          border: Border.all(color: scheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(context.l10n.grpFActionMakeTopLevel),
      );
    },
  );

  /// A subtask only nests (it is not a board card), so only a default list lets
  /// it be picked up; a main task also reorders and changes group.
  bool _canDrag(Task task, ListQuery query) =>
      query.isDefault || task.parentId.isEmpty;

  bool _canNest(TaskTree tree, Task dragged, Task target, ListQuery query) =>
      query.isDefault &&
      dragged.parentId != target.id &&
      !tree.wouldCycle(dragged.id, target.id) &&
      target.depth + 1 + tree.levelsBelow(dragged.id) < softDepthLimit;

  RowDrop? _plan(
    TaskTree tree,
    Task dragged,
    Task target,
    DropZone zone,
    ListQuery query,
  ) => planRowDrop(
    dragged: dragged,
    target: target,
    zone: zone,
    query: query,
    canNest: _canNest(tree, dragged, target, query),
  );

  Widget _dropTarget(
    TaskTree tree,
    Task target,
    ListQuery query,
    Widget child,
  ) => RowDropTarget(
    key: Key('drop-${target.id}'),
    canNest: query.isDefault,
    willAccept: (id) {
      final dragged = tree.task(id);
      return dragged != null &&
          dragged.id != target.id &&
          DropZone.values.any(
            (z) => _plan(tree, dragged, target, z, query) != null,
          );
    },
    onDrop: (id, zone) {
      final dragged = tree.task(id);
      if (dragged == null) return;
      switch (_plan(tree, dragged, target, zone, query)) {
        case NestDrop():
          _reparent(dragged, target.id);
        case MoveDrop(
          :final groupBy,
          :final column,
          :final beforeId,
          :final afterId,
        ):
          _moveCard(
            dragged,
            groupBy: groupBy,
            column: column,
            beforeId: beforeId,
            afterId: afterId,
          );
        case null:
      }
    },
    child: child,
  );

  /// A group header takes a main task: it joins that group (last).
  Widget _groupDrop(
    TaskTree tree,
    ListLayout layout,
    GroupEntry group,
    Widget header,
  ) => DragTarget<String>(
    key: Key('drop-group-${group.key}'),
    onWillAcceptWithDetails: (d) {
      final dragged = tree.task(d.data);
      return dragged != null &&
          dragged.parentId.isEmpty &&
          groupKeyOf(dragged, layout.groupBy) != group.key;
    },
    onAcceptWithDetails: (d) {
      final dragged = tree.task(d.data);
      if (dragged == null) return;
      _moveCard(dragged, groupBy: layout.groupBy, column: group.key);
    },
    builder: (context, candidates, _) => DecoratedBox(
      decoration: BoxDecoration(
        border: candidates.isEmpty
            ? null
            : Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: header,
    ),
  );

  Future<void> _moveCard(
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(taskListProvider(project.id).notifier)
          .moveCard(
            ref.read(boardClientProvider),
            task,
            groupBy: groupBy,
            column: column,
            beforeId: beforeId,
            afterId: afterId,
          );
    } on TaskException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
    }
  }

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
    this.dragHandle,
  });

  final Task task;

  /// Grip that starts dragging the task onto another (phone cards).
  final Widget? dragHandle;

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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = task.statusCategory == StatusCategory.done;
    final accent = statusColor ?? scheme.outline;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      color: selected || picked == true
          ? scheme.secondaryContainer
          : done
          ? scheme.surfaceContainerLowest
          : scheme.surfaceContainerLow,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status colour stripe: the card's state at a glance.
            Container(key: Key('stripe-${task.id}'), width: 5, color: accent),
            Expanded(child: _tile(context)),
            if (dragHandle != null) Center(child: dragHandle),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context) => ListTile(
    key: Key('task-${task.id}'),
    selected: false,
    onTap: onTap,
    onLongPress: onLongPress,
    contentPadding: EdgeInsetsDirectional.only(start: 8.0 + depth * 16, end: 8),
    shape: const RoundedRectangleBorder(),
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
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: task.statusCategory == StatusCategory.done
          ? const TextStyle(decoration: TextDecoration.lineThrough)
          : const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Row(
      children: [
        PendingMark(id: task.id),
        Icon(
          Icons.circle,
          size: 10,
          color: statusColor ?? Theme.of(context).colorScheme.outline,
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
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, radius: 10),
              title: Container(height: 12, color: color),
              subtitle: Container(height: 8, width: 120, color: color),
            ),
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
        hintText: withShortcut(
          ref,
          context.l10n.taskAddHint,
          'task.new',
          l10n: context.l10n,
        ),
        prefixIcon: const Icon(Icons.add),
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      onSubmitted: _submit,
    ),
  );
}
