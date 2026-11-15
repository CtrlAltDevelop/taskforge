import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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
      appBar: TfAppBar(
        title: Text(context.l10n.grpCImpTitle),
        actions: [
          if (allowed)
            TextButton.icon(
              key: const Key('open-export'),
              onPressed: () => showExportDialog(context),
              icon: const Icon(Icons.download),
              label: Text(context.l10n.grpCImpExport),
            ),
        ],
      ),
      body: !allowed
          ? Center(
              child: Text(
                context.l10n.grpCImpDenied,
                key: const Key('import-denied'),
              ),
            )
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ImportWizardCard(),
                  SizedBox(height: 24),
                  ImportHistory(),
                  SizedBox(height: 24),
                  PlaceholdersPanel(),
                ],
              ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(importErrorMessage(e, context.l10n))),
        );
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
        Text(
          context.l10n.grpCImpPast,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        jobs.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Row(
            children: [
              Text(importErrorMessage(e, context.l10n)),
              TextButton(
                key: const Key('history-retry'),
                onPressed: () => ref.invalidate(importJobsProvider),
                child: Text(context.l10n.grpCRetry),
              ),
            ],
          ),
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.l10n.grpCImpNothing,
                    key: const Key('history-empty'),
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
                          '${job.kind?.labelIn(context.l10n) ?? job.source} · ${job.status}'
                          '${job.stat('tasks') > 0 ? ' · ${context.l10n.grpCImpTasksCount(job.stat('tasks'))}' : ''}'
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
                                  job.canResume
                                      ? context.l10n.grpCImpResume
                                      : context.l10n.grpCImpContinue,
                                ),
                              ),
                            if (job.canUndo)
                              TextButton(
                                key: Key('job-undo-${job.id}'),
                                onPressed: () => _confirmUndo(
                                  context,
                                  () => _run(context, () => actions.undo(job)),
                                ),
                                child: Text(context.l10n.grpCUndo),
                              ),
                            if (job.status == 'uploaded' ||
                                job.status == 'analyzed' ||
                                job.status == 'undone')
                              IconButton(
                                key: Key('job-discard-${job.id}'),
                                tooltip: context.l10n.grpCImpForget,
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
        title: Text(dialog.l10n.grpCImpUndoTitle),
        content: Text(dialog.l10n.grpCImpUndoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(dialog.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('history-undo-confirm'),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(dialog.l10n.grpCImpUndoConfirm),
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
          title: Text(context.l10n.grpCImpClaimTitle(who.name)),
          content: DropdownButton<String>(
            key: const Key('claim-member'),
            isExpanded: true,
            value: chosen,
            hint: Text(context.l10n.grpCImpChooseMember),
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
              child: Text(dialog.l10n.grpCCancel),
            ),
            FilledButton(
              key: const Key('claim-confirm'),
              onPressed: chosen == null
                  ? null
                  : () => Navigator.pop(dialog, true),
              child: Text(context.l10n.grpCImpAssign),
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
          SnackBar(content: Text(context.l10n.grpCImpAssigned(n))),
        );
      }
    } on ImportException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(importErrorMessage(e, context.l10n))),
        );
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
          context.l10n.grpCImpWaiting,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(context.l10n.grpCImpWaitingBody),
        for (final who in people)
          ListTile(
            key: Key('placeholder-${who.id}'),
            contentPadding: EdgeInsets.zero,
            title: Text(who.name),
            subtitle: Text(
              context.l10n.grpCImpPersonSub(
                who.email.isEmpty ? context.l10n.grpCImpNoEmail : who.email,
                who.tasks,
              ),
            ),
            trailing: TextButton(
              key: Key('claim-${who.id}'),
              onPressed: () => _claim(context, ref, who),
              child: Text(context.l10n.grpCImpAssignTo),
            ),
          ),
      ],
    );
  }
}
