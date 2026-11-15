import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/charts/dashboard_charts.dart';

const _data = [
  ChartDatum('high', 'High', 2, '2'),
  ChartDatum('low', 'Low', 1, '1'),
];

Future<void> _show(WidgetTester tester, Widget chart, ThemeData theme) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(body: SizedBox(width: 400, height: 300, child: chart)),
      ),
    );

String _label(WidgetTester tester, Type chart) =>
    tester.getSemantics(find.byType(chart).first).label;

final _themes = {'light': ThemeData.light(), 'dark': ThemeData.dark()};

void main() {
  for (final MapEntry(key: name, value: theme) in _themes.entries) {
    group('in the $name theme', () {
      testWidgets('a number says its caption and value', (tester) async {
        final handle = tester.ensureSemantics();
        await _show(
          tester,
          const NumberTile(value: '42', caption: 'Open tasks'),
          theme,
        );
        expect(_label(tester, NumberTile), contains('Open tasks 42'));
        expect(find.byKey(const Key('number-value')), findsOneWidget);
        handle.dispose();
      });

      testWidgets('bars are labelled, each a button reporting its bucket', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        ChartDatum? tapped;
        await _show(
          tester,
          BarChartView(data: _data, onTap: (d) => tapped = d),
          theme,
        );
        expect(_label(tester, BarChartView), contains('Bar chart, 2 bars'));
        expect(
          tester.getSemantics(find.byKey(const Key('bar-high'))).label,
          'High, 2',
        );
        await tester.tap(find.byKey(const Key('bar-low')));
        expect(tapped?.key, 'low');
        handle.dispose();
      });

      testWidgets('bars without a handler are not buttons', (tester) async {
        final handle = tester.ensureSemantics();
        await _show(tester, const BarChartView(data: _data), theme);
        final node = tester.getSemantics(find.byKey(const Key('bar-high')));
        expect(node.flagsCollection.isButton, isFalse);
        handle.dispose();
      });

      testWidgets('a pie says how many slices it has', (tester) async {
        final handle = tester.ensureSemantics();
        await _show(tester, const PieChartView(data: _data), theme);
        expect(_label(tester, PieChartView), contains('Pie chart, 2 slices'));
        handle.dispose();
      });

      testWidgets('a line says how many lines and points it has', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _show(
          tester,
          const LineChartView(
            xLabels: ['1 Nov', '2 Nov', '3 Nov'],
            series: [
              ChartSeries('Done', [1, 2, null]),
              ChartSeries('Ideal', [3, 2, 1]),
            ],
          ),
          theme,
        );
        expect(
          _label(tester, LineChartView),
          contains('Line chart, 2 lines, 3 points'),
        );
        handle.dispose();
      });

      testWidgets('a table lists its rows and rows are tappable', (
        tester,
      ) async {
        ChartDatum? tapped;
        await _show(
          tester,
          TableChartView(data: _data, onTap: (d) => tapped = d),
          theme,
        );
        expect(find.text('High'), findsOneWidget);
        await tester.tap(find.byKey(const Key('row-high')));
        expect(tapped?.key, 'high');
      });
    });
  }

  test('the palette keeps its colours apart and differs by brightness', () {
    final light = chartPalette(Brightness.light);
    final dark = chartPalette(Brightness.dark);
    expect(light.toSet(), hasLength(light.length));
    expect(dark.toSet(), hasLength(dark.length));
    expect(light, isNot(dark));
  });

  testWidgets('series colours follow the theme', (tester) async {
    late Color light;
    late Color dark;
    for (final theme in [ThemeData.light(), ThemeData.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final c = chartColor(context, 0);
              if (theme.brightness == Brightness.light) {
                light = c;
              } else {
                dark = c;
              }
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(light, chartPalette(Brightness.light).first);
    expect(dark, chartPalette(Brightness.dark).first);
  });
}
