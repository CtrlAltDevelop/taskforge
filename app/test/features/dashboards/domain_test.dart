import 'dart:ui' show Brightness;

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/charts/dashboard_charts.dart';
import 'package:taskforge/features/dashboards/domain/dashboards.dart';

LayoutCell cell(String id, int x, int y, int w, int h) =>
    LayoutCell(id, x, y, w, h);

void main() {
  group('layout', () {
    test('a move snaps inside the grid and never leaves it', () {
      final out = moveCell([cell('a', 6, 0, 6, 2)], 'a', 9, -4);
      expect((out.single.x, out.single.y), (6, 0)); // x clamps to 12 - w
    });

    test('landing on another card pushes it down, the rest stay put', () {
      final start = [
        cell('a', 0, 0, 6, 2),
        cell('b', 6, 0, 6, 2),
        cell('c', 0, 5, 6, 2),
      ];
      final out = {for (final c in moveCell(start, 'b', -6, 0)) c.widgetId: c};
      // b lands on a; b is pushed below it, a stays, c is untouched.
      expect(out['a']!.y, 0);
      expect(out['b']!.y, 2);
      expect(out['c']!.y, 5);
    });

    test('no two cells overlap after any resize', () {
      final start = [cell('a', 0, 0, 4, 2), cell('b', 0, 2, 4, 2)];
      final out = resizeCell(start, 'a', 0, 3);
      for (final x in out) {
        for (final y in out) {
          if (x != y) expect(x.overlaps(y), isFalse);
        }
      }
    });

    test('a card stays at least two columns wide and two rows tall', () {
      final out = resizeCell([cell('a', 0, 0, 3, 2)], 'a', -9, -9);
      expect((out.single.w, out.single.h), (minCellWidth, minCellHeight));
    });

    test('a new card goes under everything else', () {
      final out = addCell([cell('a', 0, 0, 6, 2), cell('b', 6, 0, 6, 4)], 'n');
      expect(out.last.y, 4);
    });

    test('the layout round-trips through JSON', () {
      final cells = [cell('a', 1, 2, 3, 4)];
      final back = decodeLayout(encodeLayout(cells)).single;
      expect(
        (back.widgetId, back.x, back.y, back.w, back.h),
        ('a', 1, 2, 3, 4),
      );
      expect(decodeLayout('not json'), isEmpty);
    });
  });

  group('config', () {
    test('round-trips and survives garbage', () {
      const c = WidgetConfig(
        tfql: 'priority = high',
        measure: Measure.points,
        groupBy: 'status',
        scope: Scope.open,
        limit: 5,
      );
      expect(WidgetConfig.fromJson(c.toJson()), c);
      expect(WidgetConfig.fromJson('{{'), const WidgetConfig());
      expect(WidgetConfig.fromJson('[1]'), const WidgetConfig());
    });

    test('numbers read the way people write them', () {
      expect(shortNumber('12.00'), '12');
      expect(shortNumber('3.50'), '3.50');
      expect(shortNumber('x'), 'x');
    });
  });

  group('charts', () {
    test('colours are the same ones in both themes, eight apart', () {
      expect(chartPalette(Brightness.light).toSet(), hasLength(8));
      expect(chartPalette(Brightness.dark).toSet(), hasLength(8));
    });
  });
}
