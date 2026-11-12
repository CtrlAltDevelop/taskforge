import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/audit/application/audit_providers.dart';
import 'package:taskforge/features/audit/domain/audit.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

final _now = DateTime.utc(2026, 11, 12, 12);

Future<FakeAuditClient> open(
  WidgetTester tester, {
  required String at,
  String role = 'Owner',
  FakeAuditClient? audit,
}) async {
  final fake =
      audit ??
      FakeAuditClient(
        [
          entry(1, 'task.created'),
          entry(
            2,
            'task.status_changed',
            changes: {
              'status_id': ['s1', 's2'],
            },
          ),
        ],
        labels: const {'s1': 'To do', 's2': 'Done'},
      );
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    overrides: [
      auditClientProvider.overrideWithValue(fake),
      auditNowProvider.overrideWithValue(() => _now),
    ],
  );
  await pumped.go(tester, at);
  return fake;
}

/// Scrolls the open task's detail until [name] is built, then fully on screen.
Future<void> _reveal(WidgetTester tester, String name) async {
  await tester.scrollUntilVisible(
    key(name),
    300,
    scrollable: find
        .descendant(of: key('task-detail'), matching: find.byType(Scrollable))
        .first,
  );
  await tester.ensureVisible(key(name));
  await tester.pumpAndSettle();
}

