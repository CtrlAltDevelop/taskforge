import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/features/shortcuts/application/action_groups.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show currentUserIdProvider;
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

Project? _project(ActionContext c) {
  final id = c.projectId;
  return id == null ? null : c.container.read(projectProvider(id));
}

bool _can(ActionContext c, String permission) {
  final project = _project(c);
  return project != null &&
      !project.isArchived &&
      c.container.read(permissionSetProvider).can(permission);
}

/// The task open on screen, read from the project's list.
Task? _task(ActionContext c) {
  final project = c.projectId;
  final id = c.taskId;
  if (project == null || id == null) return null;
  return c.container
      .read(taskListProvider(project))
      .tasks
      .where((t) => t.id == id)
      .firstOrNull;
}

void _say(ActionContext c, String message) {
  if (!c.context.mounted) return;
  ScaffoldMessenger.maybeOf(c.context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _save(ActionContext c, Task task, TaskPatch patch) async {
  try {
    await c.container
        .read(taskListProvider(task.projectId).notifier)
        .update(task, patch);
  } on TaskException catch (e) {
    _say(c, taskErrorMessage(e, c.context.mounted ? c.context.l10n : null));
  }
}

Future<void> _newTask(ActionContext c) async {
  final project = c.projectId;
  if (project == null) return;
  final title = await showDialog<String>(
    context: c.context,
    builder: (_) => const _TitleDialog(),
  );
  if (title == null || title.trim().isEmpty) return;
  try {
    await c.container
        .read(taskListProvider(project).notifier)
        .create(title.trim());
  } on TaskException catch (e) {
    _say(c, taskErrorMessage(e, c.context.mounted ? c.context.l10n : null));
  }
}

Future<void> _changeStatus(ActionContext c) async {
  final task = _task(c);
  if (task == null) return;
  final flow = await c.container.read(workflowProvider(task.projectId).future);
  if (!c.context.mounted) return;
  final options = flow.targets(
    from: task.statusId,
    hasAssignee: task.assigneeIds.isNotEmpty,
    roleId: c.container.read(permissionSetProvider).roleId,
  );
  final target = await showDialog<WorkflowStatus>(
    context: c.context,
    builder: (_) => SimpleDialog(
      title: Text(c.context.l10n.grpDStatusOf(task.displayId)),
      children: [
        for (final s in options)
          if (s.id != task.statusId)
            SimpleDialogOption(
              key: Key('status-option-${s.id}'),
              onPressed: () => Navigator.of(c.context).pop(s),
              child: Text(s.name),
            ),
      ],
    ),
  );
  if (target != null) await _save(c, task, TaskPatch(status: target));
}

Future<void> _assignMe(ActionContext c) async {
  final task = _task(c);
  if (task == null) return;
  final me = c.container.read(currentUserIdProvider);
  await _save(c, task, TaskPatch(assigneeIds: [...task.assigneeIds, me]));
}

Future<void> _timer(ActionContext c, Future<void> Function() act) async {
  try {
    await act();
  } on Object catch (e) {
    _say(c, timeErrorMessage(e, c.context.mounted ? c.context.l10n : null));
  }
}

bool _timeTracked(ActionContext c) =>
    _project(c)?.enabledFeatures.contains(timeFeature) ?? false;

TimeEntry? _running(ActionContext c) =>
    c.container.read(currentTimerProvider).value?.entry;

/// Asks the list to rename the row the cursor is on; the table listens.
final renameRequestProvider = NotifierProvider<RenameRequest, int>(
  RenameRequest.new,
);

class RenameRequest extends Notifier<int> {
  @override
  int build() => 0;

  void ask() => state++;
}

/// The actions that need a project or a task on screen: they are offered
/// only there (a task is on screen when the route carries `?task=`).
final List<AppAction> taskLevelActions = [
  AppAction(
    id: 'task.new',
    titleOf: (l) => l.grpKNewTask,
    groupOf: groupThisProject,
    semanticOf: (l) => l.grpKNewTaskSem,
    keywords: const ['add', 'create', 'todo'],
    defaultKeys: 'alt+n',
    available: (c) => _can(c, Perm.taskCreate),
    run: _newTask,
  ),
  AppAction(
    id: 'task.rename',
    titleOf: (l) => l.grpKRenameTask,
    groupOf: groupListView,
    semanticOf: (l) => l.grpKRenameTaskSem,
    keywords: const ['edit', 'title'],
    defaultKeys: 'f2',
    views: const {'list'},
    available: (c) => _can(c, Perm.taskUpdate),
    run: (c) => c.container.read(renameRequestProvider.notifier).ask(),
  ),
  AppAction(
    id: 'task.status',
    titleOf: (l) => l.grpKChangeStatus,
    groupOf: groupThisTask,
    semanticOf: (l) => l.grpKChangeStatusSem,
    keywords: const ['move', 'done', 'progress', 'workflow'],
    available: (c) => _can(c, Perm.taskUpdate) && _task(c) != null,
    run: _changeStatus,
  ),
  AppAction(
    id: 'task.assign_me',
    titleOf: (l) => l.grpKAssignMe,
    groupOf: groupThisTask,
    semanticOf: (l) => l.grpKAssignMeSem,
    keywords: const ['take', 'own', 'mine'],
    available: (c) {
      final task = _task(c);
      return _can(c, Perm.taskUpdate) &&
          task != null &&
          !task.assigneeIds.contains(c.container.read(currentUserIdProvider));
    },
    run: _assignMe,
  ),
  AppAction(
    id: 'timer.start',
    titleOf: (l) => l.grpKTimerStart,
    groupOf: groupThisTask,
    semanticOf: (l) => l.grpKTimerStartSem,
    keywords: const ['track', 'time', 'clock'],
    defaultKeys: 'alt+s',
    available: (c) {
      final task = _task(c);
      return _timeTracked(c) &&
          _can(c, Perm.timeLog) &&
          task != null &&
          _running(c)?.taskId != task.id;
    },
    run: (c) => _timer(c, () async {
      final task = _task(c);
      if (task == null) return;
      await c.container
          .read(timeActionsProvider)
          .start(task.projectId, task.id);
    }),
  ),
  AppAction(
    id: 'timer.stop',
    titleOf: (l) => l.grpKTimerStop,
    groupOf: groupGeneral,
    semanticOf: (l) => l.grpKTimerStopSem,
    keywords: const ['track', 'time', 'clock', 'pause'],
    defaultKeys: 'alt+shift+s',
    available: (c) => _running(c) != null,
    run: (c) => _timer(c, () async {
      await c.container.read(timeActionsProvider).stop();
    }),
  ),
];

class _TitleDialog extends StatefulWidget {
  const _TitleDialog();

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpDNewTask),
    content: TextField(
      key: const Key('new-task-title'),
      controller: _controller,
      autofocus: true,
      maxLength: maxTitleLength,
      decoration: InputDecoration(labelText: context.l10n.grpDTitle),
      onSubmitted: (v) => Navigator.of(context).pop(v),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.grpDCancel),
      ),
      FilledButton(
        key: const Key('new-task-create'),
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: Text(context.l10n.grpDCreate),
      ),
    ],
  );
}
