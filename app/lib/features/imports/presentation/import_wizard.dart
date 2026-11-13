import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/imports/presentation/import_io.dart';
import 'package:taskforge/features/imports/presentation/mapping_step.dart';
import 'package:taskforge/features/imports/presentation/problems_list.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String _stepName(AppLocalizations l, ImportStep step) => switch (step) {
  ImportStep.source => l.grpCImpStepSource,
  ImportStep.upload => l.grpCImpStepUpload,
  ImportStep.map => l.grpCImpStepMap,
  ImportStep.review => l.grpCImpStepReview,
  ImportStep.run => l.grpCImpStepImport,
};

/// Source, Upload, Map, Review, Import: one step on screen at a time, each
/// asking the server before it moves on.
class ImportWizardCard extends ConsumerWidget {
  const ImportWizardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(importWizardProvider);
    return Card(
      key: const Key('import-wizard'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final step in ImportStep.values)
                  ChoiceChip(
                    key: Key('step-${step.name}'),
                    label: Text(
                      '${step.index + 1}. ${_stepName(context.l10n, step)}',
                    ),
                    selected: step == wizard.step,
                    onSelected: null,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (wizard.busy)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(key: Key('import-busy')),
              ),
            if (wizard.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  wizard.error!,
                  key: const Key('import-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            switch (wizard.step) {
              ImportStep.source => const _SourceStep(),
              ImportStep.upload => const _UploadStep(),
              ImportStep.map => const MappingStep(),
              ImportStep.review => const _ReviewStep(),
              ImportStep.run => const _RunStep(),
            },
          ],
        ),
      ),
    );
  }
}

class _SourceStep extends ConsumerWidget {
  const _SourceStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosen = ref.watch(importWizardProvider.select((w) => w.source));
    final wizard = ref.read(importWizardProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.grpCImpWhere,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<ImportSource?>(
          groupValue: chosen,
          onChanged: (s) => ref.read(importWizardProvider.notifier).select(s),
          child: Column(
            children: [
              RadioListTile<ImportSource?>(
                key: const Key('source-auto'),
                title: Text(context.l10n.grpCImpAuto),
                value: null,
              ),
              for (final s in ImportSource.values)
                RadioListTile<ImportSource?>(
                  key: Key('source-${s.wire}'),
                  title: Text(s.label),
                  value: s,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton(
            key: const Key('source-next'),
            onPressed: () => wizard.chooseSource(chosen),
            child: Text(context.l10n.grpCImpNext),
          ),
        ),
      ],
    );
  }
}

class _UploadStep extends ConsumerWidget {
  const _UploadStep();

