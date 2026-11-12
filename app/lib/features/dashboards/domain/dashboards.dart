import 'dart:convert';

import 'package:flutter/foundation.dart';

/// How many columns the grid has; a cell is `x..x+w` of them.
const gridColumns = 12;

/// The most widgets one dashboard holds (the server refuses more).
const maxWidgets = 20;

enum WidgetKind {
  number('number', 'Number'),
  bar('bar', 'Bar chart'),
  line('line', 'Line chart'),
  pie('pie', 'Pie chart'),
  table('table', 'Table'),
  burndown('burndown', 'Burndown'),
  workload('workload', 'Workload');

  const WidgetKind(this.wire, this.label);

  final String wire;
  final String label;

  static WidgetKind of(String wire) =>
      values.firstWhere((k) => k.wire == wire, orElse: () => number);

  /// Needs a grouping of its own choosing.
  bool get picksGrouping => this == bar || this == pie || this == table;
}

enum Measure {
  count('count', 'Task count'),
  points('points', 'Story points'),
  estimateHours('estimate_hours', 'Estimated hours'),
  loggedHours('logged_hours', 'Logged hours'),
  cycleDays('cycle_days', 'Cycle time (days)');

  const Measure(this.wire, this.label);

  final String wire;
  final String label;

  static Measure of(String wire) =>
      values.firstWhere((m) => m.wire == wire, orElse: () => count);
}

/// What a grouping is called, by its wire name.
const groupings = <String, String>{
  'status': 'Status',
  'category': 'Status category',
  'assignee': 'Person',
  'priority': 'Priority',
  'project': 'Project',
  'sprint': 'Sprint',
  'created_day': 'Created (day)',
  'created_week': 'Created (week)',
  'due_week': 'Due (week)',
};

/// The groupings that make sense on a time axis.
const timeGroupings = ['created_day', 'created_week', 'due_week'];

enum Scope {
  all('all', 'All tasks'),
  open('open', 'Open tasks'),
  done('done', 'Done tasks');

  const Scope(this.wire, this.label);

  final String wire;
  final String label;

  static Scope of(String wire) =>
      values.firstWhere((s) => s.wire == wire, orElse: () => all);
}

/// Who may open a dashboard.
enum DashVisibility {
  personal('personal', 'Only me'),
  project('project', 'Everyone in the project'),
  workspace('workspace', 'Everyone in the workspace');

  const DashVisibility(this.wire, this.label);

  final String wire;
  final String label;

  static DashVisibility of(String wire) =>
      values.firstWhere((v) => v.wire == wire, orElse: () => personal);
}

/// What a widget counts and how: the saved config, immutable.
@immutable
class WidgetConfig {
  const WidgetConfig({
    this.tfql = '',
    this.filterId = '',
    this.measure = Measure.count,
    this.groupBy = '',
    this.scope = Scope.all,
    this.sprintId = '',
    this.projectId = '',
    this.limit = 12,
    this.rangeDays = 90,
  });

  factory WidgetConfig.fromJson(String json) {
    try {
      final m = jsonDecode(json);
      if (m is! Map<String, dynamic>) return const WidgetConfig();
      final source = (m['source'] as Map?)?.cast<String, dynamic>() ?? const {};
      return WidgetConfig(
        tfql: source['tfql'] as String? ?? '',
        filterId: source['filter_id'] as String? ?? '',
        measure: Measure.of(m['measure'] as String? ?? 'count'),
        groupBy: m['group_by'] as String? ?? '',
        scope: Scope.of(m['scope'] as String? ?? 'all'),
        sprintId: m['sprint_id'] as String? ?? '',
        projectId: m['project_id'] as String? ?? '',
        limit: (m['limit'] as num?)?.toInt() ?? 12,
        rangeDays: (m['range_days'] as num?)?.toInt() ?? 90,
      );
    } on FormatException {
      return const WidgetConfig();
    }
  }

  final String tfql;
  final String filterId;
  final Measure measure;
  final String groupBy;
  final Scope scope;
  final String sprintId;
  final String projectId;
  final int limit;
  final int rangeDays;

  String toJson() => jsonEncode({
    'source': {'tfql': tfql, 'filter_id': filterId},
    'measure': measure.wire,
    'group_by': groupBy,
    'scope': scope.wire,
    'sprint_id': sprintId,
    'project_id': projectId,
    'limit': limit,
    'range_days': rangeDays,
  });

