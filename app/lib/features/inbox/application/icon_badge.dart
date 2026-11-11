import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/inbox/application/inbox_providers.dart';

/// Puts a count on the app icon (OS-specific; a no-op where there is none).
typedef BadgeSetter = Future<void> Function(int count);

Future<void> _setSystemBadge(int count) async {
  if (kIsWeb) return;
  try {
    await AppBadgePlus.updateBadge(count);
  } on Object {
    // No badge support on this platform: nothing to show, nothing to break.
  }
}

final badgeSetterProvider = Provider<BadgeSetter>((_) => _setSystemBadge);

/// Keeps the app-icon badge equal to what is unread in every workspace.
final iconBadgeProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<int>>(unreadTotalProvider, (_, next) {
    final count = next.value;
    if (count != null) unawaited(ref.read(badgeSetterProvider)(count));
  }, fireImmediately: true);
});
