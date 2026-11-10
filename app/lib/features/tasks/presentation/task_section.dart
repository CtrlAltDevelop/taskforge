import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_detail.dart';
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// Width from which the detail opens as a side panel instead of a page.
const wideBreakpoint = 900.0;

/// A project's tasks: quick-add bar, the list, and the detail of the selected one.
class TaskSection extends ConsumerStatefulWidget {
  const TaskSection({super.key, required this.project, this.initialTask});

  final Project project;

  /// Open this task's detail beside the list (wide screens) from the start.
  final String? initialTask;

  @override
  ConsumerState<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends ConsumerState<TaskSection> {
  late String? _selected = widget.initialTask;

  /// On a narrow screen the task to open as a page once the list has it.
  late String? _pending = widget.initialTask;

  Future<void> _open(Task task, bool wide) async {
    if (wide) {
      setState(() => _selected = task.id);
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(task.displayId)),
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= wideBreakpoint;
      _openPending(wide);
      final list = _TaskList(
        project: widget.project,
        wide: wide,
        selected: wide ? _selected : null,
        onOpen: (t) => _open(t, wide),
      );
      if (!wide || _selected == null) return list;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: list),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 420,
            child: TaskDetail(
              key: ValueKey(_selected),
              project: widget.project,
              taskId: _selected!,
              onClose: () => setState(() => _selected = null),
              onOpen: (t) => _open(t, true),
            ),
          ),
        ],
      );
    },
  );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canCreate) QuickAdd(projectId: project.id),
        Expanded(child: _body(context, state, flow, permissions)),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    TaskListState state,
    Workflow? flow,
    Permissions permissions,
  ) {
    if (state.error != null && state.tasks.isEmpty) {
      return Center(
        child: TextButton(
          key: const Key('retry-tasks'),
          onPressed: () =>
              ref.read(taskListProvider(project.id).notifier).load(),
          child: Text('${taskErrorMessage(state.error!)} Retry'),
        ),
      );
    }
    if (state.loading && state.tasks.isEmpty) return const _Skeleton();
    if (state.tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks yet. Add the first one above.',
          key: Key('no-tasks'),
        ),
      );
    }
    final tree = ref.watch(taskTreeProvider(project.id));
    final collapsed = ref.watch(collapsedTasksProvider(project.id));
    final rows = tree.visibleRows(collapsed);
    final editable = !project.isArchived;
    final canUpdate = editable && permissions.can(Perm.taskUpdate);
    final canCreate = editable && permissions.can(Perm.taskCreate);
    final canDelete = editable && permissions.can(Perm.taskDelete);
    final fields =
        ref.watch(fieldsProvider(project.id)).value ?? const <CustomField>[];
    final people = {
      for (final m in ref.watch(membersProvider).value ?? const <Member>[])
        m.userId: m.label,
    };
    String summarize(Task t) =>
        fieldSummary(t, fields, userLabel: (id) => people[id] ?? id);
    // Rows are built lazily (a list of thousands only builds what is on screen);
    // the inline add field counts as one more entry under its parent.
    final entries = <Object>[
      for (final row in rows) ...[
        row,
        if (_addingUnder == row.task.id) row.task.id,
      ],
    ];
    return ListView.builder(
      key: const Key('task-list'),
      itemCount: entries.length + (state.loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == entries.length) {
          return const LinearProgressIndicator(key: Key('tasks-streaming'));
        }
        final entry = entries[i];
        if (entry is String) return _inlineAdd(tree, entry);
        final row = entry as TreeRow;
        final task = row.task;
        final tile = TaskTile(
          task: task,
          statusColor: flow?.statusById(task.statusId)?.swatch,
          selected: task.id == widget.selected,
          onTap: () => widget.onOpen(task),
          depth: row.depth,
          hasChildren: row.hasChildren,
          expanded: row.expanded,
          progress: tree.progressOf(task.id),
          onToggle: () => ref
              .read(collapsedTasksProvider(project.id).notifier)
              .toggle(task.id),
          actions: [
            if (canCreate && task.depth + 1 < softDepthLimit)
              TaskAction.addSubtask,
            if (canUpdate) TaskAction.moveUnder,
            if (canUpdate && task.parentId.isNotEmpty) TaskAction.makeTopLevel,
            if (canDelete) TaskAction.delete,
          ],
          onAction: (action) => _act(action, tree, task),
          fieldSummary: summarize(task),
        );
        if (!widget.wide || !canUpdate) return tile;
        return _dropTarget(tree, task, _draggable(task, tile));
      },
    );
  }

  Widget _inlineAdd(TaskTree tree, String parentId) {
    final parent = tree.task(parentId);
    return Padding(
      padding: EdgeInsets.fromLTRB(
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
          subtitle: Text(task.displayId),
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
        setState(() => _addingUnder = task.id);
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
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
    }
  }

  Future<void> _delete(TaskTree tree, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final list = ref.read(taskListProvider(project.id).notifier);
    final below = tree.subtreeIds(task.id).length - 1;
    DeleteMode? mode;
    if (below > 0) {
      mode = await askDeleteMode(context, task, below);
      if (mode == null || !mounted) return;
    }
    try {
      final moved = await list.delete(task, mode: mode);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${task.displayId} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await list.restore(task, adopt: moved);
                } on TaskException catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(taskErrorMessage(e))),
                  );
                }
              },
            ),
          ),
        );
    } on TaskException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
    }
  }
}

/// What a row's menu can do.
enum TaskAction {
  addSubtask('Add subtask'),
  moveUnder('Move under\u2026'),
  makeTopLevel('Make top level'),
  delete('Delete');

  const TaskAction(this.label);

  final String label;
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

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('task-${task.id}'),
    selected: selected,
    onTap: onTap,
    contentPadding: EdgeInsets.only(left: 8.0 + depth * 20, right: 8),
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          child: hasChildren
              ? IconButton(
                  key: Key('toggle-${task.id}'),
                  padding: EdgeInsets.zero,
                  tooltip: expanded ? 'Collapse' : 'Expand',
                  icon: Icon(
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
          semanticLabel: task.priority.label,
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
            padding: const EdgeInsets.only(left: 8),
            child: Chip(label: Text('${task.assigneeIds.length}')),
          ),
        if (actions.isNotEmpty)
          PopupMenuButton<TaskAction>(
            key: Key('task-menu-${task.id}'),
            tooltip: 'More',
            onSelected: onAction,
            itemBuilder: (_) => [
              for (final a in actions)
                PopupMenuItem(
                  key: Key('${a.name}-${task.id}'),
                  value: a,
                  child: Text(a.label),
                ),
            ],
          ),
      ],
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
      messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
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
      decoration: const InputDecoration(
        hintText: 'Add a task and press Enter',
        prefixIcon: Icon(Icons.add),
        counterText: '',
        border: OutlineInputBorder(),
      ),
      onSubmitted: _submit,
    ),
  );
}
