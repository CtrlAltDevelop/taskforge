import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/i18n/jalali.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_grid.dart';
import 'package:taskforge/features/calendar/presentation/calendar_toolbar.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import '../tasks/fakes.dart';

class _FixedPrefs extends LocalePrefsNotifier {
  _FixedPrefs(this.prefs);
  final LocalePrefs prefs;

  @override
  LocalePrefs build() => prefs;
}

const _fa = LocalePrefs(language: 'fa', calendar: 'jalali');
const _faNative = LocalePrefs(
  language: 'fa',
  calendar: 'jalali',
  numerals: 'native',
);

int _weeks(({Day first, Day last}) r) =>
    (daysBetween(r.first, r.last) + 1) ~/ 7;

int _span(({Day first, Day last}) r) => daysBetween(r.first, r.last) + 1;

Widget _app(LocalePrefs prefs, Widget child) => ProviderScope(
  overrides: [localePrefsProvider.overrideWith(() => _FixedPrefs(prefs))],
  child: MaterialApp(
    locale: prefs.locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

Widget _grid(
  LocalePrefs prefs,
  Day anchor, {
  List<Task> tasks = const [],
  int weekStart = DateTime.saturday,
}) {
  final range = visibleRange(
    CalendarMode.month,
    anchor,
    weekStart,
    jalali: true,
  );
  return _app(
    prefs,
    SizedBox(
      width: 1000,
      height: 900,
      child: CalendarGrid(
        first: range.first,
        weeks: _weeks(range),
        weekStart: weekStart,
        tasks: tasks,
        today: day(2025, 4, 25),
        month: jalaliOf(anchor).month,
        jalali: true,
        maxLanes: 3,
        colorOf: (_) => Colors.blue,
        onOpen: (_) {},
        onDrop: (_, _) {},
        onMore: (_) {},
      ),
    ),
  );
}

String _cellText(WidgetTester tester, Day d) {
  final text = find.descendant(
    of: find.byKey(Key('day-${formatDay(d)}')),
    matching: find.byType(Text),
  );
  return tester.widget<Text>(text.first).data!;
}

void main() {
  group('Jalali fixtures', () {
    test('known new years and month starts match the Gregorian dates', () {
      expect(dayOfJalali(const JalaliDate(1404, 1, 1)), day(2025, 3, 21));
      expect(dayOfJalali(const JalaliDate(1403, 7, 1)), day(2024, 9, 22));
      expect(dayOfJalali(const JalaliDate(1403, 1, 1)), day(2024, 3, 20));
      expect(jalaliOf(day(2025, 3, 21)), const JalaliDate(1404, 1, 1));
    });

    test('1403 is a leap year: 30 Esfand 1403 is the day before Nowruz', () {
      expect(isJalaliLeapYear(1403), isTrue);
      expect(isJalaliLeapYear(1404), isFalse);
      expect(dayOfJalali(const JalaliDate(1403, 12, 30)), day(2025, 3, 20));
      expect(jalaliOf(day(2025, 3, 20)), const JalaliDate(1403, 12, 30));
    });
  });

  group('Jalali month math', () {
    test('month span has the Jalali month length', () {
      expect(_span(jalaliMonthSpan(day(2025, 4, 25))), 31); // Ordibehesht
      expect(_span(jalaliMonthSpan(day(2024, 10, 1))), 30); // Mehr 1403
      expect(_span(jalaliMonthSpan(day(2025, 3, 1))), 30); // Esfand 1403 leap
      expect(_span(jalaliMonthSpan(day(2026, 3, 1))), 29); // Esfand 1404
    });

    test('grid starts on the week start on or before the 1st', () {
      // 1 Farvardin 1404 is a Friday: a Saturday-first grid starts 6 days
      // earlier, a Monday-first grid 4 days earlier.
      final sat = visibleRange(
        CalendarMode.month,
        day(2025, 4, 1),
        DateTime.saturday,
        jalali: true,
      );
      expect(sat.first, day(2025, 3, 15));
      expect(sat.first.weekday, DateTime.saturday);
      expect(_weeks(sat), 6);
      final mon = visibleRange(
        CalendarMode.month,
        day(2025, 4, 1),
        DateTime.monday,
        jalali: true,
      );
      expect(mon.first, day(2025, 3, 17));
    });

    test('week counts for 31, 30 and 29 day months', () {
      expect(_weeks(jalaliMonthGrid(day(2025, 3, 25), DateTime.saturday)), 6);
      expect(_weeks(jalaliMonthGrid(day(2024, 10, 1), DateTime.saturday)), 5);
      expect(_weeks(jalaliMonthGrid(day(2025, 3, 1), DateTime.saturday)), 5);
      final shortest = jalaliMonthGrid(day(2026, 3, 1), DateTime.saturday);
      expect(shortest.first.weekday, DateTime.saturday);
      expect(shortest.last.weekday, DateTime.friday);
    });

    test('stepping months crosses the Jalali year end', () {
      final esfand = day(2026, 3, 1); // Esfand 1404
      expect(
        step(CalendarMode.month, esfand, 1, jalali: true),
        day(2026, 3, 21), // 1 Farvardin 1405
      );
      expect(
        step(CalendarMode.month, day(2025, 3, 21), -1, jalali: true),
        day(2025, 2, 19), // 1 Esfand 1403
      );
      expect(
        step(CalendarMode.month, day(2025, 4, 25), 12, jalali: true),
        day(2026, 4, 21), // 1 Ordibehesht 1405
      );
    });

    test('Gregorian behaviour is unchanged by default', () {
      expect(
        visibleRange(CalendarMode.month, day(2026, 11, 10), 1),
        visibleRange(CalendarMode.month, day(2026, 11, 10), 1, jalali: false),
      );
      expect(step(CalendarMode.month, day(2026, 12, 10), 1), day(2027, 1, 1));
    });
  });

  group('Jalali calendar widgets', () {
    testWidgets('title shows month and year in native digits', (tester) async {
      await tester.pumpWidget(
        _app(
          _faNative,
          Builder(
            builder: (context) => Text(
              rangeTitle(
                context,
                CalendarMode.month,
                day(2025, 4, 25),
                day(2025, 4, 20),
                day(2025, 5, 24),
              ),
            ),
          ),
        ),
      );
      expect(find.text('اردیبهشت ۱۴۰۴'), findsOneWidget);
    });

    testWidgets('first cell is the Saturday before 1 Farvardin, dimmed', (
      tester,
    ) async {
      await tester.pumpWidget(_grid(_fa, day(2025, 4, 1)));
      // 2025-03-15 = 25 Esfand 1403, outside Farvardin: dimmed.
      expect(_cellText(tester, day(2025, 3, 15)), '25');
      final dim = tester.widget<Text>(
        find
            .descendant(
              of: find.byKey(const Key('day-2025-03-15')),
              matching: find.byType(Text),
            )
            .first,
      );
      final scheme = Theme.of(tester.element(find.byType(CalendarGrid)))
          .colorScheme;
      expect(dim.style!.color, scheme.outline);
      // 1 Farvardin is the 7th cell, not dimmed.
      expect(_cellText(tester, day(2025, 3, 21)), '1');
      final inside = tester.widget<Text>(
        find
            .descendant(
              of: find.byKey(const Key('day-2025-03-21')),
              matching: find.byType(Text),
            )
            .first,
      );
      expect(inside.style!.color, isNull);
    });

    testWidgets('native digits on day numbers', (tester) async {
      await tester.pumpWidget(_grid(_faNative, day(2025, 4, 1)));
      expect(_cellText(tester, day(2025, 3, 21)), '۱');
      expect(_cellText(tester, day(2025, 4, 20)), '۳۱');
    });

    testWidgets('31 day month: 6 weeks, last Jalali day is 31', (tester) async {
      await tester.pumpWidget(_grid(_fa, day(2025, 4, 1)));
      expect(find.byKey(const Key('week-2025-03-15')), findsOneWidget);
      expect(find.byKey(const Key('week-2025-04-19')), findsOneWidget);
      expect(find.byKey(const Key('week-2025-04-26')), findsNothing);
      expect(_cellText(tester, day(2025, 4, 20)), '31');
    });

    testWidgets('30 day month Mehr 1403: 5 weeks', (tester) async {
      await tester.pumpWidget(_grid(_fa, day(2024, 10, 1)));
      expect(find.byKey(const Key('week-2024-09-21')), findsOneWidget);
      expect(find.byKey(const Key('week-2024-10-19')), findsOneWidget);
      expect(find.byKey(const Key('week-2024-10-26')), findsNothing);
      expect(_cellText(tester, day(2024, 9, 22)), '1');
      expect(_cellText(tester, day(2024, 10, 21)), '30');
    });

    testWidgets('leap Esfand 1403 shows the 30th, Esfand 1404 stops at 29', (
      tester,
    ) async {
      await tester.pumpWidget(_grid(_fa, day(2025, 3, 1)));
      expect(_cellText(tester, day(2025, 3, 20)), '30');
      await tester.pumpWidget(_grid(_fa, day(2026, 3, 1)));
      expect(_cellText(tester, day(2026, 3, 20)), '29');
    });

    testWidgets('a task lands on its Jalali day, Gregorian stored', (
      tester,
    ) async {
      final t = task('a', 'Alpha', dueDate: '2025-04-25'); // 5 Ordibehesht
      await tester.pumpWidget(_grid(_fa, day(2025, 4, 25), tasks: [t]));
      expect(find.byKey(const Key('day-2025-04-25')), findsOneWidget);
      expect(_cellText(tester, day(2025, 4, 25)), '5');
      final bar = tester.getCenter(find.byKey(const Key('chip-a-2025-04-19')));
      final cell = tester.getRect(find.byKey(const Key('day-2025-04-25')));
      expect(cell.contains(Offset(bar.dx, cell.center.dy)), isTrue);
    });

    testWidgets('week columns start on Saturday', (tester) async {
      await tester.pumpWidget(_grid(_fa, day(2025, 4, 1)));
      final first = tester.getCenter(find.byKey(const Key('day-2025-03-15')));
      final last = tester.getCenter(find.byKey(const Key('day-2025-03-21')));
      // Right to left: Saturday is the rightmost column of the first week.
      expect(first.dx, greaterThan(last.dx));
      expect(first.dy, last.dy);
      expect(day(2025, 3, 15).weekday, DateTime.saturday);
    });
  });

  group('Jalali anchor navigation', () {
    test('next and previous move by Jalali months; today returns', () {
      final container = ProviderContainer(
        overrides: [
          localePrefsProvider.overrideWith(() => _FixedPrefs(_fa)),
          todayProvider.overrideWithValue(day(2026, 3, 1)), // Esfand 1404
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(calendarAnchorProvider('p1'), (_, _) {});
      addTearDown(sub.close);
      final cursor = container.read(calendarAnchorProvider('p1').notifier);
      cursor.shift(CalendarMode.month, 1);
      expect(container.read(calendarAnchorProvider('p1')), day(2026, 3, 21));
      cursor.shift(CalendarMode.month, -1);
      expect(container.read(calendarAnchorProvider('p1')), day(2026, 2, 20));
      cursor.today();
      expect(container.read(calendarAnchorProvider('p1')), day(2026, 3, 1));
    });
  });
}
