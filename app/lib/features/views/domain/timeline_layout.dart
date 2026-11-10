import 'package:flutter/foundation.dart';

/// How a person likes a project's timeline: the zoom (`day`, `week`, `month`
/// or `quarter`), what rows are grouped by (`''` for the task tree, `assignee`
/// or `status`), whether finished tasks are hidden and whether the critical
/// path is lit.
@immutable
class TimelineLayout {
  const TimelineLayout({
    this.zoom = 'week',
    this.groupBy = '',
    this.hideDone = false,
    this.criticalPath = false,
  });

  final String zoom;
  final String groupBy;
  final bool hideDone;
  final bool criticalPath;

  TimelineLayout copyWith({
    String? zoom,
    String? groupBy,
    bool? hideDone,
    bool? criticalPath,
  }) => TimelineLayout(
    zoom: zoom ?? this.zoom,
    groupBy: groupBy ?? this.groupBy,
    hideDone: hideDone ?? this.hideDone,
    criticalPath: criticalPath ?? this.criticalPath,
  );

  @override
  bool operator ==(Object other) =>
      other is TimelineLayout &&
      other.zoom == zoom &&
      other.groupBy == groupBy &&
      other.hideDone == hideDone &&
      other.criticalPath == criticalPath;

  @override
  int get hashCode => Object.hash(zoom, groupBy, hideDone, criticalPath);
}

@immutable
class SavedTimeline {
  const SavedTimeline({
    required this.id,
    required this.name,
    required this.layout,
    required this.isShared,
    required this.version,
  });

  final String id;
  final String name;
  final TimelineLayout layout;
  final bool isShared;
  final int version;
}
