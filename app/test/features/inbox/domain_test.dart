import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:taskforge/features/inbox/data/inbox_client.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/inbox/domain/timezones.dart';
import 'package:taskforge/gen/infrastructure/inbox/grpc/inbox.pbgrpc.dart'
    as pb;

import 'fakes.dart';

void main() {
  group('payload and wording', () {
    test('an unreadable payload is empty, never an error', () {
      expect(parsePayload(''), isEmpty);
      expect(parsePayload('not json'), isEmpty);
      expect(parsePayload('[1,2]'), isEmpty);
      expect(parsePayload('{"title":"Fix"}')['title'], 'Fix');
    });

    test('the kinds read as sentences with the actor and the task', () {
      final assigned = note('1', 'task.assigned');
      expect(assigned.kind, NotificationKind.assigned);
      expect(assigned.what, 'Hank assigned you');
      expect(assigned.taskLabel, 'WEB-1 Alpha');
      expect(note('2', 'user.mentioned').what, 'Hank mentioned you in');
      expect(note('3', 'comment.added').what, 'Hank commented on');
      expect(note('4', 'task.due_soon').what, 'Due soon:');
      expect(
        note(
          '5',
          'status.changed',
          payload: {'from': 'To do', 'to': 'Done'},
        ).what,
        'Hank moved from To do to Done',
      );
      expect(note('6', 'status.changed').what, 'Hank changed the status of');
      expect(note('7', 'something.new').kind, NotificationKind.unknown);
    });

    test(
      'a missing actor is "Someone" and a missing task cannot be opened',
      () {
        final n = note('1', 'task.assigned', actor: '', task: '');
        expect(n.who, 'Someone');
        expect(n.canOpen, isFalse);
        expect(note('2', 'task.assigned').canOpen, isTrue);
      },
    );

    test(
      'a webhook switched off and goal notices name what they are about',
      () {
        final hook = note(
          '1',
          'webhook.disabled',
          task: '',
          project: '',
          actor: '',
          payload: {
            'webhook': 'Build bot',
            'webhook_id': 'h1',
            'reason': '10 failures in a row',
          },
        );
        expect(hook.kind, NotificationKind.webhookDisabled);
        expect(hook.subject, 'Build bot');
        expect(hook.reason, '10 failures in a row');
        expect(hook.route, '/developer/webhooks/h1');

        final reached = note(
          '2',
          'goal.reached',
          task: '',
          project: '',
          payload: {'goal': 'Launch', 'goal_id': 'g1', 'progress': 1.0},
        );
        expect(reached.kind, NotificationKind.goalReached);
        expect(reached.subject, 'Launch');
        expect(reached.route, '/goals/g1');

        final risk = note(
          '3',
          'goal.at_risk',
          task: '',
          project: '',
          payload: {'goal': 'Launch', 'goal_id': 'g1', 'progress': 0.256},
        );
        expect(risk.kind, NotificationKind.goalAtRisk);
        expect(risk.progressPercent, 26);
      },
    );

    test('a task notification routes to its task, one without ids nowhere', () {
      expect(note('1', 'task.assigned').route, '/projects/p1?task=a');
      expect(note('2', 'task.assigned', task: '', project: '').route, isNull);
      expect(
        note('3', 'goal.reached', task: '', project: '', payload: {}).route,
        isNull,
        reason: 'no goal id in the payload',
      );
    });

    test('payload fields are read as text', () {
      final n = note(
        '1',
        'comment.added',
        payload: {'excerpt': 'Looks good', 'due_date': '2026-11-12', 'x': 1},
      );
      expect(n.excerpt, 'Looks good');
      expect(n.dueDate, '2026-11-12');
      expect(n.from, '');
    });
  });

  group('which filter shows what', () {
    test('unread, mentions, assigned and the hidden ones', () {
      final unread = note('1', 'task.assigned');
      final read = note('2', 'user.mentioned', read: true);
      final snoozed = note(
        '3',
        'task.assigned',
        snoozedUntil: noon.add(const Duration(hours: 2)),
      );
      final woken = note(
        '4',
        'task.assigned',
        snoozedUntil: noon.subtract(const Duration(hours: 1)),
      );
      final archived = note('5', 'task.assigned', archived: true);

      bool shows(InboxNotification n, InboxFilter f) => n.belongsTo(f, noon);
      expect(shows(unread, InboxFilter.all), isTrue);
      expect(shows(unread, InboxFilter.unread), isTrue);
      expect(shows(read, InboxFilter.unread), isFalse);
      expect(shows(read, InboxFilter.mentions), isTrue);
      expect(shows(unread, InboxFilter.mentions), isFalse);
      expect(shows(unread, InboxFilter.assigned), isTrue);
      expect(shows(snoozed, InboxFilter.all), isFalse);
      expect(shows(snoozed, InboxFilter.snoozed), isTrue);
      expect(shows(woken, InboxFilter.all), isTrue); // its time has passed
      expect(shows(woken, InboxFilter.snoozed), isFalse);
      expect(shows(archived, InboxFilter.all), isFalse);
      expect(shows(archived, InboxFilter.snoozed), isFalse);
      expect(shows(archived, InboxFilter.archived), isTrue);
    });

    test('copyWith changes only what it is told to', () {
      final n = note('1', 'task.assigned');
      final read = n.copyWith(readAt: () => noon);
      expect(read.isRead, isTrue);
      expect(read.copyWith(readAt: () => null).isRead, isFalse);
      expect(read.copyWith().isRead, isTrue);
      expect(read, isNot(n));
      expect(read.id, n.id);
    });
  });

  group('time', () {
    test('relative times step from now to a date', () {
      String at(Duration ago) => relativeTime(noon.subtract(ago), noon);
      expect(at(const Duration(seconds: 10)), 'now');
      expect(at(const Duration(minutes: 5)), '5 min ago');
      expect(at(const Duration(hours: 3)), '3 h ago');
      expect(at(const Duration(hours: 30)), 'yesterday');
      expect(at(const Duration(days: 4)), '4 d ago');
      expect(at(const Duration(days: 30)), '2026-10-12');
      expect(relativeTime(noon.add(const Duration(minutes: 5)), noon), 'now');
    });

    test('snooze presets: later today, tomorrow, next Monday', () {
      final p = snoozePresets(noon); // a Wednesday
      expect(p.map((e) => e.label), ['Later today', 'Tomorrow', 'Next week']);
      expect(p[0].at, DateTime(2026, 11, 11, 18));
      expect(p[1].at, DateTime(2026, 11, 12, 9));
      expect(p[2].at, DateTime(2026, 11, 16, 9));
    });

    test('later today never lands in the past or under half an hour away', () {
      final late = DateTime(2026, 11, 11, 17, 45);
      expect(snoozePresets(late)[0].at, DateTime(2026, 11, 11, 19, 45));
      final monday = DateTime(2026, 11, 16, 10);
      expect(snoozePresets(monday)[2].at, DateTime(2026, 11, 23, 9));
    });

    test('time zones and quiet times', () {
      expect(isValidTimezone('UTC'), isTrue);
      expect(isValidTimezone('Europe/Paris'), isTrue);
      expect(isValidTimezone('America/Argentina/Buenos_Aires'), isTrue);
      expect(isValidTimezone('Mars'), isFalse);
      expect(isValidTimezone(''), isFalse);
      expect(timezoneForOffset(const Duration(minutes: 210)), 'Asia/Tehran');
      expect(timezoneForOffset(const Duration(minutes: 7)), isNull);
      expect(hhmm(7, 5), '07:05');
      expect(parseHhmm('22:30'), (hour: 22, minute: 30));
      expect(parseHhmm('24:00'), isNull);
      expect(parseHhmm('nope'), isNull);
    });
  });

  group('settings and failures', () {
    test('quiet hours are on only with both ends', () {
      expect(const InboxSettings().quietOn, isFalse);
      expect(const InboxSettings(quietStart: '22:00').quietOn, isFalse);
      expect(
        const InboxSettings(quietStart: '22:00', quietEnd: '07:00').quietOn,
        isTrue,
      );
      final s = const InboxSettings().copyWith(digestHour: 9, timezone: 'UTC');
      expect(s.digestHour, 9);
      expect(s, const InboxSettings(digestHour: 9));
    });

    test('prefs find a row and copy it', () {
      final row = defaultPrefs.of('task.assigned')!;
      expect(row.copyWith(push: false).push, isFalse);
      expect(row.copyWith(email: EmailMode.digest).email, EmailMode.digest);
      expect(row.kind, NotificationKind.assigned);
      expect(defaultPrefs.of('nope'), isNull);
      expect(EmailMode.of('instant'), EmailMode.instant);
      expect(EmailMode.of('?'), EmailMode.off);
    });

    test('failures are said in plain words', () {
      String say(InboxFailure f, {String? detail}) =>
          inboxErrorMessage(InboxException(f, detail: detail));
      expect(say(InboxFailure.network), contains('connection'));
      expect(say(InboxFailure.denied), contains('access'));
      expect(say(InboxFailure.invalid), 'That is not valid.');
      expect(say(InboxFailure.invalid, detail: 'Unknown zone'), 'Unknown zone');
      expect(say(InboxFailure.notFound), contains('no longer'));
      expect(inboxErrorMessage(StateError('x')), contains('Try again'));
    });
  });

  group('the server messages', () {
    test('a notification is read from its message', () {
      final n = notificationFromPb(
        pb.Notification(
          id: 'n1',
          workspaceId: 'w1',
          type: 'status.changed',
          taskId: 't',
          projectId: 'p',
          actorId: 'u2',
          actorName: 'Hank',
          payload: '{"key":"WEB-2","title":"Beta","from":"A","to":"B"}',
          count: 0,
          createdAt: '2026-11-11T10:00:00+00:00',
          updatedAt: '2026-11-11T10:05:00+00:00',
          readAt: '2026-11-11T10:06:00+00:00',
          snoozedUntil: '',
          archivedAt: '',
        ),
      );
      expect(n.kind, NotificationKind.statusChanged);
      expect(n.count, 1); // never below one
      expect(n.title, 'Beta');
      expect(n.isRead, isTrue);
      expect(n.snoozedUntil, isNull);
      expect(n.updatedAt.isAfter(n.createdAt), isTrue);
    });

    test('prefs are read with their defaults filled by the server', () {
      final prefs = prefsFromPb(
        pb.PrefsAnswer(
          prefs: [
            pb.PrefRow(
              eventType: 'task.assigned',
              label: 'Assigned',
              inbox: true,
              push: true,
              emailMode: 'digest',
            ),
          ],
          settings: pb.InboxSettings(
            timezone: '',
            quietStart: '22:00',
            quietEnd: '07:00',
            digestHour: 9,
          ),
        ),
      );
      expect(prefs.rows.single.email, EmailMode.digest);
      expect(prefs.settings.timezone, 'UTC');
      expect(prefs.settings.quietOn, isTrue);
      expect(prefs.settings.digestHour, 9);
    });

    test('errors from the server become the screens\' failures', () {
      expect(
        mapInboxError(GrpcError.invalidArgument('INVALID: Unknown zone'))
            .detail,
        'Unknown zone',
      );
      expect(
        mapInboxError(GrpcError.invalidArgument('bad')).failure,
        InboxFailure.invalid,
      );
      expect(
        mapInboxError(GrpcError.unavailable()).failure,
        InboxFailure.network,
      );
      expect(
        mapInboxError(GrpcError.notFound('No such notification')).failure,
        InboxFailure.notFound,
      );
      const same = InboxException(InboxFailure.denied);
      expect(mapInboxError(same), same);
      expect(mapInboxError(StateError('boom')).failure, InboxFailure.other);
    });
  });
}