  WidgetConfig copyWith({
    String? tfql,
    String? filterId,
    Measure? measure,
    String? groupBy,
    Scope? scope,
    String? sprintId,
    String? projectId,
    int? limit,
    int? rangeDays,
  }) => WidgetConfig(
    tfql: tfql ?? this.tfql,
    filterId: filterId ?? this.filterId,
    measure: measure ?? this.measure,
    groupBy: groupBy ?? this.groupBy,
    scope: scope ?? this.scope,
    sprintId: sprintId ?? this.sprintId,
    projectId: projectId ?? this.projectId,
    limit: limit ?? this.limit,
    rangeDays: rangeDays ?? this.rangeDays,
  );

  @override
  bool operator ==(Object other) =>
      other is WidgetConfig && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;
}

@immutable
class DashboardWidget {
  const DashboardWidget({
    required this.id,
    required this.kind,
    required this.title,
    required this.config,
    this.version = 1,
  });

  final String id;
  final WidgetKind kind;
  final String title;
  final WidgetConfig config;
  final int version;

  DashboardWidget copyWith({
    WidgetKind? kind,
    String? title,
    WidgetConfig? config,
  }) => DashboardWidget(
    id: id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    config: config ?? this.config,
    version: version,
  );
}

/// Where one widget sits on the 12-column grid.
@immutable
class LayoutCell {
  const LayoutCell(this.widgetId, this.x, this.y, this.w, this.h);

  final String widgetId;
  final int x;
  final int y;
  final int w;
  final int h;

  LayoutCell copyWith({int? x, int? y, int? w, int? h}) =>
      LayoutCell(widgetId, x ?? this.x, y ?? this.y, w ?? this.w, h ?? this.h);

  bool overlaps(LayoutCell o) =>
      x < o.x + o.w && o.x < x + w && y < o.y + o.h && o.y < y + h;

  Map<String, Object> toJson() => {
    'widget_id': widgetId,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
  };
}

List<LayoutCell> decodeLayout(String json) {
  try {
    final list = jsonDecode(json);
    if (list is! List) return const [];
    return [
      for (final c in list)
        if (c is Map)
          LayoutCell(
            c['widget_id'] as String? ?? '',
            (c['x'] as num?)?.toInt() ?? 0,
            (c['y'] as num?)?.toInt() ?? 0,
            (c['w'] as num?)?.toInt() ?? 6,
            (c['h'] as num?)?.toInt() ?? 3,
          ),
    ];
  } on FormatException {
    return const [];
  }
}

String encodeLayout(List<LayoutCell> cells) =>
    jsonEncode([for (final c in cells) c.toJson()]);

const minCellWidth = 2;

/// A card's header and a little body need two rows of the grid.
const minCellHeight = 2;
const maxCellHeight = 12;

/// [cell] kept on the grid: inside the columns, at least [minCellWidth] wide.
LayoutCell clampCell(LayoutCell cell) {
  final w = cell.w.clamp(minCellWidth, gridColumns);
  final h = cell.h.clamp(minCellHeight, maxCellHeight);
  return LayoutCell(
    cell.widgetId,
    cell.x.clamp(0, gridColumns - w),
    cell.y < 0 ? 0 : cell.y,
    w,
    h,
  );
}

/// Pushes a cell down until it overlaps no cell above it. Cells that did not
/// collide stay where they are, so a move never shuffles the rest.
List<LayoutCell> resolveOverlaps(List<LayoutCell> cells) {
  final sorted = [...cells]
    ..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
  final placed = <LayoutCell>[];
  for (final cell in sorted) {
    var c = clampCell(cell);
    while (placed.any(c.overlaps)) {
      c = c.copyWith(y: c.y + 1);
    }
    placed.add(c);
  }
  final byId = {for (final c in placed) c.widgetId: c};
  return [for (final c in cells) byId[c.widgetId]!];
}

/// [id] moved by [dx] columns and [dy] rows.
List<LayoutCell> moveCell(List<LayoutCell> cells, String id, int dx, int dy) =>
    resolveOverlaps([
      for (final c in cells)
        if (c.widgetId == id)
          clampCell(c.copyWith(x: c.x + dx, y: c.y + dy))
        else
          c,
    ]);

