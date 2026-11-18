import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
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
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

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
            TfButton(
              key: const Key('open-export'),
              label: context.l10n.grpCImpExport,
              variant: TfButtonVariant.ghost,
              icon: TfIcons.download,
              onPressed: () => showExportDialog(context),
            ),
        ],
      ),
      body: !allowed
          ? TfEmpty(
              key: const Key('import-denied'),
              illustration: TfIllustrationKind.noAccess,
              title: context.l10n.grpCImpDenied,
            )
          : TfPage(
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
          error: (e, _) => TfError(
            compact: true,
            message: importErrorMessage(e, context.l10n),
            details: '$e',
            retryKey: const Key('history-retry'),
            onRetry: () => ref.invalidate(importJobsProvider),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: TfSpace.xs,
                        ),
                        child: TfPanel(
                          padding: EdgeInsets.zero,
                          child: TfRow(
                            key: Key('job-${job.id}'),
                            title: job.filename,
                            subtitle:
                                '${job.kind?.labelIn(context.l10n) ?? job.source} · ${job.status}'
                                '${job.stat('tasks') > 0 ? ' · ${context.l10n.grpCImpTasksCount(job.stat('tasks'))}' : ''}'
                                '${job.createdAt.length >= 10 ? ' · ${job.createdAt.substring(0, 10)}' : ''}',
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                if (job.canResume || job.status == 'analyzed')
                                  TfButton(
                                    key: Key('job-resume-${job.id}'),
                                    label: job.canResume
                                        ? context.l10n.grpCImpResume
                                        : context.l10n.grpCImpContinue,
                                    variant: TfButtonVariant.ghost,
                                    onPressed: () => ref
                                        .read(importWizardProvider.notifier)
                                        .resume(job),
                                  ),
                                if (job.canUndo)
                                  TfButton(
                                    key: Key('job-undo-${job.id}'),
                                    label: context.l10n.grpCUndo,
                                    variant: TfButtonVariant.ghost,
                                    onPressed: () => _confirmUndo(
                                      context,
                                      () => _run(
                                        context,
                                        () => actions.undo(job),
                                      ),
                                    ),
                                  ),
                                if (job.status == 'uploaded' ||
                                    job.status == 'analyzed' ||
                                    job.status == 'undone')
                                  TfIconButton(
                                    key: Key('job-discard-${job.id}'),
                                    icon: TfIcons.trash,
                                    tooltip: context.l10n.grpCImpForget,
                                    onPressed: () => _run(
                                      context,
                                      () => actions.discard(job),
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
      builder: (dialog) => TfDialogFrame(
        key: const Key('history-undo-dialog'),
        title: dialog.l10n.grpCImpUndoTitle,
        content: Text(dialog.l10n.grpCImpUndoBody),
        actions: [
          TfButton(
            label: dialog.l10n.grpCCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.pop(dialog, false),
          ),
          TfButton(
            key: const Key('history-undo-confirm'),
            label: dialog.l10n.grpCImpUndoConfirm,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.pop(dialog, true),
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
        builder: (context, setState) => TfDialogFrame(
          key: const Key('claim-dialog'),
          title: context.l10n.grpCImpClaimTitle(who.name),
          content: TfSelectField(
            key: const Key('claim-member'),
            options: {
              for (final m in members)
                m.userId: m.displayName.isEmpty ? m.email : m.displayName,
            },
            value: chosen,
            onChanged: (v) => setState(() => chosen = v),
            hint: context.l10n.grpCImpChooseMember,
            expand: true,
          ),
          actions: [
            TfButton(
              label: dialog.l10n.grpCCancel,
              variant: TfButtonVariant.ghost,
              onPressed: () => Navigator.pop(dialog, false),
            ),
            TfButton(
              key: const Key('claim-confirm'),
              label: context.l10n.grpCImpAssign,
              variant: TfButtonVariant.primary,
              onPressed: chosen == null
                  ? null
                  : () => Navigator.pop(dialog, true),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: TfPanel(
              padding: EdgeInsets.zero,
              child: TfRow(
                key: Key('placeholder-${who.id}'),
                title: who.name,
                subtitle: context.l10n.grpCImpPersonSub(
                  who.email.isEmpty ? context.l10n.grpCImpNoEmail : who.email,
                  who.tasks,
                ),
                trailing: TfButton(
                  key: Key('claim-${who.id}'),
                  label: context.l10n.grpCImpAssignTo,
                  variant: TfButtonVariant.ghost,
                  onPressed: () => _claim(context, ref, who),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
