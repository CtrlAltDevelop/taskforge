import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/imports/presentation/import_io.dart';
import 'package:taskforge/features/imports/presentation/mapping_step.dart';
import 'package:taskforge/features/imports/presentation/problems_list.dart';

const _stepNames = {
  ImportStep.source: 'Source',
  ImportStep.upload: 'Upload',
  ImportStep.map: 'Map',
  ImportStep.review: 'Review',
  ImportStep.run: 'Import',
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
                    label: Text('${step.index + 1}. ${_stepNames[step]}'),
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
          'Where is your data coming from?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RadioGroup<ImportSource?>(
          groupValue: chosen,
          onChanged: (s) => ref.read(importWizardProvider.notifier).select(s),
          child: Column(
            children: [
              const RadioListTile<ImportSource?>(
                key: Key('source-auto'),
                title: Text('I am not sure: work it out from the file'),
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
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const Key('source-next'),
            onPressed: () => wizard.chooseSource(chosen),
            child: const Text('Next'),
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
          const Text(
            'This zip holds several data files. Which one do you want to '
            'import? (A workspace export has one per project.)',
          ),
          DropdownButton<String>(
            key: const Key('upload-member'),
            isExpanded: true,
            hint: const Text('Choose a file'),
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
              ? 'Choose the file to import (.csv, .json, or a .zip of one).'
              : 'Choose your ${source.label} file (.csv, .json, or a .zip of one).',
        ),
        const SizedBox(height: 4),
        Text(
          'The file is sent to your TaskForge server and read as a stream, so '
          'large exports are fine. Nothing is changed until you confirm.',
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
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton.icon(
              key: const Key('import-pick'),
              onPressed: busy ? null : () => _pick(ref),
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose file'),
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
          resuming ? 'Resume this import' : 'This is what will happen',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (report != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            key: const Key('review-counts'),
            children: [
              for (final e in _countLabels.entries)
                if (report.count(e.key) > 0)
                  Text('${report.count(e.key)} ${e.value}'),
            ],
          ),
          if (report.alreadyImported > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${report.alreadyImported} of these were imported before and '
                'will be skipped, not duplicated.',
                key: const Key('review-already'),
              ),
            ),
          if (report.errors > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${report.errors} row(s) cannot be imported and will be left '
                'out.',
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
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('import-start'),
              onPressed: wizard.busy ? null : notifier.start,
              child: Text(resuming ? 'Resume import' : 'Start import'),
            ),
          ],
        ),
      ],
    );
  }
}

const _countLabels = {
  'tasks': 'tasks',
  'subtasks': 'of them sub-tasks',
  'comments': 'comments',
  'links': 'links',
  'sprints': 'sprints',
  'labels': 'labels',
  'new_statuses': 'new statuses',
  'placeholders': 'people to wait for',
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
        title: const Text('Undo this import?'),
        content: const Text(
          'This removes the tasks, comments, links, sprints and statuses '
          'this import made. Anything you added to them by hand is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('undo-confirm'),
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Undo import'),
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
                ? 'Waiting to start...'
                : job.phase == 'links'
                ? 'Linking tasks...'
                : '${job.done} of ${job.total} tasks',
            key: const Key('import-progress-text'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              key: const Key('import-cancel'),
              onPressed: notifier.cancel,
              child: const Text('Cancel import'),
            ),
          ),
        ] else ...[
          Text(
            switch (job.status) {
              'done' => 'Import finished',
              'undone' => 'Import undone',
              'cancelled' => 'Import cancelled',
              _ => 'Import stopped',
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
                  child: const Text('Open the project'),
                ),
              if (job.canResume)
                FilledButton(
                  key: const Key('import-resume'),
                  onPressed: notifier.start,
                  child: const Text('Resume'),
                ),
              if (job.canUndo)
                OutlinedButton(
                  key: const Key('import-undo'),
                  onPressed: () => _undo(context, ref),
                  child: const Text('Undo'),
                ),
              TextButton(
                key: const Key('import-another'),
                onPressed: notifier.restart,
                child: const Text('Import another file'),
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
    final lines = <String>[
      if (undone is Map<String, dynamic>)
        'Removed ${(undone['tasks'] as num?) ?? 0} tasks'
            '${((undone['kept'] as num?) ?? 0) > 0 ? ', kept ${undone['kept']} that have your own sub-tasks' : ''}.'
      else ...[
        for (final e in _countLabels.entries)
          if (job.stat(e.key) > 0 && e.key != 'subtasks')
            '${job.stat(e.key)} ${e.value}',
      ],
    ];
    return Text(lines.join(' · '), key: const Key('import-stats'));
  }
}
