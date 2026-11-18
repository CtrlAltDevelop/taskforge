part of 'task_list.dart';

mixin _TaskListDrag on ConsumerState<TaskListView>, _TaskListOps {
  /// The subtask being dragged now (a drop bar to make it a main task shows).
  Task? _draggingSub;

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
      child: TfIcon(TfIcons.grip),
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
      final c = context.tf.colors;
      final hot = candidates.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hot ? c.selected : null,
          border: Border.all(color: c.accent),
          borderRadius: TfRadius.panel,
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
            : Border.all(color: context.tf.colors.accent),
      ),
      child: header,
    ),
  );
}
