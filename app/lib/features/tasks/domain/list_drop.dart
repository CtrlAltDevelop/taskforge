import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// Where on a hovered row a dragged task would land.
enum DropZone { above, onto, below }

/// What dropping on a row does.
sealed class RowDrop {
  const RowDrop();
}

/// Make the dragged task a subtask of the row.
final class NestDrop extends RowDrop {
  const NestDrop();
}

/// Move the dragged top-level task like a board card: into [column] of
/// [groupBy], next to [beforeId] / [afterId] (both empty: last).
final class MoveDrop extends RowDrop {
  const MoveDrop({
    required this.groupBy,
    required this.column,
    this.beforeId = '',
    this.afterId = '',
  });

  final String groupBy;
  final String column;
  final String beforeId;
  final String afterId;
}

/// The zone of a row [height] tall that a pointer [dy] from its top is in.
/// Without nesting the row has no middle: its halves are above and below.
DropZone zoneAt(double dy, double height, {required bool canNest}) {
  final edge = canNest ? 0.25 : 0.5;
  if (dy < height * edge) return DropZone.above;
  if (dy > height * (1 - edge)) return DropZone.below;
  return DropZone.onto;
}

/// What dropping [dragged] in [zone] of [target] does under [query]; null when
/// nothing. Only top-level tasks move (as on the board): they reorder when the
/// list is not sorted, and change group when it is grouped.
RowDrop? planRowDrop({
  required Task dragged,
  required Task target,
  required DropZone zone,
  required ListQuery query,
  required bool canNest,
}) {
  if (zone == DropZone.onto) return canNest ? const NestDrop() : null;
  if (dragged.parentId.isNotEmpty || target.parentId.isNotEmpty) return null;
  final grouped = query.groupBy.isNotEmpty;
  final column = grouped ? groupKeyOf(target, query.groupBy) : dragged.statusId;
  final reorder = query.sort.isEmpty;
  final changesGroup = grouped && column != groupKeyOf(dragged, query.groupBy);
  if (!reorder && !changesGroup) return null;
  return MoveDrop(
    groupBy: grouped ? query.groupBy : 'status',
    column: column,
    beforeId: reorder && zone == DropZone.above ? target.id : '',
    afterId: reorder && zone == DropZone.below ? target.id : '',
  );
}
