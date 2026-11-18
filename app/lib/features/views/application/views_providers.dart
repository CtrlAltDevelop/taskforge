import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How long after the last change a layout is saved: a column drag is one save.
const layoutSaveDelay = Duration(milliseconds: 600);

final viewsClientProvider = Provider<ViewsClient>(
  (ref) => GrpcViewsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    onRefusal: () => ref.read(refusalCountProvider.notifier).bump(),
  ),
);

@immutable
class LayoutState {
  const LayoutState({
    this.layout = const ListLayout(),
    this.loaded = false,
    this.shared = const [],
    this.saveFailed = false,
  });

  final ListLayout layout;

  /// False until the person's saved layout has been read (or could not be):
  /// the task list waits for it so it is read once, in the right order.
  final bool loaded;

  /// The layouts shared with the whole project.
  final List<SavedView> shared;

  /// The last automatic save did not reach the server.
  final bool saveFailed;

  LayoutState copyWith({
    ListLayout? layout,
    bool? loaded,
    List<SavedView>? shared,
    bool? saveFailed,
  }) => LayoutState(
    layout: layout ?? this.layout,
    loaded: loaded ?? this.loaded,
    shared: shared ?? this.shared,
    saveFailed: saveFailed ?? this.saveFailed,
  );
}

/// The list layout of one project for this person. Every change shows at once
/// and is saved a moment later as their personal layout, which is read again on
/// any device.
final listLayoutProvider = NotifierProvider.autoDispose
    .family<ListLayoutNotifier, LayoutState, String>(ListLayoutNotifier.new);

class ListLayoutNotifier extends Notifier<LayoutState> {
  ListLayoutNotifier(this.projectId);

  final String projectId;
  Timer? _timer;
  SavedView? _mine;
  late ViewsClient _client;
  String? _workspace;

  /// Nobody has chosen columns yet: the list shows the usual ones plus every
  /// custom field that is not hidden from it, as fields come and go.
  var _untouched = true;

  /// The layout last set, kept so a save still pending when the provider is
  /// disposed can be sent (the state cannot be read while disposing).
  ListLayout? _latest;

  @override
  LayoutState build() {
    _client = ref.watch(viewsClientProvider);
    _workspace = ref.watch(workspaceScopeProvider);
    ref.onDispose(() {
      final pending = _timer?.isActive ?? false;
      _timer?.cancel();
      final layout = _latest;
      if (pending && layout != null) unawaited(_write(layout));
    });
    ref.listen(fieldsProvider(projectId), (_, next) {
      if (next.hasValue) _applyFieldDefaults(next.requireValue);
    });
    Future.microtask(_load);
    return const LayoutState();
  }

  void _applyFieldDefaults(List<CustomField> fields) {
    if (!_untouched) return;
    state = state.copyWith(
      layout: state.layout.copyWith(
        columns: [
          ...defaultColumns,
          for (final f in fields)
            if (!f.hiddenViews.contains('list')) '$fieldColumnPrefix${f.id}',
        ],
      ),
    );
  }

  Future<void> _load() async {
    final workspace = _workspace;
    if (workspace == null) {
      state = state.copyWith(loaded: true);
      return;
    }
    try {
      final all = await _client.list(workspace, projectId);
      if (!ref.mounted) return;
      _mine = all
          .where((v) => !v.isShared && v.name == personalLayoutName)
          .firstOrNull;
      _untouched = _untouched && _mine == null;
      state = LayoutState(
        layout: _mine?.layout ?? state.layout,
        loaded: true,
        shared: [
          for (final v in all)
            if (v.isShared) v,
        ],
      );
    } on ViewException {
      // The layout is a convenience: the list works with the default one.
      if (ref.mounted) state = state.copyWith(loaded: true);
    }
  }

  /// Shows [layout] now and saves it shortly.
  void set(ListLayout layout) {
    if (layout == state.layout) return;
    _untouched = false;
    _latest = layout;
    state = state.copyWith(layout: layout);
    _timer?.cancel();
    _timer = Timer(layoutSaveDelay, () => unawaited(_save()));
  }

  void update(ListLayout Function(ListLayout current) change) =>
      set(change(state.layout));

  Future<void> _save() async {
    final ok = await _write(state.layout);
    if (ref.mounted) state = state.copyWith(saveFailed: !ok);
  }

