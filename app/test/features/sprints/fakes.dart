import 'package:taskforge/features/sprints/data/sprints_client.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';

SprintTask sTask(
  String id, {
  String sprint = '',
  double? points,
  String category = 'todo',
  int version = 1,
  bool late = false,
}) => SprintTask(
  id: id,
  key: 'WEB-$id',
  title: 'Task $id',
  statusName: category == 'done' ? 'Done' : 'To do',
  statusCategory: category,
  points: points,
  sprintId: sprint,
  version: version,
  late: late,
);

Sprint mkSprint(
  String id,
  String name, {
  SprintState state = SprintState.planned,
  DateTime? start,
  DateTime? end,
  String goal = '',
  int version = 1,
  double? capacityPoints,
  int? capacitySec,
}) => Sprint(
  id: id,
  projectId: 'p1',
  name: name,
  goal: goal,
  state: state,
  version: version,
  startDate: start ?? DateTime(2026, 11, 9),
  endDate: end ?? DateTime(2026, 11, 22),
  capacityPoints: capacityPoints,
  capacitySec: capacitySec,
);

/// An in-memory sprint server for one project.
class FakeSprintsClient implements SprintsClient {
  FakeSprintsClient({
    List<Sprint> sprints = const [],
    List<SprintTask> tasks = const [],
  }) : sprints = [...sprints],
       all = [...tasks];

  final List<Sprint> sprints;
  final List<SprintTask> all;
  Burndown? burndownAnswer;
  SprintException? failNext;

  /// Every list read fails while set (a provider retries on its own).
  SprintException? failList;
  List<String> warnNext = const [];
  final calls = <String>[];
  final completes = <({String carry, String next})>[];
  final updates = <List<String>>[];
  final points = <String, String>{};
  var _n = 0;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  Sprint _find(String id) => sprints.firstWhere(
    (s) => s.id == id,
    orElse: () => throw const SprintException(SprintFailure.notFound),
  );

  Sprint _counted(Sprint s) {
    final mine = all.where((t) => t.sprintId == s.id).toList();
    final open = mine.where((t) => !t.isDone).toList();
    double sum(Iterable<SprintTask> l) =>
        l.fold(0, (a, t) => a + (t.points ?? 0));
    return Sprint(
      id: s.id,
      projectId: s.projectId,
      name: s.name,
      goal: s.goal,
      startDate: s.startDate,
      endDate: s.endDate,
      state: s.state,
      version: s.version,
      baselinePoints: s.baselinePoints,
      baselineTasks: s.baselineTasks,
      taskCount: mine.length,
      pointsTotal: sum(mine),
      openTasks: open.length,
      openPoints: sum(open),
      doneTasks: mine.length - open.length,
      donePoints: sum(mine) - sum(open),
      capacityPoints: s.capacityPoints,
      capacitySec: s.capacitySec,
    );
  }

  void _put(Sprint s) {
    final i = sprints.indexWhere((x) => x.id == s.id);
    i < 0 ? sprints.add(s) : sprints[i] = s;
  }

  @override
  Future<List<Sprint>> list(
    String w,
    String p, {
    List<String> states = const [],
  }) async {
    calls.add('list');
    final f = failList;
    if (f != null) throw f;
    _maybeFail();
    return [for (final s in sprints) _counted(s)];
  }

  @override
  Future<SprintAnswer> create(
    String w,
    String p, {
    required String name,
    String goal = '',
    required DateTime start,
    required DateTime end,
    String capacityPoints = '',
    int capacitySec = 0,
  }) async {
    calls.add('create');
    _maybeFail();
    final s = mkSprint(
      'n${++_n}',
      name,
      goal: goal,
      start: start,
      end: end,
      capacityPoints: double.tryParse(capacityPoints),
      capacitySec: capacitySec == 0 ? null : capacitySec,
    );
    _put(s);
    return SprintAnswer(s, warnNext);
  }

