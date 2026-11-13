import 'package:flutter/foundation.dart';

/// Jalali (Solar Hijri) dates, for display only.
///
/// Stored dates stay ISO / Gregorian everywhere (server, outbox, filters); this
/// is the one place that converts, so a bug here can only mis-label a day,
/// never move one. Valid for the years the pickers offer (about 1178-1633, where
/// the 33-year arithmetic rule matches the observed calendar).

/// Leap years follow the 33-year cycle: these remainders are leap.
const _leapRemainders = {1, 5, 9, 13, 17, 22, 26, 30};

bool isJalaliLeapYear(int year) => _leapRemainders.contains(year % 33);

int jalaliMonthLength(int year, int month) {
  if (month < 1 || month > 12) {
    throw RangeError.range(month, 1, 12, 'month');
  }
  if (month <= 6) return 31;
  if (month <= 11) return 30;
  return isJalaliLeapYear(year) ? 30 : 29;
}

@immutable
class JalaliDate implements Comparable<JalaliDate> {
  const JalaliDate(this.year, this.month, this.day);

  /// The Jalali date of a Gregorian [date] (only its year, month and day count).
  factory JalaliDate.fromGregorian(DateTime date) {
    const cumulativeDays = [
      0,
      31,
      59,
      90,
      120,
      151,
      181,
      212,
      243,
      273,
      304,
      334,
    ];
    final gy = date.year;
    final shifted = date.month > 2 ? gy + 1 : gy;
    var days =
        355666 +
        (365 * gy) +
        ((shifted + 3) ~/ 4) -
        ((shifted + 99) ~/ 100) +
        ((shifted + 399) ~/ 400) +
        date.day +
        cumulativeDays[date.month - 1];
    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    final jm = days < 186 ? 1 + days ~/ 31 : 7 + (days - 186) ~/ 30;
    final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
    return JalaliDate(jy, jm, jd);
  }

  final int year;
  final int month;
  final int day;

  /// Whether year/month/day name a real day (Esfand 30 only in a leap year).
  static bool isValid(int year, int month, int day) =>
      month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= jalaliMonthLength(year, month);

  /// The same day as a date-only Gregorian [DateTime] (local midnight).
  DateTime toGregorian() {
    final jy = year + 1595;
    var days =
        -355668 +
        (365 * jy) +
        ((jy ~/ 33) * 8) +
        (((jy % 33) + 3) ~/ 4) +
        day +
        (month < 7 ? (month - 1) * 31 : ((month - 7) * 30) + 186);
    var gy = 400 * (days ~/ 146097);
    days %= 146097;
    if (days > 36524) {
      days--;
      gy += 100 * (days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    var gd = days + 1;
    final lengths = [
      0,
      31,
      (gy % 4 == 0 && gy % 100 != 0) || gy % 400 == 0 ? 29 : 28,
      31, 30, 31, 30, 31, 31, 30, 31, 30, 31, //
    ];
    var gm = 0;
    while (gm < 13 && gd > lengths[gm]) {
      gd -= lengths[gm];
      gm++;
    }
    return DateTime(gy, gm, gd);
  }

  /// `DateTime.monday` ... `DateTime.sunday`, like [DateTime.weekday].
  int get weekday => toGregorian().weekday;

  /// Whole months later (or earlier); the day is kept, or clamped into a
  /// shorter month (31 Shahrivar + 1 month = 30 Mehr).
  JalaliDate addMonths(int months) {
    final index = year * 12 + (month - 1) + months;
    final y = index ~/ 12;
    final m = index % 12 + 1;
    final length = jalaliMonthLength(y, m);
    return JalaliDate(y, m, day > length ? length : day);
  }

  JalaliDate copyWith({int? year, int? month, int? day}) =>
      JalaliDate(year ?? this.year, month ?? this.month, day ?? this.day);

  @override
  int compareTo(JalaliDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is JalaliDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-$month-$day';
}
