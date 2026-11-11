import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/sync/sync_providers.dart';

/// Tints its child for a moment when somebody else has just changed the task
/// [taskId], so a row or card that moved or changed on its own is noticed.
class LiveFlash extends ConsumerWidget {
  const LiveFlash({super.key, required this.taskId, required this.child});

  final String taskId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashing = ref.watch(
      recentChangesProvider.select((ids) => ids.contains(taskId)),
    );
    return AnimatedContainer(
      key: flashing ? const Key('live-flash') : null,
      duration: const Duration(milliseconds: 300),
      color: flashing
          ? Theme.of(context).colorScheme.tertiaryContainer
                .withValues(alpha: 0.7)
          : Colors.transparent,
      child: child,
    );
  }
}