  /// Saves [layout] as the personal layout. A conflict (the same person on
  /// another device) is retried against the version the server names; "name
  /// taken" means the first read of it failed, so it is read again and the
  /// save goes to the layout that exists.
  Future<bool> _write(ListLayout layout) async {
    final workspace = _workspace;
    if (workspace == null) return false;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final mine = _mine;
        _mine = await _client.save(
          workspace,
          projectId,
          name: personalLayoutName,
          layout: layout,
          id: mine?.id ?? '',
          expectedVersion: mine?.version ?? 0,
        );
        return true;
      } on ViewException catch (e) {
        final mine = _mine;
        if (e.failure == ViewFailure.nameTaken && mine == null) {
          if (!await _findMine(workspace)) return false;
          continue;
        }
        if (e.failure != ViewFailure.conflict || mine == null) return false;
        _mine = SavedView(
          id: mine.id,
          name: mine.name,
          layout: mine.layout,
          isShared: false,
          version: e.version,
        );
      }
    }
    return false;
  }

  Future<bool> _findMine(String workspace) async {
    try {
      final all = await _client.list(workspace, projectId);
      _mine = all
          .where((v) => !v.isShared && v.name == personalLayoutName)
          .firstOrNull;
    } on ViewException {
      return false;
    }
    return _mine != null;
  }

  /// Makes a shared layout the one in use (it is then saved as the person's
  /// own, so it can be tweaked without touching the shared one).
  void useShared(SavedView view) => set(view.layout);

  /// Shares the layout in use with the project as [name]. Throws
  /// [ViewException].
  Future<void> shareCurrent(String name) async {
    final workspace = _workspace;
    if (workspace == null) return;
    await _client.save(
      workspace,
      projectId,
      name: name,
      layout: state.layout,
      shared: true,
    );
    await _reloadShared();
  }

  /// Replaces a shared layout with the one in use. Throws [ViewException].
  Future<void> overwriteShared(SavedView view) async {
    final workspace = _workspace;
    if (workspace == null) return;
    await _client.save(
      workspace,
      projectId,
      name: view.name,
      layout: state.layout,
      id: view.id,
      expectedVersion: view.version,
      shared: true,
    );
    await _reloadShared();
  }

  /// Pins a shared layout as a tab of the project page (or removes the tab),
  /// at the end of the tabs. Throws [ViewException].
  Future<void> setTab(SavedView view, {required bool pinned}) async {
    final last = state.shared
        .where((v) => v.pinnedAsTab)
        .fold(0, (m, v) => v.tabOrder > m ? v.tabOrder : m);
    await _saveTab(view, pinned: pinned, order: pinned ? last + 1 : 0);
  }

  /// Moves a pinned tab one place earlier ([delta] -1) or later (+1). Throws
  /// [ViewException].
  Future<void> moveTab(SavedView view, int delta) async {
    final tabs = pinnedTabs(state.shared);
    final from = tabs.indexWhere((v) => v.id == view.id);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= tabs.length) return;
    final order = [...tabs];
    order.insert(to, order.removeAt(from));
    for (var i = 0; i < order.length; i++) {
      final v = order[i];
      if (v.tabOrder != i + 1) await _saveTab(v, pinned: true, order: i + 1);
    }
  }

  Future<void> _saveTab(
    SavedView view, {
    required bool pinned,
    required int order,
  }) async {
    final workspace = _workspace;
    if (workspace == null) return;
    await _client.save(
      workspace,
      projectId,
      name: view.name,
      layout: view.layout,
      id: view.id,
      expectedVersion: view.version,
      shared: true,
      pinnedAsTab: pinned,
      tabOrder: order,
    );
    await _reloadShared();
  }

  Future<void> deleteShared(SavedView view) async {
    final workspace = _workspace;
    if (workspace == null) return;
    await _client.delete(workspace, projectId, view.id);
    await _reloadShared();
  }

  Future<void> _reloadShared() async {
    final workspace = _workspace;
    if (workspace == null) return;
    final all = await _client.list(workspace, projectId);
    if (!ref.mounted) return;
    state = state.copyWith(
      shared: [
        for (final v in all)
          if (v.isShared) v,
      ],
    );
  }
}

/// What the task list asks the server for. Only a change of sort or grouping
/// changes it (widths and columns do not make the list read again).
final listQueryProvider = Provider.autoDispose.family<ListQuery, String>(
  (ref, projectId) => ref
      .watch(listLayoutProvider(projectId).select((s) => s.layout.query))
      .withFilter(ref.watch(filterJsonProvider(projectId))),
);

final listLayoutReadyProvider = Provider.autoDispose.family<bool, String>(
  (ref, projectId) =>
      ref.watch(listLayoutProvider(projectId).select((s) => s.loaded)) &&
      ref.watch(filterReadyProvider(projectId)),
);
