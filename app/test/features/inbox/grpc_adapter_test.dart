import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/features/inbox/data/inbox_client.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/gen/infrastructure/inbox/grpc/inbox.pbgrpc.dart'
    as pb;

import '../workspaces/fakes.dart';

/// Answers every call with something recognisable and notes what it was asked.
class _Server extends pb.InboxControllerServiceBase {
  final seen = <String, Object>{};
  GrpcError? fail;

  T _answer<T>(String name, Object request, T answer) {
    seen[name] = request;
    final f = fail;
    if (f != null) throw f;
    return answer;
  }

  @override
  Future<pb.UnreadTotal> archive(
    ServiceCall call,
    pb.ArchiveRequest request,
  ) async => _answer('archive', request, pb.UnreadTotal(count: 4));

  @override
  Future<pb.InboxPage> list(
    ServiceCall call,
    pb.InboxListRequest request,
  ) async => _answer(
    'list',
    request,
    pb.InboxPage(
      notifications: [
        pb.Notification(
          id: 'n1',
          type: 'task.assigned',
          payload: '{"key":"WEB-1","title":"Alpha"}',
          createdAt: '2026-11-11T10:00:00+00:00',
          updatedAt: '2026-11-11T10:00:00+00:00',
        ),
      ],
      cursor: 'next',
      unreadCount: 7,
    ),
  );

  @override
  Future<pb.UnreadTotal> markRead(
    ServiceCall call,
    pb.MarkReadRequest request,
  ) async => _answer('markRead', request, pb.UnreadTotal(count: 2));

  @override
  Future<pb.Notification> snooze(
    ServiceCall call,
    pb.SnoozeRequest request,
  ) async => _answer(
    'snooze',
    request,
    pb.Notification(
      id: request.id,
      type: 'task.assigned',
      snoozedUntil: request.until,
      createdAt: '2026-11-11T10:00:00+00:00',
      updatedAt: '2026-11-11T10:00:00+00:00',
    ),
  );

  @override
  Future<pb.UnreadTotal> unreadCount(
    ServiceCall call,
    pb.UnreadCountRequest request,
  ) async => _answer('unreadCount', request, pb.UnreadTotal(count: 9));
}

class _Prefs extends pb.PrefControllerServiceBase {
  final seen = <String, Object>{};

  pb.PrefsAnswer _answer() => pb.PrefsAnswer(
    prefs: [
      pb.PrefRow(
        eventType: 'task.assigned',
        label: 'Assigned',
        inbox: true,
        push: true,
        emailMode: 'instant',
      ),
    ],
    settings: pb.InboxSettings(timezone: 'Europe/Paris', digestHour: 6),
  );

  @override
  Future<pb.PrefsAnswer> get(
    ServiceCall call,
    pb.PrefsGetRequest request,
  ) async => _answer();

  @override
  Future<pb.PrefsAnswer> set(
    ServiceCall call,
    pb.PrefSetRequest request,
  ) async {
    seen['set'] = request;
    return _answer();
  }

  @override
  Future<pb.PrefsAnswer> setSettings(
    ServiceCall call,
    pb.SettingsSetRequest request,
  ) async {
    seen['settings'] = request;
    if (request.timezone == 'Mars') {
      throw GrpcError.invalidArgument('INVALID: Unknown time zone');
    }
    return _answer();
  }
}

class _Watchers extends pb.WatcherControllerServiceBase {
  final calls = <String>[];

  @override
  Future<pb.WatchState> add(
    ServiceCall call,
    pb.WatchAddRequest request,
  ) async {
    calls.add('add ${request.taskId}');
    return pb.WatchState(watching: true, watcherCount: 2);
  }

  @override
  Future<pb.WatchState> get(
    ServiceCall call,
    pb.WatchGetRequest request,
  ) async => pb.WatchState(watching: false, watcherCount: 1);

  @override
  Future<pb.WatchState> remove(
    ServiceCall call,
    pb.WatchRemoveRequest request,
  ) async {
    calls.add('remove ${request.taskId}');
    return pb.WatchState(watching: false, watcherCount: 1);
  }
}

class _Devices extends pb.DeviceControllerServiceBase {
  final calls = <String>[];

  @override
  Future<pb.DeviceAnswer> register(
    ServiceCall call,
    pb.DeviceRegisterRequest request,
  ) async {
    calls.add('register ${request.platform} ${request.token}');
    return pb.DeviceAnswer(registered: true);
  }

  @override
  Future<pb.DeviceAnswer> unregister(
    ServiceCall call,
    pb.DeviceUnregisterRequest request,
  ) async {
    calls.add('unregister ${request.token}');
    return pb.DeviceAnswer(registered: false);
  }
}

