import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// A layout as stored: its id and version on the server.
typedef StoredLayout<T> = ({String id, int version, T layout});

@immutable
class PersonalLayoutState<T> {
  const PersonalLayoutState({
    required this.layout,
    this.loaded = false,
    this.saveFailed = false,
  });

  final T layout;

  /// False until the person's saved layout has been read (or could not be): the
  /// view reads its data once, laid out the way they chose.
  final bool loaded;
  final bool saveFailed;

  PersonalLayoutState<T> copyWith({
    T? layout,
    bool? loaded,
    bool? saveFailed,
  }) => PersonalLayoutState(
    layout: layout ?? this.layout,
    loaded: loaded ?? this.loaded,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}

/// The layout of one kind of view (board, calendar) of one project for this
/// person: every change shows at once and is saved a moment later as their own
/// layout. A subclass says how that kind is read and stored.
abstract class PersonalLayoutNotifier<T>
    extends Notifier<PersonalLayoutState<T>> {
  PersonalLayoutNotifier(this.projectId, this.initial);

  final String projectId;
  final T initial;

  Timer? _timer;
  StoredLayout<T>? _mine;
  late ViewsClient _client;
  String? _workspace;
  T? _latest;

  /// The person's own layout of this kind, if they have saved one.
  Future<StoredLayout<T>?> findMine(ViewsClient client, String workspace);

  /// Creates (no [id]) or replaces their own layout.
  Future<StoredLayout<T>> store(
    ViewsClient client,
    String workspace,
    T layout, {
    required String id,
    required int version,
  });

  @override
  PersonalLayoutState<T> build() {
    _client = ref.watch(viewsClientProvider);
    _workspace = ref.watch(workspaceScopeProvider);
    ref.onDispose(() {
      final pending = _timer?.isActive ?? false;
      _timer?.cancel();
      final layout = _latest;
      if (pending && layout != null) unawaited(_write(layout));
    });
    Future.microtask(_load);
    return PersonalLayoutState(layout: initial);
  }

  Future<void> _load() async {
    final workspace = _workspace;
    if (workspace == null) {
      state = state.copyWith(loaded: true);
      return;
    }
    try {
      final mine = await findMine(_client, workspace);
      if (!ref.mounted) return;
      _mine = mine;
      state = PersonalLayoutState(
        layout: mine?.layout ?? state.layout,
        loaded: true,
      );
    } on ViewException {
      // A convenience: the view works with the default layout.
      if (ref.mounted) state = state.copyWith(loaded: true);
    }
  }

  void set(T layout) {
    if (layout == state.layout) return;
    _latest = layout;
    state = state.copyWith(layout: layout);
    _timer?.cancel();
    _timer = Timer(layoutSaveDelay, () => unawaited(_save()));
  }

  void update(T Function(T current) change) => set(change(state.layout));

  Future<void> _save() async {
    final ok = await _write(state.layout);
    if (ref.mounted) state = state.copyWith(saveFailed: !ok);
  }

  /// Saves [layout]; a conflict (another device) is retried against the
  /// version the server names, and "name taken" (the first read failed) finds
  /// the layout that exists and saves to it.
  Future<bool> _write(T layout) async {
    final workspace = _workspace;
    if (workspace == null) return false;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final mine = _mine;
        _mine = await store(
          _client,
          workspace,
          layout,
          id: mine?.id ?? '',
          version: mine?.version ?? 0,
        );
        return true;
      } on ViewException catch (e) {
        final mine = _mine;
        if (e.failure == ViewFailure.nameTaken && mine == null) {
          try {
            _mine = await findMine(_client, workspace);
          } on ViewException {
            return false;
          }
          if (_mine == null) return false;
          continue;
        }
        if (e.failure != ViewFailure.conflict || mine == null) return false;
        _mine = (id: mine.id, version: e.version, layout: mine.layout);
      }
    }
    return false;
  }
}
