import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/imports/presentation/export_dialog.dart';
import 'package:taskforge/features/imports/presentation/import_wizard.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';

/// Import from Jira, ClickUp or CSV; what was imported before (with undo);
/// people waiting to be matched to members; and export.
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionSetProvider).can(Perm.dataManage);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import and export'),
        actions: [
          if (allowed)
            TextButton.icon(
              key: const Key('open-export'),
              onPressed: () => showExportDialog(context),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
        ],
      ),
      body: !allowed
          ? const Center(
              child: Text(
                'Only admins can import and export data.',
                key: Key('import-denied'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ImportWizardCard(),
                SizedBox(height: 24),
                ImportHistory(),
                SizedBox(height: 24),
                PlaceholdersPanel(),
              ],
            ),
    );
  }
}

/// Past imports, newest first.
class ImportHistory extends ConsumerWidget {
  const ImportHistory({super.key});

  Future<void> _run(
    BuildContext context,
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
    } on ImportException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(importErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(importJobsProvider);
    final actions = ref.read(importActionsProvider);
    return Column(
      key: const Key('import-history'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Past imports', style: Theme.of(context).textTheme.titleMedium),
        jobs.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Row(
            children: [
              Text(importErrorMessage(e)),
              TextButton(
                key: const Key('history-retry'),
                onPressed: () => ref.invalidate(importJobsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nothing imported yet.',
                    key: Key('history-empty'),
                  ),
                )
              : Column(
                  children: [
                    for (final job in list)
                      ListTile(
                        key: Key('job-${job.id}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(job.filename),
                        subtitle: Text(
                          '${job.kind?.label ?? job.source} · ${job.status}'
                          '${job.stat('tasks') > 0 ? ' · ${job.stat('tasks')} tasks' : ''}'
                          '${job.createdAt.length >= 10 ? ' · ${job.createdAt.substring(0, 10)}' : ''}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (job.canResume || job.status == 'analyzed')
                              TextButton(
                                key: Key('job-resume-${job.id}'),
                                onPressed: () => ref
                                    .read(importWizardProvider.notifier)
                                    .resume(job),
                                child: Text(
                                  job.canResume ? 'Resume' : 'Continue',
                                ),
                              ),
                            if (job.canUndo)
                              TextButton(
                                key: Key('job-undo-${job.id}'),
                                onPressed: () => _confirmUndo(
                                  context,
                                  () => _run(context, () => actions.undo(job)),
                                ),
                                child: const Text('Undo'),
                              ),
                            if (job.status == 'uploaded' ||
                                job.status == 'analyzed' ||
                                job.status == 'undone')
                              IconButton(
                                key: Key('job-discard-${job.id}'),
                                tooltip: 'Forget',
                                onPressed: () =>
                                    _run(context, () => actions.discard(job)),
                                icon: const Icon(Icons.delete_outline),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _confirmUndo(
    BuildContext context,
    Future<void> Function() undo,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('history-undo-dialog'),
        title: const Text('Undo this import?'),
        content: const Text(
          'This removes what it made. Anything you added by hand is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('history-undo-confirm'),
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Undo import'),
          ),
        ],
      ),
    );
    if (ok == true) await undo();
  }
}

/// People a file named who are not members: their tasks wait for them, and an
/// admin can hand them to a member now.
class PlaceholdersPanel extends ConsumerWidget {
  const PlaceholdersPanel({super.key});

  Future<void> _claim(
    BuildContext context,
    WidgetRef ref,
    WaitingPerson who,
  ) async {
    final members = await ref.read(membersProvider.future);
    if (!context.mounted) return;
    String? chosen;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          key: const Key('claim-dialog'),
          title: Text('Give ${who.name}\'s tasks to...'),
          content: DropdownButton<String>(
            key: const Key('claim-member'),
            isExpanded: true,
            value: chosen,
            hint: const Text('Choose a member'),
            items: [
              for (final m in members)
                DropdownMenuItem(
                  value: m.userId,
                  child: Text(m.displayName.isEmpty ? m.email : m.displayName),
                ),
            ],
            onChanged: (v) => setState(() => chosen = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('claim-confirm'),
              onPressed: chosen == null
                  ? null
                  : () => Navigator.pop(dialog, true),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || chosen == null) return;
    try {
      final n = await ref.read(importActionsProvider).claim(who, chosen!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned $n task${n == 1 ? '' : 's'}.')),
        );
      }
    } on ImportException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(importErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(placeholdersProvider).value ?? const [];
    if (people.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('placeholders'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'People waiting to join',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          'Their tasks are assigned automatically when someone joins with the '
          'same email.',
        ),
        for (final who in people)
          ListTile(
            key: Key('placeholder-${who.id}'),
            contentPadding: EdgeInsets.zero,
            title: Text(who.name),
            subtitle: Text(
              '${who.email.isEmpty ? 'no email' : who.email} · '
              '${who.tasks} task${who.tasks == 1 ? '' : 's'}',
            ),
            trailing: TextButton(
              key: Key('claim-${who.id}'),
              onPressed: () => _claim(context, ref, who),
              child: const Text('Assign to...'),
            ),
          ),
      ],
    );
  }
}
