import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/sprints/data/sprints_client.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/gen/infrastructure/sprints/grpc/sprints.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

pb.Sprint _sprint(String id, {String state = 'active'}) => pb.Sprint(
  id: id,
  projectId: 'p1',
  name: 'Sprint $id',
  goal: 'ship',
  startDate: '2026-11-09',
  endDate: '2026-11-22',
  state: state,
  version: 3,
  baselinePoints: 10,
  baselineTasks: 4,
  taskCount: 4,
  pointsTotal: 12.5,
  openTasks: 2,
  doneTasks: 2,
  estimateSecTotal: 7200,
);

pb.SprintTask _task(String id, {bool points = true}) => pb.SprintTask(
  id: id,
  key: 'WEB-1',
  title: 'Fix',
  statusCategory: 'done',
  points: points ? 3.5 : 0,
  hasPoints_10: points,
  sprintId: 's1',
  version: 2,
  late: true,
);

class _Backlog extends pb.BacklogControllerServiceBase {
  pb.BacklogListRequest? seen;

  @override
  Future<pb.BacklogList> list(ServiceCall call, pb.BacklogListRequest r) async {
    seen = r;
    return pb.BacklogList(tasks: [_task('b1', points: false)], total: 1);
  }
}

class _Server extends pb.SprintControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _answer<T>(String name, Object request, T answer) {
    seen[name] = request;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  @override
  Future<pb.SprintList> list(ServiceCall call, pb.SprintListRequest r) async =>
      _answer(
        'list',
        r,
        pb.SprintList(
          sprints: [
            _sprint('s1'),
            _sprint('s2', state: 'planned'),
          ],
        ),
      );

  @override
  Future<pb.SprintAnswer> create(
    ServiceCall call,
    pb.SprintCreateRequest r,
  ) async => _answer(
    'create',
    r,
    pb.SprintAnswer(sprint: _sprint('new'), warnings: ['Overlaps "S1".']),
  );

  @override
  Future<pb.SprintAnswer> update(
    ServiceCall call,
    pb.SprintUpdateRequest r,
  ) async => _answer('update', r, pb.SprintAnswer(sprint: _sprint('s1')));

  @override
  Future<pb.SprintAnswer> start(
    ServiceCall call,
    pb.SprintStartRequest r,
  ) async => _answer('start', r, pb.SprintAnswer(sprint: _sprint('s1')));

  @override
  Future<pb.SprintAnswer> complete(
    ServiceCall call,
    pb.SprintCompleteRequest r,
  ) async => _answer(
    'complete',
    r,
    pb.SprintAnswer(sprint: _sprint('s1', state: 'completed')),
  );

  @override
  Future<pb.SprintTasksChanged> addTasks(
    ServiceCall call,
    pb.SprintTasksChangeRequest r,
  ) async => _answer(
    'add',
    r,
    pb.SprintTasksChanged(
      sprint: _sprint('s1'),
      changed: 2,
      addedAfterStart: 1,
    ),
  );

  @override
  Future<pb.SprintTasksChanged> removeTasks(
    ServiceCall call,
    pb.SprintTasksChangeRequest r,
  ) async => _answer(
    'remove',
    r,
    pb.SprintTasksChanged(sprint: _sprint('s1'), changed: 1),
  );

  @override
  Future<pb.SprintTaskList> tasks(
    ServiceCall call,
    pb.SprintTasksRequest r,
  ) async => _answer('tasks', r, pb.SprintTaskList(tasks: [_task('t1')]));

  @override
  Future<pb.SprintTask> setPoints(
    ServiceCall call,
    pb.PointsSetRequest r,
  ) async => _answer('points', r, _task('t1'));

  @override
  Future<pb.BurndownAnswer> burndown(
    ServiceCall call,
    pb.BurndownRequest r,
  ) async => _answer(
    'burndown',
    r,
    pb.BurndownAnswer(
      sprint: _sprint('s1'),
      baselinePoints: 10,
      baselineTasks: 4,
      averageVelocity: 8,
      days: [
        pb.BurndownDay(
          date: '2026-11-09',
          idealPoints: 10,
          hasActual: true,
          remainingPoints: 10,
          remainingTasks: 4,
        ),
        pb.BurndownDay(date: '2026-11-10', idealPoints: 5),
      ],
      scopeChanges: [pb.ScopeChange(date: '2026-11-09', points: 3, tasks: 1)],
      velocity: [
        pb.VelocityItem(
          sprintId: 'old',
          name: 'Old',
          committedPoints: 9,
          completedPoints: 7,
        ),
      ],
    ),
  );
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcSprintsClient client;
  final sprints = _Server();
  final backlog = _Backlog();

