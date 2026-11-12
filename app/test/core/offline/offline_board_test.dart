import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/features/board/data/offline_board_client.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../../features/board/fakes.dart';
import '../../features/tasks/fakes.dart' show task;
import 'fakes.dart';

/// The board server, cut off when [down].
class _Flaky extends FakeBoardClient {
  _Flaky(super.initial);

  var down = false;

  @override
  Future<List<BoardLane>> get(
    String workspaceId,
    String projectId, {
    required String groupBy,
    String swimlane = '',
    String filterAst = '',
  }) async {
    if (down) throw const TaskException(TaskFailure.network);
    return super.get(
      workspaceId,
      projectId,
      groupBy: groupBy,
      swimlane: swimlane,
      filterAst: filterAst,
    );
  }

  @override
  Future<Task> move(
    String workspaceId,
    Task task, {
    required String groupBy,
    required String column,
    String beforeId = '',
    String afterId = '',
    bool includeSubtasks = false,
    bool overrideBlocked = false,
  }) async {
    if (down) throw const TaskException(TaskFailure.network);
    return super.move(
      workspaceId,
      task,
      groupBy: groupBy,
      column: column,
      beforeId: beforeId,
      afterId: afterId,
      includeSubtasks: includeSubtasks,
      overrideBlocked: overrideBlocked,
    );
  }
}

List<String> _ids(List<BoardLane> lanes, String column) => [
  for (final t in lanes.single.columns.firstWhere((c) => c.key == column).tasks)
    t.id,
];

int _count(List<BoardLane> lanes, String column) =>
    lanes.single.columns.firstWhere((c) => c.key == column).count;

void main() {
  late Harness h;
  late _Flaky remote;
  late OfflineTasksClient tasks;
  late OfflineBoardClient board;

  setUp(() {
    h = Harness.create();
    remote = _Flaky([task('a', 'Alpha'), task('b', 'Bravo')]);
    for (final t in remote.tasks) {
      h.server.tasks[t.id] = t;
    }
    tasks = OfflineTasksClient(h.server.t, h.env);
    board = OfflineBoardClient(remote, tasks, h.env);
  });

  tearDown(() => h.close());

  Future<List<BoardLane>> read() => board.get('w1', 'p1', groupBy: 'status');

  Future<void> goOffline() async {
    remote.down = true;
    h.server.reachable = false;
    h.online = false;
  }

  test('the board last read is shown when the server is gone', () async {
    await read();
    await goOffline();
    final lanes = await read();
    expect(_ids(lanes, 'todo'), ['a', 'b']);
  });

  test('a board never read has nothing to show offline', () async {
    await goOffline();
    expect(
      read(),
      throwsA(
        isA<TaskException>().having(
          (e) => e.failure,
          'failure',
          TaskFailure.network,
        ),
      ),
    );
  });

  test(
    'a card dropped offline sits in its new column and is sent later',
    () async {
      await read();
      final a = remote.tasks.first;
      await goOffline();
      final moved = await board.move(
        'w1',
        a,
        groupBy: 'status',
        column: 'doing',
      );
      expect(moved.statusId, 'doing');
      final entry = (await h.store.queue('w1')).single;
      expect(entry.op, OutboxOp.update);
      expect(entry.payload['status'], isNotNull);
      final lanes = await read();
      expect(_ids(lanes, 'doing'), ['a']);
      expect(_ids(lanes, 'todo'), ['b']);
      expect(_count(lanes, 'doing'), 1);
      expect(_count(lanes, 'todo'), 1);

      h.server.reachable = true;
      final worker = OutboxWorker(
        store: () async => h.store,
        tasks: h.server.t,
        comments: h.server.c,
        workspace: () => 'w1',
        worked: () => h.online = true,
        failed: () => h.online = false,
      );
      expect((await worker.drain()).sent, 1);
      expect(h.server.tasks['a']!.statusId, 'doing');
    },
  );

  test(
    'a drop that cannot be sent is queued even when it looked online',
    () async {
      await read();
      final a = remote.tasks.first;
      remote.down = true; // the board server went away just now
      await board.move('w1', a, groupBy: 'status', column: 'done');
      expect((await h.store.queue('w1')).single.op, OutboxOp.update);
    },
  );

  test('priority and assignee drops are queued too', () async {
    await read();
    await goOffline();
    final a = remote.tasks.first;
    await board.move('w1', a, groupBy: 'priority', column: 'high');
    final patch = (await h.store.queue('w1')).single.payload;
    expect(patch['priority'], 'high');
  });

  test('moving the subtasks along needs the server', () async {
    await read();
    await goOffline();
    expect(
      board.move(
        'w1',
        remote.tasks.first,
        groupBy: 'status',
        column: 'doing',
        includeSubtasks: true,
      ),
      throwsA(isA<TaskException>()),
    );
    expect(await h.store.queue('w1'), isEmpty);
  });

  test(
    'a task made offline shows on the board, a deleted one is gone',
    () async {
      await read();
      await goOffline();
      final made = await tasks.create(
        'w1',
        'p1',
        title: 'Fresh',
        statusId: 'todo',
      );
      await tasks.delete('w1', 'p1', 'b');
      final lanes = await read();
      expect(_ids(lanes, 'todo'), ['a', made.id]);
      expect(_count(lanes, 'todo'), 2);
    },
  );

  test('a status change of the list view is an edit too', () async {
    await tasks.list('w1', 'p1').toList();
    await goOffline();
    final a = remote.tasks.first;
    final moved = await tasks.move('w1', a, 'done');
    expect(moved.statusId, 'done');
    expect((await h.store.queue('w1')).single.op, OutboxOp.update);
    expect(
      tasks.move('w1', a, 'done', includeSubtasks: true),
      throwsA(isA<TaskException>()),
    );
  });

  test('later pages of a column need the server', () async {
    await read();
    await goOffline();
    expect(
      board.listColumn('w1', 'p1', groupBy: 'status', column: 'todo'),
      throwsA(isA<TaskException>()),
    );
  });

  test('the column key follows the grouping', () {
    final t = task('a', 'A', priority: TaskPriority.high, assignees: ['u1']);
    expect(OfflineBoardClient.columnKey(t, 'status'), 'todo');
    expect(OfflineBoardClient.columnKey(t, 'priority'), 'high');
    expect(OfflineBoardClient.columnKey(t, 'assignee'), 'u1');
    expect(OfflineBoardClient.columnKey(t, 'sprint'), isNull);
  });
}
