import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:taskforge/core/sync/presentation/live_flash.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart'
    show ProgressRing;
import 'package:taskforge/features/tasks/presentation/table_cells.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

const tableRowHeight = 44.0;
const tableGroupHeight = 36.0;
const tableHeaderHeight = 38.0;
const _checkWidth = 44.0;
const _menuWidth = 48.0;
const _indent = 20.0;

/// The tasks of a project as a data table: sticky header with sortable,
/// resizable columns, virtualized rows (only what is on screen is built),
/// group headers with counts, in-place edits, row selection and full keyboard
/// control (arrows move, Enter opens, Space picks, F2 renames, Esc clears).
class TaskTable extends ConsumerStatefulWidget {
  const TaskTable({
    super.key,
    required this.projectId,
    required this.entries,
    required this.layout,
    required this.lookups,
    required this.loading,
    required this.canUpdate,
    required this.openTaskId,
    required this.onOpen,
    required this.actionsFor,
    required this.onAction,
    required this.progressOf,
    this.wrapRow,
  });

  final String projectId;
  final List<ListEntry> entries;
  final ListLayout layout;
  final ListLookups lookups;
  final bool loading;
  final bool canUpdate;

  /// The task open in the detail panel, shown as selected.
  final String? openTaskId;
  final void Function(Task) onOpen;
  final List<TaskAction> Function(Task) actionsFor;
  final void Function(TaskAction, Task) onAction;
  final Progress Function(String taskId) progressOf;

  /// Wraps a task row (the list uses it to make rows draggable).
  final Widget Function(Task, Widget)? wrapRow;

  @override
  ConsumerState<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends ConsumerState<TaskTable> {
  final _vertical = ScrollController();
  final _horizontal = ScrollController();
  final _focus = FocusNode(debugLabel: 'task-table');

  /// The line with the keyboard cursor: a task id, or `group:<key>`.
  String? _cursor;
  String? _renaming;
  String? _lastPicked;

  List<String> get _visible =>
      widget.layout.columns.where(widget.lookups.known).toList(growable: false);

  double get _width =>
      _checkWidth +
      widget.layout.widthOf('title') +
      _visible.fold(0.0, (sum, c) => sum + widget.layout.widthOf(c)) +
      _menuWidth;

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    _focus.dispose();
    super.dispose();
  }

  static String _id(ListEntry e) => switch (e) {
    TaskEntry(:final task) => task.id,
    GroupEntry(:final key) => 'group:$key',
  };

  int _index(String? id) =>
      id == null ? -1 : widget.entries.indexWhere((e) => _id(e) == id);

  double _extent(ListEntry e) =>
      e is GroupEntry ? tableGroupHeight : tableRowHeight;

