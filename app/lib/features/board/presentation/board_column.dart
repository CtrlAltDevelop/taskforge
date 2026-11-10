import 'package:flutter/material.dart';

import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/board/presentation/board_card.dart';
import 'package:taskforge/features/board/presentation/edge_scroll.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';

/// Width of one column.
const columnWidth = 280.0;

/// Where a card was dropped: right before [beforeId] and right after
/// [afterId] (either may be empty; both empty: last).
typedef DropHandler = void Function(
  BoardDrag drag, {
  required String beforeId,
  required String afterId,
});

/// One column: a header (name, count against the limit, fold, menu), the cards
/// loaded so far (built lazily, the next page when the end is reached), and a
/// field to add a task. Cards of its own lane can be dropped on it.
class BoardColumnView extends StatefulWidget {
  const BoardColumnView({
    super.key,
    required this.laneKey,
    required this.column,
    required this.title,
    required this.lookups,
    required this.cardFields,
    required this.onOpen,
    required this.onDrop,
    required this.onLoadMore,
    required this.onDragMove,
    required this.onDragEnd,
    required this.onSetLimit,
    required this.onToggleCollapse,
    required this.moveChoices,
    required this.onMoveTo,
    this.color,
    this.limit,
    this.collapsed = false,
    this.canMove = false,
    this.onAdd,
    this.openTaskId,
    this.longPressDrag = false,
  });

  final String laneKey;
  final BoardColumn column;
  final String title;
  final Color? color;
  final int? limit;
  final bool collapsed;
  final bool canMove;
  final bool longPressDrag;
  final ListLookups lookups;
  final List<String> cardFields;
  final String? openTaskId;
  final void Function(Task) onOpen;
  final DropHandler onDrop;
  final VoidCallback onLoadMore;

  /// A dragged card is over this column at [pointer] (global), or has left it:
  /// the board scrolls sideways from that.
  final void Function(Offset pointer) onDragMove;
  final VoidCallback onDragEnd;
  final void Function(int? limit) onSetLimit;
  final VoidCallback onToggleCollapse;
  final List<MoveChoice> moveChoices;
  final void Function(Task task, String column) onMoveTo;

  /// Adds a task to this column (null: the person may not).
  final Future<void> Function(String title)? onAdd;

  @override
  State<BoardColumnView> createState() => _BoardColumnViewState();
}

class _BoardColumnViewState extends State<BoardColumnView> {
  final _scroll = ScrollController();
  final _area = GlobalKey();
  late final _edge = EdgeScroller(
    controller: _scroll,
    axis: Axis.vertical,
    area: _area,
  );

  @override
  void dispose() {
    _edge.stop();
    _scroll.dispose();
    super.dispose();
  }

  void _pointer(Offset pointer) {
    _edge.follow(pointer);
    widget.onDragMove(pointer);
  }

  void _pointerGone() {
    _edge.stop();
    widget.onDragEnd();
  }

  bool get _over {
    final limit = widget.limit;
    return limit != null && widget.column.count > limit;
  }

