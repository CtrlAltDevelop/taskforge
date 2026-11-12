import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';

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
            ? '$title · ${tasks.requireValue.tasks.length}'
                  '${tasks.requireValue.truncated ? '+' : ''} '
                  'task${tasks.requireValue.tasks.length == 1 ? '' : 's'}'
            : title,
      ),
      content: SizedBox(
        width: 480,
        height: 360,
        child: switch (tasks) {
          AsyncData(:final value) when value.tasks.isEmpty => const Center(
            child: Text('No tasks.', key: Key('drill-empty')),
          ),
          AsyncData(:final value) => ListView(
            children: [
              if (value.truncated)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Only the first tasks are listed; narrow the filter to see the rest.',
                    key: Key('drill-truncated'),
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
                      if (t.dueDate.isNotEmpty) 'due ${t.dueDate}',
                    ].join(' · '),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/projects/${t.projectId}?task=${t.id}');
                  },
                ),
            ],
          ),
          AsyncError(:final error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dashboardErrorMessage(error),
                  key: const Key('drill-error'),
                ),
                TextButton(
                  key: const Key('drill-retry'),
                  onPressed: () => ref.invalidate(drilldownProvider(key)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