  /// Scrolls just enough to bring line [index] into view.
  void _reveal(int index) {
    if (!_vertical.hasClients || index < 0) return;
    var top = 0.0;
    for (var i = 0; i < index; i++) {
      top += _extent(widget.entries[i]);
    }
    final bottom = top + _extent(widget.entries[index]);
    final position = _vertical.position;
    if (top < position.pixels) {
      _vertical.jumpTo(top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      _vertical.jumpTo(bottom - position.viewportDimension);
    }
  }

  void _move(int delta) {
    final entries = widget.entries;
    if (entries.isEmpty) return;
    final current = _index(_cursor);
    final next = current < 0
        ? (delta > 0 ? 0 : entries.length - 1)
        : (current + delta).clamp(0, entries.length - 1);
    setState(() => _cursor = _id(entries[next]));
    _reveal(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _renaming != null) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final selection = ref.read(
      taskSelectionProvider(widget.projectId).notifier,
    );
    final index = _index(_cursor);
    final entry = index < 0 ? null : widget.entries[index];
    final shortcut =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _move(10);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _move(-10);
    } else if (key == LogicalKeyboardKey.enter && entry != null) {
      switch (entry) {
        case TaskEntry(:final task):
          widget.onOpen(task);
        case GroupEntry(:final key):
          _toggleGroup(key);
      }
    } else if (key == LogicalKeyboardKey.space && entry != null) {
      switch (entry) {
        case TaskEntry(:final task):
          selection.toggle(task.id);
          _lastPicked = task.id;
        case GroupEntry(:final key):
          _toggleGroup(key);
      }
    } else if (key == LogicalKeyboardKey.keyA && shortcut) {
      selection.addAll(taskIds(widget.entries));
    } else if (key == LogicalKeyboardKey.escape) {
      selection.clear();
    } else if (key == LogicalKeyboardKey.f2 &&
        widget.canUpdate &&
        entry is TaskEntry) {
      setState(() => _renaming = entry.task.id);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _toggleGroup(String key) =>
      ref.read(collapsedGroupsProvider(widget.projectId).notifier).toggle(key);

  void _pick(Task task) {
    final selection = ref.read(
      taskSelectionProvider(widget.projectId).notifier,
    );
    final ids = taskIds(widget.entries);
    final from = _lastPicked == null ? -1 : ids.indexOf(_lastPicked!);
    final to = ids.indexOf(task.id);
    if (HardwareKeyboard.instance.isShiftPressed && from >= 0 && to >= 0) {
      selection.addAll(ids.sublist(math.min(from, to), math.max(from, to) + 1));
    } else {
      selection.toggle(task.id);
    }
    _lastPicked = task.id;
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(taskSelectionProvider(widget.projectId));
    final ids = taskIds(widget.entries);
    final allPicked = ids.isNotEmpty && ids.every(selected.contains);
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, box) => Scrollbar(
          controller: _horizontal,
          child: SingleChildScrollView(
            controller: _horizontal,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(_width, box.maxWidth),
              height: box.maxHeight,
              child: Column(
                children: [
                  _header(context, allPicked, ids),
                  const Divider(height: 1),
                  Expanded(child: _rows(context, selected)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool allPicked, List<String> ids) {
    final layout = widget.layout;
    final selection = ref.read(
      taskSelectionProvider(widget.projectId).notifier,
    );
    final style = Theme.of(context).textTheme.labelLarge;
    return SizedBox(
      key: const Key('table-header'),
      height: tableHeaderHeight,
      child: Row(
        children: [
          SizedBox(
            width: _checkWidth,
            child: Checkbox(
              key: const Key('select-all'),
              value: allPicked,
              onChanged: ids.isEmpty
                  ? null
                  : (on) => on == true
                        ? selection.addAll(ids)
                        : selection.removeAll(ids),
            ),
          ),
          _HeaderCell(
            columnKey: 'title',
            label: 'Title',
            width: layout.widthOf('title'),
            sort: _sortOf('title'),
            sortable: true,
            style: style,
            onSort: (add) => _sort('title', add),
            onResize: (dx) => _resize('title', dx),
          ),
          for (final c in _visible)
            _HeaderCell(
              columnKey: c,
              label: widget.lookups.columnLabel(c),
              width: layout.widthOf(c),
              sort: _sortOf(c),
              sortable: widget.lookups.sortable(c),
              style: style,
              onSort: (add) => _sort(c, add),
              onResize: (dx) => _resize(c, dx),
            ),
          const SizedBox(width: _menuWidth),
        ],
      ),
    );
  }

  ({int position, bool desc})? _sortOf(String key) {
    final i = widget.layout.sort.indexWhere((s) => s.key == key);
    return i < 0 ? null : (position: i + 1, desc: widget.layout.sort[i].desc);
  }

  void _sort(String key, bool add) => ref
      .read(listLayoutProvider(widget.projectId).notifier)
      .update((l) => l.sortedBy(key, add: add));

  void _resize(String key, double dx) => ref
      .read(listLayoutProvider(widget.projectId).notifier)
      .update((l) => l.withWidth(key, l.widthOf(key) + dx));

  Widget _rows(BuildContext context, Set<String> selected) {
    final entries = widget.entries;
    final count = entries.length + (widget.loading ? 1 : 0);
    return ListView.builder(
      key: const Key('task-list'),
      controller: _vertical,
      itemCount: count,
      itemExtentBuilder: (i, _) =>
          i >= entries.length ? 4 : _extent(entries[i]),
      itemBuilder: (context, i) {
        if (i >= entries.length) {
          return const LinearProgressIndicator(key: Key('tasks-streaming'));
        }
        return switch (entries[i]) {
          GroupEntry() => _groupRow(context, entries[i] as GroupEntry),
          TaskEntry() => _taskRow(
            context,
            entries[i] as TaskEntry,
            selected.contains((entries[i] as TaskEntry).task.id),
          ),
        };
      },
    );
  }

  Widget _groupRow(BuildContext context, GroupEntry group) {
    final groupBy = widget.layout.groupBy;
    final color = widget.lookups.groupColor(groupBy, group.key);
    final focused = _cursor == 'group:${group.key}';
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        key: Key('group-${group.key}'),
        onTap: () {
          _focus.requestFocus();
          _toggleGroup(group.key);
        },
        child: Container(
          foregroundDecoration: focused ? _focusBorder(context) : null,
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(group.collapsed ? Icons.chevron_right : Icons.expand_more),
              if (color != null) ...[
                Icon(Icons.circle, size: 10, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                widget.lookups.groupLabel(groupBy, group.key),
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

  BoxDecoration _focusBorder(BuildContext context) => BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
  );

  Widget _taskRow(BuildContext context, TaskEntry entry, bool picked) {
    final task = entry.task;
    final layout = widget.layout;
    final scheme = Theme.of(context).colorScheme;
    final open = task.id == widget.openTaskId;
    final focused = _cursor == task.id;
    final actions = widget.actionsFor(task);
    final row = Material(
      color: picked
          ? scheme.secondaryContainer
          : open
          ? scheme.primaryContainer.withValues(alpha: 0.4)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          _focus.requestFocus();
          setState(() => _cursor = task.id);
          widget.onOpen(task);
        },
        child: Container(
          foregroundDecoration: focused ? _focusBorder(context) : null,
          child: Row(
            children: [
              SizedBox(
                width: _checkWidth,
                child: Checkbox(
                  key: Key('check-${task.id}'),
                  value: picked,
                  onChanged: (_) => _pick(task),
                ),
              ),
              SizedBox(
                width: layout.widthOf('title'),
                child: _titleCell(context, entry),
              ),
              for (final c in _visible)
                SizedBox(
                  width: layout.widthOf(c),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TaskCell(
                      column: c,
                      task: task,
                      lookups: widget.lookups,
                      canEdit: widget.canUpdate,
                    ),
                  ),
                ),
              SizedBox(
                width: _menuWidth,
                child: actions.isEmpty
                    ? null
                    : PopupMenuButton<TaskAction>(
                        key: Key('task-menu-${task.id}'),
                        tooltip: 'More',
                        onSelected: (a) => widget.onAction(a, task),
                        itemBuilder: (_) => [
                          for (final a in actions)
                            PopupMenuItem(
                              key: Key('${a.name}-${task.id}'),
                              value: a,
                              child: Text(a.label),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
    return LiveFlash(
      taskId: task.id,
      child: widget.wrapRow?.call(task, row) ?? row,
    );
  }

  /// The title cell is the part of a row that opens the task (a click on the
  /// other cells edits them), so it carries the row's key.
  Widget _titleCell(BuildContext context, TaskEntry entry) => InkWell(
    key: Key('task-${entry.task.id}'),
    onTap: () {
      _focus.requestFocus();
      setState(() => _cursor = entry.task.id);
      widget.onOpen(entry.task);
    },
    child: _titleContent(context, entry),
  );

  Widget _titleContent(BuildContext context, TaskEntry entry) {
    final task = entry.task;
    final progress = widget.progressOf(task.id);
    final leading = <Widget>[
      SizedBox(width: entry.depth * _indent),
      SizedBox(
        width: 32,
        child: entry.hasChildren
            ? IconButton(
                key: Key('toggle-${task.id}'),
                padding: EdgeInsets.zero,
                tooltip: entry.expanded ? 'Collapse' : 'Expand',
                icon: Icon(
                  entry.expanded ? Icons.expand_more : Icons.chevron_right,
                ),
                onPressed: () => ref
                    .read(collapsedTasksProvider(widget.projectId).notifier)
                    .toggle(task.id),
              )
            : null,
      ),
      if (task.isBlocked) ...[
        BlockedBadge(blockedBy: task.blockedBy),
        const SizedBox(width: 4),
      ],
    ];
    if (_renaming == task.id) {
      return Row(
        children: [
          ...leading,
          Expanded(
            child: _RenameField(task: task, onDone: _endRename),
          ),
        ],
      );
    }
    return Row(
      children: [
        ...leading,
        Expanded(
          child: Text(
            task.title,
            overflow: TextOverflow.ellipsis,
            style: task.statusCategory == StatusCategory.done
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
        ),
        if (!progress.isEmpty)
          KeyedSubtree(
            key: Key('progress-${task.id}'),
            child: ProgressRing(progress: progress),
          ),
        if (widget.canUpdate)
          IconButton(
            key: Key('rename-btn-${task.id}'),
            tooltip: 'Rename (F2)',
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => setState(() => _renaming = task.id),
          ),
      ],
    );
  }

  void _endRename() {
    setState(() => _renaming = null);
    _focus.requestFocus();
  }
}

/// A column heading: click sorts (shift-click adds a key), drag its right edge
/// resizes.
class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.columnKey,
    required this.label,
    required this.width,
    required this.sort,
    required this.sortable,
    required this.style,
    required this.onSort,
    required this.onResize,
  });

  final String columnKey;
  final String label;
  final double width;
  final ({int position, bool desc})? sort;
  final bool sortable;
  final TextStyle? style;
  final void Function(bool add) onSort;
  final void Function(double dx) onResize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Stack(
      children: [
        Positioned.fill(
          child: InkWell(
            key: Key('header-$columnKey'),
            onTap: sortable
                ? () => onSort(HardwareKeyboard.instance.isShiftPressed)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: style,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (sort != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      sort!.desc ? Icons.arrow_downward : Icons.arrow_upward,
                      key: Key('sort-arrow-$columnKey'),
                      size: 14,
                      semanticLabel: sort!.desc ? 'Descending' : 'Ascending',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              key: Key('resize-$columnKey'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => onResize(d.delta.dx),
              child: const VerticalDivider(width: 10, thickness: 1),
            ),
          ),
        ),
      ],
    ),
  );
}

/// The title edited in place: Enter saves, Esc or leaving the field cancels.
class _RenameField extends ConsumerStatefulWidget {
  const _RenameField({required this.task, required this.onDone});

  final Task task;
  final VoidCallback onDone;

  @override
  ConsumerState<_RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends ConsumerState<_RenameField> {
  late final _controller = TextEditingController(text: widget.task.title);
  final _node = FocusNode();
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _node.addListener(() {
      if (!_node.hasFocus) _finish(save: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _finish({required bool save}) {
    if (_finished) return;
    _finished = true;
    final title = _controller.text.trim();
    if (save && title.isNotEmpty && title != widget.task.title) {
      saveTask(context, ref, widget.task, TaskPatch(title: title));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) => Focus(
    onKeyEvent: (_, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        _finish(save: false);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: TextField(
      key: Key('rename-${widget.task.id}'),
      controller: _controller,
      focusNode: _node,
      autofocus: true,
      maxLength: maxTitleLength,
      decoration: const InputDecoration(
        isDense: true,
        counterText: '',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _finish(save: true),
    ),
  );
}
