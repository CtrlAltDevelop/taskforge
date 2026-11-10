import 'package:flutter/foundation.dart';

import 'package:taskforge/features/views/domain/list_layout.dart';

/// What a card can show besides its title and id. A custom field is
/// `field:<id>` ([fieldColumnPrefix]).
const builtInCardFields = <String, String>{
  'assignee': 'Assignee',
  'due_date': 'Due date',
  'priority': 'Priority',
  'progress': 'Subtask progress',
};

const defaultCardFields = ['assignee', 'due_date', 'priority', 'progress'];

/// What the board groups its columns by.
const boardGroupings = {'status', 'priority', 'assignee'};

/// How a person likes a project's board: the field the columns come from, the
/// optional swimlanes, what a card shows and each column's work-in-progress
/// limit. Immutable; every change returns a new layout.
@immutable
class BoardLayout {
  const BoardLayout({
    this.groupBy = 'status',
    this.swimlane = '',
    this.cardFields = defaultCardFields,
    this.limits = const {},
  });

  /// `status`, `priority`, `assignee` or `field:<select field id>`.
  final String groupBy;

  /// Empty, or `assignee`.
  final String swimlane;
  final List<String> cardFields;

  /// Column key -> limit (a column with none has no entry).
  final Map<String, int> limits;

  /// What the server needs to lay the board out: a limit or a card field
  /// changes no read.
  ({String groupBy, String swimlane}) get query =>
      (groupBy: groupBy, swimlane: swimlane);

  BoardLayout copyWith({
    String? groupBy,
    String? swimlane,
    List<String>? cardFields,
    Map<String, int>? limits,
  }) => BoardLayout(
    groupBy: groupBy ?? this.groupBy,
    swimlane: swimlane ?? this.swimlane,
    cardFields: List.unmodifiable(cardFields ?? this.cardFields),
    limits: Map.unmodifiable(limits ?? this.limits),
  );

  BoardLayout withCardField(String key, {required bool shown}) => copyWith(
    cardFields: [
      for (final f in cardFields)
        if (f != key) f,
      if (shown) key,
    ],
  );

  /// [limit] for [column]; null or less than one clears it.
  BoardLayout withLimit(String column, int? limit) => copyWith(
    limits: {
      for (final e in limits.entries)
        if (e.key != column) e.key: e.value,
      if (limit != null && limit > 0) column: limit,
    },
  );

  @override
  bool operator ==(Object other) =>
      other is BoardLayout &&
      other.groupBy == groupBy &&
      other.swimlane == swimlane &&
      listEquals(other.cardFields, cardFields) &&
      mapEquals(other.limits, limits);

  @override
  int get hashCode => Object.hash(
    groupBy,
    swimlane,
    Object.hashAll(cardFields),
    Object.hashAll(limits.entries.map((e) => Object.hash(e.key, e.value))),
  );
}

/// One stored board layout (the caller's own or one shared with the project).
@immutable
class SavedBoard {
  const SavedBoard({
    required this.id,
    required this.name,
    required this.layout,
    required this.isShared,
    required this.version,
  });

  final String id;
  final String name;
  final BoardLayout layout;
  final bool isShared;
  final int version;
}
