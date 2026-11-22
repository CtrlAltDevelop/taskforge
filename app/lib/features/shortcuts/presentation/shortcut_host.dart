import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/frame_scope.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// How long after `g` the go-to letter is waited for.
const goSequenceWindow = Duration(milliseconds: 1500);

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
    // Only the page that is showing, never one under a dialog or the palette
    // (the open task's window is the page then).
    if (ModalRoute.of(context)?.isCurrent == false &&
        !ref.read(taskCommandsProvider).onTop) {
      return false;
    }
    final chord = Chord.fromEvent(
      event,
      HardwareKeyboard.instance,
      isMac: isApplePlatform,
    );
    if (chord == null || (!chord.hasModifier && _typing())) return false;
    if (KeyClaim.holds(
      FocusManager.instance.primaryFocus?.context,
      chord.wire,
    )) {
      return false;
    }
    final armedAt = _goArmedAt;
    _goArmedAt = null;
    if (armedAt != null &&
        !chord.hasModifier &&
        DateTime.now().difference(armedAt) < goSequenceWindow) {
      return _run(_goTarget(chord.key));
    }
    final action = ref
        .read(bindingsProvider)
        .actionFor(chord, within: actionContextOf(context));
    if (action != null) return _run(action);
    if (chord.wire == 'g') {
      _goArmedAt = DateTime.now();
      return true;
    }
    return false;
  }

  /// `g` was pressed: the next letter picks a go-to action.
  DateTime? _goArmedAt;

  AppAction? _goTarget(String key) => ref
      .read(actionRegistryProvider)
      .actions
      .where((a) => a.goKey == key)
      .firstOrNull;

  bool _run(AppAction? action) {
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

/// The phone's way in: keys are not there, so a top-bar button opens the
/// available actions as a sheet.
class QuickActionsButton extends ConsumerWidget {
  const QuickActionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TfIconButton(
    key: const Key('quick-actions'),
    icon: TfIcons.bolt,
    tooltip: context.l10n.grpGQuickActions,
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      // Judged and run from here, not from the sheet that closes first.
      builder: (_) => QuickActionsSheet(from: actionContextOf(context)),
    ),
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
              label: a.semanticLabelIn(context.l10n),
              button: true,
              excludeSemantics: true,
              child: ListTile(
                key: Key('quick-${a.id}'),
                title: Text(a.titleIn(context.l10n)),
                subtitle: Text(a.groupIn(context.l10n)),
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
