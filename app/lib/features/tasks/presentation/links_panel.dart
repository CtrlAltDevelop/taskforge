import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

IconData linkIcon(LinkKind kind) => switch (kind) {
  LinkKind.blocks => TfIcons.blocked.glyph,
  LinkKind.blockedBy => TfIcons.lock.glyph,
  LinkKind.relates => TfIcons.link.glyph,
  LinkKind.duplicates || LinkKind.duplicatedBy => TfIcons.copy.glyph,
};

/// The "Links" section of a task: its links grouped by kind, seen from both
/// sides, with add and remove for people who may edit.
class LinksPanel extends ConsumerWidget {
  const LinksPanel({
    super.key,
    required this.project,
    required this.task,
    required this.canEdit,
    this.onOpen,
  });

  final Project project;
  final Task task;
  final bool canEdit;
  final void Function(TaskLink link)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(taskLinksProvider(task.id));
    final theme = Theme.of(context);
    return Column(
      key: const Key('links-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.grpFLinks, style: theme.textTheme.titleSmall),
            const Spacer(),
            if (canEdit)
              IconButton(
                key: const Key('add-link'),
                tooltip: context.l10n.grpFAddLink,
                icon: const TfIcon(TfIcons.link),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AddLinkDialog(project: project, task: task),
                ),
              ),
          ],
        ),
        links.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => TfError(
            compact: true,
            message: taskErrorMessage(e, context.l10n),
            details: '$e',
            retryKey: const Key('retry-links'),
            onRetry: () => ref.invalidate(taskLinksProvider(task.id)),
          ),
          data: (items) => items.isEmpty
              ? Text(context.l10n.grpFNoLinks, key: const Key('no-links'))
              : _Groups(
                  items: items,
                  canEdit: canEdit,
                  onOpen: onOpen,
                  onRemove: (link) => _remove(context, ref, link),
                ),
        ),
      ],
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    TaskLink link,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    try {
      await ref
          .read(tasksClientProvider)
          .removeLink(workspace, task.id, link.id);
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(taskErrorMessage(mapTaskError(e), l10n))),
      );
      return;
    }
    ref.invalidate(taskLinksProvider(task.id));
    await ref.read(taskListProvider(project.id).notifier).refresh();
  }
}

class _Groups extends StatelessWidget {
  const _Groups({
    required this.items,
    required this.canEdit,
    required this.onOpen,
    required this.onRemove,
  });

  final List<TaskLink> items;
  final bool canEdit;
  final void Function(TaskLink link)? onOpen;
  final void Function(TaskLink) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final kind in LinkKind.values)
          if (items.any((l) => l.kind == kind)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                kind.labelIn(context.l10n),
                style: theme.textTheme.labelMedium,
              ),
            ),
            for (final link in items.where((l) => l.kind == kind))
              ListTile(
                key: Key('link-${link.id}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(linkIcon(kind), size: 18),
                title: Text(
                  link.otherLabel,
                  style: link.restricted
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : link.otherDone
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                subtitle: link.restricted ? null : Text(link.otherStatusName),
                onTap: link.restricted || onOpen == null
                    ? null
                    : () => onOpen!(link),
                trailing: canEdit
                    ? IconButton(
                        key: Key('remove-link-${link.id}'),
                        tooltip: context.l10n.grpFRemoveLink,
                        icon: const TfIcon(TfIcons.close, size: 18),
                        onPressed: () => onRemove(link),
                      )
                    : null,
              ),
          ],
      ],
    );
  }
}

/// Pick a kind and a task of this project, then link. A refusal (a loop, a
/// repeat) is shown in the dialog so the choice can be changed.
class AddLinkDialog extends ConsumerStatefulWidget {
  const AddLinkDialog({super.key, required this.project, required this.task});

  final Project project;
  final Task task;

  @override
  ConsumerState<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends ConsumerState<AddLinkDialog> {
  LinkKind _kind = LinkKind.blocks;
  List<LinkCandidate> _results = const [];
  LinkCandidate? _picked;
  bool _closeDuplicate = false;
  bool _busy = false;
  bool _searching = true;
  String? _error;
  int _searchId = 0;

  bool get _isDuplicate =>
      _kind == LinkKind.duplicates || _kind == LinkKind.duplicatedBy;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  /// Asks the server (tasks of every project you can open); an answer that
  /// arrives after a newer search was started is dropped.
  Future<void> _search(String query) async {
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    final id = ++_searchId;
    setState(() => _searching = true);
    try {
      final found = await ref
          .read(tasksClientProvider)
          .searchTasks(workspace, query);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = [
          for (final t in found)
            if (t.id != widget.task.id) t,
        ];
        _searching = false;
      });
    } on Object catch (e) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _searching = false;
        _error = taskErrorMessage(mapTaskError(e), context.l10n);
      });
    }
  }

  Future<void> _submit() async {
    final other = _picked;
    final workspace = ref.read(workspaceScopeProvider);
    if (other == null || workspace == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(tasksClientProvider)
          .addLink(
            workspace,
            widget.task.id,
            other.id,
            _kind,
            closeDuplicate: _isDuplicate && _closeDuplicate,
          );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = taskErrorMessage(mapTaskError(e), context.l10n);
      });
      return;
    }
    ref.invalidate(taskLinksProvider(widget.task.id));
    await ref.read(taskListProvider(widget.project.id).notifier).refresh();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.grpFAddLink),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<LinkKind>(
              key: const Key('link-kind'),
              value: _kind,
              isExpanded: true,
              items: [
                for (final k in LinkKind.values)
                  DropdownMenuItem(
                    value: k,
                    child: Text(k.labelIn(context.l10n)),
                  ),
              ],
              onChanged: _busy ? null : (k) => setState(() => _kind = k!),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('link-search'),
              decoration: InputDecoration(
                prefixIcon: const TfIcon(TfIcons.search),
                hintText: context.l10n.grpFLinkSearchHint,
              ),
              onChanged: _search,
            ),
            SizedBox(
              height: 200,
              child: _searching && _results.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        for (final t in _results)
                          ListTile(
                            key: Key('pick-${t.id}'),
                            dense: true,
                            selected: _picked?.id == t.id,
                            title: Text('${t.displayId} ${t.title}'),
                            subtitle: Text(t.statusName),
                            onTap: () => setState(() => _picked = t),
                          ),
                      ],
                    ),
            ),
            if (_isDuplicate)
              CheckboxListTile(
                key: const Key('close-duplicate'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.grpFCloseDuplicate),
                value: _closeDuplicate,
                onChanged: (v) => setState(() => _closeDuplicate = v ?? false),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  key: const Key('link-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const Key('link-submit'),
          onPressed: _picked == null || _busy ? null : _submit,
          child: Text(context.l10n.grpFLinkAction),
        ),
      ],
    );
  }
}