  Future<void> _askLimit() async {
    final result = await showDialog<int?>(
      context: context,
      builder: (_) => _LimitDialog(current: widget.limit),
    );
    // Cancel pops nothing at all; "Clear" pops 0.
    if (result == null) return;
    widget.onSetLimit(result > 0 ? result : null);
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.column.key;
    if (widget.collapsed) return _folded(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: columnWidth,
      child: Card(
        margin: const EdgeInsets.all(6),
        color: scheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            Expanded(
              key: _area,
              child: DragTarget<BoardDrag>(
                key: Key('drop-column-$key'),
                onWillAcceptWithDetails: _accepts,
                onMove: (d) => _pointer(d.offset),
                onLeave: (_) => _pointerGone(),
                onAcceptWithDetails: (d) {
                  _pointerGone();
                  final others = [
                    for (final t in widget.column.tasks)
                      if (t.id != d.data.task.id) t,
                  ];
                  final inside = others.length != widget.column.tasks.length;
                  // Past the loaded cards of a longer column: last of all.
                  if (widget.column.hasMore) {
                    widget.onDrop(d.data, beforeId: '', afterId: '');
                  } else if (inside &&
                      widget.column.tasks.last.id == d.data.task.id) {
                    return; // already last: put back where it was
                  } else {
                    widget.onDrop(
                      d.data,
                      beforeId: '',
                      afterId: others.lastOrNull?.id ?? '',
                    );
                  }
                },
                builder: (context, hovering, _) => Container(
                  color: hovering.isEmpty
                      ? null
                      : scheme.primary.withValues(alpha: 0.06),
                  child: _cards(context),
                ),
              ),
            ),
            if (widget.onAdd != null)
              _AddField(columnKey: key, onAdd: widget.onAdd!),
          ],
        ),
      ),
    );
  }

  bool _accepts(DragTargetDetails<BoardDrag> d) =>
      widget.canMove && d.data.laneKey == widget.laneKey;

  Widget _folded(BuildContext context) => SizedBox(
    width: 48,
    child: Card(
      margin: const EdgeInsets.all(6),
      child: InkWell(
        key: Key('expand-${widget.column.key}'),
        onTap: widget.onToggleCollapse,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.unfold_more, size: 18),
            const SizedBox(height: 8),
            Text('${widget.column.count}'),
            const SizedBox(height: 8),
            Expanded(
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(widget.title, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _header(BuildContext context) {
    final key = widget.column.key;
    final scheme = Theme.of(context).colorScheme;
    final limit = widget.limit;
    return Container(
      key: _over ? Key('wip-over-$key') : null,
      color: _over ? scheme.errorContainer : null,
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          IconButton(
            key: Key('collapse-$key'),
            tooltip: 'Fold the column',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.unfold_less),
            onPressed: widget.onToggleCollapse,
          ),
          if (widget.color != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              widget.title,
              key: Key('column-title-$key'),
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            limit == null
                ? '${widget.column.count}'
                : '${widget.column.count} / $limit',
            key: Key('count-$key'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _over ? scheme.error : null,
            ),
          ),
          PopupMenuButton<String>(
            key: Key('column-menu-$key'),
            tooltip: 'Column',
            onSelected: (_) => _askLimit(),
            itemBuilder: (_) => [
              PopupMenuItem(
                key: Key('set-limit-$key'),
                value: 'limit',
                child: Text(
                  limit == null
                      ? 'Set a work-in-progress limit…'
                      : 'Change the limit…',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cards(BuildContext context) {
    final column = widget.column;
    final tasks = column.tasks;
    if (tasks.isEmpty && !column.hasMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.canMove ? 'Drop a card here' : 'No cards',
            key: Key('empty-${column.key}'),
          ),
        ),
      );
    }
    return ListView.builder(
      key: Key('cards-${column.key}'),
      controller: _scroll,
      itemCount: tasks.length + (column.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == tasks.length) {
          // Built only when scrolled to: that is the cue for the next page.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onLoadMore();
          });
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: LinearProgressIndicator()),
          );
        }
        final task = tasks[i];
        return _CardSlot(
          key: ValueKey(task.id),
          laneKey: widget.laneKey,
          task: task,
          previousId: i > 0 ? tasks[i - 1].id : '',
          canMove: widget.canMove,
          longPress: widget.longPressDrag,
          lookups: widget.lookups,
          cardFields: widget.cardFields,
          selected: task.id == widget.openTaskId,
          moveChoices: [
            for (final c in widget.moveChoices)
              if (c.key != column.key) c,
          ],
          onOpen: () => widget.onOpen(task),
          onMoveTo: (to) => widget.onMoveTo(task, to),
          onDrop: (drag, {required beforeId, required afterId}) {
            _pointerGone();
            widget.onDrop(drag, beforeId: beforeId, afterId: afterId);
          },
          onPointer: _pointer,
          onPointerGone: _pointerGone,
        );
      },
    );
  }
}

/// A card that can be picked up, and a place to drop another one just above or
/// below it (a line shows which).
class _CardSlot extends StatefulWidget {
  const _CardSlot({
    super.key,
    required this.laneKey,
    required this.task,
    required this.previousId,
    required this.canMove,
    required this.longPress,
    required this.lookups,
    required this.cardFields,
    required this.selected,
    required this.moveChoices,
    required this.onOpen,
    required this.onMoveTo,
    required this.onDrop,
    required this.onPointer,
    required this.onPointerGone,
  });

  final String laneKey;
  final Task task;
  final String previousId;
  final bool canMove;
  final bool longPress;
  final ListLookups lookups;
  final List<String> cardFields;
  final bool selected;
  final List<MoveChoice> moveChoices;
  final VoidCallback onOpen;
  final void Function(String column) onMoveTo;
  final DropHandler onDrop;
  final void Function(Offset pointer) onPointer;
  final VoidCallback onPointerGone;

