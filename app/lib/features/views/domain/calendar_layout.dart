import 'package:flutter/foundation.dart';

/// How a person likes a project's calendar: month, week or day; what the bars
/// are coloured by; the weekday a week begins on (ISO, 1 Monday ... 7 Sunday;
/// 0 lets the locale decide); whether finished tasks are hidden.
@immutable
class CalendarLayout {
  const CalendarLayout({
    this.mode = 'month',
    this.colorBy = 'status',
    this.weekStart = 0,
    this.hideDone = false,
  });

  final String mode;
  final String colorBy;
  final int weekStart;
  final bool hideDone;

  CalendarLayout copyWith({
    String? mode,
    String? colorBy,
    int? weekStart,
    bool? hideDone,
  }) => CalendarLayout(
    mode: mode ?? this.mode,
    colorBy: colorBy ?? this.colorBy,
    weekStart: weekStart ?? this.weekStart,
    hideDone: hideDone ?? this.hideDone,
  );

  @override
  bool operator ==(Object other) =>
      other is CalendarLayout &&
      other.mode == mode &&
      other.colorBy == colorBy &&
      other.weekStart == weekStart &&
      other.hideDone == hideDone;

  @override
  int get hashCode => Object.hash(mode, colorBy, weekStart, hideDone);
}

@immutable
class SavedCalendar {
  const SavedCalendar({
    required this.id,
    required this.name,
    required this.layout,
    required this.isShared,
    required this.version,
  });

  final String id;
  final String name;
  final CalendarLayout layout;
  final bool isShared;
  final int version;
}
