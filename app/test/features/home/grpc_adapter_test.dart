import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/home/data/home_client.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/gen/infrastructure/home/grpc/home.pbgrpc.dart' as pb;

import '../workspaces/fakes.dart';

class _Home extends pb.HomeControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _answer<T>(String name, Object request, T answer) {
    seen[name] = request;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  pb.HomeTask _task(String id) => pb.HomeTask(
    taskId: id,
    projectId: 'p1',
    projectKey: 'WEB',
    number: 7,
    title: 'Task $id',
    statusName: 'Doing',
    statusCategory: 'active',
    dueDate: '2026-11-18',
  );

  @override
  Future<pb.HomeMyWork> myWork(
    ServiceCall call,
    pb.HomeMyWorkRequest request,
  ) async => _answer(
    'myWork',
    request,
    pb.HomeMyWork(
      tasks: [
        pb.MyWorkTask(task: _task('a'), assigned: true),
        pb.MyWorkTask(task: _task('b'), watching: true),
      ],
      nextCursor: 'c2',
    ),
  );

  @override
  Future<pb.HomePinned> pinDashboard(
    ServiceCall call,
    pb.HomePinDashboardRequest request,
  ) async => _answer('pin', request, pb.HomePinned());

  @override
  Future<pb.HomeRecorded> recordRecent(
    ServiceCall call,
    pb.HomeRecordRecentRequest request,
  ) async => _answer('recent', request, pb.HomeRecorded());

  @override
  Future<pb.HomeSummary> summary(
    ServiceCall call,
    pb.HomeSummaryRequest request,
  ) async => _answer(
    'summary',
    request,
    pb.HomeSummary(
      todayCount: 2,
      overdueCount: 1,
      inProgressCount: 3,
      dueItems: [_task('a')],
      inProgressItems: [_task('b')],
      recent: [_task('c')],
      mentions: [
        pb.HomeMention(id: 'm1', type: 'mention', taskId: 'a', read: true),
      ],
      unreadNotifications: 4,
      unreadChat: 5,
      week: [pb.HomeDay(date: '2026-11-18', seconds: 60)],
      pinnedDashboards: [
        pb.HomePin(dashboardId: 'd1', name: 'Team', projectId: 'p1'),
      ],
      computedAt: '2026-11-18T07:00:00Z',
    ),
  );
}

class _Onboarding extends pb.OnboardingControllerServiceBase {
  final calls = <String>[];

  pb.OnboardingState get _state => pb.OnboardingState(
    steps: [
      pb.OnboardingStep(step: 'create_task', done: true),
      pb.OnboardingStep(step: 'try_board'),
    ],
    visible: true,
    sampleProjectId: 'p1',
    sampleCount: 4,
    starters: [pb.OnboardingStarter(key: 'blank', name: 'Blank')],
  );

  @override
  Future<pb.OnboardingStarterApplied> applyStarter(
    ServiceCall call,
    pb.OnboardingApplyStarterRequest request,
  ) async {
    calls.add('starter ${request.starter}');
    return pb.OnboardingStarterApplied(projectId: 'pn', taskCount: 3);
  }

  @override
  Future<pb.OnboardingState> completeStep(
    ServiceCall call,
    pb.OnboardingCompleteStepRequest request,
  ) async {
    calls.add('step ${request.step}');
    return _state;
  }

  @override
  Future<pb.OnboardingSamplesDeleted> deleteSamples(
    ServiceCall call,
    pb.OnboardingDeleteSamplesRequest request,
  ) async => pb.OnboardingSamplesDeleted(deleted: 4);

  @override
  Future<pb.OnboardingState> dismiss(
    ServiceCall call,
    pb.OnboardingDismissRequest request,
  ) async {
    calls.add('dismiss');
    return _state;
  }

  @override
  Future<pb.OnboardingState> get(
    ServiceCall call,
    pb.OnboardingGetRequest request,
  ) async => _state;
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcHomeClient client;
  final home = _Home();
  final onboarding = _Onboarding();

