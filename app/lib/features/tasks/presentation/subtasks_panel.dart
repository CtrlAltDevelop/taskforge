import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/task_tree.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// `WEB-3 › WEB-9 › WEB-14`: where a task sits. Each ancestor opens that task.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.chain, required this.onOpen});

  /// The ancestors from the top down, then the task itself.
  final List<Task> chain;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext context) {
    if (chain.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Wrap(
      key: const Key('breadcrumb'),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, t) in chain.indexed) ...[
          if (i > 0) const Text(' › '),
          if (i == chain.length - 1)
            Text(isolateLtr(t.displayId), style: theme.textTheme.labelLarge)
          else
            InkWell(
              key: Key('crumb-${t.id}'),
              onTap: () => onOpen(t),
              child: Text(
                t.displayId,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// A small ring showing how much of a task's subtasks is done.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress});

  final Progress progress;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '${progress.done} of ${progress.total} subtasks done',
    child: SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.fraction,
            strokeWidth: 3,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          Text(
            '${progress.done}/${progress.total}',
            style: const TextStyle(fontSize: 8),
          ),
        ],
      ),
    ),
  );
}

/// The subtasks of one task as a checklist, with a field to add another.
class SubtasksPanel extends ConsumerWidget {
  const SubtasksPanel({
    super.key,
    required this.project,
    required this.task,
    required this.canEdit,
    required this.canCreate,
    required this.onOpen,
  });

  final Project project;
  final Task task;
  final bool canEdit;
  final bool canCreate;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(taskTreeProvider(project.id));
    final flow = ref.watch(workflowProvider(project.id)).value;
    final children = tree.childrenOf(task.id);
    final progress = tree.progressOf(task.id);
    final tooDeep = task.depth + 1 >= softDepthLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.grpFSubtasks,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 8),
            if (!progress.isEmpty)
              Text(
                '${progress.done}/${progress.total}',
                key: const Key('subtasks-progress'),
              ),
          ],
        ),
        if (!progress.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: LinearProgressIndicator(
              key: const Key('subtasks-bar'),
              value: progress.fraction,
            ),
          ),
        for (final child in children)
          CheckboxListTile(
            key: Key('subtask-${child.id}'),
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            value: child.statusCategory == StatusCategory.done,
            onChanged: canEdit && flow != null
                ? (checked) =>
                      _toggle(context, ref, flow, child, checked ?? false)
                : null,
            title: GestureDetector(
              key: Key('open-subtask-${child.id}'),
              onTap: () => onOpen(child),
              child: Text(
                '${child.displayId}  ${child.title}',
                style: child.statusCategory == StatusCategory.done
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
            ),
          ),
        if (canCreate && !project.isArchived)
          tooDeep
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    context.l10n.grpFSubtaskDepthLimit,
                    key: const Key('subtask-depth-limit'),
                  ),
                )
              : AddSubtaskField(projectId: project.id, parentId: task.id),
      ],
    );
  }

  /// Ticking finishes the subtask (the workflow's first done status); unticking
  /// sends it back to where new tasks start.
  void _toggle(
    BuildContext context,
    WidgetRef ref,
    Workflow flow,
    Task child,
    bool checked,
  ) {
    final target = checked
        ? flow.statuses
              .where((s) => s.category == StatusCategory.done)
              .firstOrNull
        : flow.defaultStatus;
    if (target == null || target.id == child.statusId) return;
    saveTask(context, ref, child, TaskPatch(status: target));
  }
}

/// One field: Enter adds a subtask under [parentId].
class AddSubtaskField extends ConsumerStatefulWidget {
  const AddSubtaskField({
    super.key,
    required this.projectId,
    required this.parentId,
    this.autofocus = false,
    this.onDone,
  });

  final String projectId;
  final String parentId;
  final bool autofocus;

  /// Called after a subtask was added, or the field was dismissed empty.
  final VoidCallback? onDone;

  @override
  ConsumerState<AddSubtaskField> createState() => _AddSubtaskFieldState();
}

class _AddSubtaskFieldState extends ConsumerState<AddSubtaskField> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    final title = value.trim();
    if (title.isEmpty) {
      widget.onDone?.call();
      return;
    }
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    // Everything is read before the await: the panel may be closed meanwhile.
    final list = ref.read(taskListProvider(widget.projectId).notifier);
    final collapsed = ref.read(
      collapsedTasksProvider(widget.projectId).notifier,
    );
    final onDone = widget.onDone;
    final parentId = widget.parentId;
    setState(() => _busy = true);
    try {
      await list.create(title, parentId: parentId);
      collapsed.expand(parentId);
      if (mounted) _controller.clear();
      onDone?.call();
    } on TaskException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(e, l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: TextField(
      key: Key('add-subtask-${widget.parentId}'),
      controller: _controller,
      enabled: !_busy,
      autofocus: widget.autofocus,
      maxLength: maxTitleLength,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: context.l10n.grpFAddSubtaskHint,
        prefixIcon: const Icon(Icons.subdirectory_arrow_right),
        counterText: '',
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onSubmitted: _submit,
    ),
  );
}
