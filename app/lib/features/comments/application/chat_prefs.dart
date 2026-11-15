import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// Whether this person hides the change messages in every task's chat
/// (remembered per person on this device).
final hideChatChangesProvider = NotifierProvider<HideChatChangesNotifier, bool>(
  HideChatChangesNotifier.new,
);

class HideChatChangesNotifier extends Notifier<bool> {
  String get _key => 'chat.hideChanges.${ref.read(currentUserIdProvider)}';

  @override
  bool build() {
    final key = 'chat.hideChanges.${ref.watch(currentUserIdProvider)}';
    ref.read(localPrefsProvider).read(key).then((saved) {
      if (ref.mounted && saved != null) state = saved == 'true';
    });
    return false;
  }

  void set({required bool hidden}) {
    state = hidden;
    ref.read(localPrefsProvider).write(_key, '$hidden');
  }
}

/// "Now" for the chat's relative times (tests bring their own).
final chatNowProvider = Provider<DateTime Function()>((_) => DateTime.now);
