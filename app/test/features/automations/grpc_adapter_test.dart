import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/automations/data/automations_client.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/gen/infrastructure/automations/grpc/automations.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

pb.Automation _rule({String reason = ''}) => pb.Automation(
  id: 'a1',
  projectId: 'p1',
  name: 'Done notifier',
  enabled: reason.isEmpty,
  triggerJson: '{"type":"status_changed","to_status":"s1"}',
  conditionTfql: 'priority = high',
  actionsJson: '[{"type":"add_comment","text":"hi"},{"type":"notify","to":["owner"],"message":"m"}]',
  ownerId: 'u1',
  disabledReason: reason,
  version: 4,
  lastRunAt: '2026-11-12T10:00:00Z',
  lastRunStatus: 'failed',
);

class _Rules extends pb.AutomationControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _answer<T>(String name, Object request, T answer) {
    seen[name] = request;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  @override
  Future<pb.AutomationList> list(
    ServiceCall call,
    pb.AutomationListRequest r,
  ) async => _answer(
    'list',
    r,
    pb.AutomationList(
      automations: [
        _rule(),
        _rule(reason: 'A status was deleted.'),
      ],
    ),
  );

  @override
  Future<pb.AutomationAnswer> create(
    ServiceCall call,
    pb.AutomationCreateRequest r,
  ) async => _answer('create', r, pb.AutomationAnswer(automation: _rule()));

  @override
  Future<pb.AutomationAnswer> update(
    ServiceCall call,
    pb.AutomationUpdateRequest r,
  ) async => _answer('update', r, pb.AutomationAnswer(automation: _rule()));

  @override
  Future<pb.AutomationAnswer> toggle(
    ServiceCall call,
    pb.AutomationToggleRequest r,
  ) async => _answer('toggle', r, pb.AutomationAnswer(automation: _rule()));

  @override
  Future<pb.AutomationDeleted> delete(
    ServiceCall call,
    pb.AutomationDeleteRequest r,
  ) async => _answer('delete', r, pb.AutomationDeleted(id: 'a1'));

  @override
  Future<pb.AutomationDryRunAnswer> dryRun(
    ServiceCall call,
    pb.AutomationDryRunRequest r,
  ) async => _answer(
    'dry',
    r,
    pb.AutomationDryRunAnswer(
      wouldRun: true,
      status: 'succeeded',
      stepsJson: jsonEncode([
        {
          'type': 'set_field',
          'status': 'planned',
          'detail': '',
          'changes': [
            {'field': 'priority', 'from': 'low', 'to': 'high'},
          ],
        },
      ]),
    ),
  );
}

class _Runs extends pb.AutomationRunControllerServiceBase {
  pb.AutomationRunListRequest? seen;

  @override
  Future<pb.AutomationRunList> list(
    ServiceCall call,
    pb.AutomationRunListRequest r,
  ) async {
    seen = r;
    return pb.AutomationRunList(
      runs: [
        pb.AutomationRun(
          id: 'r1',
          automationId: 'a1',
          automationName: 'Done notifier',
          taskKey: 'WEB-1',
          status: 'skipped_condition',
          explanation: 'the task does not meet: priority = high',
          stepsJson: '[]',
        ),
      ],
    );
  }

  @override
  Future<pb.AutomationRunAnswer> get(
    ServiceCall call,
    pb.AutomationRunGetRequest r,
  ) async => pb.AutomationRunAnswer();
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcAutomationsClient client;
  final rules = _Rules();
  final runs = _Runs();

