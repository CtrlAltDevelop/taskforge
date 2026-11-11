import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/time/data/time_client.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/gen/infrastructure/timetracking/grpc/timetracking.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

pb.Entry _entry(String id, {bool running = false, int seconds = 90}) =>
    pb.Entry(
      id: id,
      taskId: 't1',
      projectId: 'p1',
      key: 'WEB-1',
      title: 'Fix',
      userId: 'u1',
      userName: 'Zoe',
      startedAt: '2026-11-11T12:00:00+00:00',
      endedAt: running ? '' : '2026-11-11T12:01:30+00:00',
      durationSec: seconds,
      note: 'n',
      billable: true,
      flags: running ? ['running'] : ['overlap', 'long'],
    );

class _Server extends pb.TimeControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _answer<T>(String name, Object request, T answer) {
    seen[name] = request;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  @override
  Future<pb.TimerStarted> start(
    ServiceCall call,
    pb.TimeStartRequest r,
  ) async => _answer(
    'start',
    r,
    pb.TimerStarted(
      entry: _entry('new', running: true, seconds: 0),
      stopped: r.taskId == 'swap' ? _entry('old') : null,
    ),
  );

  @override
  Future<pb.TimerStopped> stop(ServiceCall call, pb.TimeStopRequest r) async =>
      _answer('stop', r, pb.TimerStopped(entry: _entry('s')));

  @override
  Future<pb.TimerState> current(
    ServiceCall call,
    pb.TimeCurrentRequest r,
  ) async => _answer(
    'current',
    r,
    r.workspaceId == 'none'
        ? pb.TimerState(running: false)
        : pb.TimerState(running: true, entry: _entry('run', running: true)),
  );

  @override
  Future<pb.Entry> createEntry(
    ServiceCall call,
    pb.EntryCreateRequest r,
  ) async => _answer('create', r, _entry('c'));

  @override
  Future<pb.Entry> updateEntry(
    ServiceCall call,
    pb.EntryUpdateRequest r,
  ) async => _answer('update', r, _entry('u'));

  @override
  Future<pb.EntryDeleted> deleteEntry(
    ServiceCall call,
    pb.EntryDeleteRequest r,
  ) async => _answer('delete', r, pb.EntryDeleted(ok: true));

  @override
  Future<pb.EntryList> entries(ServiceCall call, pb.EntriesRequest r) async =>
      _answer('entries', r, pb.EntryList(entries: [_entry('a'), _entry('b')]));

  @override
  Future<pb.TimeSummary> summary(
    ServiceCall call,
    pb.TimeSummaryRequest r,
  ) async => _answer(
    'summary',
    r,
    pb.TimeSummary(
      estimateSec: 7200,
      loggedSec: 3600,
      billableSec: 1800,
      running: true,
    ),
  );

  @override
  Future<pb.EstimateSet> setEstimate(
    ServiceCall call,
    pb.EstimateSetRequest r,
  ) async => _answer('estimate', r, pb.EstimateSet(estimateSec: r.estimateSec));

  @override
  Future<pb.TimesheetAnswer> timesheet(
    ServiceCall call,
    pb.TimesheetRequest r,
  ) async => _answer(
    'timesheet',
    r,
    pb.TimesheetAnswer(
      rows: [
        pb.SheetRow(
          taskId: 't1',
          projectId: 'p1',
          key: 'WEB-1',
          title: 'Fix',
          seconds: [3600, 0, 1800, 0, 0, 0, 0],
          total: 5400,
          billable: 1800,
        ),
      ],
      dayTotals: [3600, 0, 1800, 0, 0, 0, 0],
      total: 5400,
    ),
  );

  @override
  Future<pb.TotalsAnswer> totals(ServiceCall call, pb.TotalsRequest r) async =>
      pb.TotalsAnswer();
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcTimeClient client;
  final time = _Server();

  setUpAll(() async {
    server = Server.create(services: [time]);
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
    client = GrpcTimeClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  tearDown(() => time.fail = null);

  test('starting names the task and reports the timer it replaced', () async {
    final plain = await client.start('w1', 'p1', 't1');
    final swapped = await client.start('w1', 'p1', 'swap');

    final asked = time.seen['start']! as pb.TimeStartRequest;
    expect(
      (asked.workspaceId, asked.projectId, asked.taskId),
      ('w1', 'p1', 'swap'),
    );
    expect(plain.entry.running, isTrue);
    expect(plain.stopped, isNull);
    expect(swapped.stopped?.id, 'old');
  });

  test('entries carry their times, note, flags and who', () async {
    final e = (await client.stop('w1'));

    expect(e.startedAt, DateTime.utc(2026, 11, 11, 12));
    expect(e.endedAt, DateTime.utc(2026, 11, 11, 12, 1, 30));
    expect(
      (e.durationSec, e.note, e.billable, e.userName),
      (90, 'n', true, 'Zoe'),
    );
    expect((e.overlaps, e.isLong, e.running), (true, true, false));
  });

  test('the current timer is read with the time it was received', () async {
    final before = DateTime.now();
    final state = await client.current('w1');

    expect(state.running, isTrue);
    expect(state.entry!.running, isTrue);
    expect(state.receivedAt.isBefore(before), isFalse);
    expect((await client.current('none')).running, isFalse);
  });

  test('a manual entry is sent in UTC with an offset', () async {
    await client.createEntry(
      'w1',
      'p1',
      't1',
      startedAt: DateTime.utc(2026, 11, 2, 9),
      durationSec: 5400,
      note: 'x',
      billable: true,
    );

    final r = time.seen['create']! as pb.EntryCreateRequest;
    expect(r.startedAt, '2026-11-02T09:00:00.000+00:00');
    expect((r.durationSec, r.note, r.billable), (5400, 'x', true));
  });

  test('an update names only the fields it changes', () async {
    await client.updateEntry('w1', 'e1', note: 'later', billable: false);

    final r = time.seen['update']! as pb.EntryUpdateRequest;
    expect(r.fields.toList(), ['note', 'billable']);
    expect((r.id, r.note, r.billable), ('e1', 'later', false));
    await client.deleteEntry('w1', 'e1');
    expect((time.seen['delete']! as pb.EntryDeleteRequest).id, 'e1');
  });

  test('entries, summary and estimate go through', () async {
    expect((await client.entries('w1', 'p1', 't1')).map((e) => e.id), [
      'a',
      'b',
    ]);
    final s = await client.summary('w1', 'p1', 't1');
    expect(
      (s.estimateSec, s.loggedSec, s.billableSec, s.running),
      (7200, 3600, 1800, true),
    );
    await client.setEstimate('w1', 'p1', 't1', 600);
    expect((time.seen['estimate']! as pb.EstimateSetRequest).estimateSec, 600);
  });

  test(
    'a timesheet asks for the week at an offset and reads the grid',
    () async {
      final sheet = await client.timesheet('w1', DateTime(2026, 11, 9), 240);

      final r = time.seen['timesheet']! as pb.TimesheetRequest;
      expect(
        (r.weekStart, r.timezone, r.utcOffsetMinutes),
        ('2026-11-09', '', 240),
      );
      expect(sheet.rows.single.seconds, [3600, 0, 1800, 0, 0, 0, 0]);
      expect((sheet.total, sheet.dayTotals[2]), (5400, 1800));
    },
  );

  test('a refusal is mapped', () async {
    time.fail = GrpcError.invalidArgument('VALIDATION_ERROR: Switched off');

    expect(
      client.start('w1', 'p1', 't1'),
      throwsA(
        isA<TimeException>().having((e) => e.detail, 'detail', 'Switched off'),
      ),
    );
  });
}
