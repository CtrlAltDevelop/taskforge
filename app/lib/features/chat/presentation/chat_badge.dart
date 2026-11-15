import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';

/// [child] with the number of unread chat messages on it (nothing when none).
class ChatBadge extends ConsumerWidget {
  const ChatBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(chatUnreadProvider);
    return Semantics(
      label: count > 0 ? context.l10n.chatUnreadLabel(count) : null,
      child: Badge(
        key: const Key('chat-badge'),
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: child,
      ),
    );
  }
}
