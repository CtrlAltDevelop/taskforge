import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: TfPanel(
        key: const Key('import-wizard'),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(TfSpace.lg),
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
              const SizedBox(height: TfSpace.lg),
              if (wizard.busy)
                const Padding(
                  padding: EdgeInsets.only(bottom: TfSpace.md),
                  child: LinearProgressIndicator(key: Key('import-busy')),
                ),
              if (wizard.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: TfSpace.md),
                  child: Text(
                    wizard.error!,
                    key: const Key('import-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
              TfRadioTile<ImportSource?>(
                key: const Key('source-auto'),
                value: null,
                title: context.l10n.grpCImpAuto,
              ),
              for (final s in ImportSource.values)
                TfRadioTile<ImportSource?>(
                  key: Key('source-${s.wire}'),
                  value: s,
                  title: s.labelIn(context.l10n),
                ),
            ],
          ),
        ),
        const SizedBox(height: TfSpace.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TfButton(
            key: const Key('source-next'),
            label: context.l10n.grpCImpNext,
            variant: TfButtonVariant.primary,
            onPressed: () => wizard.chooseSource(chosen),
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
    if (source == ImportSource.clickupApi) return const _ClickUpStep();
    if (choices.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.grpCImpZipSeveral),
          const SizedBox(height: TfSpace.md),
          TfSelectField<String>(
            key: const Key('upload-member'),
            options: {for (final m in choices) m: m},
            value: null,
            onChanged: busy
                ? null
                : (m) =>
                      ref.read(importWizardProvider.notifier).chooseMember(m),
            hint: context.l10n.grpCImpChooseAFile,
            expand: true,
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
              : context.l10n.grpCImpChooseSource(source.labelIn(context.l10n)),
        ),
        const SizedBox(height: TfSpace.xs),
        Text(
          context.l10n.grpCImpSentNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: TfSpace.md),
        Row(
          children: [
            TfButton(
              key: const Key('upload-back'),
              label: context.l10n.grpCBack,
              variant: TfButtonVariant.ghost,
              onPressed: busy
                  ? null
                  : ref.read(importWizardProvider.notifier).back,
            ),
            const Spacer(),
            TfButton(
              key: const Key('import-pick'),
              label: context.l10n.grpCImpPickFile,
              variant: TfButtonVariant.primary,
              icon: TfIcons.upload,
              onPressed: busy ? null : () => _pick(ref),
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
          const SizedBox(height: TfSpace.sm),
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
              padding: const EdgeInsets.only(top: TfSpace.sm),
              child: Text(
                context.l10n.grpCImpAlready(report.alreadyImported),
                key: const Key('review-already'),
              ),
            ),
          if (report.errors > 0)
            Padding(
              padding: const EdgeInsets.only(top: TfSpace.sm),
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
        const SizedBox(height: TfSpace.md),
        Row(
          children: [
            TfButton(
              key: const Key('review-back'),
              label: context.l10n.grpCBack,
              variant: TfButtonVariant.ghost,
              onPressed: wizard.busy ? null : notifier.back,
            ),
            const Spacer(),
            TfButton(
              key: const Key('import-start'),
              label: resuming
                  ? context.l10n.grpCImpResumeImport
                  : context.l10n.grpCImpStart,
              variant: TfButtonVariant.primary,
              onPressed: wizard.busy ? null : notifier.start,
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
      builder: (dialog) => TfDialogFrame(
        key: const Key('undo-dialog'),
        title: dialog.l10n.grpCImpUndoTitle,
        content: Text(dialog.l10n.grpCImpUndoRunBody),
        actions: [
          TfButton(
            label: dialog.l10n.grpCCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.pop(dialog, false),
          ),
          TfButton(
            key: const Key('undo-confirm'),
            label: dialog.l10n.grpCImpUndoConfirm,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.pop(dialog, true),
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
          const SizedBox(height: TfSpace.sm),
          Text(
            job.status == 'queued'
                ? context.l10n.grpCImpWaitingStart
                : job.phase == 'links'
                ? context.l10n.grpCImpLinking
                : context.l10n.grpCImpProgress(job.done, job.total),
            key: const Key('import-progress-text'),
          ),
          const SizedBox(height: TfSpace.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TfButton(
              key: const Key('import-cancel'),
              label: context.l10n.grpCImpCancel,
              onPressed: notifier.cancel,
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
          const SizedBox(height: TfSpace.xs),
          _Stats(job: job),
          const SizedBox(height: TfSpace.sm),
          ImportProblems(jobId: job.id, count: job.problemCount),
          const SizedBox(height: TfSpace.sm),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (job.status == 'done' && job.projectId.isNotEmpty)
                TfButton(
                  key: const Key('import-open-project'),
                  label: context.l10n.grpCImpOpenProject,
                  variant: TfButtonVariant.primary,
                  onPressed: () => context.go('/projects/${job.projectId}'),
                ),
              if (job.canResume)
                TfButton(
                  key: const Key('import-resume'),
                  label: context.l10n.grpCImpResume,
                  variant: TfButtonVariant.primary,
                  onPressed: notifier.start,
                ),
              if (job.canUndo)
                TfButton(
                  key: const Key('import-undo'),
                  label: context.l10n.grpCUndo,
                  onPressed: () => _undo(context, ref),
                ),
              TfButton(
                key: const Key('import-another'),
                label: context.l10n.grpCImpAnother,
                variant: TfButtonVariant.ghost,
                onPressed: notifier.restart,
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

/// ClickUp source: a token, then the lists to bring, then the server fetches.
class _ClickUpStep extends ConsumerStatefulWidget {
  const _ClickUpStep();

  @override
  ConsumerState<_ClickUpStep> createState() => _ClickUpStepState();
}

class _ClickUpStepState extends ConsumerState<_ClickUpStep> {
  final _token = TextEditingController();
  final _picked = <String>{};

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final fetching = wizard.job?.status == fetchingStatus;
    final lists = [for (final w in wizard.clickup) ...w.lists];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('clickup-token'),
          controller: _token,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          enabled: !wizard.busy,
          decoration: InputDecoration(
            labelText: context.l10n.grpCImpCuTokenHint,
            helperText: context.l10n.grpCImpCuTokenNote,
          ),
        ),
        if (lists.isNotEmpty) ...[
          const SizedBox(height: TfSpace.md),
          Text(context.l10n.grpCImpCuPick),
          for (final l in lists)
            TfCheckbox(
              key: Key('clickup-list-${l.id}'),
              value: _picked.contains(l.id),
              onChanged: wizard.busy
                  ? null
                  : (on) => setState(
                      () =>
                          on == true ? _picked.add(l.id) : _picked.remove(l.id),
                    ),
              label: l.path,
            ),
        ],
        if (fetching) ...[
          const SizedBox(height: TfSpace.md),
          Text(
            '${context.l10n.grpCImpCuFetching} ${wizard.job?.done ?? 0}',
            key: const Key('clickup-progress'),
          ),
        ],
        const SizedBox(height: TfSpace.md),
        Row(
          children: [
            TfButton(
              key: const Key('clickup-back'),
              label: context.l10n.grpCBack,
              variant: TfButtonVariant.ghost,
              onPressed: wizard.busy ? null : notifier.back,
            ),
            const Spacer(),
            if (lists.isEmpty)
              TfButton(
                key: const Key('clickup-load'),
                label: context.l10n.grpCImpCuLoad,
                variant: TfButtonVariant.primary,
                onPressed: wizard.busy || _token.text.trim().isEmpty
                    ? null
                    : () => notifier.loadClickUp(_token.text.trim()),
              )
            else
              TfButton(
                key: const Key('clickup-fetch'),
                label: context.l10n.grpCImpCuFetch,
                variant: TfButtonVariant.primary,
                onPressed: wizard.busy || _picked.isEmpty
                    ? null
                    : () => notifier.fetchClickUp(
                        _token.text.trim(),
                        _picked.toList(),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}
