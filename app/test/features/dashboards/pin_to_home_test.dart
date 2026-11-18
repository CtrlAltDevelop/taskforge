import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';
import 'package:taskforge/features/home/domain/home.dart';

import '../home/fakes.dart';
import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Finder _key(String k) => find.byKey(Key(k));

Future<Pumped> _open(WidgetTester t, FakeHomeClient home) async {
  final fake = FakeDashboardsClient([
    dashboardOf('d1', 'Team', [widgetOf('w1', WidgetKind.number)]),
  ])..dataOf['w1'] = numberData('1');
  final app = await pumpProjects(
    t,
    projects: [project('p1', 'Web')],
    home: home,
    overrides: [
      dashboardsClientProvider.overrideWithValue(fake),
      dashboardRefreshProvider.overrideWithValue(null),
    ],
  );
  await app.go(t, '/dashboards');
  return app;
}

void main() {
  testWidgets('Pin to Home pins the open dashboard and Home follows', (
    t,
  ) async {
    final home = FakeHomeClient();
    final app = await _open(t, home);
    expect(find.byTooltip('Pin to Home'), findsOneWidget);

    // The server now lists it as pinned; the button turns into Unpin.
    home.summaryValue = const HomeSummary(
      pinned: [HomePin(dashboardId: 'd1', name: 'Team', projectId: '')],
    );
    await t.tap(_key('pin-dashboard'));
    await t.pumpAndSettle();
    expect(home.calls, contains('pin d1 true'));
    expect(find.byTooltip('Unpin from Home'), findsOneWidget);

    // Home's Pinned card shows it.
    await app.go(t, '/');
    expect(_key('home-pin-d1'), findsOneWidget);
  });

  testWidgets('Unpin takes it off again', (t) async {
    final home = FakeHomeClient(
      summaryValue: const HomeSummary(
        pinned: [HomePin(dashboardId: 'd1', name: 'Team', projectId: '')],
      ),
    );
    await _open(t, home);
    expect(find.byTooltip('Unpin from Home'), findsOneWidget);
    home.summaryValue = const HomeSummary();
    await t.tap(_key('pin-dashboard'));
    await t.pumpAndSettle();
    expect(home.calls, contains('pin d1 false'));
    expect(find.byTooltip('Pin to Home'), findsOneWidget);
  });

  testWidgets('a refused pin says so and changes nothing', (t) async {
    final home = FakeHomeClient()
      ..pinError = const HomeException(HomeFailure.denied);
    await _open(t, home);
    await t.tap(_key('pin-dashboard'));
    await t.pumpAndSettle();
    expect(find.text('Could not change the pin.'), findsOneWidget);
    expect(find.byTooltip('Pin to Home'), findsOneWidget);
  });
}
