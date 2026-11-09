import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// One task's fields. A side panel on wide screens, a page on narrow ones;
/// every edit sends only that field and shows at once.
class TaskDetail extends ConsumerWidget {
  const TaskDetail({
    super.key,
    required this.project,
    required this.taskId,
    this.onClose,
  });

  final Project project;
  final String taskId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref
        .watch(taskListProvider(project.id))
        .tasks
        .where((t) => t.id == taskId)
        .firstOrNull;
    if (task == null) {
      return const Center(child: Text('Task not found.', key: Key('no-task')));
    }
    final permissions = ref.watch(permissionSetProvider);
    final canEdit = !project.isArchived && permissions.can(Perm.taskUpdate);
    final canDelete = !project.isArchived && permissions.can(Perm.taskDelete);
    final members = _candidates(ref);
    return ListView(
      key: const Key('task-detail'),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.displayId,
                key: const Key('detail-id'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (canDelete)
              IconButton(
                key: const Key('delete-task'),
                tooltip: 'Delete task',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, task),
              ),
            if (onClose != null)
              IconButton(
                key: const Key('close-detail'),
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
          ],
        ),
        _TextField(
          fieldKey: const Key('detail-title'),
          value: task.title,
          enabled: canEdit,
          maxLength: maxTitleLength,
          label: 'Title',
          allowEmpty: false,
          onSave: (v) {
            final title = v.trim();
            if (title == task.title) return;
            saveTask(context, ref, task, TaskPatch(title: title));
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              // Keyed by the value so a rollback (a refused move) shows again.
              child: KeyedSubtree(
                key: ValueKey('status-${task.statusId}'),
                child: _StatusPicker(
                  task: task,
                  workflow: ref.watch(workflowProvider(project.id)).value,
                  roleId: permissions.roleId,
                  enabled: canEdit,
                  onPick: (s) =>
                      saveTask(context, ref, task, TaskPatch(status: s)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey('priority-${task.priority.wire}'),
                child: DropdownButtonFormField<TaskPriority>(
                  key: const Key('detail-priority'),
                  isExpanded: true,
                  initialValue: task.priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: [
                    for (final p in TaskPriority.values)
                      DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(
                              priorityIcon(p),
                              color: priorityColor(p),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: canEdit
                      ? (p) {
                          if (p != null && p != task.priority) {
                            saveTask(
                              context,
                              ref,
                              task,
                              TaskPatch(priority: p),
                            );
                          }
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateField(
                fieldKey: const Key('detail-start'),
                label: 'Start',
                value: task.startDate,
                enabled: canEdit,
                onPicked: (v) =>
                    saveTask(context, ref, task, TaskPatch(startDate: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                fieldKey: const Key('detail-due'),
                label: 'Due',
                value: task.dueDate,
                enabled: canEdit,
                onPicked: (v) =>
                    saveTask(context, ref, task, TaskPatch(dueDate: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Assignees', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final m in members)
              FilterChip(
                key: Key('assignee-${m.userId}'),
                avatar: CircleAvatar(
                  child: Text(m.label.isEmpty ? '?' : m.label[0].toUpperCase()),
                ),
                label: Text(m.label),
                selected: task.assigneeIds.contains(m.userId),
                onSelected: canEdit
                    ? (on) => _toggleAssignee(context, ref, m.userId, on)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _TextField(
          fieldKey: const Key('detail-description'),
          value: docToMarkdown(task.description),
          enabled: canEdit,
          label: 'Description',
          multiline: true,
          onSave: (v) {
            if (v == docToMarkdown(task.description)) return;
            saveTask(
              context,
              ref,
              task,
              TaskPatch(description: markdownToDoc(v)),
            );
          },
        ),
      ],
    );
  }

  /// Who may be assigned: the project's members. An open project is every
  /// workspace member; a private one only its own members (none are offered
  /// until they have loaded, so nobody ineligible is ever shown).
  List<Member> _candidates(WidgetRef ref) {
    final everyone = ref.watch(membersProvider).value ?? const <Member>[];
    if (!project.isPrivate) return everyone;
    final inProject = {
      for (final m
          in ref.watch(projectMembersProvider(project.id)).value ??
              const <ProjectMember>[])
        m.userId,
    };
    return [
      for (final m in everyone)
        if (inProject.contains(m.userId)) m,
    ];
  }

  /// Built from the task as it is now, so two quick toggles both count.
  void _toggleAssignee(
    BuildContext context,
    WidgetRef ref,
    String userId,
    bool on,
  ) {
    final current = ref
        .read(taskListProvider(project.id))
        .tasks
        .where((t) => t.id == taskId)
        .firstOrNull;
    if (current == null) return;
    final others = [
      for (final id in current.assigneeIds)
        if (id != userId) id,
    ];
    saveTask(
      context,
      ref,
      current,
      TaskPatch(assigneeIds: on ? [...others, userId] : others),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final list = ref.read(taskListProvider(project.id).notifier);
    onClose?.call();
    if (onClose == null) Navigator.of(context).maybePop();
    try {
      await list.delete(task);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${task.displayId} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await list.restore(task);
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

/// The status of a task: only where the workflow lets it go (the current one is
/// always there). Until the workflow has loaded it shows the current status alone.
class _StatusPicker extends StatelessWidget {
  const _StatusPicker({
    required this.task,
    required this.workflow,
    required this.roleId,
    required this.enabled,
    required this.onPick,
  });

  final Task task;
  final Workflow? workflow;
  final String roleId;
  final bool enabled;
  final void Function(WorkflowStatus) onPick;

  @override
  Widget build(BuildContext context) {
    final flow = workflow;
    final options = flow == null
        ? [
            WorkflowStatus(
              id: task.statusId,
              name: task.statusName,
              category: task.statusCategory,
            ),
          ]
        : flow.targets(
            from: task.statusId,
            hasAssignee: task.assigneeIds.isNotEmpty,
            roleId: roleId,
          );
    return DropdownButtonFormField<String>(
      key: const Key('detail-status'),
      isExpanded: true,
      initialValue: task.statusId,
      decoration: const InputDecoration(labelText: 'Status'),
      items: [
        for (final s in options)
          DropdownMenuItem(
            value: s.id,
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: s.swatch),
                const SizedBox(width: 8),
                Flexible(child: Text(s.name, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: enabled && flow != null
          ? (id) {
              final target = flow.statusById(id ?? '');
              if (target != null && target.id != task.statusId) onPick(target);
            }
          : null,
    );
  }
}

/// A text field that saves when it loses focus (or on Enter for one line).
class _TextField extends StatefulWidget {
  const _TextField({
    required this.fieldKey,
    required this.value,
    required this.enabled,
    required this.label,
    required this.onSave,
    this.maxLength,
    this.multiline = false,
    this.allowEmpty = true,
  });

  final Key fieldKey;
  final String value;
  final bool enabled;
  final String label;
  final int? maxLength;
  final bool multiline;

  /// False for a required field: blanking it puts the old value back.
  final bool allowEmpty;
  final void Function(String) onSave;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  late var _saved = widget.value;

  /// Saves once per change: Enter and then losing focus must not send twice.
  void _commit(String text) {
    if (!widget.allowEmpty && text.trim().isEmpty) {
      _controller.text = widget.value;
      return;
    }
    if (text == _saved) return;
    _saved = text;
    widget.onSave(text);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(_TextField old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _saved = widget.value;
    // Someone else's value (or a rollback) replaces ours unless we are typing.
    if (!_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: widget.fieldKey,
    controller: _controller,
    focusNode: _focus,
    enabled: widget.enabled,
    maxLength: widget.maxLength,
    maxLines: widget.multiline ? 6 : 1,
    minLines: widget.multiline ? 3 : 1,
    decoration: InputDecoration(
      labelText: widget.label,
      counterText: '',
      border: const OutlineInputBorder(),
    ),
    onSubmitted: widget.multiline ? null : _commit,
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onPicked,
  });

  final Key fieldKey;
  final String label;
  final String value;
  final bool enabled;
  final void Function(String) onPicked;

  @override
  Widget build(BuildContext context) => InkWell(
    key: fieldKey,
    onTap: !enabled
        ? null
        : () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(value) ?? now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;
            onPicked(picked.toIso8601String().substring(0, 10));
          },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: value.isEmpty || !enabled
            ? const Icon(Icons.calendar_today, size: 18)
            : IconButton(
                tooltip: 'Clear $label',
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onPicked(''),
              ),
      ),
      child: Text(value.isEmpty ? '—' : value),
    ),
  );
}
