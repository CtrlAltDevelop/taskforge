import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

typedef Opened = ({Pumped pumped, FakeInboxClient inbox});

Future<Opened> open(
  WidgetTester tester, {
  List<InboxNotification> items = const [],
  FakeInboxClient? client,
  int pageSize = 50,
  List<String> workspaces = const ['w1'],
  String location = '/inbox',
}) async {
  final fake = client ?? FakeInboxClient(initial: items, pageSize: pageSize);
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    inbox: fake,
    workspaces: workspaces,
    overrides: [inboxNowProvider.overrideWithValue(() => noon)],
  );
  await pumped.go(tester, location);
  return (pumped: pumped, inbox: fake);
}

Finder key(String k) => find.byKey(Key(k));

Future<void> pickMenu(WidgetTester tester, String id, String item) async {
  await tester.tap(key('menu-$id'));
  await tester.pumpAndSettle();
  await tester.tap(key(item));
  await tester.pumpAndSettle();
}

String badgeText(WidgetTester tester) =>
    tester.widget<Badge>(key('inbox-badge').first).label.toString();

void main() {
  testWidgets('shows who did what to which task, unread first in style', (
    tester,
  ) async {
    await open(
      tester,
      items: [
        note('n1', 'task.assigned'),
        note(
          'n2',
          'user.mentioned',
          read: true,
          actor: 'Ana',
          payload: {'key': 'WEB-2', 'title': 'Beta', 'excerpt': 'ping @Zoe'},
          updatedAt: noon.subtract(const Duration(hours: 3)),
        ),
      ],
    );

    expect(find.text('Hank assigned you WEB-1 Alpha'), findsOneWidget);
    expect(find.text('Ana mentioned you in WEB-2 Beta'), findsOneWidget);
    expect(find.text('ping @Zoe'), findsOneWidget);
    expect(key('unread-n1'), findsOneWidget);
    expect(key('unread-n2'), findsNothing); // already read
    expect(find.text('5 min ago'), findsOneWidget);
    expect(find.text('3 h ago'), findsOneWidget);
    expect(find.text('1 unread'), findsOneWidget);
  });

  testWidgets('the sidebar shows how many are unread', (tester) async {
    await open(
      tester,
      items: [note('n1', 'task.assigned'), note('n2', 'user.mentioned')],
    );

    expect(key('open-inbox'), findsOneWidget);
    expect(
      find.descendant(of: key('open-inbox'), matching: find.text('2')),
      findsOneWidget,
    );
  });

  testWidgets('filters read from the server and show their own kind', (
    tester,
  ) async {
    final o = await open(
      tester,
      items: [
        note('n1', 'task.assigned'),
        note('n2', 'user.mentioned', read: true),
      ],
    );

    await tester.tap(key('filter-mentions'));
    await tester.pumpAndSettle();
    expect(key('notification-n2'), findsOneWidget);
    expect(key('notification-n1'), findsNothing);

    await tester.tap(key('filter-unread'));
    await tester.pumpAndSettle();
    expect(key('notification-n1'), findsOneWidget);
    expect(key('notification-n2'), findsNothing);

    expect(
      o.inbox.lists.map((l) => l.filter),
      containsAll([InboxFilter.all, InboxFilter.mentions, InboxFilter.unread]),
    );
  });

  testWidgets('tapping one opens its task and marks it read', (tester) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);
    expect(badgeText(tester), contains('1'));

    await tester.tap(key('notification-n1'));
    await tester.pumpAndSettle();

    expect(key('detail-id'), findsOneWidget); // the task is open
    expect(o.inbox.markReads.single.ids, ['n1']);
    expect(o.inbox.items.single.isRead, isTrue);
    expect(
      find.descendant(of: key('open-inbox'), matching: find.text('1')),
      findsNothing,
    ); // the badge went away
  });

  testWidgets('a notification without a task only gets marked read', (
    tester,
  ) async {
    final o = await open(
      tester,
      items: [note('n1', 'task.assigned', task: '', project: '')],
    );

    await tester.tap(key('notification-n1'));
    await tester.pumpAndSettle();

    expect(key('inbox-list'), findsOneWidget); // still here
    expect(o.inbox.items.single.isRead, isTrue);
  });

  testWidgets('read can be undone from the menu', (tester) async {
    final o = await open(
      tester,
      items: [note('n1', 'task.assigned', read: true)],
    );

    await pickMenu(tester, 'n1', 'menu-toggle-read');

    expect(o.inbox.markReads.single.read, isFalse);
    expect(key('unread-n1'), findsOneWidget);
    expect(find.text('1 unread'), findsOneWidget);

    await pickMenu(tester, 'n1', 'menu-toggle-read');
    expect(key('unread-n1'), findsNothing);
  });

  testWidgets('snoozing with a preset hides it until then', (tester) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);

    await tester.tap(key('menu-n1'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-snooze'));
    await tester.pumpAndSettle();
    await tester.tap(key('snooze-preset-1')); // tomorrow
    await tester.pumpAndSettle();

    expect(o.inbox.snoozes.single.until, DateTime(2026, 11, 12, 9));
    expect(key('notification-n1'), findsNothing);
    expect(key('inbox-empty'), findsOneWidget);

    await tester.tap(key('filter-snoozed'));
    await tester.pumpAndSettle();
    expect(key('notification-n1'), findsOneWidget);

    await pickMenu(tester, 'n1', 'menu-unsnooze');
    expect(o.inbox.snoozes.last.until, isNull);
    expect(key('notification-n1'), findsNothing);
  });

  testWidgets('a date and time of their own can be picked', (tester) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);

    await tester.tap(key('menu-n1'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-snooze'));
    await tester.pumpAndSettle();
    await tester.tap(key('snooze-custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12')); // the day after "now" (Nov 11)
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // 9:00, the picker's start
    await tester.pumpAndSettle();

    expect(o.inbox.snoozes.single.until, DateTime(2026, 11, 12, 9));
    expect(key('notification-n1'), findsNothing);
  });

  testWidgets('a time that is not in the future is not taken', (tester) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);

    await tester.tap(key('menu-n1'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-snooze'));
    await tester.pumpAndSettle();
    await tester.tap(key('snooze-custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // today, 9:00: already past at noon
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(o.inbox.snoozes, isEmpty);
    expect(key('notification-n1'), findsOneWidget);
  });

  testWidgets('backing out of the snooze sheet changes nothing', (
    tester,
  ) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);

    await tester.tap(key('menu-n1'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-snooze'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // the barrier
    await tester.pumpAndSettle();

    expect(o.inbox.snoozes, isEmpty);
    expect(key('notification-n1'), findsOneWidget);
  });

  testWidgets('archive moves it to the archive, and back', (tester) async {
    final o = await open(tester, items: [note('n1', 'task.assigned')]);

    await pickMenu(tester, 'n1', 'menu-archive');
    expect(key('notification-n1'), findsNothing);
    expect(o.inbox.archives.single.archived, isTrue);

    await tester.tap(key('filter-archived'));
    await tester.pumpAndSettle();
    expect(key('notification-n1'), findsOneWidget);

    await pickMenu(tester, 'n1', 'menu-unarchive');
    expect(key('notification-n1'), findsNothing);
    expect(o.inbox.archives.last.archived, isFalse);
  });

  testWidgets('mark all read clears the badge and the unread chip', (
    tester,
  ) async {
    final o = await open(
      tester,
      items: [note('n1', 'task.assigned'), note('n2', 'user.mentioned')],
    );

    await tester.tap(key('mark-all-read'));
    await tester.pumpAndSettle();

    expect(o.inbox.markReads.single.all, isTrue);
    expect(key('unread-total'), findsNothing);
    expect(key('unread-n1'), findsNothing);
    expect(
      tester.widget<IconButton>(key('mark-all-read')).onPressed,
      isNull, // nothing left to mark
    );
  });

  testWidgets('a long inbox is read a page at a time', (tester) async {
    final o = await open(
      tester,
      pageSize: 2,
      items: [
        for (var i = 1; i <= 5; i++)
          note(
            'n$i',
            'task.assigned',
            updatedAt: noon.subtract(Duration(minutes: i)),
          ),
      ],
    );
    expect(key('notification-n1'), findsOneWidget);
    expect(key('notification-n3'), findsNothing);

    await tester.ensureVisible(key('load-more'));
    await tester.tap(key('load-more'));
    await tester.pumpAndSettle();
    expect(key('notification-n3'), findsOneWidget);
    expect(o.inbox.lists.last.before, '2');

    await tester.ensureVisible(key('load-more'));
    await tester.tap(key('load-more'));
    await tester.pumpAndSettle();
    expect(key('notification-n5'), findsOneWidget);
    expect(key('load-more'), findsNothing); // the end
  });

  testWidgets('a burst folded into one says how many more', (tester) async {
    await open(
      tester,
      items: [
        note(
          'n1',
          'status.changed',
          count: 10,
          payload: {
            'key': 'WEB-1',
            'title': 'Alpha',
            'from': 'To do',
            'to': 'Done',
          },
        ),
      ],
    );

    expect(find.text('+9 more'), findsOneWidget);
    expect(
      find.text('Hank moved from To do to Done WEB-1 Alpha'),
      findsOneWidget,
    );
  });

  testWidgets('an empty inbox says so, per filter', (tester) async {
    await open(tester);
    expect(find.textContaining('all caught up'), findsOneWidget);

    await tester.tap(key('filter-snoozed'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing is snoozed.'), findsOneWidget);
  });

  testWidgets('a failed read offers a retry', (tester) async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')])
      ..failReads = true;
    await open(tester, client: fake);

    expect(key('inbox-error'), findsOneWidget);
    fake.failReads = false;
    await tester.tap(key('retry-inbox'));
    await tester.pumpAndSettle();

    expect(key('notification-n1'), findsOneWidget);
  });

  testWidgets('a refused change is put back and explained', (tester) async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')])
      ..gate = null;
    await open(tester, client: fake);
    final gate = Completer<void>();
    fake
      ..failNext = const InboxException(InboxFailure.network)
      ..gate = gate;

    await tester.tap(key('menu-n1'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-toggle-read'));
    await tester.pump();
    // At once: it shows as read, before the server has answered.
    expect(key('unread-n1'), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(key('unread-n1'), findsOneWidget); // put back
    expect(find.textContaining('Could not reach the server'), findsOneWidget);
    expect(find.text('1 unread'), findsOneWidget);
  });

  testWidgets('a refused archive keeps the notification', (tester) async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    await open(tester, client: fake);
    fake.failNext = const InboxException(InboxFailure.denied);

    await pickMenu(tester, 'n1', 'menu-archive');

    expect(key('notification-n1'), findsOneWidget);
    expect(find.textContaining('do not have access'), findsOneWidget);
  });

  testWidgets('the home screen has a bell with the count and a way in', (
    tester,
  ) async {
    await open(tester, items: [note('n1', 'task.assigned')], location: '/');

    expect(key('open-inbox-bell'), findsOneWidget);
    await tester.tap(key('open-inbox-bell'));
    await tester.pumpAndSettle();
    expect(key('inbox-list'), findsOneWidget);
  });

  testWidgets('unread elsewhere shows on the workspace switcher', (
    tester,
  ) async {
    final fake = FakeInboxClient(
      initial: [
        note('n1', 'task.assigned'),
        note('n2', 'task.assigned', workspace: 'w2'),
        note('n3', 'task.assigned', workspace: 'w2'),
      ],
    );
    await open(tester, client: fake, workspaces: const ['w1', 'w2']);

    final badge = tester.widget<Badge>(key('switcher-badge'));
    expect(badge.isLabelVisible, isTrue);
    expect((badge.label as Text).data, '2'); // the two in w2
  });

  testWidgets('the notification settings are one tap from the inbox', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(key('open-notification-prefs'));
    await tester.pumpAndSettle();

    expect(find.text('Notification settings'), findsWidgets);
    expect(key('pref-task.assigned'), findsOneWidget);
  });
}
