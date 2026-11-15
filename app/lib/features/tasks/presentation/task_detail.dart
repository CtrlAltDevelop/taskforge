import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/features/docs/presentation/related_docs_panel.dart';
import 'package:taskforge/features/goals/presentation/contributes_panel.dart';
import 'package:taskforge/features/attachments/presentation/attachments_section.dart';
import 'package:taskforge/features/time/domain/time.dart' show timeFeature;
import 'package:taskforge/features/time/presentation/time_section.dart';
import 'package:taskforge/features/comments/presentation/comments_section.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/tasks/presentation/presence_strip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/inbox/presentation/watch_button.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/recurrence/presentation/repeat_section.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/links_panel.dart';
import 'package:taskforge/features/tasks/presentation/subtask_dialogs.dart';
import 'package:taskforge/features/tasks/presentation/subtasks_panel.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/task_fields_panel.dart';
import 'package:taskforge/features/templates/presentation/template_dialogs.dart';
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
    this.onOpen,
  });

  final Project project;
  final String taskId;
  final VoidCallback? onClose;

  /// Opens another task (an ancestor in the breadcrumb, a subtask in the checklist).
  final void Function(Task)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref
        .watch(taskListProvider(project.id))
        .tasks
        .where((t) => t.id == taskId)
        .firstOrNull;
    if (task == null) {
      if (ref.watch(taskListProvider(project.id)).loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(context.l10n.grpDTaskNotFound, key: const Key('no-task')),
      );
    }
    final permissions = ref.watch(permissionSetProvider);
    final canEdit = !project.isArchived && permissions.can(Perm.taskUpdate);
    final canDelete = !project.isArchived && permissions.can(Perm.taskDelete);
    final canCreate = !project.isArchived && permissions.can(Perm.taskCreate);
    final tree = ref.watch(taskTreeProvider(project.id));
    final members = _candidates(ref);
    return ListView(
      key: const Key('task-detail'),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            PendingMark(id: task.id),
            Expanded(
              child: Text(
                task.displayId,
                key: const Key('detail-id'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            PresenceStrip(projectId: project.id, taskId: task.id),
            WatchButton(projectId: project.id, taskId: task.id),
            if (task.isBlocked) BlockedBadge(blockedBy: task.blockedBy),
            if (permissions.can(Perm.templateCreate))
              IconButton(
                key: const Key('save-task-template'),
                tooltip: context.l10n.tplSaveTask,
                icon: const Icon(Icons.copy_all_outlined),
                onPressed: () async {
                  final saved = await showSaveTemplateSheet(
                    context,
                    projectId: project.id,
                    taskId: task.id,
                    initialName: task.title,
                  );
                  if (saved != null && context.mounted) {
                    sayTemplates(context, context.l10n.tplSaved);
                  }
                },
              ),
            if (canDelete)
              IconButton(
                key: const Key('delete-task'),
                tooltip: context.l10n.grpDDeleteTask,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, task),
              ),
            if (onClose != null)
              IconButton(
                key: const Key('close-detail'),
                tooltip: context.l10n.grpDClose,
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
          ],
        ),
        Breadcrumb(
          chain: tree.breadcrumb(task.id),
          onOpen: (t) => onOpen?.call(t),
        ),
        _TextField(
          fieldKey: const Key('detail-title'),
          value: task.title,
          enabled: canEdit,
          maxLength: maxTitleLength,
          label: context.l10n.grpDTitle,
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
                  onPick: (s) => _pickStatus(context, ref, tree, task, s),
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
                  decoration: InputDecoration(
                    labelText: context.l10n.grpDPriority,
                  ),
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
                            Flexible(
                              child: Text(
                                p.labelIn(context.l10n),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                label: context.l10n.grpDStart,
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
                label: context.l10n.grpDDue,
                value: task.dueDate,
                enabled: canEdit,
                onPicked: (v) =>
                    saveTask(context, ref, task, TaskPatch(dueDate: v)),
              ),
            ),
          ],
        ),
        if (task.dueDate.isNotEmpty) ...[
          const SizedBox(height: 12),
          _TimeField(
            task: task,
            enabled: canEdit,
            onPicked: (utc) =>
                saveTask(context, ref, task, TaskPatch(dueTime: utc)),
          ),
        ],
        const SizedBox(height: 12),
        RepeatSection(task: task, canEdit: canEdit),
        const SizedBox(height: 16),
        Text(
          context.l10n.grpDAssignees,
          style: Theme.of(context).textTheme.labelLarge,
        ),
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
          label: context.l10n.grpDDescription,
          multiline: true,
          onFocusChanged: (focused) =>
              ref.read(presenceReporterProvider).setEditing(focused),
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
        EditingHint(taskId: task.id),
        const SizedBox(height: 16),
        TaskFieldsPanel(
          projectId: project.id,
          task: task,
          canEdit: canEdit,
          members: members,
        ),
        const SizedBox(height: 16),
        SubtasksPanel(
          project: project,
          task: task,
          canEdit: canEdit,
          canCreate: canCreate,
          onOpen: (t) => onOpen?.call(t),
        ),
        const SizedBox(height: 16),
        LinksPanel(
          project: project,
          task: task,
          canEdit: canEdit,
          onOpen: (link) {
            if (link.otherProjectId != project.id) {
              context.go(
                '/projects/${link.otherProjectId}?task=${link.otherId}',
              );
              return;
            }
            final other = ref
                .read(taskListProvider(project.id))
                .tasks
                .where((t) => t.id == link.otherId)
                .firstOrNull;
            if (other != null) onOpen?.call(other);
          },
        ),
        const SizedBox(height: 16),
        RelatedDocsPanel(
          projectId: project.id,
          taskId: task.id,
          canEdit: ref.watch(permissionSetProvider).can(Perm.docEdit),
        ),
        const SizedBox(height: 16),
        ContributesPanel(taskId: task.id),
        if (project.enabledFeatures.contains(timeFeature)) ...[
          const SizedBox(height: 16),
          const Divider(),
          TimeSection(
            key: ValueKey('time-${task.id}'),
            projectId: project.id,
            taskId: task.id,
            archived: project.isArchived,
          ),
        ],
        const SizedBox(height: 16),
        const Divider(),
        AttachmentsSection(
          key: ValueKey('attachments-${task.id}'),
          projectId: project.id,
          taskId: task.id,
          archived: project.isArchived,
        ),
        const SizedBox(height: 16),
        const Divider(),
        CommentsSection(
          key: ValueKey('comments-${task.id}'),
          projectId: project.id,
          taskId: task.id,
          archived: project.isArchived,
          isPrivate: project.isPrivate,
        ),
      ],
    );
  }

  /// Moving a task to a finished status while subtasks are open asks whether to
  /// finish them too; either way the workflow still has the last word.
  Future<void> _pickStatus(
    BuildContext context,
    WidgetRef ref,
    TaskTree tree,
    Task task,
    WorkflowStatus target,
  ) async {
    final open = tree.openBelow(task.id);
    if (target.category != StatusCategory.done || open == 0) {
      await saveTask(context, ref, task, TaskPatch(status: target));
      return;
    }
    final choice = await askCompleteSubtasks(context, task, open, target.name);
    if (choice == null || !context.mounted) return;
    if (choice == CompleteChoice.leave) {
      await saveTask(context, ref, task, TaskPatch(status: target));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final list = ref.read(taskListProvider(project.id).notifier);
    try {
      try {
        await list.moveWithSubtasks(task, target);
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.blocked) rethrow;
        if (!context.mounted || !await askOverride(context, e)) return;
        await list.moveWithSubtasks(task, target, overrideBlocked: true);
      }
    } on TaskException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
    }
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
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final list = ref.read(taskListProvider(project.id).notifier);
    final below =
        ref.read(taskTreeProvider(project.id)).subtreeIds(task.id).length - 1;
    DeleteMode? mode;
    if (below > 0) {
      mode = await askDeleteMode(context, task, below);
      if (mode == null || !context.mounted) return;
    }
    // Last, so cancelling an earlier question never stops a series.
    if (!await confirmDeleteTemplate(context, ref, task)) return;
    if (!context.mounted) return;
    onClose?.call();
    if (onClose == null) Navigator.of(context).maybePop();
    try {
      final moved = await list.delete(task, mode: mode);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.grpDTaskDeleted(task.displayId)),
            action: SnackBarAction(
              label: l10n.grpDUndo,
              onPressed: () async {
                try {
                  await list.restore(task, adopt: moved);
                } on TaskException catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(taskErrorMessage(e, l10n))),
                  );
                }
              },
            ),
          ),
        );
    } on TaskException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
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
      decoration: InputDecoration(labelText: context.l10n.grpDStatus),
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
    this.onFocusChanged,
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

  /// Told when the field gains or loses focus (someone typing in it).
  final void Function(bool focused)? onFocusChanged;

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
      widget.onFocusChanged?.call(_focus.hasFocus);
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
            final picked = await showAppDatePicker(
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
                tooltip: context.l10n.grpDClearField(label),
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onPicked(''),
              ),
      ),
      child: Text(value.isEmpty ? '—' : value),
    ),
  );
}

