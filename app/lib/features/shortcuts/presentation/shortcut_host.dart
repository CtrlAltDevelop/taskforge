import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// Runs the action a key press is bound to, from anywhere on the page. It
/// listens to the keyboard itself, so it works even after a tap has taken
/// focus away from everything. A key with no modifier is left alone while a
/// text field has focus; a combination with Ctrl/Cmd/Alt always counts.
class ShortcutHost extends ConsumerStatefulWidget {
  const ShortcutHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShortcutHost> createState() => _ShortcutHostState();
}

class _ShortcutHostState extends ConsumerState<ShortcutHost> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  static bool _typing() {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;
    return focused.widget is EditableText ||
        focused.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    // Only the page that is showing, never one under a dialog or the palette.
    if (ModalRoute.of(context)?.isCurrent == false) return false;
    final chord = Chord.fromEvent(
      event,
      HardwareKeyboard.instance,
      isMac: isApplePlatform,
    );
    if (chord == null || (!chord.hasModifier && _typing())) return false;
    final action = ref.read(bindingsProvider).actionFor(chord);
    if (action == null) return false;
    final ctx = actionContextOf(context);
    if (!action.isAvailable(ctx)) return false;
    ref.read(recentActionsProvider.notifier).ran(action.id);
    action.run(ctx);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Read the person's own keys now, so the first key press already knows them.
    ref.watch(shortcutOverridesProvider);
    return widget.child;
  }
}

/// The phone's way in: keys are not there, so a button opens the available
/// actions as a sheet.
class QuickActionsButton extends ConsumerWidget {
  const QuickActionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FloatingActionButton.small(
        key: const Key('quick-actions'),
        tooltip: context.l10n.grpGQuickActions,
        heroTag: 'quick-actions',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          // Judged and run from here, not from the sheet that closes first.
          builder: (_) => QuickActionsSheet(from: actionContextOf(context)),
        ),
        child: const Icon(Icons.bolt),
      );
}

class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({super.key, required this.from});

  final ActionContext from;

  @override
  Widget build(BuildContext context) {
    final actions = from.container.read(actionRegistryProvider).available(from);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final a in actions)
            Semantics(
              label: a.semanticLabel,
              button: true,
              excludeSemantics: true,
              child: ListTile(
                key: Key('quick-${a.id}'),
                title: Text(a.title),
                subtitle: Text(a.group),
                onTap: () {
                  Navigator.of(context).pop();
                  from.container.read(recentActionsProvider.notifier).ran(a.id);
                  a.run(from);
                },
              ),
            ),
        ],
      ),
    );
  }
}
