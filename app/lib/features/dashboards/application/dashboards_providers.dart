import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/dashboards/data/dashboards_client.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final dashboardsClientProvider = Provider<DashboardsClient>(
  (ref) => GrpcDashboardsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The viewer's day, asked for at every read: today's date and the device's
/// offset from UTC *now*, so a dashboard left open past midnight (or across a
/// daylight-saving change) asks about the right day. Tests bring their own.
final viewerDayProvider = Provider<ViewerDay Function()>(
  (ref) => () {
    final now = DateTime.now();
    final d =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return (today: d, offsetMinutes: now.timeZoneOffset.inMinutes);
  },
);

/// How often an open dashboard asks again (null: never). The server's own
/// cache lasts a minute, so asking sooner would only read the cache.
final dashboardRefreshProvider = Provider<Duration?>(
  (_) => const Duration(seconds: 60),
);

/// Dashboards the caller may open: of one project, or (empty) all of them.
final dashboardsProvider = FutureProvider.autoDispose
    .family<List<Dashboard>, String>((ref, projectId) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(dashboardsClientProvider).list(ws, projectId: projectId);
    }, retry: (_, _) => null);

/// The timer's tick: every widget on screen reads again (the server's cache
/// answers when it is still fresh).
class DashboardTick extends Notifier<int> {
  @override
  int build() => 0;

  void auto() => state = state + 1;
}

final dashboardTickProvider = NotifierProvider<DashboardTick, int>(
  DashboardTick.new,
);

/// The numbers of one saved widget. Keyed by its version, so editing it reads
/// afresh; a tick reads again without flicker (the old numbers stay up).
typedef WidgetKey = ({String id, int version});

final widgetDataProvider = FutureProvider.autoDispose
    .family<WidgetData, WidgetKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const WidgetData();
      ref.watch(dashboardTickProvider);
      return ref
          .watch(dashboardsClientProvider)
          .data(ws, key.id, ref.read(viewerDayProvider)());
    }, retry: (_, _) => null);

/// The tasks behind a widget's number or one of its buckets ('' for all).
typedef DrillKey = ({String widgetId, String bucket});

final drilldownProvider = FutureProvider.autoDispose.family<Drilled, DrillKey>((
  ref,
  key,
) async {
  final ws = ref.watch(workspaceScopeProvider);
  if (ws == null) return const Drilled([]);
  return ref
      .watch(dashboardsClientProvider)
      .drilldown(ws, key.widgetId, key.bucket, ref.read(viewerDayProvider)());
}, retry: (_, _) => null);

/// What the buttons do.
class DashboardActions {
  DashboardActions(this._ref);

  final Ref _ref;

  DashboardsClient get _client => _ref.read(dashboardsClientProvider);
  String get _ws => _ref.read(workspaceScopeProvider) ?? '';

  void _reread() => _ref.invalidate(dashboardsProvider);

  Future<Dashboard> save(Dashboard d) async {
    try {
      return await _client.save(_ws, d);
    } finally {
      _reread();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.delete(_ws, id);
    } finally {
      _reread();
    }
  }

  Future<Dashboard> fromTemplate(
    String template, {
    String projectId = '',
  }) async {
    try {
      return await _client.fromTemplate(_ws, template, projectId: projectId);
    } finally {
      _reread();
    }
  }

  /// Reads [keys] past the server's cache, then lets each widget read again
  /// (the fresh numbers are in the cache by then). Only the widgets named are
  /// asked; a failure is left for the widget's own read to show.
  Future<void> refreshWidgets(Iterable<WidgetKey> keys) async {
    final day = _ref.read(viewerDayProvider)();
    for (final key in keys) {
      try {
        await _client.data(_ws, key.id, day, refresh: true);
      } on Object {
        // The widget's own read, next, reports it.
      } finally {
        _ref.invalidate(widgetDataProvider(key));
      }
    }
  }

  Future<WidgetData> preview(
    String projectId,
    WidgetKind kind,
    WidgetConfig config,
  ) => _client.preview(
    _ws,
    projectId,
    kind,
    config,
    _ref.read(viewerDayProvider)(),
  );

  Future<String> exportCsv(String widgetId) =>
      _client.exportCsv(_ws, widgetId, _ref.read(viewerDayProvider)());
}

final dashboardActionsProvider = Provider<DashboardActions>(
  DashboardActions.new,
);