  setUpAll(() async {
    server = Server.create(services: [sprints, backlog]);
    await server.serve(address: '127.0.0.1', port: 0);
    channel = ClientChannel(
      '127.0.0.1',
      port: server.port!,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    final store = MemoryTokenStore();
    final payload = base64Url
        .encode(utf8.encode('{"exp":4102444800}'))
        .replaceAll('=', '');
    await store.write(
      AuthTokens(
        accessToken: 'e30.$payload.sig',
        refreshToken: 'r',
        sessionId: 's',
      ),
    );
    final session = AuthSession(api: MockAuthApi(), store: store);
    await session.restore();
    client = GrpcSprintsClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  tearDown(() => sprints.fail = null);

  test('sprints list with state, dates and the counted figures', () async {
    final list = await client.list('w1', 'p1', states: ['planned']);

    final r = sprints.seen['list']! as pb.SprintListRequest;
    expect((r.workspaceId, r.projectId), ('w1', 'p1'));
    expect(r.states.toList(), ['planned']);
    expect(list.map((s) => s.state), [SprintState.active, SprintState.planned]);
    final s = list.first;
    expect(s.startDate, DateTime(2026, 11, 9));
    expect(
      (s.version, s.goal, s.pointsTotal, s.openTasks),
      (3, 'ship', 12.5, 2),
    );
    expect(s.estimateSecTotal, 7200);
  });

  test('create sends days and returns the overlap warnings', () async {
    final a = await client.create(
      'w1',
      'p1',
      name: 'S',
      goal: 'g',
      start: DateTime(2026, 11, 9),
      end: DateTime(2026, 11, 22),
    );

    final r = sprints.seen['create']! as pb.SprintCreateRequest;
    expect((r.startDate, r.endDate, r.goal), ('2026-11-09', '2026-11-22', 'g'));
    expect(a.warnings, ['Overlaps "S1".']);
  });

  test('an update names only the fields it changes and the version', () async {
    await client.update(
      'w1',
      'p1',
      's1',
      fields: ['name'],
      expectedVersion: 3,
      name: 'New',
    );

    final r = sprints.seen['update']! as pb.SprintUpdateRequest;
    expect(r.fields.toList(), ['name']);
    expect((r.expectedVersion, r.name, r.startDate), (3, 'New', ''));
  });

  test('start and complete say which sprint and where the rest goes', () async {
    await client.start('w1', 'p1', 's1');
    final done = await client.complete(
      'w1',
      'p1',
      's1',
      carryOver: 'next',
      nextSprintId: 's2',
    );

    expect((sprints.seen['start']! as pb.SprintStartRequest).sprintId, 's1');
    final r = sprints.seen['complete']! as pb.SprintCompleteRequest;
    expect((r.carryOver, r.nextSprintId), ('next', 's2'));
    expect(done.sprint.isCompleted, isTrue);
  });

  test('adding tasks reports what was added after the start', () async {
    final a = await client.addTasks('w1', 'p1', 's1', ['t1', 't2']);
    final r = await client.removeTasks('w1', 'p1', 's1', ['t1']);

    expect(
      (sprints.seen['add']! as pb.SprintTasksChangeRequest).taskIds.toList(),
      ['t1', 't2'],
    );
    expect((a.changed, a.addedAfterStart), (2, 1));
    expect((r.changed, r.addedAfterStart), (1, 0));
  });

  test('tasks and backlog read points only when the task has them', () async {
    final t = (await client.tasks('w1', 'p1', 's1')).single;
    final b = (await client.backlog('w1', 'p1', limit: 50)).single;

    expect((t.points, t.isDone, t.late, t.version), (3.5, true, true, 2));
    expect(b.points, isNull);
    expect(backlog.seen!.limit, 50);
  });

  test('points are sent as text with the task version', () async {
    await client.setPoints('w1', 'p1', 't1', '5', expectedVersion: 2);

    final r = sprints.seen['points']! as pb.PointsSetRequest;
    expect((r.taskId, r.points, r.expectedVersion), ('t1', '5', 2));
  });

  test('a burndown carries days, scope steps and velocity', () async {
    final b = await client.burndown('w1', 'p1', 's1');

    expect(b.days.map((d) => d.hasActual), [true, false]);
    expect(b.days.first.date, DateTime(2026, 11, 9));
    expect((b.scopeChanges.single.points, b.scopeChanges.single.tasks), (3, 1));
    expect((b.velocity.single.completedPoints, b.averageVelocity), (7, 8));
  });

  test('a second active sprint and a stale version are conflicts', () async {
    sprints.fail = GrpcError.alreadyExists('CONFLICT: "S1" is already active.');

    expect(
      client.start('w1', 'p1', 's2'),
      throwsA(
        isA<SprintException>()
            .having((e) => e.failure, 'failure', SprintFailure.conflict)
            .having((e) => e.detail, 'detail', '"S1" is already active.'),
      ),
    );
  });

  test('other refusals are mapped', () async {
    sprints.fail = GrpcError.permissionDenied('no');
    await expectLater(
      client.start('w1', 'p1', 's1'),
      throwsA(
        isA<SprintException>().having(
          (e) => e.failure,
          'f',
          SprintFailure.denied,
        ),
      ),
    );
    sprints.fail = GrpcError.invalidArgument(
      'VALIDATION_ERROR: Sprints are off.',
    );
    await expectLater(
      client.list('w1', 'p1'),
      throwsA(
        isA<SprintException>().having((e) => e.detail, 'd', 'Sprints are off.'),
      ),
    );
  });
}
