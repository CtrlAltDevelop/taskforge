import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/jalali.dart';

void main() {
  group('Gregorian to Jalali against reference dates', () {
    // Nowruz and other well-known anchors (dates published by the Iranian
    // calendar authority); each row is gregorian y-m-d -> jalali y-m-d.
    const fixtures = <(int, int, int, int, int, int)>[
      (1970, 1, 1, 1348, 10, 11),
      (2000, 1, 1, 1378, 10, 11),
      (2021, 3, 20, 1399, 12, 30), // the leap day of 1399
      (2021, 3, 21, 1400, 1, 1),
      (2022, 3, 21, 1401, 1, 1),
      (2023, 3, 21, 1402, 1, 1),
      (2024, 2, 29, 1402, 12, 10), // a Gregorian leap day
      (2024, 3, 19, 1402, 12, 29),
      (2024, 3, 20, 1403, 1, 1),
      (2025, 3, 20, 1403, 12, 30), // 1403 is a leap year
      (2025, 3, 21, 1404, 1, 1),
      (2025, 9, 22, 1404, 6, 31),
      (2025, 9, 23, 1404, 7, 1),
      (2026, 3, 21, 1405, 1, 1),
    ];
    for (final (gy, gm, gd, jy, jm, jd) in fixtures) {
      test('$gy-$gm-$gd is $jy-$jm-$jd', () {
        final j = JalaliDate.fromGregorian(DateTime(gy, gm, gd));
        expect((j.year, j.month, j.day), (jy, jm, jd));
        expect(j.toGregorian(), DateTime(gy, gm, gd));
      });
    }
  });

  group('leap years and month lengths', () {
    test('the 33-year pattern marks 1399 and 1403 leap, 1400 to 1402 not', () {
      expect([1399, 1400, 1401, 1402, 1403, 1404].map(isJalaliLeapYear), [
        true,
        false,
        false,
        false,
        true,
        false,
      ]);
    });

    test('first six months have 31 days, next five 30, Esfand 29 or 30', () {
      expect(
        [for (var m = 1; m <= 12; m++) jalaliMonthLength(1404, m)],
        [
          31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29, //
        ],
      );
      expect(jalaliMonthLength(1403, 12), 30);
    });

    test('a leap Esfand 30 exists and a common one does not', () {
      expect(JalaliDate.isValid(1403, 12, 30), isTrue);
      expect(JalaliDate.isValid(1404, 12, 30), isFalse);
      expect(JalaliDate.isValid(1404, 13, 1), isFalse);
      expect(JalaliDate.isValid(1404, 0, 1), isFalse);
    });
  });

  test('every day from 1990 to 2060 survives a round trip and stays in order', () {
    var previous = JalaliDate.fromGregorian(DateTime(1990, 1, 1));
    for (
      var d = DateTime(1990, 1, 2);
      d.year < 2060;
      d = d.add(const Duration(days: 1))
    ) {
      // add(Duration) can land on 23:00 across a DST change: keep it date-only.
      final day = DateTime(d.year, d.month, d.day);
      final j = JalaliDate.fromGregorian(day);
      expect(j.toGregorian(), day, reason: '$day -> $j');
      expect(JalaliDate.isValid(j.year, j.month, j.day), isTrue, reason: '$j');
      expect(j.compareTo(previous), greaterThan(0), reason: '$day');
      previous = j;
    }
  });

  test(
    'weekday follows the Gregorian day: Saturday is the first of the week',
    () {
      // 2025-03-22 was a Saturday.
      expect(
        JalaliDate.fromGregorian(DateTime(2025, 3, 22)).weekday,
        DateTime.saturday,
      );
      expect(
        JalaliDate.fromGregorian(DateTime(2025, 3, 21)).weekday,
        DateTime.friday,
      );
    },
  );

  test('addMonths clamps the day into the shorter month', () {
    final end = JalaliDate(1404, 6, 31); // 31 Shahrivar
    expect(end.addMonths(1), JalaliDate(1404, 7, 30));
    expect(end.addMonths(6), JalaliDate(1404, 12, 29));
    expect(end.addMonths(-5), JalaliDate(1404, 1, 31));
    expect(
      end.addMonths(-6),
      JalaliDate(1403, 12, 30),
    ); // Esfand 1403 is a leap month
    expect(end.addMonths(-18), JalaliDate(1402, 12, 29)); // and 1402 is not
    expect(JalaliDate(1404, 12, 29).addMonths(1), JalaliDate(1405, 1, 29));
  });
}
