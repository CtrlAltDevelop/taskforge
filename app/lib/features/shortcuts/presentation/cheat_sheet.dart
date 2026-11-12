import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/data/shortcuts_client.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// Opens the list of every shortcut, where a key can also be changed.
Future<void> openCheatSheet(BuildContext context) => showDialog<void>(
  context: context,
  barrierLabel: 'Close the keyboard shortcuts',
  builder: (_) => const CheatSheet(),
);

/// Actions by heading, in the order they were registered. The sheet is built
/// from this, so a new action shows up without anyone editing a list.
Map<String, List<AppAction>> groupActions(Iterable<AppAction> actions) {
  final groups = <String, List<AppAction>>{};
  for (final a in actions) {
    groups.putIfAbsent(a.group, () => []).add(a);
  }
  return groups;
}

class CheatSheet extends ConsumerWidget {
  const CheatSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(actionRegistryProvider);
    final bindings = ref.watch(bindingsProvider);
    final groups = groupActions(registry.actions);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Keyboard shortcuts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    key: const Key('cheat-close'),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  for (final MapEntry(key: group, value: actions)
                      in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                      child: Text(
                        group,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    for (final a in actions)
                      _Row(
                        action: a,
                        chord: bindings.chordOf(a.id),
                        changed: bindings.overrides.containsKey(a.id),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({
    required this.action,
    required this.chord,
    required this.changed,
  });

  final AppAction action;
  final Chord? chord;
  final bool changed;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    key: Key('cheat-${action.id}'),
    dense: true,
    title: Text(action.title),
    subtitle: changed ? const Text('Changed by you') : null,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (chord == null)
          Text('none', style: Theme.of(context).textTheme.labelSmall)
        else
          Keycap(chord!.label(isMac: isApplePlatform)),
        IconButton(
          key: Key('rebind-${action.id}'),
          tooltip: 'Change the keys for ${action.title}',
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => RebindDialog(action: action),
          ),
        ),
      ],
    ),
  );
}

/// Waits for the next key combination and binds it, refusing one that is
/// already taken (and naming the action that has it).
class RebindDialog extends ConsumerStatefulWidget {
  const RebindDialog({super.key, required this.action});

  final AppAction action;

  @override
  ConsumerState<RebindDialog> createState() => _RebindDialogState();
}

class _RebindDialogState extends ConsumerState<RebindDialog> {
  Chord? _chord;
  String? _problem;
  bool _saving = false;

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    final chord = Chord.fromEvent(
      event,
      HardwareKeyboard.instance,
      isMac: isApplePlatform,
    );
    if (chord == null) return KeyEventResult.handled; // a lone modifier
    final bindings = ref.read(bindingsProvider);
    final clash = bindings.conflict(widget.action.id, chord);
    setState(() {
      _chord = chord;
      _problem = chord.isBrowserReserved
          ? 'The browser keeps ${chord.label(isMac: isApplePlatform)}.'
          : clash == null
          ? null
          : 'Already used by "${clash.title}".';
    });
    return KeyEventResult.handled;
  }

  Future<void> _save() async {
    final chord = _chord;
    if (chord == null || _problem != null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(shortcutOverridesProvider.notifier)
          .bind(widget.action.id, chord);
      if (mounted) Navigator.of(context).pop();
    } on ShortcutException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _problem = switch (e.failure) {
          ShortcutFailure.conflict => 'Another action already uses those keys.',
          ShortcutFailure.invalid =>
            e.detail.isEmpty ? 'Those keys cannot be used.' : e.detail,
          _ => 'Could not save. Check your connection.',
        };
      });
    }
  }

  Future<void> _reset() async {
    // The default may have been given to another action meanwhile.
    final home = Chord.parse(widget.action.defaultKeys);
    final clash = home == null
        ? null
        : ref.read(bindingsProvider).conflict(widget.action.id, home);
    if (clash != null) {
      setState(
        () => _problem = 'The default keys are used by "${clash.title}".',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(shortcutOverridesProvider.notifier)
          .reset(widget.action.id, defaultKeys: home?.wire ?? '');
      if (mounted) Navigator.of(context).pop();
    } on ShortcutException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _problem = e.failure == ShortcutFailure.conflict
            ? 'The default keys are used by another action.'
            : 'Could not save. Check your connection.';
      });
    }
  }

  Future<void> _unbind() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(shortcutOverridesProvider.notifier)
          .bind(widget.action.id, null);
      if (mounted) Navigator.of(context).pop();
    } on ShortcutException {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _problem = 'Could not save. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final overridden = ref
        .watch(bindingsProvider)
        .overrides
        .containsKey(widget.action.id);
    return AlertDialog(
      title: Text('Keys for ${widget.action.title}'),
      content: Focus(
        autofocus: true,
        onKeyEvent: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Press the keys you want.'),
            const SizedBox(height: 12),
            Text(
              _chord == null ? '…' : _chord!.label(isMac: isApplePlatform),
              key: const Key('rebind-chord'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_problem != null) ...[
              const SizedBox(height: 8),
              Text(
                _problem!,
                key: const Key('rebind-problem'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (overridden)
          TextButton(
            key: const Key('rebind-reset'),
            onPressed: _saving ? null : _reset,
            child: const Text('Use default'),
          ),
        TextButton(
          key: const Key('rebind-unbind'),
          onPressed: _saving ? null : _unbind,
          child: const Text('No key'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('rebind-save'),
          onPressed: _saving || _chord == null || _problem != null
              ? null
              : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
