import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/ui/appearance.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';
import 'package:taskforge/features/tasks/presentation/work/work_style.dart';

import '../board/fakes.dart';
import '../calendar/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../timeline/fakes.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

const _wide = Size(1400, 1000);
const _phone = Size(400, 900);

Future<Pumped> _open(
  WidgetTester tester, {
  List<Task>? tasks,
  FakeTasksClient? server,
  FakeBoardClient? board,
  FakeTimelineClient? timeline,
  FakeCalendarClient Function(FakeTasksClient)? calendar,
  Size size = _wide,
  String view = '',
}) async {
  final fake = server ?? FakeTasksClient(tasks ?? const []);
  final pumped = await pumpProjects(
    tester,
    projects: [project('p1', 'Web')],
    tasks: fake,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: board ?? FakeBoardClient(fake.tasks),
    timeline: timeline,
    calendar: calendar?.call(fake) ?? FakeCalendarClient(fake),
    today: day(2026, 11, 10),
    size: size,
  );
  await pumped.go(tester, '/projects/p1${view.isEmpty ? '' : '?view=$view'}');
  return pumped;
}

Future<void> _tapIcon(WidgetTester tester, TfIconData icon) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('view-switch')),
      matching: find.byIcon(icon.glyph),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('loading', () {
    for (final (density, height) in [
      (TfDensity.compact, 36.0),
      (TfDensity.comfortable, 44.0),
    ]) {
      testWidgets('skeleton rows are as tall as real ones (${density.name})', (
        tester,
      ) async {
        final server = FakeTasksClient([task('a', 'One')]);
        final gate = server.gate = Completer<void>();
        final pumped = await pumpProjects(
          tester,
          projects: [project('p1', 'Web')],
          tasks: server,
        );
        pumped.container.read(routerProvider).go('/projects/p1');
        await tester.pump();
        await tester.pump();
        pumped.container.read(densityProvider.notifier).choose(density);
        await tester.pumpAndSettle();

        final rows = find.byKey(const Key('skeleton-row-0'));
        expect(rows, findsOneWidget);
        expect(tester.getSize(rows).height, height);
        gate.complete();
        await tester.pumpAndSettle();
      });
    }

    testWidgets('the phone skeleton is cards of the real height', (
      tester,
    ) async {
      final server = FakeTasksClient([task('a', 'One')]);
      final gate = server.gate = Completer<void>();
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        tasks: server,
        size: _phone,
      );
      pumped.container.read(routerProvider).go('/projects/p1');
      await tester.pump();
      await tester.pump();

      expect(
        tester.getSize(find.byKey(const Key('skeleton-row-0'))).height,
        phoneCardHeight,
      );
      gate.complete();
      await tester.pumpAndSettle();
      // A card is as tall as its skeleton, so nothing jumps.
      expect(
        tester.getSize(find.byKey(const Key('stripe-a'))).height +
            TfSpace.xs * 2,
        phoneCardHeight,
      );
    });

    testWidgets('the board shows placeholder columns while it loads', (
      tester,
    ) async {
      final board = FakeBoardClient()..getGate = Completer<void>();
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        workflows: FakeWorkflowsClient(defaultWorkflow()),
        board: board,
      );
      pumped.container.read(routerProvider).go('/projects/p1?view=board');
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('board-loading')), findsOneWidget);
      expect(find.byType(TfSkeleton), findsWidgets);
      board.getGate!.complete();
      await tester.pumpAndSettle();
    });
  });

  group('empty', () {
    testWidgets('no tasks: says so and offers to add the first', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.byKey(const Key('no-tasks')), findsOneWidget);
      expect(find.text('Add your first task'), findsOneWidget);
    });

    testWidgets('a search that hides everything offers to clear it', (
      tester,
    ) async {
      final pumped = await _open(
        tester,
        tasks: [task('a', 'Alpha'), task('b', 'Bravo', number: 2)],
      );
      pumped.container.read(viewSearchProvider('p1').notifier).set('zzz');
      await tester.pumpAndSettle();

      expect(find.text('No tasks match these filters'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
      expect(find.byKey(const Key('no-tasks')), findsNothing);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(pumped.container.read(viewSearchProvider('p1')), isEmpty);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('the same on a phone', (tester) async {
      final pumped = await _open(
        tester,
        tasks: [task('a', 'Alpha')],
        size: _phone,
      );
      pumped.container.read(viewSearchProvider('p1').notifier).set('zzz');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('no-matches')), findsOneWidget);
    });

    testWidgets(
      'the board says nothing matches, not just shows empty columns',
      (tester) async {
        final pumped = await _open(
          tester,
          tasks: [task('a', 'Alpha')],
          view: 'board',
        );
        pumped.container.read(viewSearchProvider('p1').notifier).set('zzz');
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('no-matches')), findsOneWidget);

        await tester.tap(find.text('Clear filters'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('card-a')), findsOneWidget);
      },
    );
  });

  group('error', () {
    testWidgets('the list: the reason and a retry', (tester) async {
      final server = FakeTasksClient([task('a', 'Back again')])
        ..failList = const TaskException(TaskFailure.network);
      await _open(tester, server: server);

      expect(find.byKey(const Key('work-error')), findsOneWidget);
      expect(find.byType(TfError), findsOneWidget);
      server.failList = null;
      await tester.tap(find.byKey(const Key('retry-tasks')));
      await tester.pumpAndSettle();
      expect(find.text('Back again'), findsOneWidget);
      expect(find.byKey(const Key('work-error')), findsNothing);
    });

    testWidgets('the board retries', (tester) async {
      final board = FakeBoardClient([task('a', 'Alpha')])
        ..failGet = const TaskException(TaskFailure.network);
      await _open(tester, board: board, view: 'board');

      expect(find.byKey(const Key('work-error')), findsOneWidget);
      await tester.tap(find.byKey(const Key('retry-board')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('card-a')), findsOneWidget);
    });

    testWidgets('the timeline shows the error as a banner', (tester) async {
      final timeline = FakeTimelineClient(FakeTasksClient([task('a', 'Alpha')]))
        ..failRead = const TaskException(TaskFailure.network);
      await _open(tester, timeline: timeline);
      await _tapIcon(tester, TfIcons.timeline);

      expect(find.byKey(const Key('timeline-error')), findsOneWidget);
      expect(find.byKey(const Key('timeline-retry')), findsOneWidget);
    });
  });

  group('offline', () {
    testWidgets('the project page shows the offline banner', (tester) async {
      final pumped = await _open(tester, tasks: [task('a', 'Alpha')]);
      pumped.container.read(networkProvider.notifier).failed();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('offline-banner')), findsOneWidget);
    });
  });
}
