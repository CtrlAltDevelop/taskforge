import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/gen/infrastructure/dashboards/grpc/dashboards.pbgrpc.dart'
    as pb;

/// The caller's day: what "today" is and how far it is from UTC, so buckets
/// of days and relative dates in a filter fall where the viewer expects.
typedef ViewerDay = ({String today, int offsetMinutes});

abstract interface class DashboardsClient {
  Future<List<Dashboard>> list(String workspaceId, {String projectId = ''});
  Future<Dashboard> save(String workspaceId, Dashboard dashboard);
  Future<void> delete(String workspaceId, String id);
  Future<Dashboard> fromTemplate(
    String workspaceId,
    String template, {
    String projectId = '',
  });
  Future<WidgetData> data(
    String workspaceId,
    String widgetId,
    ViewerDay day, {
    bool refresh = false,
  });
  Future<WidgetData> preview(
    String workspaceId,
    String projectId,
    WidgetKind kind,
    WidgetConfig config,
    ViewerDay day,
  );
  Future<Drilled> drilldown(
    String workspaceId,
    String widgetId,
    String bucket,
    ViewerDay day,
  );
  Future<String> exportCsv(String workspaceId, String widgetId, ViewerDay day);
}

DashboardException mapDashboardError(Object error) {
  if (error is DashboardException) return error;
  if (error is GrpcError) {
    final text = error.message ?? '';
    final message = text.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), '');
    return switch (error.code) {
      StatusCode.permissionDenied => const DashboardException(
        DashboardFailure.denied,
      ),
      StatusCode.notFound => const DashboardException(
        DashboardFailure.notFound,
      ),
      StatusCode.aborted => const DashboardException(DashboardFailure.conflict),
      StatusCode.invalidArgument =>
        text.startsWith('DASHBOARD_TOO_HEAVY')
            ? const DashboardException(DashboardFailure.tooHeavy)
            : DashboardException(DashboardFailure.invalid, detail: message),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const DashboardException(DashboardFailure.network),
      _ => const DashboardException(DashboardFailure.other),
    };
  }
  return const DashboardException(DashboardFailure.network);
}

Dashboard dashboardFromPb(pb.Dashboard d) => Dashboard(
  id: d.id,
  name: d.name,
  visibility: DashVisibility.of(d.visibility),
  projectId: d.projectId,
  ownerId: d.ownerId,
  version: d.version,
  canEdit: d.canEdit,
  layout: decodeLayout(d.layoutJson),
  widgets: [
    for (final w in d.widgets)
      DashboardWidget(
        id: w.id,
        kind: WidgetKind.of(w.type),
        title: w.title,
        config: WidgetConfig.fromJson(w.configJson),
        version: w.version,
      ),
  ],
);

WidgetData dataFromPb(pb.WidgetData d) => WidgetData(
  total: d.total,
  truncated: d.truncated,
  cached: d.cached,
  computedAt: DateTime.tryParse(d.computedAt),
  buckets: [for (final b in d.buckets) Bucket(b.key, b.label, b.value)],
  series: [
    for (final s in d.series)
      Series(s.name, [for (final p in s.points) SeriesPoint(p.x, p.y)]),
  ],
);

class GrpcDashboardsClient implements DashboardsClient {
  GrpcDashboardsClient(ClientChannelBase channel, this._session)
    : _dashboards = pb.DashboardControllerClient(channel),
      _widgets = pb.WidgetControllerClient(channel);

  final pb.DashboardControllerClient _dashboards;
  final pb.WidgetControllerClient _widgets;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapDashboardError(e);
    }
  }

  @override
  Future<List<Dashboard>> list(String workspaceId, {String projectId = ''}) =>
      _run(() async {
        final out = await _dashboards.list(
          pb.DashboardListRequest(
            workspaceId: workspaceId,
            projectId: projectId,
          ),
          options: _options,
        );
        return List.unmodifiable(out.dashboards.map(dashboardFromPb));
      });

  @override
  Future<Dashboard> save(String workspaceId, Dashboard d) => _run(
    () async => dashboardFromPb(
      (await _dashboards.save(
        pb.DashboardSaveRequest(
          workspaceId: workspaceId,
          id: d.id,
          name: d.name,
          visibility: d.visibility.wire,
          projectId: d.projectId,
          widgets: [
            for (final w in d.widgets)
              pb.WidgetInput(
                id: w.id,
                type: w.kind.wire,
                title: w.title,
                configJson: w.config.toJson(),
              ),
          ],
          layoutJson: encodeLayout(d.layout),
          expectedVersion: d.id.isEmpty ? 0 : d.version,
        ),
        options: _options,
      )).dashboard,
    ),
  );

  @override
  Future<void> delete(String workspaceId, String id) => _run(
    () async => _dashboards.delete(
      pb.DashboardDeleteRequest(workspaceId: workspaceId, id: id),
      options: _options,
    ),
  );

  @override
  Future<Dashboard> fromTemplate(
    String workspaceId,
    String template, {
    String projectId = '',
  }) => _run(
    () async => dashboardFromPb(
      (await _dashboards.fromTemplate(
        pb.DashboardFromTemplateRequest(
          workspaceId: workspaceId,
          template: template,
          projectId: projectId,
        ),
        options: _options,
      )).dashboard,
    ),
  );

  @override
  Future<WidgetData> data(
    String workspaceId,
    String widgetId,
    ViewerDay day, {
    bool refresh = false,
  }) => _run(
    () async => dataFromPb(
      await _widgets.data(
        pb.WidgetDataRequest(
          workspaceId: workspaceId,
          widgetId: widgetId,
          today: day.today,
          utcOffsetMinutes: day.offsetMinutes,
          refresh: refresh,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<WidgetData> preview(
    String workspaceId,
    String projectId,
    WidgetKind kind,
    WidgetConfig config,
    ViewerDay day,
  ) => _run(
    () async => dataFromPb(
      await _widgets.preview(
        pb.WidgetPreviewRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          type: kind.wire,
          configJson: config.toJson(),
          today: day.today,
          utcOffsetMinutes: day.offsetMinutes,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Drilled> drilldown(
    String workspaceId,
    String widgetId,
    String bucket,
    ViewerDay day,
  ) => _run(() async {
    final out = <DrillTask>[];
    var cut = false;
    await for (final m in _widgets.drilldown(
      pb.WidgetDrilldownRequest(
        workspaceId: workspaceId,
        widgetId: widgetId,
        bucket: bucket,
        today: day.today,
        utcOffsetMinutes: day.offsetMinutes,
      ),
      options: _options,
    )) {
      cut = cut || m.truncated;
      final t = m.task;
      out.add(
        DrillTask(
          id: t.id,
          projectId: t.projectId,
          displayId: t.displayId,
          title: t.title,
          statusName: t.statusName,
          statusCategory: t.statusCategory,
          priority: t.priority,
          dueDate: t.dueDate,
          points: t.points,
        ),
      );
    }
    return Drilled(List.unmodifiable(out), truncated: cut);
  });

  @override
  Future<String> exportCsv(
    String workspaceId,
    String widgetId,
    ViewerDay day,
  ) => _run(
    () async => (await _widgets.export(
      pb.WidgetExportRequest(
        workspaceId: workspaceId,
        widgetId: widgetId,
        today: day.today,
        utcOffsetMinutes: day.offsetMinutes,
      ),
      options: _options,
    )).csv,
  );
}
