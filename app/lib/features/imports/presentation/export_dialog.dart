import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        setState(() => _saveError = 'The file could not be saved. Try again.');
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
    return AlertDialog(
      key: const Key('export-dialog'),
      title: const Text('Export'),
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
                  RadioListTile<bool>(
                    key: const Key('export-scope-all'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Every project I can open'),
                    value: true,
                  ),
                  RadioListTile<bool>(
                    key: const Key('export-scope-project'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('One project'),
                    value: false,
                  ),
                ],
              ),
            ),
            if (!_everything)
              DropdownButton<String>(
                key: const Key('export-project'),
                isExpanded: true,
                value: projects.any((p) => p.id == _projectId)
                    ? _projectId
                    : null,
                items: [
                  for (final p in projects)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} (${p.key})'),
                    ),
                ],
                onChanged: (id) => setState(() => _projectId = id ?? ''),
              ),
            const SizedBox(height: 8),
            const Text(
              'A zip with tasks.json (which TaskForge can import again), '
              'tasks.csv, comments, an attachments manifest and a README.',
            ),
            if (state.busy)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(key: Key('export-busy')),
              ),
            if (state.saved != null && _saveError == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Saved ${state.saved}'
                  '${state.job != null ? ' (${humanSize(state.job!.size)})' : ''}.',
                  key: const Key('export-done'),
                ),
              ),
            if (_saveError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _saveError!,
                  key: const Key('export-save-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          key: const Key('export-go'),
          onPressed: state.busy || (!_everything && _projectId.isEmpty)
              ? null
              : _go,
          child: const Text('Export'),
        ),
      ],
    );
  }
}
