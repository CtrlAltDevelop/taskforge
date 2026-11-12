import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/dashboards/presentation/drill_sheet.dart';
import 'package:taskforge/features/dashboards/presentation/widget_body.dart';

/// One widget on a dashboard: title, menu, and its numbers (kept on screen
/// while they are read again; a failure says so and offers Retry).
class WidgetCard extends ConsumerWidget {
  const WidgetCard({
    super.key,
    required this.widget,
    this.editing = false,
    this.saved = true,
    this.onEdit,
    this.onRemove,
  });

  final DashboardWidget widget;
  final bool editing;

  /// False while the widget only exists in an unsaved draft: the server does
  /// not know it yet, so there is nothing to read.
  final bool saved;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = widget.title.isEmpty ? widget.kind.label : widget.title;
    final key = (id: widget.id, version: widget.version);
    final data = saved ? ref.watch(widgetDataProvider(key)) : null;
    return Card(
      key: Key('widget-${widget.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (editing) const Icon(Icons.drag_indicator, size: 18),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (saved)
                  IconButton(
                    key: Key('refresh-${widget.id}'),
                    tooltip: 'Refresh',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: () => ref
                        .read(dashboardActionsProvider)
                        .refreshWidgets([key]),
                  ),
                PopupMenuButton<String>(
                  key: Key('menu-${widget.id}'),
                  tooltip: 'Widget menu',
                  itemBuilder: (_) => [
                    if (saved)
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Export CSV'),
                      ),
                    if (editing)
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (editing)
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove'),
                      ),
                  ],
                  onSelected: (v) {
                    switch (v) {
                      case 'export':
                        _export(context, ref, title);
                      case 'edit':
                        onEdit?.call();
                      case 'remove':
                        onRemove?.call();
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: switch (data) {
                null => const Center(
                  child: Text('Save to see numbers.', key: Key('unsaved')),
                ),
                AsyncData(:final value) => _Loaded(
                  widget: widget,
                  data: value,
                  onBucket: editing
                      ? null
                      : (bucket) => showDrillSheet(
                          context,
                          widgetId: widget.id,
                          bucket: bucket,
                          title: title,
                        ),
                ),
                AsyncError(:final error) when !data.hasValue => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dashboardErrorMessage(error),
                        key: Key('error-${widget.id}'),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        key: Key('retry-${widget.id}'),
                        onPressed: () =>
                            ref.invalidate(widgetDataProvider(key)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = await ref.read(dashboardActionsProvider).exportCsv(widget.id);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          key: const Key('widget-export-dialog'),
          title: Text('$title (CSV)'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: SelectableText(
                csv,
                key: const Key('widget-export-text'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              key: const Key('widget-export-copy'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csv));
                messenger.showSnackBar(
                  const SnackBar(content: Text('CSV copied.')),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Copy'),
            ),
            TextButton(
              key: const Key('widget-export-save'),
              onPressed: () async {
                await FilePicker.saveFile(
                  fileName: '${title.replaceAll(RegExp(r'[^\w-]+'), '-')}.csv',
                  bytes: Uint8List.fromList(utf8.encode(csv)),
                  mimeType: 'text/csv',
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save as file'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(dashboardErrorMessage(e))));
    }
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.widget, required this.data, this.onBucket});

  final DashboardWidget widget;
  final WidgetData data;
  final ValueChanged<String>? onBucket;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: WidgetBody(widget: widget, data: data, onBucket: onBucket),
      ),
      if (data.truncated)
        Text(
          widget.kind == WidgetKind.line
              ? 'Showing the latest ${widget.config.limit} points; '
                    'shorten the range to see them all.'
              : 'Showing the top ${widget.config.limit}; '
                    'narrow the filter to see the rest.',
          key: const Key('widget-truncated'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
    ],
  );
}
