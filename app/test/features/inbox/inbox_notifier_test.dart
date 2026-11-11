import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

ProviderContainer make(FakeInboxClient fake, {String? workspace = 'w1'}) {
  final c = ProviderContainer(
    overrides: [
      workspaceScopeProvider.overrideWithValue(workspace),
      inboxClientProvider.overrideWithValue(fake),
      inboxNowProvider.overrideWithValue(() => noon),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

/// Keeps the autoDispose notifier alive, loaded.
Future<ProviderSubscription<InboxState>> load(
  ProviderContainer c, [
  InboxFilter filter = InboxFilter.all,
]) async {
  final sub = c.listen(inboxProvider(filter), (_, _) {});
  await pumpEventQueue();
  return sub;
}

void main() {
  test('a read of nothing is not an error', () async {
    final c = make(FakeInboxClient());
    final sub = await load(c);

    expect(sub.read().items, isEmpty);
    expect(sub.read().loading, isFalse);
    expect(sub.read().error, isNull);
    expect(sub.read().hasMore, isFalse);
  });

  test('without a workspace there is nothing to read', () async {
    final c = make(FakeInboxClient(), workspace: null);
    final sub = await load(c);

    expect(sub.read().error?.failure, InboxFailure.other);
    expect(await c.read(unreadCountProvider.future), 0);
    expect(await c.read(unreadTotalProvider.future), 0);
  });

  test('what is on screen stays when a later read fails', () async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final c = make(fake);
    final sub = await load(c);

    fake.failReads = true;
    await c.read(inboxProvider(InboxFilter.all).notifier).refresh();

    expect(sub.read().items, hasLength(1));
    expect(sub.read().error?.failure, InboxFailure.network);
  });

  test(
    'a failed "load more" keeps what there is and can be tried again',
    () async {
      final fake = FakeInboxClient(
        pageSize: 1,
        initial: [
          note('n1', 'task.assigned'),
          note(
            'n2',
            'task.assigned',
            updatedAt: noon.subtract(const Duration(hours: 1)),
          ),
        ],
      );
      final c = make(fake);
      final sub = await load(c);
      final notifier = c.read(inboxProvider(InboxFilter.all).notifier);

      fake.failReads = true;
      await notifier.loadMore();
      expect(sub.read().items, hasLength(1));
      expect(sub.read().loadingMore, isFalse);

      fake.failReads = false;
      await notifier.loadMore();
      expect(sub.read().items, hasLength(2));
      await notifier.loadMore(); // the end: nothing to ask
      expect(fake.lists.where((l) => l.before.isNotEmpty), hasLength(2));
    },
  );

  test('an answer that arrives late does not replace a newer one', () async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final c = make(fake);
    final sub = await load(c);
    final notifier = c.read(inboxProvider(InboxFilter.all).notifier);

    final gate = Completer<void>();
    fake.gate = gate;
    final slow = notifier.load();
    fake.gate = null;
    fake.items.add(note('n2', 'task.assigned'));
    await notifier.load(); // the newer read answers first
    gate.complete();
    await slow;

    expect(sub.read().items, hasLength(2));
  });

  test('marking what is already read asks nothing', () async {
    final fake = FakeInboxClient(
      initial: [note('n1', 'task.assigned', read: true)],
    );
    final c = make(fake);
    final sub = await load(c);

    await c
        .read(inboxProvider(InboxFilter.all).notifier)
        .markRead(sub.read().items.single);

    expect(fake.markReads, isEmpty);
  });

  test('unread follows what is read, unread and snoozed or archived', () async {
    final fake = FakeInboxClient(
      initial: [
        note('n1', 'task.assigned'),
        note(
          'n2',
          'task.assigned',
          updatedAt: noon.subtract(const Duration(hours: 1)),
        ),
        note(
          'n3',
          'task.assigned',
          updatedAt: noon.subtract(const Duration(hours: 2)),
        ),
      ],
    );
    final c = make(fake);
    final sub = await load(c);
    final notifier = c.read(inboxProvider(InboxFilter.all).notifier);
    expect(sub.read().unread, 3);

    await notifier.markRead(sub.read().items[0]);
    expect(sub.read().unread, 2);
    await notifier.markRead(sub.read().items[0], read: false);
    expect(sub.read().unread, 3);
    await notifier.snooze(
      sub.read().items[0],
      noon.add(const Duration(days: 1)),
    );
    expect(sub.read().unread, 2);
    await notifier.archive(sub.read().items[0]);
    expect(sub.read().unread, 1);
    expect(sub.read().items, hasLength(1));
  });

  test('a refused snooze brings the list back as it was', () async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final c = make(fake);
    final sub = await load(c);
    fake.failNext = const InboxException(InboxFailure.denied);

    await expectLater(
      c
          .read(inboxProvider(InboxFilter.all).notifier)
          .snooze(sub.read().items.single, noon.add(const Duration(hours: 4))),
      throwsA(isA<InboxException>()),
    );

    expect(sub.read().items, hasLength(1));
    expect(sub.read().unread, 1);
  });

  test('a change reads the other open lists again', () async {
    final fake = FakeInboxClient(initial: [note('n1', 'task.assigned')]);
    final c = make(fake);
    final all = await load(c);
    final unread = await load(c, InboxFilter.unread);
    expect(unread.read().items, hasLength(1));

    await c
        .read(inboxProvider(InboxFilter.all).notifier)
        .markRead(all.read().items.single);
    await pumpEventQueue();

    expect(unread.read().items, isEmpty); // it read itself again
  });

  test('marking everything read leaves nothing unread anywhere', () async {
    final fake = FakeInboxClient(
      initial: [note('n1', 'task.assigned'), note('n2', 'user.mentioned')],
    );
    final c = make(fake);
    final sub = await load(c);

    await c.read(inboxProvider(InboxFilter.all).notifier).markAllRead();

    expect(sub.read().unread, 0);
    expect(sub.read().items.every((n) => n.isRead), isTrue);
    expect(await c.read(unreadCountProvider.future), 0);
  });

  test(
    'a badge that cannot be read says nothing rather than failing',
    () async {
      final fake = FakeInboxClient()..failReads = true;
      final c = make(fake);

      expect(await c.read(unreadCountProvider.future), 0);
      expect(await c.read(unreadTotalProvider.future), 0);
    },
  );

  test('preferences are put back when the server refuses them', () async {
    final fake = FakeInboxClient();
    final c = make(fake);
    final sub = c.listen(prefsProvider, (_, _) {});
    final prefs = await c.read(prefsProvider.future);
    final notifier = c.read(prefsProvider.notifier);
    fake.failNext = const InboxException(InboxFailure.network);

    await expectLater(
      notifier.setPref(prefs.rows.first.copyWith(inbox: false)),
      throwsA(isA<InboxException>()),
    );
    expect(sub.read().value!.rows.first.inbox, isTrue);

    fake.failNext = const InboxException(InboxFailure.invalid);
    await expectLater(
      notifier.setSettings(prefs.settings.copyWith(timezone: 'Mars')),
      throwsA(isA<InboxException>()),
    );
    expect(sub.read().value!.settings.timezone, 'UTC');
  });

  test('a watch is put back when the server refuses it', () async {
    final fake = FakeInboxClient();
    final c = make(fake);
    final ref0 = (project: 'p1', task: 'a');
    final sub = c.listen(watchProvider(ref0), (_, _) {});
    await c.read(watchProvider(ref0).future);
    final notifier = c.read(watchProvider(ref0).notifier);

    await notifier.toggle();
    expect(sub.read().value!.watching, isTrue);
    expect(sub.read().value!.watcherCount, 2);

    fake.failNext = const InboxException(InboxFailure.network);
    await expectLater(notifier.toggle(), throwsA(isA<InboxException>()));
    expect(sub.read().value!.watching, isTrue); // back to what it was
  });

  test('with no workspace there is nothing to watch', () async {
    final c = make(FakeInboxClient(), workspace: null);
    final ref0 = (project: 'p1', task: 'a');

    expect((await c.read(watchProvider(ref0).future)).watching, isFalse);
    await c.read(watchProvider(ref0).notifier).toggle(); // nothing happens
  });
}
