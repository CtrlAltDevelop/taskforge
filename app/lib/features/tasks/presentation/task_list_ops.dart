part of 'task_list.dart';

mixin _TaskListOps on ConsumerState<TaskListView> {
  /// The task whose inline "add subtask" field is open.
  String? _addingUnder;

  Project get project => widget.project;

  Future<void> _moveCard(
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref
          .read(taskListProvider(project.id).notifier)
          .moveCard(
            ref.read(boardClientProvider),
            task,
            groupBy: groupBy,
            column: column,
            beforeId: beforeId,
            afterId: afterId,
          );
    } on TaskException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
    }
  }

  Future<void> _act(TaskAction action, TaskTree tree, Task task) async {
    switch (action) {
      case TaskAction.addSubtask:
        ref.read(collapsedTasksProvider(project.id).notifier).expand(task.id);
        if (widget.wide) {
          // Table rows have a fixed height: the field opens in a dialog.
          await showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: Text(dialog.l10n.grpFAddSubtaskTo(task.displayId)),
              content: SizedBox(
                width: 360,
                child: AddSubtaskField(
                  projectId: project.id,
                  parentId: task.id,
                  autofocus: true,
                  onDone: () => Navigator.pop(dialog),
                ),
              ),
            ),
          );
        } else {
          setState(() => _addingUnder = task.id);
        }
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
    final l10n = context.l10n;
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
        ..showSnackBar(SnackBar(content: Text(taskErrorMessage(e, l10n))));
    }
  }

  Future<void> _delete(TaskTree tree, Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final list = ref.read(taskListProvider(project.id).notifier);
    final below = tree.subtreeIds(task.id).length - 1;
    DeleteMode? mode;
    if (below > 0) {
      mode = await askDeleteMode(context, task, below);
      if (mode == null || !mounted) return;
    }
    // Last, so cancelling an earlier question never stops a series.
    if (!await confirmDeleteTemplate(context, ref, task) || !mounted) return;
    try {
      final moved = await list.delete(task, mode: mode);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.grpFTaskDeleted(task.displayId)),
            action: SnackBarAction(
              label: l10n.grpFUndo,
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
