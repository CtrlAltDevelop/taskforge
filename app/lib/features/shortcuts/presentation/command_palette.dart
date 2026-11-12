import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/fuzzy.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// True on Apple platforms, where Cmd is the main modifier.
bool get isApplePlatform =>
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// What an action sees of the screen it is run from.
ActionContext actionContextOf(BuildContext context) {
  final router = GoRouter.of(context);
  return ActionContext(
    context: context,
    container: ProviderScope.containerOf(context),
    router: router,
    location: router.routeInformationProvider.value.uri.toString(),
  );
}

/// Opens the palette over the current screen and runs what is chosen (after
/// it closes, so an action may open another dialog).
Future<void> openCommandPalette(BuildContext context) async {
  // Taken here, where the palette was asked for, not inside the dialog that
  // is gone by the time the chosen action runs.
  final from = actionContextOf(context);
  final pick = await showDialog<_Pick>(
    context: context,
    barrierLabel: 'Close the command palette',
    builder: (_) => CommandPalette(from: from),
  );
  if (pick == null || !context.mounted) return;
  switch (pick) {
    case _PickAction(:final action):
      await action.run(from);
    case _PickHit(:final hit):
      GoRouter.of(context).go(hit.location);
  }
}

sealed class _Pick {}

class _PickAction extends _Pick {
  _PickAction(this.action);

  final AppAction action;
}

class _PickHit extends _Pick {
  _PickHit(this.hit);

  final SearchHit hit;
}

/// How a question reads: `>` actions only, `#` projects, `@` people, else
/// actions plus a search of everything (a task id jumps to it).
enum PaletteMode { all, actions, projects, people }

({PaletteMode mode, String text}) parsePaletteQuery(String raw) {
  final t = raw.trimLeft();
  if (t.startsWith('>')) {
    return (mode: PaletteMode.actions, text: t.substring(1).trim());
  }
  if (t.startsWith('#')) {
    return (mode: PaletteMode.projects, text: t.substring(1).trim());
  }
  if (t.startsWith('@')) {
    return (mode: PaletteMode.people, text: t.substring(1).trim());
  }
  return (mode: PaletteMode.all, text: t.trim());
}

/// The actions that match [text], best first. With no text, the recently run
/// ones come first, then the rest in registration order.
List<AppAction> rankActions(
  List<AppAction> actions,
  String text, {
  List<String> recent = const [],
}) {
  if (text.isEmpty) {
    int rank(AppAction a) {
      final i = recent.indexOf(a.id);
      return i < 0 ? recent.length : i;
    }

    final sorted = [...actions];
    // List.sort is not stable everywhere; the index keeps ties in order.
    final order = {for (var i = 0; i < actions.length; i++) actions[i].id: i};
    sorted.sort((a, b) {
      final byRecent = rank(a).compareTo(rank(b));
      return byRecent != 0 ? byRecent : order[a.id]!.compareTo(order[b.id]!);
    });
    return sorted;
  }
  final scored = <(AppAction, int)>[];
  for (final a in actions) {
    final scores = [
      fuzzyScore(text, a.title),
      for (final k in a.keywords) ?_discount(fuzzyScore(text, k)),
      ?_discount(fuzzyScore(text, a.group)),
    ].nonNulls;
    if (scores.isEmpty) continue;
    final best = scores.reduce((x, y) => x > y ? x : y);
    final boost = recent.contains(a.id) ? 25 : 0;
    scored.add((a, best + boost));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final s in scored) s.$1];
}

// A keyword is a weaker signal than the title.
int? _discount(int? score) => score == null ? null : score - 150;

/// Ids of the actions run lately, newest first; kept for this run of the app.
final recentActionsProvider = NotifierProvider<RecentActions, List<String>>(
  RecentActions.new,
);

