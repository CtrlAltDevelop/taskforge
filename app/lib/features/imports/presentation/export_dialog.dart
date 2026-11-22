import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/imports/presentation/import_io.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';

Future<void> showExportDialog(BuildContext context, {String projectId = ''}) =>
    showDialog<void>(
      context: context,
      builder: (_) => ExportDialog(projectId: projectId),
    );

/// Export a project, or every project you can open, as a zip of open formats
/// (JSON that can be imported again, CSV, comments, an attachments manifest).
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key, this.projectId = ''});

  final String projectId;

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  late String _projectId = widget.projectId;
  late bool _everything = widget.projectId.isEmpty;

  String? _saveError;

  Future<void> _go() async {
    setState(() => _saveError = null);
    final done = await ref
        .read(exportProvider.notifier)
        .run(projectId: _everything ? '' : _projectId);
    if (done == null || !mounted) return;
    try {
      await ref.read(exportSaverProvider)(done.$1, done.$2);
    } on Object {
      // The chooser failed or the file could not be written: say so, the zip
      // can be asked for again.
      if (mounted) {
        setState(() => _saveError = context.l10n.grpGExportSaveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exportProvider);
    final projects =
        (ref.watch(projectsProvider(false)).value?.projects ?? const [])
            .where((p) => !p.isArchived)
            .toList();
    if (!_everything && _projectId.isEmpty && projects.isNotEmpty) {
      _projectId = projects.first.id;
    }
    return TfDialogFrame(
      key: const Key('export-dialog'),
      title: context.l10n.grpGExport,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<bool>(
              groupValue: _everything,
              onChanged: (v) => setState(() => _everything = v ?? true),
              child: Column(
                children: [
                  TfRadioTile<bool>(
                    key: const Key('export-scope-all'),
                    value: true,
                    title: context.l10n.grpGEveryProject,
                  ),
                  TfRadioTile<bool>(
                    key: const Key('export-scope-project'),
                    value: false,
                    title: context.l10n.grpGOneProject,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TfSpace.md),
            if (!_everything)
              TfSelectField(
                key: const Key('export-project'),
                options: {
                  for (final p in projects) p.id: '${p.name} (${p.key})',
                },
                value: projects.any((p) => p.id == _projectId)
                    ? _projectId
                    : null,
                onChanged: (id) => setState(() => _projectId = id),
                expand: true,
              ),
            const SizedBox(height: TfSpace.sm),
            Text(context.l10n.grpGExportInfo),
            if (state.busy)
              const Padding(
                padding: EdgeInsets.only(top: TfSpace.md),
                child: LinearProgressIndicator(key: Key('export-busy')),
              ),
            if (state.saved != null && _saveError == null)
              Padding(
                padding: const EdgeInsets.only(top: TfSpace.md),
                child: Text(
                  state.job != null
                      ? context.l10n.grpGExportSavedSized(
                          '${state.saved}',
                          context.localDigits(
                            humanSize(state.job!.size, context.l10n),
                          ),
                        )
                      : context.l10n.grpGExportSaved('${state.saved}'),
                  key: const Key('export-done'),
                ),
              ),
            if (_saveError != null)
              Padding(
                padding: const EdgeInsets.only(top: TfSpace.md),
                child: Text(
                  _saveError!,
                  key: const Key('export-save-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: TfSpace.md),
                child: Text(
                  state.error!,
                  key: const Key('export-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TfButton(
          label: context.l10n.grpGClose,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
        TfButton(
          key: const Key('export-go'),
          label: context.l10n.grpGExport,
          variant: TfButtonVariant.primary,
          onPressed: state.busy || (!_everything && _projectId.isEmpty)
              ? null
              : _go,
        ),
      ],
    );
  }
}
