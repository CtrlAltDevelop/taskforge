import 'package:taskforge/core/charts/dashboard_charts.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

Future<({FakeDashboardsClient fake, Pumped pumped})> open(
  WidgetTester tester, {
  FakeDashboardsClient? client,
  String at = '/dashboards',
  String role = 'Owner',
  Size size = const Size(1400, 1200),
}) async {
  final fake =
      client ??
      (FakeDashboardsClient([
          dashboardOf('d1', 'Team', [
            widgetOf('w1', WidgetKind.number, title: 'Open'),
            widgetOf(
              'w2',
              WidgetKind.bar,
              title: 'By priority',
              config: const WidgetConfig(groupBy: 'priority'),
            ),
          ]),
        ])
        ..dataOf['w1'] = numberData('3.00')
        ..dataOf['w2'] = barsData({'high': '2.00', 'low': '1.00'})
        ..drillOf['w1|'] = [drill('1', 'A'), drill('2', 'B'), drill('3', 'C')]
        ..drillOf['w2|high'] = [drill('1', 'A'), drill('2', 'B')]);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Alpha')]),
    size: size,
    overrides: [
      dashboardsClientProvider.overrideWithValue(fake),
      dashboardRefreshProvider.overrideWithValue(null),
      viewerDayProvider.overrideWithValue(
        () => (today: '2026-11-12', offsetMinutes: 0),
      ),
    ],
  );
  await pumped.go(tester, at);
  return (fake: fake, pumped: pumped);
}

String location(Pumped p) => p.container
    .read(routerProvider)
    .routeInformationProvider
    .value
    .uri
    .toString();

