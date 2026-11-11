// `Ref.exists` is deprecated for a replacement this Riverpod does not have yet;
// it is the only way to ask whether another filter's list is alive.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart'
    show TaskRef;
import 'package:taskforge/features/inbox/data/inbox_client.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final inboxClientProvider = Provider<InboxClient>(
  (ref) => GrpcInboxClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// "Now" for the inbox (snooze, relative times); tests bring their own.
final inboxNowProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Unread notifications in the current workspace (0 while it cannot be read:
/// a badge must never be the thing that breaks a screen).
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final workspace = ref.watch(workspaceScopeProvider);
  if (workspace == null) return 0;
  try {
    return await ref.read(inboxClientProvider).unreadCount(workspace);
  } on Object {
    return 0;
  }
});

/// Unread in every workspace (what an app-icon badge would show).
final unreadTotalProvider = FutureProvider.autoDispose<int>((ref) async {
  if (ref.watch(workspaceScopeProvider) == null) return 0;
  try {
    return await ref.read(inboxClientProvider).unreadCount('');
  } on Object {
    return 0;
  }
});

@immutable
class InboxState {
  const InboxState({
    this.items = const [],
    this.cursor = '',
    this.unread = 0,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<InboxNotification> items;
  final String cursor;
  final int unread;
  final bool loading;
  final bool loadingMore;
  final InboxException? error;

  bool get hasMore => cursor.isNotEmpty;

  InboxState copyWith({
    List<InboxNotification>? items,
    String? cursor,
    int? unread,
    bool? loading,
    bool? loadingMore,
    InboxException? Function()? error,
  }) => InboxState(
    items: items ?? this.items,
    cursor: cursor ?? this.cursor,
    unread: unread ?? this.unread,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error == null ? this.error : error(),
  );
}

/// The caller's notifications in the current workspace under one filter:
/// newest page first, more on request; what the person does (read, snooze,
/// archive) shows at once and is put back, with the error thrown, when the
/// server refuses.
final inboxProvider = NotifierProvider.autoDispose
    .family<InboxNotifier, InboxState, InboxFilter>(InboxNotifier.new);

class InboxNotifier extends Notifier<InboxState> {
  InboxNotifier(this.filter);

  final InboxFilter filter;
  var _generation = 0;

  InboxClient get _client => ref.read(inboxClientProvider);
  DateTime get _now => ref.read(inboxNowProvider)();

  @override
  InboxState build() {
    ref.watch(workspaceScopeProvider);
    Future.microtask(load);
    return const InboxState();
  }

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const InboxException(InboxFailure.other);
    return id;
  }

  /// Reads the newest page again (what is on screen stays until it is here).
  Future<void> load() async {
    final generation = ++_generation;
    try {
      final page = await _client.list(_workspace, filter);
      if (generation != _generation || !ref.mounted) return;
      state = InboxState(
        items: page.notifications,
        cursor: page.cursor,
        unread: page.unread,
        loading: false,
      );
    } on Object catch (e) {
      if (generation != _generation || !ref.mounted) return;
      state = state.copyWith(loading: false, error: () => mapInboxError(e));
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    final generation = _generation;
    final workspace = _workspace;
    state = state.copyWith(loadingMore: true);
    try {
      final page = await _client.list(workspace, filter, before: state.cursor);
      if (generation != _generation || !ref.mounted) return;
      final have = {for (final n in state.items) n.id};
      state = state.copyWith(
        items: List.unmodifiable([
          ...state.items,
          for (final n in page.notifications)
            if (!have.contains(n.id)) n,
        ]),
        cursor: page.cursor,
        unread: page.unread,
        loadingMore: false,
      );
    } on Object {
      if (ref.mounted) state = state.copyWith(loadingMore: false);
    }
  }

  /// Applies [change] to what is shown, keeping only what still belongs here.
  List<InboxNotification> _shown(
    InboxNotification Function(InboxNotification) change,
    Set<String> ids,
  ) {
    final now = _now;
    final shown = <InboxNotification>[];
    for (final n in state.items) {
      final m = ids.contains(n.id) ? change(n) : n;
      if (m.belongsTo(filter, now)) shown.add(m);
    }
    return List.unmodifiable(shown);
  }

  /// Shows [items] and [unread] at once, runs [call], and puts the old list
  /// back (throwing what went wrong) if it fails.
  Future<void> _do(
    List<InboxNotification> items,
    int unread,
    Future<int?> Function(String workspace) call,
  ) async {
    final workspace = _workspace;
    final before = state;
    state = state.copyWith(items: items, unread: unread < 0 ? 0 : unread);
    try {
      final count = await call(workspace);
      if (!ref.mounted) return;
      if (count != null) state = state.copyWith(unread: count);
      ref.invalidate(unreadCountProvider);
      ref.invalidate(unreadTotalProvider);
      for (final other in InboxFilter.values) {
        if (other != filter && ref.exists(inboxProvider(other))) {
          ref.invalidate(inboxProvider(other));
        }
      }
    } on Object catch (e) {
      if (ref.mounted) state = before;
      throw mapInboxError(e);
    }
  }

  Future<void> markRead(InboxNotification n, {bool read = true}) {
    if (n.isRead == read) return Future.value();
    final at = _now;
    return _do(
      _shown((x) => x.copyWith(readAt: () => read ? at : null), {n.id}),
      state.unread + (read ? -1 : 1),
      (ws) => _client.markRead(ws, ids: [n.id], read: read),
    );
  }

  Future<void> markAllRead() {
    final at = _now;
    return _do(
      _shown((x) => x.copyWith(readAt: () => x.readAt ?? at), {
        for (final n in state.items) n.id,
      }),
      0,
      (ws) => _client.markRead(ws, all: true),
    );
  }

  Future<void> archive(InboxNotification n, {bool archived = true}) {
    final at = _now;
    return _do(
      _shown((x) => x.copyWith(archivedAt: () => archived ? at : null), {n.id}),
      state.unread - (archived && !n.isRead ? 1 : 0),
      (ws) async {
        await _client.archive(ws, [n.id], archived: archived);
        return null;
      },
    );
  }

  /// Hides [n] until [until] (null brings it back).
  Future<void> snooze(InboxNotification n, DateTime? until) => _do(
    _shown((x) => x.copyWith(snoozedUntil: () => until), {n.id}),
    state.unread - (until != null && !n.isRead ? 1 : 0),
    (ws) async {
      await _client.snooze(ws, n.id, until);
      return null;
    },
  );
}

/// The caller's channels per kind of event, and when they may be disturbed.
final prefsProvider = AsyncNotifierProvider.autoDispose<PrefsNotifier, Prefs>(
  PrefsNotifier.new,
);

class PrefsNotifier extends AsyncNotifier<Prefs> {
  InboxClient get _client => ref.read(inboxClientProvider);

  @override
  Future<Prefs> build() => _client.prefs();

  /// Changes one kind's channels at once; puts them back (and throws) when
  /// the server refuses.
  Future<void> setPref(PrefRow row) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData(
      Prefs([
        for (final r in before.rows)
          if (r.eventType == row.eventType) row else r,
      ], before.settings),
    );
    try {
      final saved = await _client.setPref(
        row.eventType,
        inbox: row.inbox,
        push: row.push,
        email: row.email,
      );
      if (ref.mounted) state = AsyncData(saved);
    } on Object catch (e) {
      if (ref.mounted) state = AsyncData(before);
      throw mapInboxError(e);
    }
  }

  Future<void> setSettings(InboxSettings settings) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData(Prefs(before.rows, settings));
    try {
      final saved = await _client.setSettings(settings);
      if (ref.mounted) state = AsyncData(saved);
    } on Object catch (e) {
      if (ref.mounted) state = AsyncData(before);
      throw mapInboxError(e);
    }
  }
}

/// Whether the caller watches a task, and how many people do.
final watchProvider = AsyncNotifierProvider.autoDispose
    .family<WatchNotifier, WatchState, TaskRef>(WatchNotifier.new);

class WatchNotifier extends AsyncNotifier<WatchState> {
  WatchNotifier(this.task);

  final TaskRef task;

  InboxClient get _client => ref.read(inboxClientProvider);

  @override
  Future<WatchState> build() {
    final workspace = ref.watch(workspaceScopeProvider);
    if (workspace == null) return Future.value(const WatchState());
    return _client.watchState(workspace, task.project, task.task);
  }

  Future<void> toggle() async {
    final workspace = ref.read(workspaceScopeProvider);
    final before = state.value;
    if (workspace == null || before == null) return;
    final on = !before.watching;
    state = AsyncData(
      WatchState(
        watching: on,
        watcherCount: (before.watcherCount + (on ? 1 : -1)).clamp(0, 1 << 30),
      ),
    );
    try {
      final saved = await _client.watch(
        workspace,
        task.project,
        task.task,
        on: on,
      );
      if (ref.mounted) state = AsyncData(saved);
    } on Object catch (e) {
      if (ref.mounted) state = AsyncData(before);
      throw mapInboxError(e);
    }
  }
}