  @override
  Future<SprintAnswer> update(
    String w,
    String p,
    String id, {
    required List<String> fields,
    required int expectedVersion,
    String name = '',
    String goal = '',
    DateTime? start,
    DateTime? end,
    String capacityPoints = '',
    int capacitySec = 0,
  }) async {
    calls.add('update');
    updates.add(fields);
    _maybeFail();
    final cur = _find(id);
    if (cur.version != expectedVersion) {
      throw const SprintException(
        SprintFailure.conflict,
        detail: 'This sprint changed since you opened it. Reload and retry.',
      );
    }
    final s = mkSprint(
      id,
      fields.contains('name') ? name : cur.name,
      state: cur.state,
      goal: fields.contains('goal') ? goal : cur.goal,
      start: fields.contains('start_date') ? start : cur.startDate,
      end: fields.contains('end_date') ? end : cur.endDate,
      version: cur.version + 1,
      capacityPoints: fields.contains('capacity_points')
          ? double.tryParse(capacityPoints)
          : cur.capacityPoints,
      capacitySec: fields.contains('capacity_sec')
          ? (capacitySec == 0 ? null : capacitySec)
          : cur.capacitySec,
    );
    _put(s);
    return SprintAnswer(s, warnNext);
  }

  @override
  Future<SprintAnswer> start(String w, String p, String id) async {
    calls.add('start');
    _maybeFail();
    final running = sprints.where((s) => s.isActive).firstOrNull;
    if (running != null) {
      throw SprintException(
        SprintFailure.conflict,
        detail: '"${running.name}" is already active. Complete it first.',
      );
    }
    final cur = _find(id);
    final s = mkSprint(
      id,
      cur.name,
      state: SprintState.active,
      start: cur.startDate,
      end: cur.endDate,
      goal: cur.goal,
      version: cur.version + 1,
    );
    _put(s);
    return SprintAnswer(_counted(s));
  }

  @override
  Future<SprintAnswer> complete(
    String w,
    String p,
    String id, {
    required String carryOver,
    String nextSprintId = '',
  }) async {
    calls.add('complete');
    completes.add((carry: carryOver, next: nextSprintId));
    _maybeFail();
    final cur = _find(id);
    for (var i = 0; i < all.length; i++) {
      final t = all[i];
      if (t.sprintId == id && !t.isDone) {
        all[i] = sTask(
          t.id,
          sprint: carryOver == 'next' ? nextSprintId : '',
          points: t.points,
        );
      }
    }
    final s = mkSprint(
      id,
      cur.name,
      state: SprintState.completed,
      start: cur.startDate,
      end: cur.endDate,
      version: cur.version + 1,
    );
    _put(s);
    return SprintAnswer(s);
  }

  TasksChanged _move(String id, List<String> ids, String to) {
    var late = 0;
    final sprint = _find(id);
    for (var i = 0; i < all.length; i++) {
      final t = all[i];
      if (!ids.contains(t.id)) continue;
      all[i] = sTask(
        t.id,
        sprint: to,
        points: t.points,
        category: t.statusCategory,
      );
      if (to.isNotEmpty && sprint.isActive) late++;
    }
    return TasksChanged(
      sprint: _counted(sprint),
      changed: ids.length,
      addedAfterStart: late,
    );
  }

  @override
  Future<TasksChanged> addTasks(
    String w,
    String p,
    String id,
    List<String> ids,
  ) async {
    calls.add('add:${ids.join(',')}');
    _maybeFail();
    return _move(id, ids, id);
  }

  @override
  Future<TasksChanged> removeTasks(
    String w,
    String p,
    String id,
    List<String> ids,
  ) async {
    calls.add('remove:${ids.join(',')}');
    _maybeFail();
    return _move(id, ids, '');
  }

  @override
  Future<List<SprintTask>> tasks(String w, String p, String id) async {
    _maybeFail();
    return [
      for (final t in all)
        if (t.sprintId == id) t,
    ];
  }

  @override
  Future<List<SprintTask>> backlog(String w, String p, {int limit = 0}) async {
    _maybeFail();
    return [
      for (final t in all)
        if (t.sprintId.isEmpty && !t.isDone) t,
    ];
  }

  @override
  Future<SprintTask> setPoints(
    String w,
    String p,
    String taskId,
    String text, {
    int expectedVersion = 0,
  }) async {
    calls.add('points:$taskId=$text');
    _maybeFail();
    points[taskId] = text;
    final i = all.indexWhere((t) => t.id == taskId);
    final t = all[i];
    all[i] = sTask(
      t.id,
      sprint: t.sprintId,
      points: text.isEmpty ? null : double.parse(text),
      category: t.statusCategory,
      version: t.version + 1,
    );
    return all[i];
  }

  @override
  Future<Burndown> burndown(String w, String p, String id) async {
    calls.add('burndown');
    _maybeFail();
    return burndownAnswer ?? Burndown(sprint: _find(id));
  }
}
