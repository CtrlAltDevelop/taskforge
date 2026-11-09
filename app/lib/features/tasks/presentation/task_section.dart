import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/task_detail.dart';

/// Width from which the detail opens as a side panel instead of a page.
const wideBreakpoint = 900.0;

/// A project's tasks: quick-add bar, the list, and the detail of the selected one.
class TaskSection extends ConsumerStatefulWidget {
  const TaskSection({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends ConsumerState<TaskSection> {
  String? _selected;

  Future<void> _open(Task task, bool wide) async {
    if (wide) {
      setState(() => _selected = task.id);
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(task.displayId)),
          body: TaskDetail(project: widget.project, taskId: task.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= wideBreakpoint;
      final list = _TaskList(
        project: widget.project,
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
            ),
          ),
        ],
      );
    },
  );
}

class _TaskList extends ConsumerWidget {
  const _TaskList({
    required this.project,
    required this.selected,
    required this.onOpen,
  });

  final Project project;
  final String? selected;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListProvider(project.id));
    final canCreate =
        !project.isArchived &&
        ref.watch(permissionSetProvider).can(Perm.taskCreate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canCreate) QuickAdd(projectId: project.id),
        Expanded(child: _body(context, ref, state)),
      ],
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, TaskListState state) {
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
    return ListView.builder(
      key: const Key('task-list'),
      itemCount: state.tasks.length + (state.loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == state.tasks.length) {
          return const LinearProgressIndicator(key: Key('tasks-streaming'));
        }
        final task = state.tasks[i];
        return TaskTile(
          task: task,
          selected: task.id == selected,
          onTap: () => onOpen(task),
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    this.selected = false,
  });

  final Task task;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('task-${task.id}'),
    selected: selected,
    onTap: onTap,
    leading: Icon(
      priorityIcon(task.priority),
      color: priorityColor(task.priority),
      semanticLabel: task.priority.label,
    ),
    title: Text(
      task.title,
      style: task.status == TaskStatus.done
          ? const TextStyle(decoration: TextDecoration.lineThrough)
          : null,
    ),
    subtitle: Text(
      [
        task.displayId,
        task.status.label,
        if (task.dueDate.isNotEmpty) 'due ${task.dueDate}',
      ].join(' · '),
    ),
    trailing: task.assigneeIds.isEmpty
        ? null
        : Chip(label: Text('${task.assigneeIds.length}')),
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
      await ref.read(taskListProvider(widget.projectId).notifier).create(title);
      _controller.clear();
    } on TaskException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(taskErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
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