  setUpAll(() async {
    server = Server.create(services: [home, onboarding]);
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
    client = GrpcHomeClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  setUp(() => home.fail = null);

  test('summary sends the day and the offset and maps every part', () async {
    final s = await client.summary(
      'w1',
      today: '2026-11-18',
      utcOffsetMinutes: 270,
    );
    final sent = home.seen['summary']! as pb.HomeSummaryRequest;
    expect(sent.workspaceId, 'w1');
    expect(sent.today, '2026-11-18');
    expect(sent.utcOffsetMinutes, 270);
    expect(s.todayCount, 2);
    expect(s.overdueCount, 1);
    expect(s.dueItems.single.displayId, 'WEB-7');
    expect(s.dueItems.single.isDone, isFalse);
    expect(s.inProgressItems.single.taskId, 'b');
    expect(s.recent.single.title, 'Task c');
    expect(s.mentions.single.read, isTrue);
    expect(s.unreadNotifications, 4);
    expect(s.unreadChat, 5);
    expect(s.weekSeconds, 60);
    expect(s.pinned.single.name, 'Team');
    expect(s.computedAt, '2026-11-18T07:00:00Z');
  });

  test('my work sends the relation, done flag, filter and cursor', () async {
    final page = await client.myWork(
      'w1',
      today: '2026-11-18',
      query: const MyWorkQuery(
        relation: MyWorkRelation.watching,
        includeDone: true,
        filterAst: '{"op":"cmp"}',
      ),
      cursor: 'c1',
      limit: 10,
    );
    final sent = home.seen['myWork']! as pb.HomeMyWorkRequest;
    expect(sent.relation, 'watching');
    expect(sent.includeDone, isTrue);
    expect(sent.filterAst, '{"op":"cmp"}');
    expect(sent.cursor, 'c1');
    expect(sent.limit, 10);
    expect(page.items.map((i) => (i.assigned, i.watching)), [
      (true, false),
      (false, true),
    ]);
    expect(page.nextCursor, 'c2');
    expect(page.hasMore, isTrue);
  });

  test('recent and pin send their ids', () async {
    await client.recordRecent('w1', 't9');
    expect((home.seen['recent']! as pb.HomeRecordRecentRequest).taskId, 't9');
    await client.pinDashboard('w1', 'd1', pinned: true);
    final sent = home.seen['pin']! as pb.HomePinDashboardRequest;
    expect((sent.dashboardId, sent.pinned), ('d1', true));
  });

  test('the checklist maps its steps, samples and starters', () async {
    final state = await client.get('w1');
    expect(state.done('create_task'), isTrue);
    expect(state.done('try_board'), isFalse);
    expect(state.doneCount, 1);
    expect(state.visible, isTrue);
    expect(state.sampleProjectId, 'p1');
    expect(state.sampleCount, 4);
    expect(state.starters.single.key, 'blank');
  });

  test('onboarding actions reach the server', () async {
    await client.completeStep('w1', 'try_board');
    await client.dismiss('w1');
    final made = await client.applyStarter('w1', 'marketing');
    expect(made.projectId, 'pn');
    expect(made.taskCount, 3);
    expect(await client.deleteSamples('w1'), 4);
    expect(onboarding.calls, [
      'step try_board',
      'dismiss',
      'starter marketing',
    ]);
  });

  group('failures become a HomeException', () {
    Future<HomeFailure> failure(GrpcError e) async {
      home.fail = e;
      try {
        await client.summary('w1', today: 'x', utcOffsetMinutes: 0);
      } on HomeException catch (x) {
        return x.failure;
      }
      fail('did not throw');
    }

    test('mapped by status', () async {
      expect(
        await failure(GrpcError.permissionDenied('no')),
        HomeFailure.denied,
      );
      expect(await failure(GrpcError.notFound('no')), HomeFailure.notFound);
      expect(await failure(GrpcError.unavailable('no')), HomeFailure.network);
      expect(await failure(GrpcError.deadlineExceeded()), HomeFailure.network);
      expect(await failure(GrpcError.internal('x')), HomeFailure.other);
      expect(
        await failure(GrpcError.invalidArgument('INVALID: bad day')),
        HomeFailure.invalid,
      );
    });

    test('an invalid request keeps the server words, without the code', () {
      final e = mapHomeError(GrpcError.invalidArgument('INVALID: bad day'));
      expect(e.detail, 'bad day');
      expect(homeErrorMessage(e), 'bad day');
    });
  });

  test('every failure has words for the person', () {
    for (final f in HomeFailure.values) {
      expect(homeErrorMessage(HomeException(f)), isNotEmpty, reason: f.name);
    }
  });
}