void main() {
  group('a task’s activity', () {
    testWidgets('opens on demand and says who did what, newest first', (
      tester,
    ) async {
      final fake = await open(tester, at: '/projects/p1?task=a');
      expect(fake.taskCalls, isEmpty); // closed tasks cost nothing to read

      await _reveal(tester, 'activity-section');
      await tester.tap(key('activity-section'));
      await tester.pumpAndSettle();

      expect(fake.taskCalls.single.task, 'a');
      expect(find.text('Ali changed status To do → Done'), findsOneWidget);
      expect(find.text('Ali created this task'), findsOneWidget);
      final order = [
        tester.getTopLeft(find.text('Ali changed status To do → Done')).dy,
        tester.getTopLeft(find.text('Ali created this task')).dy,
      ];
      expect(order[0], lessThan(order[1]));
    });

    testWidgets('an empty history says so, and an error offers Retry', (
      tester,
    ) async {
      final fake = FakeAuditClient([])
        ..failNext = const AuditException(AuditFailure.network);
      await open(tester, at: '/projects/p1?task=a', audit: fake);
      await _reveal(tester, 'activity-section');
      await tester.tap(key('activity-section'));
      await tester.pumpAndSettle();
      expect(key('activity-error'), findsOneWidget);

      await _reveal(tester, 'activity-retry');
      await tester.tap(key('activity-retry'));
      await tester.pumpAndSettle();
      expect(key('activity-empty'), findsOneWidget);
    });

    testWidgets('Show older reads the next page', (tester) async {
      final fake = FakeAuditClient([
        for (var i = 1; i <= 5; i++) entry(i, 'task.deleted'),
      ], pageSize: 3);
      await open(tester, at: '/projects/p1?task=a', audit: fake);
      await _reveal(tester, 'activity-section');
      await tester.tap(key('activity-section'));
      await tester.pumpAndSettle();
      expect(key('activity-5'), findsOneWidget);
      expect(key('activity-1'), findsNothing);

      await _reveal(tester, 'activity-more');
      await tester.tap(key('activity-more'));
      await tester.pumpAndSettle();
      await _reveal(tester, 'activity-1');
      expect(key('activity-1'), findsOneWidget);
      expect(fake.taskCalls.last.before, 3);
      expect(key('activity-more'), findsNothing);
    });
  });

  group('the audit log screen', () {
    testWidgets('an Owner sees the rows and opens a before/after', (
      tester,
    ) async {
      await open(tester, at: '/audit');
      expect(key('audit-row-1'), findsOneWidget);
      expect(
        find.textContaining('Ali · changed status To do → Done'),
        findsOneWidget,
      );

      await tester.tap(key('audit-row-2'));
      await tester.pumpAndSettle();
      expect(key('diff-dialog'), findsOneWidget);
      expect(find.textContaining('To do'), findsWidgets);
      expect(key('diff-status_id'), findsOneWidget);
    });

    testWidgets('a Member is told they may not, and nothing is read', (
      tester,
    ) async {
      final fake = await open(tester, at: '/audit', role: 'Member');
      expect(key('audit-denied'), findsOneWidget);
      expect(key('audit-export'), findsNothing);
      expect(fake.listCalls, isEmpty);
    });

    testWidgets('an area chip narrows by action prefix; Clear brings it back', (
      tester,
    ) async {
      final fake = await open(
        tester,
        at: '/audit',
        audit: FakeAuditClient([
          entry(1, 'task.created'),
          entry(2, 'member.removed', targetType: 'member'),
        ]),
      );
      expect(key('audit-row-2'), findsOneWidget);

      await tester.tap(key('area-task.'));
      await tester.pumpAndSettle();
      expect(fake.listCalls.last.filters.action, 'task.');
      expect(key('audit-row-1'), findsOneWidget);
      expect(key('audit-row-2'), findsNothing);

      await tester.tap(key('filters-clear'));
      await tester.pumpAndSettle();
      expect(key('audit-row-2'), findsOneWidget);
    });

    testWidgets('older entries load by id and never repeat', (tester) async {
      final fake = FakeAuditClient([
        for (var i = 1; i <= 7; i++) entry(i, 'task.created', targetId: 'a$i'),
      ], pageSize: 3);
      await open(tester, at: '/audit', audit: fake);
      await tester.scrollUntilVisible(
        key('audit-more'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(key('audit-more'));
      await tester.pumpAndSettle();

      expect(fake.listCalls.last.before, 5);
      expect(key('audit-row-7'), findsOneWidget);
      expect(key('audit-row-4'), findsOneWidget);
    });

    testWidgets('Export shows the CSV and can copy it', (tester) async {
      final fake = await open(tester, at: '/audit');
      await tester.tap(key('audit-export'));
      await tester.pumpAndSettle();

      expect(fake.exports, hasLength(1));
      expect(find.textContaining('task.created'), findsWidgets);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      await tester.tap(key('audit-export-copy'));
      await tester.pumpAndSettle();
      expect(copied, startsWith('id,at,action'));
    });

    testWidgets('a failed read offers Retry', (tester) async {
      final fake = FakeAuditClient([entry(1, 'task.created')])
        ..failNext = const AuditException(AuditFailure.network);
      await open(tester, at: '/audit', audit: fake);
      expect(key('audit-error'), findsOneWidget);
      await tester.tap(key('audit-retry'));
      await tester.pumpAndSettle();
      expect(key('audit-row-1'), findsOneWidget);
    });
  });

  Future<bool> paletteOffersAudit(WidgetTester tester, String role) async {
    await open(tester, at: '/', role: role);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(key('palette-field'), '> audit');
    await tester.pump();
    return key('palette-row-nav.audit').evaluate().isNotEmpty;
  }

  testWidgets('the palette offers the audit log to an Owner', (tester) async {
    expect(await paletteOffersAudit(tester, 'Owner'), isTrue);
  });

  testWidgets('the palette does not offer it to a Member', (tester) async {
    expect(await paletteOffersAudit(tester, 'Member'), isFalse);
  });

  testWidgets('saving the open task adds a line to its history', (
    tester,
  ) async {
    final fake = await open(tester, at: '/projects/p1?task=a');
    await _reveal(tester, 'activity-section');
    await tester.tap(key('activity-section'));
    await tester.pumpAndSettle();
    expect(fake.taskCalls, hasLength(1));

    fake.entries = [
      entry(
        3,
        'task.updated',
        changes: {
          'priority': ['none', 'high'],
        },
      ),
      ...fake.entries,
    ];
    await tester.scrollUntilVisible(
      key('detail-title'),
      -300,
      scrollable: find
          .descendant(of: key('task-detail'), matching: find.byType(Scrollable))
          .first,
    );
    await tester.enterText(key('detail-title'), 'Alpha renamed');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(fake.taskCalls.length, greaterThan(1));
    await _reveal(tester, 'activity-3');
    expect(find.textContaining('changed priority'), findsOneWidget);
  });

  testWidgets('a big export shows a preview, not every line', (tester) async {
    final fake = await open(tester, at: '/audit');
    fake.bigExport = [
      'id,at,action',
      for (var i = 0; i < 500; i++) '$i,2026-11-12,task.created',
    ].join('\n');
    await tester.tap(key('audit-export'));
    await tester.pumpAndSettle();
    expect(key('audit-export-note'), findsOneWidget);
    expect(
      find.textContaining('Showing the first 40 of 501 lines'),
      findsOneWidget,
    );
    expect(find.textContaining('499,2026-11-12'), findsNothing);
  });
}
