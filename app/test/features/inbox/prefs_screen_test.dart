import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../projects/projects_test_support.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<({FakeInboxClient inbox, FakeLocalNotifier local})> open(
  WidgetTester tester, {
  FakeInboxClient? client,
  FakeLocalNotifier? local,
  List<Override> overrides = const [],
}) async {
  final fake = client ?? FakeInboxClient();
  final notifier = local ?? FakeLocalNotifier();
  final pumped = await pumpProjects(
    tester,
    inbox: fake,
    localNotifier: notifier,
    overrides: [inboxNowProvider.overrideWithValue(() => noon), ...overrides],
  );
  await pumped.go(tester, '/inbox/preferences');
  return (inbox: fake, local: notifier);
}

Future<void> toggle(WidgetTester tester, String k) async {
  await tester.ensureVisible(key(k));
  await tester.tap(key(k));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a row per kind, with its channels as chosen', (tester) async {
    await open(tester);

    for (final row in defaultPrefs.rows) {
      expect(key('pref-${row.eventType}'), findsOneWidget);
    }
    expect(
      tester.widget<TfToggle>(key('pref-push-task.assigned')).value,
      isTrue,
    );
    expect(
      tester.widget<TfToggle>(key('pref-push-user.mentioned')).value,
      isFalse,
    );
    expect(
      tester
          .widget<SegmentedButton<EmailMode>>(key('pref-email-comment.added'))
          .selected,
      {EmailMode.digest},
    );
  });

  testWidgets('switching the inbox off for a kind is saved', (tester) async {
    final o = await open(tester);

    await toggle(tester, 'pref-inbox-task.assigned');

    expect(o.inbox.prefSets.single.eventType, 'task.assigned');
    expect(o.inbox.prefSets.single.inbox, isFalse);
    expect(
      tester.widget<TfToggle>(key('pref-inbox-task.assigned')).value,
      isFalse,
    );
  });

  testWidgets('email can be off, instant or a daily digest', (tester) async {
    final o = await open(tester);

    await tester.ensureVisible(key('pref-email-comment.added'));
    await tester.tap(
      find.descendant(
        of: key('pref-email-comment.added'),
        matching: find.text('Instant'),
      ),
    );
    await tester.pumpAndSettle();

    expect(o.inbox.prefSets.single.email, EmailMode.instant);
  });

  testWidgets('a refused change goes back and is explained', (tester) async {
    final o = await open(tester);
    o.inbox.failNext = const InboxException(InboxFailure.network);

    await toggle(tester, 'pref-inbox-user.mentioned');

    expect(
      tester.widget<TfToggle>(key('pref-inbox-user.mentioned')).value,
      isTrue,
    );
    expect(find.textContaining('Could not reach the server'), findsOneWidget);
  });

  testWidgets('push is explained before the system is asked', (tester) async {
    final o = await open(
      tester,
      overrides: [
        pushTokenSourceProvider.overrideWithValue(
          FakePushTokenSource(const PushToken('android', 'tok-1')),
        ),
      ],
    );

    await toggle(tester, 'pref-push-user.mentioned');
    expect(key('push-explainer'), findsOneWidget);
    expect(o.local.permissionAsks, 0); // not yet
    expect(o.inbox.prefSets, isEmpty);

    await tester.tap(key('push-explainer-continue'));
    await tester.pumpAndSettle();

    expect(o.local.permissionAsks, 1);
    expect(o.inbox.prefSets.single.push, isTrue);
    expect(
      o.inbox.registered.single.token,
      'tok-1',
    ); // this device is registered

    // Once allowed, the next one needs no explaining.
    await toggle(tester, 'pref-push-comment.added');
    expect(key('push-explainer'), findsNothing);
    expect(o.local.permissionAsks, 1);
    expect(o.inbox.prefSets.last.eventType, 'comment.added');
  });

  testWidgets('not now leaves push off and asks nothing', (tester) async {
    final o = await open(tester);

    await toggle(tester, 'pref-push-user.mentioned');
    await tester.tap(key('push-explainer-cancel'));
    await tester.pumpAndSettle();

    expect(o.local.permissionAsks, 0);
    expect(o.inbox.prefSets, isEmpty);
    expect(
      tester.widget<TfToggle>(key('pref-push-user.mentioned')).value,
      isFalse,
    );
  });

  testWidgets('a system "no" is said, and the choice is still kept', (
    tester,
  ) async {
    final o = await open(tester, local: FakeLocalNotifier(grant: false));

    await toggle(tester, 'pref-push-user.mentioned');
    await tester.tap(key('push-explainer-continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('off for this device'), findsOneWidget);
    expect(o.inbox.prefSets.single.push, isTrue);
    expect(o.inbox.registered, isEmpty); // no permission, no device
  });

  testWidgets('quiet hours: on gives a night, off clears it', (tester) async {
    final o = await open(tester);
    expect(key('quiet-start'), findsNothing);

    await toggle(tester, 'quiet-switch');
    expect(o.inbox.settingsSets.last.quietStart, '22:00');
    expect(o.inbox.settingsSets.last.quietEnd, '07:00');
    expect(key('quiet-start'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);

    await toggle(tester, 'quiet-switch');
    expect(o.inbox.settingsSets.last.quietOn, isFalse);
    expect(key('quiet-start'), findsNothing);
  });

  testWidgets('quiet hours that start and end together are refused', (
    tester,
  ) async {
    final o = await open(
      tester,
      client: FakeInboxClient(
        prefsValue: const Prefs(
          [],
          InboxSettings(quietStart: '07:00', quietEnd: '07:00'),
        ),
      ),
    );

    await toggle(tester, 'quiet-start');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(key('quiet-error'), findsOneWidget);
    expect(o.inbox.settingsSets, isEmpty);
  });

  testWidgets('picking a quiet time saves it', (tester) async {
    final o = await open(
      tester,
      client: FakeInboxClient(
        prefsValue: const Prefs(
          [],
          InboxSettings(quietStart: '22:00', quietEnd: '07:00'),
        ),
      ),
    );

    await toggle(tester, 'quiet-end');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(key('quiet-error'), findsNothing);
    expect(o.inbox.settingsSets.single.quietEnd, '07:00');

    await toggle(tester, 'quiet-start');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(o.inbox.settingsSets, hasLength(1)); // backing out saved nothing
  });

  testWidgets('the time zone must look like one, and is saved when it does', (
    tester,
  ) async {
    final o = await open(tester);

    await tester.enterText(key('timezone-field'), 'Mars');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Europe/Paris or UTC'), findsOneWidget);
    expect(o.inbox.settingsSets, isEmpty);

    await tester.enterText(key('timezone-field'), 'Europe/Paris');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Europe/Paris or UTC'), findsNothing);
    expect(o.inbox.settingsSets.single.timezone, 'Europe/Paris');
  });

  testWidgets('the device time zone is offered, or the person is told', (
    tester,
  ) async {
    final o = await open(tester);

    await toggle(tester, 'timezone-device');

    // Either a zone with this machine's offset was saved, or it says to type.
    final saved = o.inbox.settingsSets.isNotEmpty;
    expect(
      saved || find.textContaining('Type your time zone').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('the digest hour is chosen from the list', (tester) async {
    final o = await open(tester);

    await toggle(tester, 'digest-hour');
    await tester.tap(find.text('09:00').last);
    await tester.pumpAndSettle();

    expect(o.inbox.settingsSets.single.digestHour, 9);
  });

  testWidgets('a failed read offers a retry', (tester) async {
    final fake = FakeInboxClient()..failReads = true;
    await open(tester, client: fake);

    expect(key('prefs-error'), findsOneWidget);
    fake.failReads = false;
    await tester.tap(key('retry-prefs'));
    await tester.pumpAndSettle();

    expect(key('pref-task.assigned'), findsOneWidget);
  });
}
