import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/presentation/live_flash.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart'
    show ProgressRing;
import 'package:taskforge/features/tasks/presentation/table_cells.dart';
import 'package:taskforge/features/tasks/presentation/table_metrics.dart';
import 'package:taskforge/features/tasks/presentation/table_rename.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/home/presentation/sample_badge.dart';

/// One task as a line of the table: check box, title with its fold arrow and
/// subtask ring, one cell per column, and the row menu. Rename and the menu
/// show while the pointer is over the row (or the row has the focus), and
/// always on touch screens.
class TaskRow extends StatefulWidget {
  const TaskRow({
    super.key,
    required this.entry,
    required this.layout,
    required this.columns,
    required this.lookups,
    required this.height,
    required this.picked,
    required this.open,
    required this.focused,
    required this.renaming,
    required this.canUpdate,
    required this.actions,
    required this.progress,
    required this.renameHint,
    required this.onOpen,
    required this.onPick,
    required this.onToggleFold,
    required this.onRename,
    required this.onRenameDone,
    required this.onAction,
    this.wrap,
  });

  final TaskEntry entry;
  final ListLayout layout;
  final List<String> columns;
  final ListLookups lookups;
  final double height;
  final bool picked;

  /// The task whose detail is open beside the list.
  final bool open;

  /// The keyboard cursor is on this line.
  final bool focused;
  final bool renaming;
  final bool canUpdate;
  final List<TaskAction> actions;
  final Progress progress;

  /// The tooltip of the rename button (it names the key).
  final String renameHint;
  final VoidCallback onOpen;
  final VoidCallback onPick;
  final VoidCallback onToggleFold;
  final VoidCallback onRename;
  final VoidCallback onRenameDone;
  final void Function(TaskAction) onAction;

  /// Wraps the row (the list makes rows draggable and drop targets).
  final Widget Function(Task, Widget)? wrap;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  var _hovered = false;

  Task get _task => widget.entry.task;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    final shown = _hovered || widget.focused || tfIsTouch;
    final fill = widget.picked || widget.open
        ? c.selected
        : (_hovered ? c.hover : Colors.transparent);
    final row = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: fill,
        child: InkWell(
          onTap: widget.onOpen,
          // The title cell is the one named, announced target; this is the
          // mouse's wider hit area.
          excludeFromSemantics: true,
          // The title cell is the row's one tab stop.
          canRequestFocus: false,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.border, width: tfHairline),
              ),
            ),
            foregroundDecoration: widget.focused
                ? BoxDecoration(border: tfFocusRing(c))
                : null,
            child: Row(
              children: [
                SizedBox(
                  width: tableCheckWidth,
                  child: Semantics(
                    label: _task.title,
                    child: Checkbox(
                      key: Key('check-${_task.id}'),
                      visualDensity: VisualDensity.compact,
                      value: widget.picked,
                      onChanged: (_) => widget.onPick(),
                    ),
                  ),
                ),
                SizedBox(
                  width: widget.layout.widthOf('title'),
                  child: _title(context, shown),
                ),
                for (final col in widget.columns)
                  SizedBox(
                    width: widget.layout.widthOf(col),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: TfSpace.sm,
                      ),
                      child: TaskCell(
                        column: col,
                        task: _task,
                        lookups: widget.lookups,
                        canEdit: widget.canUpdate,
                      ),
                    ),
                  ),
                SizedBox(width: tableMenuWidth, child: _menu(context, shown)),
              ],
            ),
          ),
        ),
      ),
    );
    return LiveFlash(
      taskId: _task.id,
      child: widget.wrap?.call(_task, row) ?? row,
    );
  }

  /// The title cell is the part of a row that opens the task (a click on the
  /// other cells edits them), so it carries the row's key.
  Widget _title(BuildContext context, bool shown) {
    final tf = context.tf;
    final entry = widget.entry;
    final leading = [
      SizedBox(width: entry.depth * tableIndent),
      SizedBox(
        width: 32,
        child: entry.hasChildren
            ? TfIconButton(
                key: Key('toggle-${_task.id}'),
                icon: entry.expanded ? TfIcons.chevronDown : TfIcons.chevronEnd,
                tooltip: entry.expanded
                    ? context.l10n.grpBCollapse
                    : context.l10n.grpBExpand,
                size: TfButtonSize.small,
                onPressed: widget.onToggleFold,
              )
            : null,
      ),
      if (_task.isBlocked) ...[
        BlockedBadge(blockedBy: _task.blockedBy),
        const SizedBox(width: TfSpace.xs),
      ],
      if (_task.isSample) ...[
        const SampleBadge(),
        const SizedBox(width: TfSpace.xs),
      ],
    ];
    if (widget.renaming) {
      return Row(
        children: [
          ...leading,
          Expanded(
            child: RenameField(task: _task, onDone: widget.onRenameDone),
          ),
        ],
      );
    }
    final done = _task.statusCategory == StatusCategory.done;
    return InkWell(
      key: Key('task-${_task.id}'),
      onTap: widget.onOpen,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Row(
        children: [
          ...leading,
          Expanded(
            child: Tooltip(
              message: _task.title,
              // Hover only: a long press belongs to dragging the row.
              triggerMode: TooltipTriggerMode.manual,
              child: Text(
                _task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tf.typography.body.copyWith(
                  color: done ? tf.colors.textMuted : tf.colors.text,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
          if (!widget.progress.isEmpty)
            KeyedSubtree(
              key: Key('progress-${_task.id}'),
              child: ProgressRing(progress: widget.progress),
            ),
          if (widget.canUpdate)
            _Reveal(
              visible: shown,
              reachable: _hovered || widget.focused,
              child: TfIconButton(
                key: Key('rename-btn-${_task.id}'),
                icon: TfIcons.edit,
                tooltip: widget.renameHint,
                size: TfButtonSize.small,
                onPressed: widget.onRename,
              ),
            ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, bool shown) {
    if (widget.actions.isEmpty) return const SizedBox.shrink();
    return _Reveal(
      visible: shown,
      reachable: _hovered || widget.focused,
      child: TfMenu(
        key: Key('task-menu-${_task.id}'),
        items: [
          for (final a in widget.actions)
            TfMenuItem(
              key: Key('${a.name}-${_task.id}'),
              label: a.labelIn(context.l10n),
              danger: a == TaskAction.delete,
              onSelected: () => widget.onAction(a),
            ),
        ],
        builder: (context, toggle) => TfIconButton(
          icon: TfIcons.more,
          tooltip: context.l10n.grpFMore,
          size: TfButtonSize.small,
          onPressed: toggle,
        ),
      ),
    );
  }
}

/// Hover actions: transparent (and out of the tab order, the table's own keys
/// do the same: arrows, F2, the palette) until [visible]; the pointer or the
/// row's keyboard cursor makes them appear.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.visible,
    required this.reachable,
    required this.child,
  });

  final bool visible;
  final bool reachable;
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ExcludeFocus(
      excluding: !reachable,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: TfMotion.of(context, TfDuration.fast),
        child: child,
      ),
    ),
  );
}
