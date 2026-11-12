import 'package:taskforge/features/dashboards/data/dashboards_client.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';

DashboardWidget widgetOf(
  String id,
  WidgetKind kind, {
  String title = '',
  WidgetConfig config = const WidgetConfig(),
  int version = 1,
}) => DashboardWidget(
  id: id,
  kind: kind,
  title: title.isEmpty ? kind.label : title,
  config: config,
  version: version,
);

Dashboard dashboardOf(
  String id,
  String name,
  List<DashboardWidget> widgets, {
  List<LayoutCell>? layout,
  DashVisibility visibility = DashVisibility.workspace,
  bool canEdit = true,
  String projectId = '',
}) => Dashboard(
  id: id,
  name: name,
  visibility: visibility,
  projectId: projectId,
  canEdit: canEdit,
  widgets: widgets,
  layout:
      layout ??
      [
        for (var i = 0; i < widgets.length; i++)
          LayoutCell(widgets[i].id, (i % 2) * 6, (i ~/ 2) * 3, 6, 3),
      ],
);

WidgetData numberData(String value) => WidgetData(total: value);

WidgetData barsData(Map<String, String> byKey, {String? total}) => WidgetData(
  total: total ?? '0',
  buckets: [
    for (final e in byKey.entries) Bucket(e.key, e.key.toUpperCase(), e.value),
  ],
);

/// A dashboards server in memory: it keeps what was saved, answers each
/// widget from [dataOf], lists drill-down tasks from [drillOf], and notes the
/// calls it got.
class FakeDashboardsClient implements DashboardsClient {
  FakeDashboardsClient(List<Dashboard> initial) : dashboards = [...initial];

  final List<Dashboard> dashboards;
  final Map<String, WidgetData> dataOf = {};
  final Map<String, List<DrillTask>> drillOf = {}; // "widgetId|bucket"
  final Set<String> cutShort = {}; // drill keys the server says it truncated
  WidgetData previewData = const WidgetData(total: '7');

  final dataCalls = <({String widget, bool refresh})>[];
  final saved = <Dashboard>[];
  final previews = <({WidgetKind kind, WidgetConfig config})>[];
  final templates = <String>[];
  final deleted = <String>[];
  final drills = <String>[];
  final days = <String>[]; // the day each numbers read asked about

  DashboardException? failData;
  var _n = 0;

  @override
  Future<List<Dashboard>> list(
    String workspaceId, {
    String projectId = '',
  }) async => [
    for (final d in dashboards)
      if (projectId.isEmpty || d.projectId == projectId) d,
  ];

  @override
  Future<Dashboard> save(String workspaceId, Dashboard dashboard) async {
    saved.add(dashboard);
    final made = Dashboard(
      id: dashboard.id.isEmpty ? 'd${++_n}' : dashboard.id,
      name: dashboard.name,
      visibility: dashboard.visibility,
      projectId: dashboard.projectId,
      widgets: dashboard.widgets,
      layout: dashboard.layout,
      version: dashboard.version + 1,
    );
    dashboards
      ..removeWhere((d) => d.id == made.id)
      ..add(made);
    return made;
  }

  @override
  Future<void> delete(String workspaceId, String id) async {
    deleted.add(id);
    dashboards.removeWhere((d) => d.id == id);
  }

  @override
  Future<Dashboard> fromTemplate(
    String workspaceId,
    String template, {
    String projectId = '',
  }) async {
    templates.add(template);
    final made = dashboardOf('t${++_n}', template, [
      widgetOf('${template}1', WidgetKind.number, title: 'Open tasks'),
      widgetOf('${template}2', WidgetKind.bar, title: 'By status'),
    ], visibility: DashVisibility.personal);
    dashboards.add(made);
    dataOf['${template}1'] = numberData('4');
    dataOf['${template}2'] = barsData({'todo': '3', 'done': '1'});
    return made;
  }

  @override
  Future<WidgetData> data(
    String workspaceId,
    String widgetId,
    ViewerDay day, {
    bool refresh = false,
  }) async {
    dataCalls.add((widget: widgetId, refresh: refresh));
    days.add(day.today);
    final f = failData;
    if (f != null) {
      failData = null;
      throw f;
    }
    return dataOf[widgetId] ?? const WidgetData();
  }

  @override
  Future<WidgetData> preview(
    String workspaceId,
    String projectId,
    WidgetKind kind,
    WidgetConfig config,
    ViewerDay day,
  ) async {
    previews.add((kind: kind, config: config));
    return previewData;
  }

  @override
  Future<Drilled> drilldown(
    String workspaceId,
    String widgetId,
    String bucket,
    ViewerDay day,
  ) async {
    drills.add('$widgetId|$bucket');
    return Drilled(
      drillOf['$widgetId|$bucket'] ?? const [],
      truncated: cutShort.contains('$widgetId|$bucket'),
    );
  }

  @override
  Future<String> exportCsv(
    String workspaceId,
    String widgetId,
    ViewerDay day,
  ) async => 'key,label,value\nhigh,High,2.00\n';
}

DrillTask drill(String id, String title, {String project = 'p1'}) => DrillTask(
  id: id,
  projectId: project,
  displayId: 'WEB-$id',
  title: title,
  statusName: 'To do',
  priority: 'high',
);
