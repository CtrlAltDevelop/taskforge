import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// The tasks behind a number or one bar of a chart: as many as it counted.
Future<void> showDrillSheet(
  BuildContext context, {
  required String widgetId,
  required String bucket,
  required String title,
}) => showDialog<void>(
  context: context,
  builder: (_) => DrillDialog(widgetId: widgetId, bucket: bucket, title: title),
);

class DrillDialog extends ConsumerWidget {
  const DrillDialog({
    super.key,
    required this.widgetId,
    required this.bucket,
    required this.title,
  });

  final String widgetId;
  final String bucket;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (widgetId: widgetId, bucket: bucket);
    final tasks = ref.watch(drilldownProvider(key));
    return AlertDialog(
      key: const Key('drill-dialog'),
      title: Text(
        tasks.hasValue
            ? context.l10n.grpIDrillTitle(
                title,
                tasks.requireValue.tasks.length,
                tasks.requireValue.truncated ? '+' : '',
              )
            : title,
      ),
      content: SizedBox(
        width: 480,
        height: 360,
        child: switch (tasks) {
          AsyncData(:final value) when value.tasks.isEmpty => TfEmpty(
            key: const Key('drill-empty'),
            compact: true,
            illustration: TfIllustrationKind.goals,
            title: context.l10n.grpINoTasks,
          ),
          AsyncData(:final value) => ListView(
            children: [
              if (value.truncated)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    context.l10n.grpIDrillTruncated,
                    key: const Key('drill-truncated'),
                  ),
                ),
              for (final t in value.tasks)
                ListTile(
                  key: Key('drill-${t.id}'),
                  dense: true,
                  title: Text('${t.displayId}  ${t.title}'),
                  subtitle: Text(
                    [
                      t.statusName,
                      if (t.priority.isNotEmpty && t.priority != 'none')
                        t.priority,
                      if (t.dueDate.isNotEmpty)
                        context.l10n.grpIDueOn(t.dueDate),
                    ].join(' · '),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/projects/${t.projectId}?task=${t.id}');
                  },
                ),
            ],
          ),
          AsyncError(:final error) => TfError(
            key: const Key('drill-error'),
            message: dashboardErrorMessage(error, context.l10n),
            details: '$error',
            retryKey: const Key('drill-retry'),
            onRetry: () => ref.invalidate(drilldownProvider(key)),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpIClose),
        ),
      ],
    );
  }
}