void main() {
  late Server server;
  late ClientChannel channel;
  late GrpcInboxClient client;
  final inbox = _Server();
  final prefs = _Prefs();
  final watchers = _Watchers();
  final devices = _Devices();

  setUpAll(() async {
    server = Server.create(services: [inbox, prefs, watchers, devices]);
    await server.serve(address: '127.0.0.1', port: 0);
    channel = ClientChannel(
      '127.0.0.1',
      port: server.port!,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    final store = MemoryTokenStore();
    // A token that does not expire for years, so no refresh is attempted.
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
    client = GrpcInboxClient(channel, session);
  });

  tearDownAll(() async {
    await channel.shutdown();
    await server.shutdown();
  });

  test(
    'list asks for the workspace, filter and page and reads the page',
    () async {
      final page = await client.list(
        'w1',
        InboxFilter.mentions,
        before: 'c1',
        pageSize: 5,
      );

      final asked = inbox.seen['list']! as pb.InboxListRequest;
      expect(
        (asked.workspaceId, asked.filter, asked.before, asked.pageSize),
        ('w1', 'mentions', 'c1', 5),
      );
      expect(page.notifications.single.title, 'Alpha');
      expect((page.cursor, page.unread), ('next', 7));
    },
  );

  test('marking read, archiving and counting go through', () async {
    expect(await client.markRead('w1', ids: ['a', 'b'], read: false), 2);
    final read = inbox.seen['markRead']! as pb.MarkReadRequest;
    expect(read.ids.toList(), ['a', 'b']);
    expect((read.all, read.read), (false, false));

    expect(await client.markRead('w1', all: true), 2);
    expect((inbox.seen['markRead']! as pb.MarkReadRequest).all, isTrue);

    expect(await client.archive('w1', ['a'], archived: true), 4);
    expect((inbox.seen['archive']! as pb.ArchiveRequest).archived, isTrue);

    expect(await client.unreadCount(''), 9);
    expect(
      (inbox.seen['unreadCount']! as pb.UnreadCountRequest).workspaceId,
      '',
    );
  });

  test('a snooze sends an offset time, and none clears it', () async {
    final until = DateTime.utc(2026, 11, 12, 9);
    final n = await client.snooze('w1', 'n1', until);

    expect(
      (inbox.seen['snooze']! as pb.SnoozeRequest).until,
      until.toIso8601String(),
    );
    expect(n.snoozedUntil, until);

    final cleared = await client.snooze('w1', 'n1', null);
    expect((inbox.seen['snooze']! as pb.SnoozeRequest).until, '');
    expect(cleared.snoozedUntil, isNull);
  });

  test('preferences are read and written', () async {
    final read = await client.prefs();
    expect(read.rows.single.email, EmailMode.instant);
    expect(read.settings.timezone, 'Europe/Paris');
    expect(read.settings.digestHour, 6);

    await client.setPref(
      'task.assigned',
      inbox: false,
      push: true,
      email: EmailMode.digest,
    );
    final set = prefs.seen['set']! as pb.PrefSetRequest;
    expect(
      (set.eventType, set.inbox, set.push, set.emailMode),
      ('task.assigned', false, true, 'digest'),
    );

    await client.setSettings(
      const InboxSettings(
        timezone: 'UTC',
        quietStart: '22:00',
        quietEnd: '07:00',
        digestHour: 8,
      ),
    );
    final s = prefs.seen['settings']! as pb.SettingsSetRequest;
    expect(
      (s.timezone, s.quietStart, s.quietEnd, s.digestHour),
      ('UTC', '22:00', '07:00', 8),
    );
  });

  test('a refused setting says why', () async {
    await expectLater(
      client.setSettings(const InboxSettings(timezone: 'Mars')),
      throwsA(
        isA<InboxException>()
            .having((e) => e.failure, 'failure', InboxFailure.invalid)
            .having((e) => e.detail, 'detail', 'Unknown time zone'),
      ),
    );
  });

  test('watching and devices go through', () async {
    expect((await client.watchState('w1', 'p1', 'a')).watching, isFalse);
    expect((await client.watch('w1', 'p1', 'a', on: true)).watcherCount, 2);
    await client.watch('w1', 'p1', 'a', on: false);
    expect(watchers.calls, ['add a', 'remove a']);

    await client.registerDevice('ios', 'tok');
    await client.unregisterDevice('tok');
    expect(devices.calls, ['register ios tok', 'unregister tok']);
  });

  test('a server that refuses becomes the failure the screens know', () async {
    inbox.fail = GrpcError.permissionDenied('no');
    await expectLater(
      client.unreadCount('w1'),
      throwsA(
        isA<InboxException>().having(
          (e) => e.failure,
          'failure',
          InboxFailure.forbidden,
        ),
      ),
    );
    inbox.fail = null;
  });
}
