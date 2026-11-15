import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The keys [actionId] answers to right now ("Alt+I"), or null when it has
/// none. Read from the bindings, so a rebinding changes it everywhere.
///
/// Key names are in the language of [l10n] (English when null).
String? shortcutLabel(
  WidgetRef ref,
  String actionId, {
  AppLocalizations? l10n,
}) => ref
    .watch(bindingsProvider)
    .chordOf(actionId)
    ?.label(isMac: isApplePlatform, l10n: l10n);

/// [text] with the keys of [actionId] after it: "Stop the timer (Alt+Shift+S)".
String withShortcut(
  WidgetRef ref,
  String text,
  String actionId, {
  AppLocalizations? l10n,
}) {
  final keys = shortcutLabel(ref, actionId, l10n: l10n);
  return keys == null ? text : '$text ($keys)';
}

/// A small key cap beside a menu item; nothing when the action has no keys.
class ShortcutHint extends ConsumerWidget {
  const ShortcutHint(this.actionId, {super.key});

  final String actionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = shortcutLabel(ref, actionId, l10n: context.l10n);
    return keys == null
        ? const SizedBox.shrink()
        : KeyedSubtree(key: Key('hint-$actionId'), child: Keycap(keys));
  }
}