/// The optional time of day a task is due, read and picked on the viewer's
/// clock and stored in UTC (the due date never moves with it).
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.task,
    required this.enabled,
    required this.onPicked,
  });

  final Task task;
  final bool enabled;
  final void Function(String utc) onPicked;

  @override
  Widget build(BuildContext context) {
    final local = dueTimeLocal(task);
    return InkWell(
      key: const Key('detail-due-time'),
      onTap: !enabled
          ? null
          : () async {
              final now = TimeOfDay.now();
              final initial = local.isEmpty
                  ? now
                  : TimeOfDay(
                      hour: int.parse(local.substring(0, 2)),
                      minute: int.parse(local.substring(3)),
                    );
              final picked = await showTimePicker(
                context: context,
                initialTime: initial,
              );
              if (picked == null) return;
              onPicked(utcClock(task.dueDate, picked.hour, picked.minute));
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.grpDDueTime,
          border: const OutlineInputBorder(),
          suffixIcon: local.isEmpty || !enabled
              ? const Icon(Icons.schedule, size: 18)
              : IconButton(
                  key: const Key('clear-due-time'),
                  tooltip: context.l10n.grpDClearDueTime,
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onPicked(''),
                ),
        ),
        child: Text(local.isEmpty ? '—' : context.localDigits(local)),
      ),
    );
  }
}
