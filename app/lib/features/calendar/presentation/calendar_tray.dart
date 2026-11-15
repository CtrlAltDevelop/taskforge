import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/presentation/calendar_drag.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

/// Open tasks with no dates. On a wide screen each drags onto a day; every
/// one also has a "Schedule…" button that asks for a date (the way without a
/// mouse, and the only one on a phone).
class CalendarTray extends ConsumerWidget {
  const CalendarTray({
    super.key,
    required this.projectId,
    required this.canMove,
    required this.draggable,
    required this.onOpen,
    required this.onSchedule,
  });

  final String projectId;
  final bool canMove;
  final bool draggable;
  final void Function(Task) onOpen;
  final void Function(Task) onSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tray = ref.watch(trayProvider(projectId));
    final Widget body;
    if (tray.error != null && tray.tasks.isEmpty) {
      body = Center(
        child: TextButton(
          key: const Key('retry-tray'),
          onPressed: () => ref.read(trayProvider(projectId).notifier).load(),
          child: Text(
            context.l10n.grpFErrorRetry(
              taskErrorMessage(tray.error!, context.l10n),
            ),
          ),
        ),
      );
    } else if (tray.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (tray.tasks.isEmpty) {
      body = Center(
        child: Text(
          context.l10n.grpFEverythingDated,
          key: const Key('tray-empty'),
        ),
      );
    } else {
      body = ListView.builder(
        key: const Key('tray-list'),
        itemCount: tray.tasks.length + (tray.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == tray.tasks.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(trayProvider(projectId).notifier).loadMore();
            });
            return const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            );
          }
          final task = tray.tasks[i];
          final tile = ListTile(
            key: Key('tray-${task.id}'),
            dense: true,
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(isolateLtr(task.displayId)),
            onTap: () => onOpen(task),
            trailing: canMove
                ? IconButton(
                    key: Key('schedule-${task.id}'),
                    tooltip: context.l10n.grpFSchedule,
                    icon: const Icon(Icons.event_available_outlined),
                    onPressed: () => onSchedule(task),
                  )
                : null,
          );
          if (!canMove || !draggable) return tile;
          return Draggable<CalDrag>(
            data: CalDrag(task, fromTray: true),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(task.title),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.4, child: tile),
            child: tile,
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            context.l10n.grpFUnscheduled,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