/// [id] made [dw] columns wider and [dh] rows taller.
List<LayoutCell> resizeCell(
  List<LayoutCell> cells,
  String id,
  int dw,
  int dh,
) => resolveOverlaps([
  for (final c in cells)
    if (c.widgetId == id)
      clampCell(c.copyWith(w: c.w + dw, h: c.h + dh))
    else
      c,
]);

/// A new cell for [id] under everything else.
List<LayoutCell> addCell(List<LayoutCell> cells, String id) {
  final bottom = cells.fold<int>(0, (m, c) => c.y + c.h > m ? c.y + c.h : m);
  return [...cells, LayoutCell(id, 0, bottom, 6, 3)];
}

@immutable
class Dashboard {
  const Dashboard({
    required this.id,
    required this.name,
    required this.visibility,
    required this.widgets,
    required this.layout,
    this.projectId = '',
    this.ownerId = '',
    this.version = 1,
    this.canEdit = true,
  });

  final String id;
  final String name;
  final DashVisibility visibility;
  final String projectId;
  final String ownerId;
  final List<DashboardWidget> widgets;
  final List<LayoutCell> layout;
  final int version;
  final bool canEdit;

  Dashboard copyWith({
    String? name,
    DashVisibility? visibility,
    String? projectId,
    List<DashboardWidget>? widgets,
    List<LayoutCell>? layout,
  }) => Dashboard(
    id: id,
    name: name ?? this.name,
    visibility: visibility ?? this.visibility,
    projectId: projectId ?? this.projectId,
    ownerId: ownerId,
    widgets: widgets ?? this.widgets,
    layout: layout ?? this.layout,
    version: version,
    canEdit: canEdit,
  );
}

@immutable
class Bucket {
  const Bucket(this.key, this.label, this.value);

  final String key;
  final String label;

  /// The number as the server wrote it ("12.50"), so nothing is rounded twice.
  final String value;

  double get amount => double.tryParse(value) ?? 0;
}

@immutable
class SeriesPoint {
  const SeriesPoint(this.x, this.y);

  final String x;
  final String y;

  double get amount => double.tryParse(y) ?? 0;
}

@immutable
class Series {
  const Series(this.name, this.points);

  final String name;
  final List<SeriesPoint> points;
}

@immutable
class WidgetData {
  const WidgetData({
    this.total = '0',
    this.buckets = const [],
    this.series = const [],
    this.truncated = false,
    this.cached = false,
    this.computedAt,
  });

  final String total;
  final List<Bucket> buckets;
  final List<Series> series;
  final bool truncated;
  final bool cached;
  final DateTime? computedAt;
}

@immutable
class DrillTask {
  const DrillTask({
    required this.id,
    required this.projectId,
    required this.displayId,
    required this.title,
    required this.statusName,
    this.statusCategory = '',
    this.priority = '',
    this.dueDate = '',
    this.points = '',
  });

  final String id;
  final String projectId;
  final String displayId;
  final String title;
  final String statusName;
  final String statusCategory;
  final String priority;
  final String dueDate;
  final String points;
}

/// The tasks behind a number; [truncated] says the server cut the list short.
@immutable
class Drilled {
  const Drilled(this.tasks, {this.truncated = false});

  final List<DrillTask> tasks;
  final bool truncated;
}

/// A number as a person reads it: no trailing `.00`.
String shortNumber(String raw) {
  final v = double.tryParse(raw);
  if (v == null) return raw;
  return v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);
}

enum DashboardFailure {
  denied,
  notFound,
  invalid,
  tooHeavy,
  conflict,
  network,
  other,
}

class DashboardException implements Exception {
  const DashboardException(this.failure, {this.detail = ''});

  final DashboardFailure failure;
  final String detail;

  @override
  String toString() => 'DashboardException($failure: $detail)';
}

String dashboardErrorMessage(Object error) {
  final e = error is DashboardException ? error : null;
  return switch (e?.failure) {
    DashboardFailure.denied =>
      'You are not allowed to do that on this dashboard.',
    DashboardFailure.notFound => 'That dashboard or widget is not available.',
    DashboardFailure.invalid =>
      e!.detail.isEmpty ? 'That is not valid.' : e.detail,
    DashboardFailure.tooHeavy =>
      'This widget takes too long to compute. Narrow its filter.',
    DashboardFailure.conflict =>
      'Someone else changed this dashboard. Reload it and try again.',
    DashboardFailure.network => 'Could not reach the server. Try again.',
    _ => 'Something went wrong. Try again.',
  };
}
