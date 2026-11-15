import 'dart:convert';

import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

/// A task as the local copy keeps it.
Map<String, dynamic> taskToMap(Task t) => {
  'id': t.id,
  'projectId': t.projectId,
  'number': t.number,
  'displayId': t.displayId,
  'title': t.title,
  'description': t.description,
  'statusId': t.statusId,
  'statusName': t.statusName,
  'statusCategory': t.statusCategory.wire,
  'priority': t.priority.wire,
  'startDate': t.startDate,
  'dueDate': t.dueDate,
  'dueTime': t.dueTime,
  'assigneeIds': t.assigneeIds,
  'version': t.version,
  'position': t.position,
  'deletedAt': t.deletedAt,
  'parentId': t.parentId,
  'depth': t.depth,
  'isBlocked': t.isBlocked,
  'blockedBy': t.blockedBy,
  'fieldValues': t.fieldValues,
  'blockersDue': t.blockersDue,
  'blocksDue': t.blocksDue,
  'progressDone': t.progressDone,
  'progressTotal': t.progressTotal,
  'createdAt': t.createdAt,
  'updatedAt': t.updatedAt,
};

String taskToJson(Task t) => jsonEncode(taskToMap(t));

List<String> _strings(Object? v) => [
  for (final s in (v as List<dynamic>? ?? const [])) '$s',
];

Task taskFromMap(Map<String, dynamic> m) => Task(
  id: '${m['id']}',
  projectId: '${m['projectId']}',
  number: (m['number'] as num?)?.toInt() ?? 0,
  displayId: '${m['displayId'] ?? ''}',
  title: '${m['title'] ?? ''}',
  description: '${m['description'] ?? ''}',
  statusId: '${m['statusId'] ?? ''}',
  statusName: '${m['statusName'] ?? ''}',
  statusCategory: StatusCategory.parse('${m['statusCategory'] ?? ''}'),
  priority: TaskPriority.parse('${m['priority'] ?? ''}'),
  startDate: '${m['startDate'] ?? ''}',
  dueDate: '${m['dueDate'] ?? ''}',
  dueTime: '${m['dueTime'] ?? ''}',
  assigneeIds: List.unmodifiable(_strings(m['assigneeIds'])),
  version: (m['version'] as num?)?.toInt() ?? 1,
  position: '${m['position'] ?? ''}',
  deletedAt: '${m['deletedAt'] ?? ''}',
  parentId: '${m['parentId'] ?? ''}',
  depth: (m['depth'] as num?)?.toInt() ?? 0,
  isBlocked: m['isBlocked'] == true,
  blockedBy: List.unmodifiable(_strings(m['blockedBy'])),
  fieldValues: Map.unmodifiable({
    for (final e
        in ((m['fieldValues'] as Map<String, dynamic>?) ?? const {}).entries)
      e.key: '${e.value}',
  }),
  blockersDue: '${m['blockersDue'] ?? ''}',
  blocksDue: '${m['blocksDue'] ?? ''}',
  progressDone: (m['progressDone'] as num?)?.toInt() ?? 0,
  progressTotal: (m['progressTotal'] as num?)?.toInt() ?? 0,
  createdAt: '${m['createdAt'] ?? ''}',
  updatedAt: '${m['updatedAt'] ?? ''}',
);

Task taskFromJson(String json) =>
    taskFromMap(jsonDecode(json) as Map<String, dynamic>);

/// The fields of a patch (only those set), as the outbox keeps them.
Map<String, dynamic> patchToMap(TaskPatch p) => {
  'title': ?p.title,
  'description': ?p.description,
  if (p.status != null)
    'status': {
      'id': p.status!.id,
      'name': p.status!.name,
      'category': p.status!.category.wire,
    },
  if (p.priority != null) 'priority': p.priority!.wire,
  'startDate': ?p.startDate,
  'dueDate': ?p.dueDate,
  'dueTime': ?p.dueTime,
  'assigneeIds': ?p.assigneeIds,
  'fieldValues': ?p.fieldValues,
};

TaskPatch patchFromMap(Map<String, dynamic> m) {
  final status = m['status'] as Map<String, dynamic>?;
  return TaskPatch(
    title: m['title'] as String?,
    description: m['description'] as String?,
    status: status == null
        ? null
        : WorkflowStatus(
            id: '${status['id']}',
            name: '${status['name'] ?? ''}',
            category: StatusCategory.parse('${status['category'] ?? ''}'),
          ),
    priority: m['priority'] == null
        ? null
        : TaskPriority.parse('${m['priority']}'),
    startDate: m['startDate'] as String?,
    dueDate: m['dueDate'] as String?,
    dueTime: m['dueTime'] as String?,
    assigneeIds: m['assigneeIds'] == null ? null : _strings(m['assigneeIds']),
    fieldValues: m['fieldValues'] == null
        ? null
        : {
            for (final e in (m['fieldValues'] as Map<String, dynamic>).entries)
              e.key: '${e.value}',
          },
  );
}

