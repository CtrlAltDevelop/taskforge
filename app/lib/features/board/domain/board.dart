import 'package:flutter/foundation.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';

/// One column of the board: [key] is what its cards hold (a status id, a
/// priority, a user id, an option id; empty: tasks with no value). [count] is
/// every card of the column, [tasks] the ones loaded so far, [cursor] where
/// the next page starts (empty: all loaded).
@immutable
class BoardColumn {
  const BoardColumn({
    required this.key,
    this.name = '',
    this.count = 0,
    this.tasks = const [],
    this.cursor = '',
  });

  final String key;
  final String name;
  final int count;
  final List<Task> tasks;
  final String cursor;

  bool get hasMore => cursor.isNotEmpty;

  BoardColumn copyWith({int? count, List<Task>? tasks, String? cursor}) =>
      BoardColumn(
        key: key,
        name: name,
        count: count ?? this.count,
        tasks: List.unmodifiable(tasks ?? this.tasks),
        cursor: cursor ?? this.cursor,
      );
}

/// A row of the board: the assignee it is for, or empty for the only row of a
/// board without swimlanes.
@immutable
class BoardLane {
  const BoardLane({required this.key, required this.columns});

  final String key;
  final List<BoardColumn> columns;

  BoardLane mapColumns(BoardColumn Function(BoardColumn) change) => BoardLane(
    key: key,
    columns: List.unmodifiable([for (final c in columns) change(c)]),
  );
}

/// [lanes] with [task] dropped into column [toColumn] of lane [laneKey]:
/// right before [beforeId], else right after [afterId], else last. The card
/// leaves the column it was in (counts follow). Pure: the optimistic view of a
/// drop, put right again by the server's answer.
List<BoardLane> dropCard(
  List<BoardLane> lanes,
  Task task, {
  required String laneKey,
  required String toColumn,
  String beforeId = '',
  String afterId = '',
}) => List.unmodifiable([
  for (final lane in lanes)
    if (lane.key != laneKey)
      lane
    else
      lane.mapColumns((column) {
        final had = column.tasks.any((t) => t.id == task.id);
        final others = [
          for (final t in column.tasks)
            if (t.id != task.id) t,
        ];
        if (column.key != toColumn) {
          return had
              ? column.copyWith(count: column.count - 1, tasks: others)
              : column;
        }
        var at = others.length;
        final before = others.indexWhere((t) => t.id == beforeId);
        final after = others.indexWhere((t) => t.id == afterId);
        if (before >= 0) {
          at = before;
        } else if (after >= 0) {
          at = after + 1;
        }
        return column.copyWith(
          count: had ? column.count : column.count + 1,
          tasks: [...others.take(at), task, ...others.skip(at)],
        );
      }),
]);

/// [lanes] with [task] swapped for its newer copy wherever it is shown.
List<BoardLane> replaceCard(List<BoardLane> lanes, Task task) =>
    List.unmodifiable([
      for (final lane in lanes)
        lane.mapColumns(
          (c) => c.tasks.any((t) => t.id == task.id)
              ? c.copyWith(
                  tasks: [for (final t in c.tasks) t.id == task.id ? task : t],
                )
              : c,
        ),
    ]);

/// [lanes] with a later page appended to one column (cards already shown are
/// skipped: a card dropped at the end of a long column is in its loaded part).
List<BoardLane> appendPage(
  List<BoardLane> lanes, {
  required String laneKey,
  required String columnKey,
  required List<Task> tasks,
  required String cursor,
}) => List.unmodifiable([
  for (final lane in lanes)
    if (lane.key != laneKey)
      lane
    else
      lane.mapColumns((c) {
        if (c.key != columnKey) return c;
        final shown = {for (final t in c.tasks) t.id};
        return c.copyWith(
          tasks: [
            ...c.tasks,
            for (final t in tasks)
              if (!shown.contains(t.id)) t,
          ],
          cursor: cursor,
        );
      }),
]);
