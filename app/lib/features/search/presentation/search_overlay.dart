import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// Opens the search box over the current screen; following a result goes to
/// it. Does nothing while it is already open.
Future<void> openSearch(BuildContext context) async {
  final router = GoRouter.of(context);
  final hit = await showDialog<SearchHit>(
    context: context,
    barrierLabel: context.l10n.grpFSearchClose,
    builder: (_) => const SearchOverlay(),
  );
  if (hit != null) router.go(hit.location);
}

/// The search box with grouped results: Up/Down move, Enter opens, Escape
/// closes.
class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(searchBoxProvider.notifier).open());
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _open(SearchHit hit) {
    ref.read(searchBoxProvider.notifier).remember();
    Navigator.of(context).pop(hit);
  }

  void _setText(String value) {
    _text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    ref.read(searchBoxProvider.notifier).setText(value);
    _focus.requestFocus();
  }

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || event is KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final box = ref.read(searchBoxProvider.notifier);
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      box.move(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      box.move(-1);
      return KeyEventResult.handled;
    }
    final enter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    // Enter that confirms an IME composition (Persian, CJK) is not "open".
    if (enter && _text.value.composing.isValid) return KeyEventResult.ignored;
    if (enter) {
      final hit = box.current;
      if (hit == null) return KeyEventResult.handled;
      _open(hit);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchBoxProvider);
    final results = state.results;
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
                  key: const Key('search-field'),
                  controller: _text,
                  focusNode: _focus,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.l10n.grpFSearchHint,
                    prefixIcon: const TfIcon(
                      TfIcons.search,
                      size: TfIconSize.control,
                    ),
                    suffixIcon: state.loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (v) =>
                      ref.read(searchBoxProvider.notifier).setText(v),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final chip in operatorChips)
                    FilterChip(
                      key: Key('chip-$chip'),
                      label: Text(operatorChipLabel(chip, context.l10n)),
                      selected: hasOperator(state.text, chip),
                      onSelected: (_) =>
                          _setText(toggleOperator(state.text, chip)),
                    ),
                ],
              ),
            ),
            const Divider(height: 16),
            Flexible(child: _body(state, results)),
          ],
        ),
      ),
    );
  }

  Widget _body(SearchState state, SearchResults? results) {
    if (state.error != null && results == null) {
      return TfError(
        key: const Key('search-error'),
        compact: true,
        message: searchErrorMessage(state.error!, context.l10n),
        details: '${state.error}',
        retryKey: const Key('search-retry'),
        onRetry: ref.read(searchBoxProvider.notifier).retry,
      );
    }
    if (state.text.trim().isEmpty) return _Recent(state.recent, _setText);
    if (results == null) return const SizedBox(height: 72);
    if (results.isEmpty) {
      return TfEmpty(
        key: const Key('search-empty'),
        compact: true,
        illustration: TfIllustrationKind.search,
        title: context.l10n.grpFSearchNothing,
      );
    }
    final rows = results.ordered;
    return ListView(
      shrinkWrap: true,
      children: [
        if (state.error != null)
          Padding(
            key: const Key('search-more-error'),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
            child: Text(searchErrorMessage(state.error!, context.l10n)),
          ),
        if (results.jump != null)
          _Section(
            title: context.l10n.grpFGoTo,
            children: [_row(results.jump!, rows, 0)],
          ),
        for (final kind in SearchKind.values)
          if (results.of(kind).isNotEmpty)
            _Section(
              title: kind.labelIn(context.l10n),
              children: [
                for (final hit in results.of(kind))
                  _row(hit, rows, rows.indexOf(hit)),
                if (results.cursors[kind] != null)
                  TextButton(
                    key: Key('more-${kind.wire}'),
                    onPressed: state.loadingMore.contains(kind)
                        ? null
                        : () => ref.read(searchBoxProvider.notifier).more(kind),
                    child: Text(
                      context.l10n.grpFShowMore(
                        kind.labelIn(context.l10n).toLowerCase(),
                      ),
                    ),
                  ),
              ],
            ),
      ],
    );
  }

  Widget _row(SearchHit hit, List<SearchHit> rows, int index) => _HitTile(
    hit: hit,
    selected: ref.watch(searchBoxProvider).highlighted == index,
    onTap: () => _open(hit),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.labelLarge),
      ),
      ...children,
    ],
  );
}

class _HitTile extends StatelessWidget {
  const _HitTile({
    required this.hit,
    required this.selected,
    required this.onTap,
  });

  final SearchHit hit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Scrollable.ensureVisible(context);
      });
    }
    final where = [
      if (hit.key.isNotEmpty && hit.kind != SearchKind.project) hit.key,
      if (hit.kind == SearchKind.comment && hit.author.isNotEmpty) hit.author,
      if (hit.status.isNotEmpty) hit.status,
    ].join(' · ');
    return ListTile(
      key: Key('hit-${hit.kind.wire}-${hit.id}'),
      dense: true,
      selected: selected,
      leading: Icon(hit.kind.icon),
      title: Highlighted(hit.title, hit.titleMarks),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (where.isNotEmpty) Text(where, style: theme.textTheme.bodySmall),
          if (hit.snippet.isNotEmpty)
            Highlighted(hit.snippet, hit.snippetMarks, maxLines: 2),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// [text] with the [marks] in bold.
class Highlighted extends StatelessWidget {
  const Highlighted(this.text, this.marks, {super.key, this.maxLines = 1});

  final String text;
  final List<Mark> marks;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);
    final spans = <TextSpan>[];
    var at = 0;
    for (final m in marks) {
      if (m.start < at || m.end > text.length || m.start >= m.end) continue;
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      spans.add(TextSpan(text: text.substring(m.start, m.end), style: bold));
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent(this.recent, this.onPick);

  final List<String> recent;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return _Message(
        key: const Key('search-tips'),
        text: context.l10n.grpFSearchTips,
      );
    }
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
          child: Text(context.l10n.grpFRecent),
        ),
        for (final q in recent)
          ListTile(
            key: Key('recent-$q'),
            dense: true,
            leading: const TfIcon(TfIcons.history, size: TfIconSize.control),
            title: Text(q),
            onTap: () => onPick(q),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text(text, textAlign: TextAlign.center)],
    ),
  );
}
