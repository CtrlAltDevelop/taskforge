import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/dashboards/presentation/drill_sheet.dart';
import 'package:taskforge/features/dashboards/presentation/widget_body.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

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
    final title = widget.title.isEmpty
        ? widget.kind.labelIn(context.l10n)
        : widget.title;
    final key = (id: widget.id, version: widget.version);
    final data = saved ? ref.watch(widgetDataProvider(key)) : null;
    return Padding(
      padding: EdgeInsets.zero,
      child: TfPanel(
        key: Key('widget-${widget.id}'),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (editing) const TfIcon(TfIcons.grip, size: 18),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (saved)
                    TfIconButton(
                      key: Key('refresh-${widget.id}'),
                      icon: TfIcons.refresh,
                      tooltip: context.l10n.grpIRefresh,
                      onPressed: () => ref
                          .read(dashboardActionsProvider)
                          .refreshWidgets([key]),
                    ),
                  PopupMenuButton<String>(
                    key: Key('menu-${widget.id}'),
                    tooltip: context.l10n.grpIWidgetMenu,
                    itemBuilder: (_) => [
                      if (saved)
                        PopupMenuItem(
                          value: 'export',
                          child: Text(context.l10n.grpIExportCsv),
                        ),
                      if (editing)
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(context.l10n.grpIEdit),
                        ),
                      if (editing)
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(context.l10n.grpIRemove),
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
                  null => TfEmpty(
                    key: const Key('unsaved'),
                    compact: true,
                    illustration: TfIllustrationKind.goals,
                    title: context.l10n.grpISaveToSeeNumbers,
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
                          dashboardErrorMessage(error, context.l10n),
                          key: Key('error-${widget.id}'),
                          textAlign: TextAlign.center,
                        ),
                        TfButton(
                          key: Key('retry-${widget.id}'),
                          label: context.l10n.grpIRetry,
                          variant: TfButtonVariant.ghost,
                          onPressed: () =>
                              ref.invalidate(widgetDataProvider(key)),
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
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final csv = await ref.read(dashboardActionsProvider).exportCsv(widget.id);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => TfDialogFrame(
          key: const Key('widget-export-dialog'),
          title: context.l10n.grpICsvTitle(title),
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
            TfButton(
              key: const Key('widget-export-copy'),
              label: context.l10n.grpICopy,
              variant: TfButtonVariant.ghost,
              onPressed: () async {
                final copied = context.l10n.grpICsvCopied;
                await Clipboard.setData(ClipboardData(text: csv));
                messenger.showSnackBar(SnackBar(content: Text(copied)));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            TfButton(
              key: const Key('widget-export-save'),
              label: context.l10n.grpISaveAsFile,
              variant: TfButtonVariant.ghost,
              onPressed: () async {
                await FilePicker.saveFile(
                  fileName: '${title.replaceAll(RegExp(r'[^\w-]+'), '-')}.csv',
                  bytes: Uint8List.fromList(utf8.encode(csv)),
                  mimeType: 'text/csv',
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
            TfButton(
              label: context.l10n.grpIClose,
              variant: TfButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(dashboardErrorMessage(e, l10n))),
      );
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
              ? context.l10n.grpILatestPoints(widget.config.limit)
              : context.l10n.grpITopLimit(widget.config.limit),
          key: const Key('widget-truncated'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
    ],
  );
}