void main() {
  testWidgets('a dashboard shows each widget with its numbers', (tester) async {
    final h = await open(tester);
    expect(find.text('Team'), findsOneWidget); // the picker
    expect(find.text('3'), findsOneWidget); // "3.00" read as 3
    expect(key('bar-high'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(h.fake.dataCalls.map((c) => c.widget).toSet(), {'w1', 'w2'});
    expect(h.fake.dataCalls.every((c) => !c.refresh), isTrue);
  });

  testWidgets('a click on a number lists exactly the tasks it counted', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(key('number-tap'));
    await tester.pumpAndSettle();
    expect(key('drill-dialog'), findsOneWidget);
    expect(find.textContaining('3 tasks'), findsOneWidget);
    expect(key('drill-1'), findsOneWidget);
    expect(key('drill-3'), findsOneWidget);
  });

  testWidgets('a click on a bar lists that bucket and a task opens', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(key('bar-high'));
    await tester.pumpAndSettle();
    expect(h.fake.drills, contains('w2|high'));
    expect(find.textContaining('2 tasks'), findsOneWidget);

    await tester.tap(key('drill-2'));
    await tester.pumpAndSettle();
    expect(location(h.pumped), '/projects/p1?task=2');
  });

  testWidgets('a burndown draws the whole sprint, not only the days so far', (
    tester,
  ) async {
    final fake =
        FakeDashboardsClient([
            dashboardOf('d1', 'Sprint', [widgetOf('w1', WidgetKind.burndown)]),
          ])
          ..dataOf['w1'] = const WidgetData(
            total: '5',
            series: [
              Series('Remaining', [SeriesPoint('2026-11-10', '5')]),
              Series('Ideal', [
                SeriesPoint('2026-11-10', '5'),
                SeriesPoint('2026-11-11', '3'),
                SeriesPoint('2026-11-12', '1'),
              ]),
            ],
          );
    await open(tester, client: fake);
    // The chart is painted, so its axis is checked through its description:
    // three days on the axis, the ideal line running to the end of the sprint.
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(LineChartView)).label,
      contains('3 points'),
    );
    handle.dispose();
    expect(key('widget-empty'), findsNothing);
  });

  testWidgets('dragging the resize corner past the card never breaks layout', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    final drag = await tester.startGesture(
      tester.getCenter(key('resize-w1')),
      kind: PointerDeviceKind.mouse,
    );
    await drag.moveBy(const Offset(-2000, -2000));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await drag.up();
    await tester.pumpAndSettle();
    await tester.tap(key('save-dashboard'));
    await tester.pumpAndSettle();
    final cell = h.fake.saved.single.layout.firstWhere(
      (c) => c.widgetId == 'w1',
    );
    expect(cell.w, greaterThanOrEqualTo(minCellWidth));
    expect(cell.h, greaterThanOrEqualTo(minCellHeight));
  });

  testWidgets('a widget made here gets a random version-4 id', (tester) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('add-widget'));
    await tester.pumpAndSettle();
    await tester.tap(key('widget-save'));
    await tester.pumpAndSettle();
    await tester.tap(key('save-dashboard'));
    await tester.pumpAndSettle();
    final id = h.fake.saved.single.widgets.last.id;
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  testWidgets('a cut-short drill-down says so', (tester) async {
    final h = await open(tester);
    h.fake.cutShort.add('w1|');
    await tester.tap(key('number-tap'));
    await tester.pumpAndSettle();
    expect(key('drill-truncated'), findsOneWidget);
    expect(find.textContaining('3+ tasks'), findsOneWidget);
  });

  testWidgets(
    'Refresh asks past the cache, for every widget of the dashboard',
    (tester) async {
      final h = await open(tester);
      h.fake.dataCalls.clear();
      await tester.tap(key('refresh-all'));
      await tester.pumpAndSettle();
      final forced = {
        for (final c in h.fake.dataCalls)
          if (c.refresh) c.widget,
      };
      expect(forced, {'w1', 'w2'});
    },
  );

  testWidgets('a card’s own Refresh asks only for that card', (tester) async {
    final h = await open(tester);
    h.fake.dataCalls.clear();
    await tester.tap(key('refresh-w2'));
    await tester.pumpAndSettle();
    expect(
      {
        for (final c in h.fake.dataCalls)
          if (c.refresh) c.widget,
      },
      {'w2'},
    );
    // Nothing keeps skipping the cache afterwards: later reads are ordinary.
    h.fake.dataCalls.clear();
    h.pumped.container.read(dashboardTickProvider.notifier).auto();
    await tester.pumpAndSettle();
    expect(h.fake.dataCalls.every((c) => !c.refresh), isTrue);
  });

  testWidgets('the day is asked for at every read, not once per run', (
    tester,
  ) async {
    var day = '2026-11-12';
    final fake = FakeDashboardsClient([
      dashboardOf('d1', 'Team', [widgetOf('w1', WidgetKind.number)]),
    ])..dataOf['w1'] = numberData('1');
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      overrides: [
        dashboardsClientProvider.overrideWithValue(fake),
        dashboardRefreshProvider.overrideWithValue(null),
        viewerDayProvider.overrideWithValue(
          () => (today: day, offsetMinutes: 0),
        ),
      ],
    );
    await pumped.go(tester, '/dashboards');
    expect(fake.days, ['2026-11-12']);
    day = '2026-11-13'; // midnight passes with the dashboard open
    pumped.container.read(dashboardTickProvider.notifier).auto();
    await tester.pumpAndSettle();
    expect(fake.days.last, '2026-11-13');
  });

  testWidgets('the numbers are read again every refresh period', (
    tester,
  ) async {
    final fake = FakeDashboardsClient([
      dashboardOf('d1', 'Team', [widgetOf('w1', WidgetKind.number)]),
    ])..dataOf['w1'] = numberData('5');
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      overrides: [
        dashboardsClientProvider.overrideWithValue(fake),
        dashboardRefreshProvider.overrideWithValue(const Duration(seconds: 30)),
        viewerDayProvider.overrideWithValue(
          () => (today: '2026-11-12', offsetMinutes: 0),
        ),
      ],
    );
    await pumped.go(tester, '/dashboards');
    final first = fake.days.length;
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(fake.days.length, greaterThan(first));
    // Leaving the screen stops the clock (no timer is left running).
    await pumped.go(tester, '/');
    await tester.pump(const Duration(seconds: 60));
  });

  testWidgets('a widget that fails says so and Retry reads it again', (
    tester,
  ) async {
    final fake =
        FakeDashboardsClient([
            dashboardOf('d1', 'Team', [widgetOf('w1', WidgetKind.number)]),
          ])
          ..dataOf['w1'] = numberData('5')
          ..failData = const DashboardException(DashboardFailure.tooHeavy);
    await open(tester, client: fake);
    expect(key('error-w1'), findsOneWidget);
    expect(find.textContaining('takes too long'), findsOneWidget);
    await tester.tap(key('retry-w1'));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('with none yet, a template makes a dashboard and shows it', (
    tester,
  ) async {
    final fake = FakeDashboardsClient([]);
    await open(tester, client: fake);
    expect(key('dashboards-empty'), findsOneWidget);
    await tester.tap(key('template-my_work'));
    await tester.pumpAndSettle();
    expect(fake.templates, ['my_work']);
    expect(find.text('Open tasks'), findsWidgets);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('a project page offers the project overview', (tester) async {
    final fake = FakeDashboardsClient([]);
    await open(tester, client: fake, at: '/projects/p1/dashboards');
    expect(key('template-project_overview'), findsOneWidget);
    await tester.tap(key('template-project_overview'));
    await tester.pumpAndSettle();
    expect(fake.templates, ['project_overview']);
  });

  testWidgets('adding a widget previews it, then Save sends it with the rest', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('add-widget'));
    await tester.pumpAndSettle();
    expect(key('widget-editor'), findsOneWidget);
    expect(h.fake.previews, isNotEmpty); // a number, to begin with

    await tester.tap(key('widget-kind'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pie chart').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(h.fake.previews.last.kind, WidgetKind.pie);
    expect(h.fake.previews.last.config.groupBy, 'status');

    await tester.tap(key('widget-save'));
    await tester.pumpAndSettle();
    expect(key('unsaved'), findsOneWidget); // the server does not know it yet

    await tester.tap(key('save-dashboard'));
    await tester.pumpAndSettle();
    expect(h.fake.saved.single.widgets, hasLength(3));
    expect(h.fake.saved.single.layout, hasLength(3));
    expect(h.fake.saved.single.widgets.last.kind, WidgetKind.pie);
    expect(key('save-dashboard'), findsNothing); // back to viewing
  });

  testWidgets('dragging a card by its header moves it on the grid', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    final cellW = tester.getSize(key('dashboard-grid')).width / gridColumns;

    final start = tester.getCenter(key('move-w1'));
    final drag = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await drag.moveBy(Offset(cellW * 3, rowHeightForTest * 4));
    await drag.up();
    await tester.pumpAndSettle();

    await tester.tap(key('save-dashboard'));
    await tester.pumpAndSettle();
    final moved = h.fake.saved.single.layout.firstWhere(
      (c) => c.widgetId == 'w1',
    );
    expect(moved.x, 3);
    expect(moved.y, greaterThan(0));
    for (final a in h.fake.saved.single.layout) {
      for (final b in h.fake.saved.single.layout) {
        if (a != b) expect(a.overlaps(b), isFalse);
      }
    }
  });

  testWidgets('a card is removed from the draft, and Cancel drops the change', (
    tester,
  ) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('menu-w2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(key('widget-w2'), findsNothing);
    await tester.tap(key('cancel-edit'));
    await tester.pumpAndSettle();
    expect(key('widget-w2'), findsOneWidget);
    expect(h.fake.saved, isEmpty);
  });

  testWidgets('sharing is for those with the permission', (tester) async {
    await open(tester, role: 'Member');
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-dashboard'));
    await tester.pumpAndSettle();
    expect(key('share-denied'), findsOneWidget);
    final workspace = tester.widget<RadioListTile<DashVisibility>>(
      key('visibility-workspace'),
    );
    expect(workspace.enabled, isFalse);
  });

  testWidgets('an Owner can change who sees it and the name', (tester) async {
    final h = await open(tester);
    await tester.tap(key('edit-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-dashboard'));
    await tester.pumpAndSettle();
    await tester.enterText(key('dashboard-name'), 'Shared');
    await tester.tap(key('visibility-personal'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-ok'));
    await tester.pumpAndSettle();
    await tester.tap(key('save-dashboard'));
    await tester.pumpAndSettle();
    expect(h.fake.saved.single.name, 'Shared');
    expect(h.fake.saved.single.visibility, DashVisibility.personal);
  });

  testWidgets('a dashboard you cannot edit has no Edit or Delete', (
    tester,
  ) async {
    final fake = FakeDashboardsClient([
      dashboardOf('d1', 'Theirs', [
        widgetOf('w1', WidgetKind.number),
      ], canEdit: false),
    ])..dataOf['w1'] = numberData('1');
    await open(tester, client: fake);
    expect(key('edit-dashboard'), findsNothing);
    expect(key('delete-dashboard'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('deleting asks first', (tester) async {
    final h = await open(tester);
    await tester.tap(key('delete-dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(key('confirm-delete-dashboard'));
    await tester.pumpAndSettle();
    expect(h.fake.deleted, ['d1']);
    expect(key('dashboards-empty'), findsOneWidget);
  });

  testWidgets('a widget exports its numbers as CSV', (tester) async {
    await open(tester);
    await tester.tap(key('menu-w2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    expect(key('widget-export-dialog'), findsOneWidget);
    expect(find.textContaining('high,High,2.00'), findsOneWidget);
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
    await tester.tap(key('widget-export-copy'));
    await tester.pumpAndSettle();
    expect(copied, startsWith('key,label,value'));
  });

  testWidgets('on a phone the widgets stack in one column', (tester) async {
    await open(tester, size: const Size(420, 900));
    expect(key('dashboard-stack'), findsOneWidget);
    expect(key('dashboard-grid'), findsNothing);
    expect(key('widget-w1'), findsOneWidget);
  });

  testWidgets('the palette offers the dashboards', (tester) async {
    await open(tester, at: '/');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(key('palette-field'), '> dashboards');
    await tester.pump();
    expect(key('palette-row-nav.dashboards'), findsOneWidget);
  });

  group('goals widget', () {
    FakeDashboardsClient goalsClient() =>
        (FakeDashboardsClient([
            dashboardOf('d1', 'Team', [
              widgetOf('g', WidgetKind.goals, title: 'Goal progress'),
            ]),
          ])
          ..dataOf['g'] = const WidgetData(
            total: '37.50',
            buckets: [
              Bucket('g1', 'Launch', '75.00'),
              Bucket('g2', 'Hire', '0.00'),
            ],
          ));

    testWidgets('draws one bar per goal in percent', (tester) async {
      await open(tester, client: goalsClient());
      expect(find.text('Launch'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(key('bar-g1'), findsOneWidget);
    });

    testWidgets('a bar opens its goal, not a task list', (tester) async {
      final h = await open(tester, client: goalsClient());
      await tester.tap(key('bar-g1'));
      await tester.pumpAndSettle();
      expect(location(h.pumped), '/goals/g1');
      expect(h.fake.drills, isEmpty);
    });

    testWidgets(
      'the editor offers scope and a limit, not measure or grouping',
      (tester) async {
        final h = await open(tester, client: goalsClient());
        await tester.tap(key('edit-dashboard'));
        await tester.pumpAndSettle();
        await tester.tap(key('add-widget'));
        await tester.pumpAndSettle();
        await tester.tap(key('widget-kind'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Goals').last);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        expect(h.fake.previews.last.kind, WidgetKind.goals);
        expect(key('widget-measure'), findsNothing);
        expect(key('widget-group'), findsNothing);
        expect(key('widget-tfql'), findsNothing);
        expect(key('widget-scope'), findsOneWidget);
        expect(key('widget-limit'), findsOneWidget);

        await tester.tap(key('widget-limit'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5').last);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(h.fake.previews.last.config.limit, 5);
      },
    );
  });
}

/// One grid row, as the grid draws it.
const rowHeightForTest = 76.0;