  setUpAll(() async {
    server = Server.create(services: [rules, runs]);
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
    client = GrpcAutomationsClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  tearDown(() => rules.fail = null);

  test('list decodes the trigger, condition and actions JSON', () async {
    final list = await client.list('w1', 'p1');
    expect(list, hasLength(2));
    final a = list.first;
    expect(a.trigger.type, TriggerType.statusChanged);
    expect(a.trigger.toStatus, 's1');
    expect(a.condition, 'priority = high');
    expect(a.actions.map((x) => x.type), [
      ActionType.addComment,
      ActionType.notify,
    ]);
    expect(a.version, 4);
    expect(a.lastRunStatus, 'failed');
    expect(list.last.wasSwitchedOffByServer, isTrue);
    expect((rules.seen['list']! as pb.AutomationListRequest).workspaceId, 'w1');
  });

  test('create sends the spec JSON', () async {
    await client.create(
      'w1',
      'p1',
      const RuleDraft(
        name: ' Notify ',
        trigger: Trigger(type: TriggerType.dueDateReached, daysBefore: 2),
        condition: ' priority = high ',
        actions: [RuleAction(type: ActionType.createSubtask, text: 'Check')],
      ),
      enabled: true,
    );
    final r = rules.seen['create']! as pb.AutomationCreateRequest;
    expect(r.name, 'Notify');
    expect(jsonDecode(r.triggerJson), {
      'type': 'due_date_reached',
      'days_before': 2,
    });
    expect(r.conditionTfql, 'priority = high');
    expect(jsonDecode(r.actionsJson), [
      {'type': 'create_subtask', 'title': 'Check'},
    ]);
    expect(r.enabled, isTrue);
  });

  test('update names the fields and sends the expected version', () async {
    final old = (await client.list('w1', 'p1')).first;
    await client.update('w1', old, old.toDraft().copyWith(name: 'New'), [
      'name',
    ]);
    final r = rules.seen['update']! as pb.AutomationUpdateRequest;
    expect(r.fields, ['name']);
    expect(r.expectedVersion, 4);
    expect(r.automationId, 'a1');
    expect(r.name, 'New');
  });

  test('toggle and delete', () async {
    await client.toggle('w1', 'p1', 'a1', enabled: false);
    final t = rules.seen['toggle']! as pb.AutomationToggleRequest;
    expect(t.enabled, isFalse);
    await client.delete('w1', 'p1', 'a1');
    expect(
      (rules.seen['delete']! as pb.AutomationDeleteRequest).automationId,
      'a1',
    );
  });

  test('dry run decodes the would-be changes', () async {
    final r = await client.dryRun('w1', 'p1', 'a1', 't1');
    expect(r.wouldRun, isTrue);
    expect(r.steps.single.changes.single.field, 'priority');
    expect(r.steps.single.changes.single.from, 'low');
    expect((rules.seen['dry']! as pb.AutomationDryRunRequest).taskId, 't1');
  });

  test('runs decode status and explanation, and pass the filters', () async {
    final list = await client.runs('w1', 'p1', automationId: 'a1', limit: 20);
    expect(list.single.status, RunStatus.skippedCondition);
    expect(list.single.explanation, contains('priority = high'));
    expect(runs.seen!.automationId, 'a1');
    expect(runs.seen!.limit, 20);
  });

  test('server errors map to failures', () async {
    final cases = {
      StatusCode.invalidArgument: AutomationFailure.invalid,
      StatusCode.aborted: AutomationFailure.conflict,
      StatusCode.permissionDenied: AutomationFailure.denied,
      StatusCode.notFound: AutomationFailure.notFound,
      StatusCode.unavailable: AutomationFailure.network,
      StatusCode.internal: AutomationFailure.other,
    };
    for (final e in cases.entries) {
      rules.fail = GrpcError.custom(e.key, 'VALIDATION_ERROR: Nope.');
      await expectLater(
        client.list('w1', 'p1'),
        throwsA(
          isA<AutomationException>().having(
            (x) => x.failure,
            'failure',
            e.value,
          ),
        ),
      );
    }
    rules.fail = GrpcError.invalidArgument('VALIDATION_ERROR: Name too long.');
    await expectLater(
      client.list('w1', 'p1'),
      throwsA(
        isA<AutomationException>().having(
          (x) => x.detail,
          'detail',
          'Name too long.',
        ),
      ),
    );
  });
}