/// The tasks of one project in tree order (a parent right before its own
/// subtasks, each level by `position`), as the server lists them.
List<Task> inTreeOrder(Iterable<Task> tasks) {
  final byParent = <String, List<Task>>{};
  final ids = {for (final t in tasks) t.id};
  for (final t in tasks) {
    // A subtask whose parent is not here is listed at the top.
    final parent = ids.contains(t.parentId) ? t.parentId : '';
    byParent.putIfAbsent(parent, () => []).add(t);
  }
  for (final list in byParent.values) {
    list.sort((a, b) {
      final byPosition = a.position.compareTo(b.position);
      return byPosition != 0 ? byPosition : a.id.compareTo(b.id);
    });
  }
  final out = <Task>[];
  void walk(String parent) {
    for (final t in byParent[parent] ?? const <Task>[]) {
      out.add(t);
      walk(t.id);
    }
  }

  walk('');
  return out;
}

Map<String, dynamic> commentToMap(Comment c) => {
  'id': c.id,
  'taskId': c.taskId,
  'authorId': c.authorId,
  'parentId': c.parentId,
  'body': c.body,
  'createdAt': c.createdAt.toIso8601String(),
  'editedAt': c.editedAt?.toIso8601String(),
  'deleted': c.deleted,
  'pinned': c.pinned,
  'version': c.version,
  'mentionIds': c.mentionIds,
  'reactions': c.reactions,
  'editCount': c.editCount,
  'kind': c.kind,
  'event': c.event?.toJson(),
};

String commentToJson(Comment c) => jsonEncode(commentToMap(c));

Comment commentFromMap(
  Map<String, dynamic> m, {
  SendState sendState = SendState.sent,
}) => Comment(
  id: '${m['id']}',
  taskId: '${m['taskId']}',
  authorId: '${m['authorId'] ?? ''}',
  parentId: '${m['parentId'] ?? ''}',
  body: '${m['body'] ?? ''}',
  createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
  editedAt: m['editedAt'] == null
      ? null
      : DateTime.tryParse('${m['editedAt']}'),
  deleted: m['deleted'] == true,
  pinned: m['pinned'] == true,
  version: (m['version'] as num?)?.toInt() ?? 1,
  mentionIds: List.unmodifiable(_strings(m['mentionIds'])),
  reactions: Map.unmodifiable({
    for (final e
        in ((m['reactions'] as Map<String, dynamic>?) ?? const {}).entries)
      e.key: List<String>.unmodifiable(_strings(e.value)),
  }),
  editCount: (m['editCount'] as num?)?.toInt() ?? 0,
  sendState: sendState,
  kind: m['kind'] == 'system' ? 'system' : 'user',
  event: ChatEvent.tryParse('${m['event'] ?? ''}'),
);

Comment commentFromJson(String json, {SendState sendState = SendState.sent}) =>
    commentFromMap(
      jsonDecode(json) as Map<String, dynamic>,
      sendState: sendState,
    );

/// The board as it was last read (lanes, columns and their first cards).
String lanesToJson(List<BoardLane> lanes) => jsonEncode([
  for (final l in lanes)
    {
      'key': l.key,
      'columns': [
        for (final c in l.columns)
          {
            'key': c.key,
            'name': c.name,
            'count': c.count,
            'cursor': c.cursor,
            'tasks': [for (final t in c.tasks) taskToMap(t)],
          },
      ],
    },
]);

List<BoardLane> lanesFromJson(String json) => [
  for (final l in jsonDecode(json) as List<dynamic>)
    BoardLane(
      key: '${l['key']}',
      columns: [
        for (final c in l['columns'] as List<dynamic>)
          BoardColumn(
            key: '${c['key']}',
            name: '${c['name']}',
            count: (c['count'] as num?)?.toInt() ?? 0,
            cursor: '${c['cursor'] ?? ''}',
            tasks: List.unmodifiable([
              for (final t in c['tasks'] as List<dynamic>)
                taskFromMap(t as Map<String, dynamic>),
            ]),
          ),
      ],
    ),
];
