import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/board/presentation/edge_scroll.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_drag.dart';
import 'package:taskforge/features/calendar/presentation/calendar_grid.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

Task _bar() => Task(
  id: 'b',
  projectId: 'p1',
  number: 1,
  displayId: 'WEB-1',
  title: 'Bar',
  statusId: 'todo',
  startDate: '2026-11-09', // Monday
  dueDate: '2026-11-11',
);

Widget _grid(TextDirection direction, void Function(CalDrag, Day) onDrop) =>
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SizedBox(
            width: 700,
            height: 300,
            child: CalendarGrid(
              first: day(2026, 11, 9),
              weeks: 1,
              weekStart: 1,
              tasks: [_bar()],
              today: day(2026, 11, 10),
              canMove: true,
              colorOf: (_) => Colors.blue,
              onOpen: (_) {},
              onDrop: onDrop,
              onMore: (_) {},
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('left to right the first day is on the left', (tester) async {
    await tester.pumpWidget(_grid(TextDirection.ltr, (_, _) {}));

    final bar = tester.getRect(find.byKey(const Key('bar-b-2026-11-09')));
    final monday = tester.getRect(find.byKey(const Key('day-2026-11-09')));

    expect(bar.left, closeTo(monday.left + 1, 2));
  });

  testWidgets('right to left the bar starts at the right, on its first day', (
    tester,
  ) async {
    await tester.pumpWidget(_grid(TextDirection.rtl, (_, _) {}));

    final bar = tester.getRect(find.byKey(const Key('bar-b-2026-11-09')));
    final monday = tester.getRect(find.byKey(const Key('day-2026-11-09')));
    final wednesday = tester.getRect(find.byKey(const Key('day-2026-11-11')));

    expect(monday.right, greaterThan(wednesday.right));
    expect(bar.right, closeTo(monday.right - 1, 2));
    expect(bar.left, closeTo(wednesday.left + 1, 2));
  });

  testWidgets('right to left the day it was picked up on is mirrored', (
    tester,
  ) async {
    CalDrag? seen;
    await tester.pumpWidget(_grid(TextDirection.rtl, (d, _) => seen = d));
    final bar = tester.getRect(find.byKey(const Key('bar-b-2026-11-09')));
    final target = tester.getCenter(find.byKey(const Key('day-2026-11-14')));

    // The right end of the bar is its first day (Monday).
    final gesture = await tester.startGesture(
      bar.centerRight - const Offset(30, 0),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, 24));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(target);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(formatDay(seen!.grabbed!), '2026-11-09');
  });

  testWidgets('right to left a card held at the left edge scrolls on', (
    tester,
  ) async {
    final controller = ScrollController();
    final area = GlobalKey();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            key: area,
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: const SizedBox(width: 3000, height: 100),
          ),
        ),
      ),
    );
    late final BuildContext context;
    context = tester.element(find.byKey(area));
    final edge = EdgeScroller(
      controller: controller,
      axis: Axis.horizontal,
      area: area,
      direction: () => Directionality.of(context),
    );
    addTearDown(edge.stop);
    final before = controller.offset;

    // Over the visual left edge: the far end of a right-to-left scroll.
    edge.follow(const Offset(5, 50));
    await tester.pump(const Duration(milliseconds: 100));
    edge.stop();

    expect(controller.offset, greaterThan(before));
  });
}
