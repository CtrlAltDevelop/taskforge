import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/inbox/application/inbox_providers.dart';

/// [child] with the number of unread notifications in the current workspace
/// on it (nothing when there are none).
class InboxBadge extends ConsumerWidget {
  const InboxBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider).value ?? 0;
    return Semantics(
      label: count > 0 ? '$count unread' : null,
      child: Badge(
        key: const Key('inbox-badge'),
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: child,
      ),
    );
  }
}
