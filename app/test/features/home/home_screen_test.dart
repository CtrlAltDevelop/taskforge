import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/home/data/home_client.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

HomeSummary _summary() => HomeSummary(
  todayCount: 2,
  overdueCount: 1,
  inProgressCount: 3,
  dueItems: [
    homeTask('a', title: 'Ship the report', due: '2026-11-18', number: 1),
    homeTask('b', title: 'Late thing', due: '2026-11-10', number: 2),
  ],
  recent: [homeTask('c', title: 'Opened one', number: 3)],
  mentions: const [
    HomeMention(
      id: 'm1',
      type: 'mention',
      taskId: 'a',
      createdAt: '2026-11-18T08:00:00Z',
      read: false,
    ),
  ],
  unreadNotifications: 4,
  unreadChat: 2,
  week: [
    for (var i = 0; i < 7; i++)
      HomeDay(date: '2026-11-${12 + i}', seconds: i == 3 ? 3600 : 0),
  ],
  pinned: const [
    HomePin(dashboardId: 'd1', name: 'Sprint health', projectId: 'p1'),
  ],
  computedAt: '2026-11-18T07:30:00Z',
);

MyWorkItem _mine(String id, String title) => MyWorkItem(
  task: homeTask(id, title: title, number: 1),
  assigned: true,
  watching: false,
);

final _noon = DateTime(2026, 11, 18, 12, 30);

