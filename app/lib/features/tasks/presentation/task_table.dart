import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_list_motion.dart';
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/application/task_level_actions.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart'
    show isApplePlatform;
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/table_group_header.dart';
import 'package:taskforge/features/tasks/presentation/table_header.dart';
import 'package:taskforge/features/tasks/presentation/table_metrics.dart';
import 'package:taskforge/features/tasks/presentation/table_row.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

part 'task_table_rows.dart';

/// The tasks of a project as a data table: sticky header with sortable,
/// resizable columns, virtualized rows (only what is on screen is built),
/// group headers with counts, in-place edits, row selection and full keyboard
/// control (arrows move, Enter opens, Space picks, F2 renames, Esc clears).
/// The pieces live in `table_header`, `table_row`, `table_cells` and
/// `table_group_header`; this holds the scrolling, the cursor and the keys.
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
    this.wrapGroup,
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

  /// Wraps a group header (the list uses it to take dropped tasks).
  final Widget Function(GroupEntry, Widget)? wrapGroup;

  @override
  ConsumerState<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends ConsumerState<TaskTable> {
  final _vertical = ScrollController();

  /// Rows that arrive after the first settled paint ease in; cached ones do not.
  final _fresh = TfFreshIds();

  /// Rows removed after the first settled paint play out as ghosts.
  final _removals = TfRemovals<ListEntry>(
    (e) => e is TaskEntry ? e.task.id : null,
  );

  void _rebuild() {
    if (mounted) setState(() {});
  }

  final _horizontal = ScrollController();
  final _focus = FocusNode(debugLabel: 'task-table');

  /// The line with the keyboard cursor: a task id, or `group:<key>`.
  String? _cursor;
  String? _renaming;
  String? _lastPicked;

  /// The height of a line, set from the density on every build.
  var _rowHeight = workRowComfortable;

  List<String> get _visible =>
      widget.layout.columns.where(widget.lookups.known).toList(growable: false);

  double get _width =>
      tableCheckWidth +
      widget.layout.widthOf('title') +
      _visible.fold(0.0, (sum, c) => sum + widget.layout.widthOf(c)) +
      tableMenuWidth;

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

  /// Scrolls just enough to bring line [index] into view.
  void _reveal(int index) {
    if (!_vertical.hasClients || index < 0) return;
    final top = index * _rowHeight;
    final bottom = top + _rowHeight;
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

  /// Whether [event] is the key the person has for "rename": the registry
  /// knows it (F2 unless rebound). With a shortcut host the key reaches
  /// [renameRequestProvider] first; this keeps a bare table working too.
  bool _isRenameKey(KeyEvent event) {
    final chord = Chord.fromEvent(
      event,
      HardwareKeyboard.instance,
      isMac: isApplePlatform,
    );
    return chord != null &&
        chord == ref.read(bindingsProvider).chordOf('task.rename');
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
    } else if (widget.canUpdate && entry is TaskEntry && _isRenameKey(event)) {
      setState(() => _renaming = entry.task.id);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _setCursor(String id) => setState(() => _cursor = id);

  void _startRename(String id) => setState(() => _renaming = id);

  void _endRename() {
    setState(() => _renaming = null);
    _focus.requestFocus();
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
    _rowHeight = workRowHeight(context);
    final selected = ref.watch(taskSelectionProvider(widget.projectId));
    ref.listen(renameRequestProvider, (_, _) {
      final i = _index(_cursor);
      final entry = i < 0 ? null : widget.entries[i];
      if (widget.canUpdate && entry is TaskEntry && _renaming == null) {
        setState(() => _renaming = entry.task.id);
      }
    });
    final ids = taskIds(widget.entries);
    final allPicked = ids.isNotEmpty && ids.every(selected.contains);
    final selection = ref.read(
      taskSelectionProvider(widget.projectId).notifier,
    );
    final layoutNotifier = ref.read(
      listLayoutProvider(widget.projectId).notifier,
    );
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
              // The header stays; only the rows scroll under it.
              child: Column(
                children: [
                  TableHeader(
                    layout: widget.layout,
                    columns: _visible,
                    lookups: widget.lookups,
                    allPicked: allPicked,
                    canPick: ids.isNotEmpty,
                    onPickAll: (on) =>
                        on ? selection.addAll(ids) : selection.removeAll(ids),
                    onSort: (key, add) =>
                        layoutNotifier.update((l) => l.sortedBy(key, add: add)),
                    onResize: (key, dx) => layoutNotifier.update(
                      (l) => l.withWidth(key, l.widthOf(key) + dx),
                    ),
                  ),
                  Expanded(child: _rows(context, selected)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