  @override
  State<_CardSlot> createState() => _CardSlotState();
}

class _CardSlotState extends State<_CardSlot> {
  /// While something hovers: whether the pointer is in the lower half.
  bool? _below;

  /// Its own card accepts too (and does nothing), so dropping a card back where
  /// it was is not taken as a drop at the end of the column.
  bool _accepts(DragTargetDetails<BoardDrag> d) =>
      widget.canMove && d.data.laneKey == widget.laneKey;

  void _track(DragTargetDetails<BoardDrag> d) {
    widget.onPointer(d.offset);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(d.offset);
    final below = local.dy > box.size.height / 2;
    if (below != _below) setState(() => _below = below);
  }

  void _drop(DragTargetDetails<BoardDrag> d) {
    final below = _below ?? false;
    setState(() => _below = null);
    if (d.data.task.id == widget.task.id) {
      widget.onPointerGone();
      return;
    }
    if (below) {
      widget.onDrop(d.data, beforeId: '', afterId: widget.task.id);
    } else {
      widget.onDrop(
        d.data,
        beforeId: widget.task.id,
        afterId: widget.previousId == d.data.task.id ? '' : widget.previousId,
      );
    }
  }

  Widget _card() => BoardCard(
    task: widget.task,
    lookups: widget.lookups,
    cardFields: widget.cardFields,
    selected: widget.selected,
    onTap: widget.onOpen,
    moveChoices: widget.canMove ? widget.moveChoices : const [],
    onMoveTo: widget.canMove ? widget.onMoveTo : null,
  );

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.primary,
    );
    final drag = BoardDrag(widget.task, widget.laneKey);
    final feedback = Material(
      elevation: 6,
      child: SizedBox(width: columnWidth - 20, child: _card()),
    );
    final child = _card();
    final draggable = !widget.canMove
        ? child
        : widget.longPress
        ? LongPressDraggable<BoardDrag>(
            data: drag,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: feedback,
            childWhenDragging: Opacity(opacity: 0.35, child: _card()),
            child: child,
          )
        : Draggable<BoardDrag>(
            data: drag,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: feedback,
            childWhenDragging: Opacity(opacity: 0.35, child: _card()),
            child: child,
          );
    return DragTarget<BoardDrag>(
      key: Key('drop-${widget.task.id}'),
      onWillAcceptWithDetails: _accepts,
      onMove: _track,
      onLeave: (_) {
        widget.onPointerGone();
        setState(() => _below = null);
      },
      onAcceptWithDetails: _drop,
      builder: (context, hovering, _) => Column(
        children: [
          if (hovering.isNotEmpty && _below == false)
            KeyedSubtree(
              key: Key('drop-line-above-${widget.task.id}'),
              child: line,
            ),
          draggable,
          if (hovering.isNotEmpty && _below == true)
            KeyedSubtree(
              key: Key('drop-line-below-${widget.task.id}'),
              child: line,
            ),
        ],
      ),
    );
  }
}

class _AddField extends StatefulWidget {
  const _AddField({required this.columnKey, required this.onAdd});

  final String columnKey;
  final Future<void> Function(String title) onAdd;

  @override
  State<_AddField> createState() => _AddFieldState();
}

class _AddFieldState extends State<_AddField> {
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
    setState(() => _busy = true);
    try {
      await widget.onAdd(title);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
    child: TextField(
      key: Key('add-${widget.columnKey}'),
      controller: _controller,
      enabled: !_busy,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        isDense: true,
        hintText: 'Add a task',
        prefixIcon: Icon(Icons.add, size: 18),
      ),
      onSubmitted: _submit,
    ),
  );
}

class _LimitDialog extends StatefulWidget {
  const _LimitDialog({this.current});

  final int? current;

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final _controller = TextEditingController(
    text: widget.current?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = int.tryParse(_controller.text.trim());
    if (value != null && value > 0) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Work-in-progress limit'),
    content: TextField(
      key: const Key('wip-input'),
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Most cards this column should hold',
      ),
      onSubmitted: (_) => _save(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      if (widget.current != null)
        TextButton(
          key: const Key('wip-clear'),
          onPressed: () => Navigator.pop(context, 0),
          child: const Text('Clear'),
        ),
      FilledButton(
        key: const Key('wip-save'),
        onPressed: _save,
        child: const Text('Save'),
      ),
    ],
  );
}