  Future<void> _pick(WidgetRef ref) async {
    final picked = await ref.read(importPickerProvider)();
    if (picked == null) return;
    await ref
        .read(importWizardProvider.notifier)
        .upload(
          filename: picked.name,
          stream: picked.open(),
          size: picked.size,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(importWizardProvider.select((w) => w.busy));
    final source = ref.watch(importWizardProvider.select((w) => w.source));
    final choices = ref.watch(importWizardProvider.select((w) => w.choices));
    if (choices.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.grpCImpZipSeveral),
          DropdownButton<String>(
            key: const Key('upload-member'),
            isExpanded: true,
            hint: Text(context.l10n.grpCImpChooseAFile),
            items: [
              for (final m in choices)
                DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: busy
                ? null
                : (m) {
                    if (m != null) {
                      ref.read(importWizardProvider.notifier).chooseMember(m);
                    }
                  },
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source == null
              ? context.l10n.grpCImpChooseGeneric
              : context.l10n.grpCImpChooseSource(source.label),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.grpCImpSentNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              key: const Key('upload-back'),
              onPressed: busy
                  ? null
                  : ref.read(importWizardProvider.notifier).back,
              child: Text(context.l10n.grpCBack),
            ),
            const Spacer(),
            FilledButton.icon(
              key: const Key('import-pick'),
              onPressed: busy ? null : () => _pick(ref),
              icon: const Icon(Icons.upload_file),
              label: Text(context.l10n.grpCImpPickFile),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final report = wizard.report;
    final resuming = wizard.job?.canResume ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resuming
              ? context.l10n.grpCImpResumeThis
              : context.l10n.grpCImpWhatHappens,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (report != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            key: const Key('review-counts'),
            children: [
              for (final e in _countLabels(context.l10n).entries)
                if (report.count(e.key) > 0)
                  Text('${report.count(e.key)} ${e.value}'),
            ],
          ),
          if (report.alreadyImported > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.grpCImpAlready(report.alreadyImported),
                key: const Key('review-already'),
              ),
            ),
          if (report.errors > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.grpCImpRowErrors(report.errors),
                key: const Key('review-errors'),
              ),
            ),
          ProblemsList(
            key: const Key('review-warnings'),
            problems: report.warnings,
            total: report.errors + report.warningTotal,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              key: const Key('review-back'),
              onPressed: wizard.busy ? null : notifier.back,
              child: Text(context.l10n.grpCBack),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('import-start'),
              onPressed: wizard.busy ? null : notifier.start,
              child: Text(
                resuming
                    ? context.l10n.grpCImpResumeImport
                    : context.l10n.grpCImpStart,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Map<String, String> _countLabels(AppLocalizations l) => {
  'tasks': l.grpCImpCountTasks,
  'subtasks': l.grpCImpCountSubtasks,
  'comments': l.grpCImpCountComments,
  'links': l.grpCImpCountLinks,
  'sprints': l.grpCImpCountSprints,
  'labels': l.grpCImpCountLabels,
  'new_statuses': l.grpCImpCountStatuses,
  'placeholders': l.grpCImpCountPlaceholders,
};

class _RunStep extends ConsumerWidget {
  const _RunStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(importWizardProvider);
    final started = wizard.job;
    if (started == null) return const SizedBox.shrink();
    final live = ref.watch(importProgressProvider(started.id)).value;
    // The streamed job is newer than the one Start answered with, unless the
    // wizard itself just changed it (cancel, undo).
    final job = (live != null && live.version >= started.version)
        ? live
        : started;
    return _Run(job: job);
  }
}

class _Run extends ConsumerWidget {
  const _Run({required this.job});

  final ImportJob job;

  Future<void> _undo(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('undo-dialog'),
        title: Text(dialog.l10n.grpCImpUndoTitle),
        content: Text(dialog.l10n.grpCImpUndoRunBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(dialog.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('undo-confirm'),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(dialog.l10n.grpCImpUndoConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(importWizardProvider.notifier).undo();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(importWizardProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const Key('import-run'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.isActive ||
            job.status == 'uploaded' ||
            job.status == 'analyzed') ...[
          LinearProgressIndicator(
            key: const Key('import-progress'),
            value: job.total == 0 ? null : job.progress,
          ),
          const SizedBox(height: 8),
          Text(
            job.status == 'queued'
                ? context.l10n.grpCImpWaitingStart
                : job.phase == 'links'
                ? context.l10n.grpCImpLinking
                : context.l10n.grpCImpProgress(job.done, job.total),
            key: const Key('import-progress-text'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton(
              key: const Key('import-cancel'),
              onPressed: notifier.cancel,
              child: Text(context.l10n.grpCImpCancel),
            ),
          ),
        ] else ...[
          Text(
            switch (job.status) {
              'done' => context.l10n.grpCImpFinished,
              'undone' => context.l10n.grpCImpUndone,
              'cancelled' => context.l10n.grpCImpCancelled,
              _ => context.l10n.grpCImpStopped,
            },
            key: const Key('import-result'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (job.error.isNotEmpty)
            Text(
              job.error,
              key: const Key('import-failure'),
              style: TextStyle(color: scheme.error),
            ),
          const SizedBox(height: 4),
          _Stats(job: job),
          const SizedBox(height: 8),
          ImportProblems(jobId: job.id, count: job.problemCount),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (job.status == 'done' && job.projectId.isNotEmpty)
                FilledButton(
                  key: const Key('import-open-project'),
                  onPressed: () => context.go('/projects/${job.projectId}'),
                  child: Text(context.l10n.grpCImpOpenProject),
                ),
              if (job.canResume)
                FilledButton(
                  key: const Key('import-resume'),
                  onPressed: notifier.start,
                  child: Text(context.l10n.grpCImpResume),
                ),
              if (job.canUndo)
                OutlinedButton(
                  key: const Key('import-undo'),
                  onPressed: () => _undo(context, ref),
                  child: Text(context.l10n.grpCUndo),
                ),
              TextButton(
                key: const Key('import-another'),
                onPressed: notifier.restart,
                child: Text(context.l10n.grpCImpAnother),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.job});

  final ImportJob job;

  @override
  Widget build(BuildContext context) {
    final undone = job.stats['undone'];
    final l10n = context.l10n;
    final lines = <String>[
      if (undone is Map<String, dynamic>)
        ((undone['kept'] as num?) ?? 0) > 0
            ? l10n.grpCImpRemovedKept(
                (undone['tasks'] as num?) ?? 0,
                undone['kept'] as num,
              )
            : l10n.grpCImpRemoved((undone['tasks'] as num?) ?? 0)
      else ...[
        for (final e in _countLabels(l10n).entries)
          if (job.stat(e.key) > 0 && e.key != 'subtasks')
            '${job.stat(e.key)} ${e.value}',
      ],
    ];
    return Text(lines.join(' · '), key: const Key('import-stats'));
  }
}
