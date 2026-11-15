import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<FakeInboxClient> open(WidgetTester tester) async {
  final fake = FakeInboxClient();
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    inbox: fake,
  );
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.text('Alpha'));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('the eye on a task watches it and stops watching', (
    tester,
  ) async {
    final fake = await open(tester);
    expect(key('watch-toggle'), findsOneWidget);
    expect(tester.widget<IconButton>(key('watch-toggle')).isSelected, isFalse);

    await tester.tap(key('watch-toggle'));
    await tester.pumpAndSettle();
    expect(fake.watchCalls.single, (task: 'a', on: true));
    expect(tester.widget<IconButton>(key('watch-toggle')).isSelected, isTrue);
    expect(
      tester.widget<IconButton>(key('watch-toggle')).tooltip,
      contains('Stop'),
    );

    await tester.tap(key('watch-toggle'));
    await tester.pumpAndSettle();
    expect(fake.watchCalls.last.on, isFalse);
    expect(tester.widget<IconButton>(key('watch-toggle')).isSelected, isFalse);
  });

  testWidgets('a refused change puts the eye back and says why', (
    tester,
  ) async {
    final fake = await open(tester);
    fake.failNext = const InboxException(InboxFailure.denied);

    await tester.tap(key('watch-toggle'));
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(key('watch-toggle')).isSelected, isFalse);
    expect(find.textContaining('do not have access'), findsOneWidget);
  });

  testWidgets('a task already watched shows as watched', (tester) async {
    final fake = FakeInboxClient()
      ..watchStates['a'] = const WatchState(watching: true, watcherCount: 3);
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: FakeTasksClient([task('a', 'Alpha')]),
      inbox: fake,
    );
    await pumped.go(tester, '/projects/p1');
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(key('watch-toggle')).isSelected, isTrue);
  });
}