Future<Pumped> _pump(
  WidgetTester tester, {
  required FakeHomeClient home,
  FakeTasksClient? tasks,
  Size size = const Size(1400, 1100),
  DateTime Function()? now,
  MemoryPrefs? prefs,
  List<Override> overrides = const [],
}) async {
  final app = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: tasks ?? FakeTasksClient([task('a', 'Ship the report')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    home: home,
    size: size,
    overrides: [
      localPrefsProvider.overrideWithValue(prefs ?? MemoryPrefs()),
      homeNowProvider.overrideWithValue(now ?? () => _noon),
      ...overrides,
    ],
  );
  return app;
}

Finder _key(String k) => find.byKey(Key(k));

void main() {
  testWidgets('shows the greeting, the date and every card with data', (
    t,
  ) async {
    final home = FakeHomeClient(
      summaryValue: _summary(),
      assigned: [_mine('a', 'Ship the report')],
    );
    await _pump(t, home: home);

    expect(find.text('Good afternoon, Zoe'), findsOneWidget);
    expect(_key('home-date'), findsOneWidget);
    for (final id in [
      'today',
      'assigned',
      'mentions',
      'recent',
      'time',
      'pinned',
    ]) {
      expect(_key('home-card-$id'), findsOneWidget, reason: id);
    }
    expect(find.text('Late thing'), findsOneWidget);
    expect(find.text('Opened one'), findsOneWidget);
    expect(find.text('Sprint health'), findsOneWidget);
    expect(_key('home-mention-m1'), findsOneWidget);
    expect(_key('home-time-total'), findsOneWidget);
    // Overdue counts and marks the late row.
    expect(find.textContaining('Overdue'), findsWidgets);
  });

  testWidgets('each card has its own empty state', (t) async {
    await _pump(t, home: FakeHomeClient());
    for (final k in [
      'home-today-empty',
      'home-assigned-empty',
      'home-mentions-empty',
      'home-recent-empty',
      'home-time-empty',
      'home-pinned-empty',
    ]) {
      expect(_key(k), findsOneWidget, reason: k);
    }
  });

  testWidgets('one failing read never blanks Home', (t) async {
    final home = FakeHomeClient(
      summaryValue: _summary(),
      assigned: [_mine('a', 'Ship the report')],
    )..summaryError = const HomeException(HomeFailure.network);
    await _pump(t, home: home);

    // Today, Mentions, Recent, Time, Pinned come from the failed summary:
    // each says so on its own, with Retry.
    expect(find.byKey(const Key('home-card-retry')), findsNWidgets(5));
    // The assigned card has its own read and is fine.
    expect(find.text('Ship the report'), findsOneWidget);
    expect(_key('home-greeting'), findsOneWidget);

    home.summaryError = null;
    await t.tap(find.byKey(const Key('home-card-retry')).first);
    await t.pumpAndSettle();
    expect(find.byKey(const Key('home-card-retry')), findsNothing);
    expect(find.text('Late thing'), findsOneWidget);
  });

  testWidgets('the assigned card failing leaves the others alone', (t) async {
    final home = FakeHomeClient(summaryValue: _summary())
      ..assignedError = const HomeException(HomeFailure.other);
    await _pump(t, home: home);
    expect(find.byKey(const Key('home-card-retry')), findsOneWidget);
    expect(find.text('Late thing'), findsOneWidget);
  });

  testWidgets('offline shows the last saved copy with a stale mark', (t) async {
    final home = FakeHomeClient(summaryValue: _summary());
    final app = await _pump(t, home: home);
    expect(_key('home-stale-today'), findsNothing);

    app.container.read(networkProvider.notifier).failed();
    app.container.invalidate(homeSummaryProvider);
    await t.pumpAndSettle();
    expect(_key('home-stale-today'), findsOneWidget);
    expect(find.textContaining('Offline'), findsWidgets);
    // The saved copy is still on screen.
    expect(find.text('Late thing'), findsOneWidget);
  });

  testWidgets('the greeting and the day move on at midnight', (t) async {
    var now = DateTime(2026, 11, 18, 23, 50);
    final home = FakeHomeClient(summaryValue: _summary());
    await _pump(t, home: home, now: () => now);
    expect(find.text('Good evening, Zoe'), findsOneWidget);
    expect(home.lastToday, '2026-11-18');

    now = DateTime(2026, 11, 19, 0, 10);
    await t.pump(const Duration(minutes: 20));
    await t.pumpAndSettle();
    expect(home.lastToday, '2026-11-19');
  });

  testWidgets('the greeting turns from morning to afternoon by itself', (
    t,
  ) async {
    var now = DateTime(2026, 11, 18, 11, 55);
    await _pump(t, home: FakeHomeClient(), now: () => now);
    expect(find.text('Good morning, Zoe'), findsOneWidget);
    now = DateTime(2026, 11, 18, 12, 1);
    await t.pump(const Duration(minutes: 10));
    expect(find.text('Good afternoon, Zoe'), findsOneWidget);
  });

  group('layout', () {
    Future<Set<double>> lefts(WidgetTester t, Size size) async {
      await _pump(
        t,
        home: FakeHomeClient(summaryValue: _summary()),
        size: size,
      );
      return {
        for (final id in [
          'today',
          'assigned',
          'mentions',
          'recent',
          'time',
          'pinned',
        ])
          t.getTopLeft(_key('home-card-$id')).dx.roundToDouble(),
      };
    }

    testWidgets('one column on a phone', (t) async {
      expect((await lefts(t, const Size(390, 900))).length, 1);
    });

    testWidgets('two columns on a tablet', (t) async {
      expect((await lefts(t, const Size(800, 900))).length, 2);
    });

    testWidgets('three columns on a desktop', (t) async {
      expect((await lefts(t, const Size(1400, 900))).length, 3);
    });
  });

  group('personal layout', () {
    testWidgets('a card can be hidden from its menu and brought back', (
      t,
    ) async {
      await _pump(t, home: FakeHomeClient(summaryValue: _summary()));
      await t.tap(_key('home-card-menu-recent'));
      await t.pumpAndSettle();
      await t.tap(_key('home-card-hide-recent'));
      await t.pumpAndSettle();
      expect(_key('home-card-recent'), findsNothing);

      await t.tap(_key('home-customize'));
      await t.pumpAndSettle();
      await t.tap(
        find.descendant(
          of: _key('home-customize-recent'),
          matching: find.byType(TfCheckbox),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(_key('home-customize-done'));
      await t.pumpAndSettle();
      expect(_key('home-card-recent'), findsOneWidget);
    });

    testWidgets('cards can be moved and the order is kept', (t) async {
      final prefs = MemoryPrefs();
      await _pump(
        t,
        home: FakeHomeClient(summaryValue: _summary()),
        prefs: prefs,
      );
      final before = t.getTopLeft(_key('home-card-time'));
      await t.tap(_key('home-customize'));
      await t.pumpAndSettle();
      await t.tap(_key('home-up-time'));
      await t.pumpAndSettle();
      await t.tap(_key('home-customize-done'));
      await t.pumpAndSettle();
      expect(t.getTopLeft(_key('home-card-time')), isNot(before));
      expect(await prefs.read('home.cards.v1'), contains('"order":'));
    });

    testWidgets('hiding every card says so and offers Customize', (t) async {
      await _pump(t, home: FakeHomeClient());
      for (final id in homeCardIds) {
        if (id == 'checklist') continue;
        await t.tap(_key('home-card-menu-$id'));
        await t.pumpAndSettle();
        await t.tap(_key('home-card-hide-$id'));
        await t.pumpAndSettle();
      }
      expect(_key('home-all-hidden'), findsOneWidget);
    });
  });

  group('quick status change', () {
    testWidgets('moves the task through the task client', (t) async {
      final tasks = FakeTasksClient([task('a', 'Ship the report')]);
      final home = FakeHomeClient(
        summaryValue: _summary(),
        assigned: [_mine('a', 'Ship the report')],
      );
      await _pump(t, home: home, tasks: tasks);
      await t.tap(_key('home-status-a'));
      await t.pumpAndSettle();
      await t.tap(_key('home-status-doing-a'));
      await t.pumpAndSettle();
      expect(tasks.moves.map((m) => (m.task, m.status)), [('a', 'doing')]);
    });

    testWidgets('groups assigned tasks by project', (t) async {
      final home = FakeHomeClient(
        summaryValue: _summary(),
        assigned: [
          _mine('a', 'One'),
          MyWorkItem(
            task: homeTask('z', project: 'p2', key: 'OPS', title: 'Two'),
            assigned: true,
            watching: false,
          ),
        ],
      );
      await _pump(t, home: home);
      expect(_key('home-group-p1'), findsOneWidget);
      expect(_key('home-group-p2'), findsOneWidget);
    });
  });

  group('the getting-started checklist', () {
    OnboardingState state({bool visible = true, Map<String, bool>? steps}) =>
        OnboardingState(
          visible: visible,
          steps: steps ?? {for (final s in checklistSteps) s: false},
          sampleProjectId: 'p1',
        );

    testWidgets('shows four steps and ticks the ones done', (t) async {
      final home = FakeHomeClient(
        onboarding: state(
          steps: {
            'create_task': true,
            'invite_member': false,
            'try_board': false,
            'open_palette': false,
          },
        ),
      );
      await _pump(t, home: home);
      for (final s in checklistSteps) {
        expect(_key('checklist-$s'), findsOneWidget);
      }
      expect(find.text('1 of 4 done'), findsOneWidget);
    });

    testWidgets('is not on Home when the server says it is not visible', (
      t,
    ) async {
      await _pump(t, home: FakeHomeClient(onboarding: state(visible: false)));
      expect(_key('home-card-checklist'), findsNothing);
    });

    testWidgets('Dismiss tells the server and the card goes', (t) async {
      final home = FakeHomeClient(onboarding: state());
      await _pump(t, home: home);
      await t.tap(_key('checklist-dismiss'));
      home.onboarding = const OnboardingState(visible: false, dismissed: true);
      await t.pumpAndSettle();
      expect(home.calls, contains('dismiss'));
      expect(_key('home-card-checklist'), findsNothing);
    });

    testWidgets('a failing checklist does not take Home down', (t) async {
      final home = FakeHomeClient(summaryValue: _summary())
        ..onboardingError = const HomeException(HomeFailure.other);
      await _pump(t, home: home);
      expect(_key('home-card-checklist'), findsNothing);
      expect(find.text('Late thing'), findsOneWidget);
    });

    testWidgets('opening a board and the palette tell the server', (t) async {
      final home = FakeHomeClient(onboarding: state());
      final app = await _pump(t, home: home);
      await app.go(t, '/projects/p1?view=board');
      await t.pumpAndSettle();
      expect(home.calls, contains('step try_board'));

      await app.go(t, '/');
      await t.tap(_key('checklist-open_palette'));
      await t.pumpAndSettle();
      expect(home.calls, contains('step open_palette'));
    });
  });

  group('sample tasks', () {
    testWidgets('a banner offers one click to delete them', (t) async {
      final home = FakeHomeClient(
        onboarding: const OnboardingState(
          sampleCount: 5,
          sampleProjectId: 'p1',
        ),
      );
      await _pump(t, home: home);
      expect(_key('sample-banner'), findsOneWidget);
      await t.tap(_key('delete-samples'));
      await t.pumpAndSettle();
      expect(home.calls, contains('delete-samples'));
      expect(_key('sample-banner'), findsNothing);
    });

    testWidgets('no banner without sample tasks', (t) async {
      await _pump(t, home: FakeHomeClient());
      expect(_key('sample-banner'), findsNothing);
    });
  });

  testWidgets('opening a task records it as recent', (t) async {
    final home = FakeHomeClient();
    final app = await _pump(t, home: home);
    await app.go(t, '/projects/p1?task=a');
    await t.pumpAndSettle();
    expect(home.calls, contains('recent a'));
  });

  testWidgets('Home links to My work and the inbox', (t) async {
    final home = FakeHomeClient(
      summaryValue: _summary(),
      assigned: [_mine('a', 'Ship the report')],
    );
    await _pump(t, home: home);
    await t.tap(_key('home-open-my-work'));
    await t.pumpAndSettle();
    expect(find.text('My work'), findsWidgets);
  });

  test('homeErrorMessage never leaks raw errors', () {
    expect(
      homeErrorMessage(const HomeException(HomeFailure.other)),
      'This card could not load.',
    );
    expect(homeErrorMessage(StateError('x')), 'This card could not load.');
    expect(mapHomeError(StateError('x')).failure, HomeFailure.other);
  });
}
