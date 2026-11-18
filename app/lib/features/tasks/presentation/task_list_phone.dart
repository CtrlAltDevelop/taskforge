part of 'task_list.dart';

mixin _TaskListPhone
    on ConsumerState<TaskListView>, _TaskListOps, _TaskListDrag {
  /// Cards that arrive after the first settled paint ease in; cached ones do not.
  final _fresh = TfFreshIds();

  /// Cards removed after the first settled paint play out as ghosts.
  final _removals = TfRemovals<ListEntry>(
    (e) => e is TaskEntry ? e.task.id : null,
  );

  void _resetMotion() {
    _fresh.reset();
    _removals.reset();
  }

  void _rebuildList() {
    if (mounted) setState(() {});
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
    _fresh.update([
      for (final e in entries)
        if (e is TaskEntry) e.task.id,
    ], settled: !state.loading);
    final items = <Object>[
      for (final entry in _removals.update(
        entries,
        settled: !state.loading,
        reduced: TfMotion.reduced(context),
      )) ...[
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
          if (item is TfGhost) return _removals.ghostRow(item, _rebuildList);
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
          return TfSettleIn(
            key: ValueKey('settle-${task.id}'),
            enabled: _fresh.isFresh(task.id),
            child: _removals.remember(
              task.id,
              canDrag ? _dropTarget(tree, task, layout.query, row) : row,
            ),
          );
        },
      ),
    );
  }

  Widget _groupTile(ListLookups lookups, ListLayout layout, GroupEntry group) =>
      TableGroupHeader(
        group: group,
        groupBy: layout.groupBy,
        lookups: lookups,
        height: workRowComfortable,
        focused: false,
        onToggle: () => ref
            .read(collapsedGroupsProvider(project.id).notifier)
            .toggle(group.key),
      );

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
      background: TaskSwipeBackground(
        icon: TfIcons.check,
        label: context.l10n.grpFSwipeComplete,
        alignment: AlignmentDirectional.centerStart,
      ),
      secondaryBackground: TaskSwipeBackground(
        icon: TfIcons.trash,
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
}