class RecentActions extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void ran(String id) =>
      state = [id, ...state.where((x) => x != id)].take(8).toList();
}

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key, required this.from});

  /// The screen the palette was opened over; availability is judged there.
  final ActionContext from;

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  SearchResults? _found;
  bool _searching = false;
  Object? _searchError;
  int _asked = 0;
  int _highlighted = 0;
  String _query = '';

  ActionContext get _context => widget.from;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<AppAction> _actions(PaletteMode mode, String text) {
    if (mode == PaletteMode.projects || mode == PaletteMode.people) {
      return const [];
    }
    final registry = ref.read(actionRegistryProvider);
    return rankActions(
      registry.available(_context),
      text,
      recent: ref.read(recentActionsProvider),
    );
  }

  List<SearchHit> get _hits => _found?.ordered ?? const [];

  int _rowCount(List<AppAction> actions) => actions.length + _hits.length;

  void _changed(String value) {
    setState(() {
      _query = value;
      _highlighted = 0;
    });
    _debounce?.cancel();
    final q = parsePaletteQuery(value);
    final searchable =
        q.mode != PaletteMode.actions &&
        (q.mode != PaletteMode.all || q.text.length >= 2) &&
        (q.mode == PaletteMode.all || q.text.isNotEmpty);
    if (!searchable) {
      setState(() {
        _found = null;
        _searching = false;
        _searchError = null;
      });
      return;
    }
    _debounce = Timer(searchDebounce, () => _search(q.mode, q.text));
  }

  Future<void> _search(PaletteMode mode, String text) async {
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    final ask = ++_asked;
    setState(() => _searching = true);
    try {
      final answer = await ref
          .read(searchClientProvider)
          .query(
            workspace,
            text,
            types: switch (mode) {
              PaletteMode.projects => [SearchKind.project],
              PaletteMode.people => [SearchKind.member],
              _ => const [SearchKind.task, SearchKind.project, SearchKind.doc],
            },
            pageSize: 4,
          );
      if (!mounted || ask != _asked) return;
      setState(() {
        _found = answer;
        _searching = false;
        _searchError = null;
      });
    } on Object catch (e) {
      if (!mounted || ask != _asked) return;
      setState(() {
        _searching = false;
        _searchError = e;
      });
    }
  }

  void _choose(List<AppAction> actions, int index) {
    if (index < actions.length) {
      final action = actions[index];
      ref.read(recentActionsProvider.notifier).ran(action.id);
      Navigator.of(context).pop(_PickAction(action));
      return;
    }
    final hit = _hits[index - actions.length];
    Navigator.of(context).pop(_PickHit(hit));
  }

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final q = parsePaletteQuery(_query);
    final actions = _actions(q.mode, q.text);
    final count = _rowCount(actions);
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown && count > 0) {
      setState(() => _highlighted = (_highlighted + 1) % count);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp && count > 0) {
      setState(() => _highlighted = (_highlighted - 1 + count) % count);
      return KeyEventResult.handled;
    }
    final enter =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    // Enter that confirms an IME composition is not "run".
    if (enter && _text.value.composing.isValid) return KeyEventResult.ignored;
    if (enter && event is KeyDownEvent) {
      if (count > 0) _choose(actions, _highlighted.clamp(0, count - 1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final q = parsePaletteQuery(_query);
    final actions = _actions(q.mode, q.text);
    final bindings = ref.watch(bindingsProvider);
    final hits = _hits;
    final count = actions.length + hits.length;
    final highlighted = count == 0 ? 0 : _highlighted.clamp(0, count - 1);
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              onKeyEvent: _keys,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  key: const Key('palette-field'),
                  controller: _text,
                  focusNode: _focus,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'Type a command, or > actions  # projects  @ people',
                    prefixIcon: const Icon(Icons.keyboard_command_key),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: _changed,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: count == 0 && !_searching
                  ? const Padding(
                      key: Key('palette-empty'),
                      padding: EdgeInsets.all(24),
                      child: Text('Nothing matches.'),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (var i = 0; i < actions.length; i++)
                          _ActionRow(
                            action: actions[i],
                            keys: bindings
                                .chordOf(actions[i].id)
                                ?.label(isMac: isApplePlatform),
                            selected: i == highlighted,
                            onTap: () => _choose(actions, i),
                          ),
                        for (var i = 0; i < hits.length; i++)
                          _HitRow(
                            hit: hits[i],
                            selected: actions.length + i == highlighted,
                            onTap: () => _choose(actions, actions.length + i),
                          ),
                        if (_searchError != null)
                          const Padding(
                            key: Key('palette-search-error'),
                            padding: EdgeInsets.all(16),
                            child: Text('Search is not available right now.'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.action,
    required this.keys,
    required this.selected,
    required this.onTap,
  });

  final AppAction action;
  final String? keys;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: action.semanticLabel,
    button: true,
    selected: selected,
    excludeSemantics: true,
    child: ListTile(
      key: Key('palette-row-${action.id}'),
      dense: true,
      selected: selected,
      leading: const Icon(Icons.bolt_outlined),
      title: Text(action.title),
      subtitle: Text(action.group),
      trailing: keys == null ? null : _Keycap(keys!),
      onTap: onTap,
    ),
  );
}

class _HitRow extends StatelessWidget {
  const _HitRow({
    required this.hit,
    required this.selected,
    required this.onTap,
  });

  final SearchHit hit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('palette-hit-${hit.kind.wire}-${hit.id}'),
    dense: true,
    selected: selected,
    leading: Icon(hit.kind.icon),
    title: Text(hit.key.isEmpty ? hit.title : '${hit.key}  ${hit.title}'),
    subtitle: Text(hit.kind.label),
    onTap: onTap,
  );
}

/// A key combination drawn as a small rounded tag.
class Keycap extends StatelessWidget {
  const Keycap(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => _Keycap(label);
}

class _Keycap extends StatelessWidget {
  const _Keycap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    ),
  );
}

/// Runs [action] from [context]; the one way keys, menus and the phone sheet
/// call an entry, so they cannot drift apart.
Future<void> runAction(BuildContext context, AppAction action) async {
  final ctx = actionContextOf(context);
  if (!action.isAvailable(ctx)) return;
  ProviderScope.containerOf(context)
      .read(recentActionsProvider.notifier)
      .ran(action.id);
  await action.run(ctx);
}
