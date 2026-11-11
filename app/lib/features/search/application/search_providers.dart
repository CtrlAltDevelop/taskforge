import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/search/data/search_client.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final searchClientProvider = Provider<SearchClient>(
  (ref) => GrpcSearchClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// How long typing pauses before a question is sent.
const searchDebounce = Duration(milliseconds: 200);

@immutable
class SearchState {
  const SearchState({
    this.text = '',
    this.results,
    this.recent = const [],
    this.loading = false,
    this.loadingMore = const {},
    this.error,
    this.highlighted = 0,
  });

  final String text;

  /// The answer to [text]; null while nothing was asked (or it is loading).
  final SearchResults? results;
  final List<String> recent;
  final bool loading;
  final Set<SearchKind> loadingMore;
  final Object? error;

  /// Index into [SearchResults.ordered] of the row the keyboard is on.
  final int highlighted;

  SearchState copyWith({
    String? text,
    Object? results = _keep,
    List<String>? recent,
    bool? loading,
    Set<SearchKind>? loadingMore,
    Object? error = _keep,
    int? highlighted,
  }) => SearchState(
    text: text ?? this.text,
    results: identical(results, _keep)
        ? this.results
        : results as SearchResults?,
    recent: recent ?? this.recent,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: identical(error, _keep) ? this.error : error,
    highlighted: highlighted ?? this.highlighted,
  );
}

const _keep = Object();

/// The search box: waits for typing to pause, asks, and drops any answer that
/// a newer question has overtaken.
class SearchBoxController extends Notifier<SearchState> {
  Timer? _timer;
  var _generation = 0;
  var _disposed = false;

  @override
  SearchState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    return const SearchState();
  }

  SearchClient get _client => ref.read(searchClientProvider);
  String? get _workspace => ref.read(workspaceScopeProvider);

  /// Loads the recent searches (when the box opens).
  Future<void> open() async {
    final ws = _workspace;
    if (ws == null) return;
    try {
      final recent = await _client.recent(ws);
      if (_disposed) return;
      state = state.copyWith(recent: recent);
    } on Object {
      // Recent searches are a convenience; the box works without them.
    }
  }

  void setText(String text) {
    _timer?.cancel();
    final generation = ++_generation;
    if (text.trim().isEmpty) {
      state = state.copyWith(
        text: text,
        results: null,
        loading: false,
        error: null,
        highlighted: 0,
      );
      return;
    }
    state = state.copyWith(
      text: text,
      loading: true,
      error: null,
      loadingMore: const {},
    );
    _timer = Timer(searchDebounce, () => _ask(text, generation));
  }

  Future<void> _ask(String text, int generation) async {
    final ws = _workspace;
    if (ws == null) {
      state = state.copyWith(loading: false);
      return;
    }
    try {
      final results = await _client.query(ws, text.trim());
      if (_disposed || generation != _generation) return;
      state = state.copyWith(
        results: results,
        loading: false,
        error: null,
        highlighted: 0,
      );
    } on Object catch (e) {
      if (_disposed || generation != _generation) return;
      state = state.copyWith(loading: false, error: e, results: null);
    }
  }

  /// Asks again now (the retry button).
  void retry() => setText(state.text);

  /// The next page of one kind, added below what is shown.
  Future<void> more(SearchKind kind) async {
    final ws = _workspace;
    final current = state.results;
    final cursor = current?.cursors[kind];
    if (ws == null || current == null || cursor == null) return;
    if (state.loadingMore.contains(kind)) return;
    final generation = _generation;
    state = state.copyWith(loadingMore: {...state.loadingMore, kind});
    try {
      final page = await _client.query(
        ws,
        state.text.trim(),
        types: [kind],
        cursor: cursor,
      );
      if (_disposed || generation != _generation) return;
      // Merge into what is shown now: another page may have landed meanwhile.
      final latest = state.results ?? current;
      final merged = SearchResults(
        hits: {
          ...latest.hits,
          kind: [...latest.of(kind), ...page.of(kind)],
        },
        jump: latest.jump,
        cursors: {
          for (final e in latest.cursors.entries)
            if (e.key != kind) e.key: e.value,
          if (page.cursors[kind] != null) kind: page.cursors[kind]!,
        },
      );
      state = state.copyWith(
        results: merged,
        loadingMore: {...state.loadingMore}..remove(kind),
      );
    } on Object catch (e) {
      if (_disposed || generation != _generation) return;
      state = state.copyWith(
        error: e,
        loadingMore: {...state.loadingMore}..remove(kind),
      );
    }
  }

  /// Moves the keyboard highlight by [delta], staying inside the results.
  void move(int delta) {
    final count = state.results?.ordered.length ?? 0;
    if (count == 0) return;
    state = state.copyWith(
      highlighted: (state.highlighted + delta).clamp(0, count - 1),
    );
  }

  /// What Enter opens: the highlighted row.
  SearchHit? get current {
    final rows = state.results?.ordered ?? const <SearchHit>[];
    if (rows.isEmpty) return null;
    return rows[state.highlighted.clamp(0, rows.length - 1)];
  }

  /// Keeps the text as a recent search (a result was opened).
  Future<void> remember() async {
    final ws = _workspace;
    final text = state.text.trim();
    if (ws == null || text.isEmpty) return;
    try {
      await _client.remember(ws, text);
    } on Object {
      // Not worth interrupting a navigation for.
    }
  }
}

final searchBoxProvider =
    NotifierProvider.autoDispose<SearchBoxController, SearchState>(
      SearchBoxController.new,
    );
