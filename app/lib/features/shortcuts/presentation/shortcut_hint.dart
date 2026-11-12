import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// The keys [actionId] answers to right now ("Alt+I"), or null when it has
/// none. Read from the bindings, so a rebinding changes it everywhere.
String? shortcutLabel(WidgetRef ref, String actionId) => ref
    .watch(bindingsProvider)
    .chordOf(actionId)
    ?.label(isMac: isApplePlatform);

/// [text] with the keys of [actionId] after it: "Stop the timer (Alt+Shift+S)".
String withShortcut(WidgetRef ref, String text, String actionId) {
  final keys = shortcutLabel(ref, actionId);
  return keys == null ? text : '$text ($keys)';
}

/// A small key cap beside a menu item; nothing when the action has no keys.
class ShortcutHint extends ConsumerWidget {
  const ShortcutHint(this.actionId, {super.key});

  final String actionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = shortcutLabel(ref, actionId);
    return keys == null
        ? const SizedBox.shrink()
        : KeyedSubtree(key: Key('hint-$actionId'), child: Keycap(keys));
  }
}
