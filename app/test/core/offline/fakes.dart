import 'package:drift/native.dart';
import 'package:taskforge/core/offline/local_db.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/features/comments/data/comments_client.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

Task serverTask(
  String id,
  String title, {
  String project = 'p1',
  int version = 1,
  String parent = '',
  int depth = 0,
  String position = 'aaaaaa',
  String due = '',
}) => Task(
  id: id,
  projectId: project,
  number: 1,
  displayId: 'WEB-1',
  title: title,
  statusId: 's-todo',
  statusName: 'To do',
  version: version,
  parentId: parent,
  depth: depth,
  position: position,
  dueDate: due,
);

/// A server that keeps tasks and comments, remembers the mutation ids it has
/// applied, checks versions, and can be cut off or told to refuse.
class FakeServer {
  final tasks = <String, Task>{};
  final comments = <String, Comment>{};
  final applied = <String, String>{}; // mutation id -> entity id
  var reachable = true;

  /// Applies the next create/update/delete but loses the answer.
  var dropNextAnswer = false;
  TaskException? refuse;
  CommentException? refuseComment;
  final sent = <String>[]; // 'create t1', 'update t1 v1', ...

  late final TaskServer t = TaskServer(this);
  late final CommentServer c = CommentServer(this);
}

class TaskServer implements TasksClient {
  TaskServer(this.s);

  final FakeServer s;

  void _check() {
    if (!s.reachable) throw const TaskException(TaskFailure.network);
  }

  void _maybeDrop() {
    if (s.dropNextAnswer) {
      s.dropNextAnswer = false;
      throw const TaskException(TaskFailure.network);
    }
  }

  @override
  Stream<Task> list(
    String workspaceId,
    String projectId, {
    ListQuery query = const ListQuery(),
  }) async* {
    _check();
    for (final t in s.tasks.values.where((t) => t.projectId == projectId)) {
      yield t;
    }
  }

  @override
  Future<Task> get(String workspaceId, String projectId, String id) async {
    _check();
    final t = s.tasks[id];
    if (t == null) throw const TaskException(TaskFailure.notFound);
    return t;
  }

  @override
  Future<Task> create(
    String workspaceId,
    String projectId, {
    required String title,
    TaskPriority priority = TaskPriority.none,
    List<String> assigneeIds = const [],
    String parentId = '',
    String statusId = '',
    Map<String, String> fieldValues = const {},
    String clientId = '',
    String mutationId = '',
  }) async {
    _check();
    final r = s.refuse;
    if (r != null) throw r;
    final known = s.applied[mutationId];
    if (mutationId.isNotEmpty && known != null) return s.tasks[known]!;
    s.sent.add('create ${clientId.isEmpty ? '?' : clientId}');
    final id = clientId.isEmpty ? 'srv${s.tasks.length + 1}' : clientId;
    final made = serverTask(
      id,
      title,
      project: projectId,
      parent: parentId,
      depth: parentId.isEmpty ? 0 : s.tasks[parentId]!.depth + 1,
      position: 'b${s.tasks.length}',
    );
    s.tasks[id] = made;
    if (mutationId.isNotEmpty) s.applied[mutationId] = id;
    _maybeDrop();
    return made;
  }

  @override
  Future<Task> update(
    String workspaceId,
    Task task,
    TaskPatch patch, {
    int? expectedVersion,
    bool overrideBlocked = false,
    String mutationId = '',
  }) async {
    _check();
    final r = s.refuse;
    if (r != null) throw r;
    final known = s.applied[mutationId];
    if (mutationId.isNotEmpty && known != null) return s.tasks[known]!;
    final current = s.tasks[task.id];
    if (current == null) throw const TaskException(TaskFailure.notFound);
    final seen = expectedVersion ?? task.version;
    if (seen != current.version) {
      throw TaskException(
        TaskFailure.conflict,
        conflict: TaskConflict(
          field: 'title',
          current: current.title,
          version: current.version,
        ),
      );
    }
    s.sent.add('update ${task.id} v$seen');
    final next = current.apply(patch);
    final saved = Task(
      id: next.id,
      projectId: next.projectId,
      number: next.number,
      displayId: next.displayId,
      title: next.title,
      statusId: next.statusId,
      statusName: next.statusName,
      priority: next.priority,
      dueDate: next.dueDate,
      version: current.version + 1,
      position: next.position,
      parentId: next.parentId,
    );
    s.tasks[task.id] = saved;
    if (mutationId.isNotEmpty) s.applied[mutationId] = task.id;
    _maybeDrop();
    return saved;
  }

  @override
  Future<Task> delete(
    String workspaceId,
    String projectId,
    String id, {
    DeleteMode? mode,
    String mutationId = '',
  }) async {
    _check();
    final r = s.refuse;
    if (r != null) throw r;
    final gone = s.tasks.remove(id);
    if (gone == null && !s.applied.containsKey(mutationId)) {
      throw const TaskException(TaskFailure.notFound);
    }
    s.sent.add('delete $id');
    if (mutationId.isNotEmpty) s.applied[mutationId] = id;
    _maybeDrop();
    return gone ?? serverTask(id, '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class CommentServer implements CommentsClient {
  CommentServer(this.s);

  final FakeServer s;

  void _commentCheck() {
    if (!s.reachable) throw const CommentException(CommentFailure.network);
    final r = s.refuseComment;
    if (r != null) throw r;
  }

  @override
  Future<CommentPage> list(
    String workspaceId,
    String projectId,
    String taskId, {
    String before = '',
  }) async {
    _commentCheck();
    return CommentPage([
      for (final c in s.comments.values)
        if (c.taskId == taskId) c,
    ], '');
  }

  @override
  Future<Comment> create(
    String workspaceId,
    String projectId,
    String taskId,
    String body, {
    String parentId = '',
    bool grantAccess = false,
    String clientId = '',
    String mutationId = '',
  }) async {
    _commentCheck();
    final known = s.applied[mutationId];
    if (mutationId.isNotEmpty && known != null) return s.comments[known]!;
    s.sent.add('comment ${clientId.isEmpty ? '?' : clientId}');
    final id = clientId.isEmpty ? 'c${s.comments.length + 1}' : clientId;
    final made = Comment(
      id: id,
      taskId: taskId,
      authorId: 'u1',
      createdAt: DateTime.utc(2026, 11, 12, 9),
      body: body,
    );
    s.comments[id] = made;
    if (mutationId.isNotEmpty) s.applied[mutationId] = id;
    return made;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class Harness {
  Harness._(this.db, this.store, this.server);

  final LocalDb db;
  final OfflineStore store;
  final FakeServer server;
  var online = true;
  var failures = 0;
  var successes = 0;
  var _id = 0;
  var clock = DateTime.utc(2026, 11, 12, 10);

  late final env = OfflineEnv(
    store: () async => store,
    online: () => online,
    failed: () {
      online = false;
      failures++;
    },
    worked: () => successes++,
    newId: () => 'id-${++_id}',
    now: () => clock = clock.add(const Duration(seconds: 1)),
    me: () => 'u1',
  );

  static Harness create() {
    final db = LocalDb(NativeDatabase.memory());
    return Harness._(db, OfflineStore(db), FakeServer());
  }

  Future<void> close() => db.close();
}
