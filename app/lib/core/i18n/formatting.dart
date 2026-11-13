import 'package:taskforge/core/i18n/jalali.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

export 'package:taskforge/core/i18n/locale_prefs.dart' show localizeDigits;

String _two(int n) => n.toString().padLeft(2, '0');

String jalaliMonthName(AppLocalizations l10n, int month) => switch (month) {
  1 => l10n.jalaliMonth1,
  2 => l10n.jalaliMonth2,
  3 => l10n.jalaliMonth3,
  4 => l10n.jalaliMonth4,
  5 => l10n.jalaliMonth5,
  6 => l10n.jalaliMonth6,
  7 => l10n.jalaliMonth7,
  8 => l10n.jalaliMonth8,
  9 => l10n.jalaliMonth9,
  10 => l10n.jalaliMonth10,
  11 => l10n.jalaliMonth11,
  _ => l10n.jalaliMonth12,
};

/// A date as the person asked to see it (calendar and digits); the time of day
/// is ignored. [long] spells the Jalali month; Gregorian long dates keep the
/// numeric form so every screen agrees on what a date looks like.
String formatDate(
  DateTime date,
  LocalePrefs prefs,
  AppLocalizations l10n, {
  bool long = false,
}) {
  final String text;
  if (prefs.isJalali) {
    final j = JalaliDate.fromGregorian(date);
    text = long
        ? '${j.day} ${jalaliMonthName(l10n, j.month)} ${j.year}'
        : '${j.year}/${_two(j.month)}/${_two(j.day)}';
  } else {
    text = '${date.year}/${_two(date.month)}/${_two(date.day)}';
  }
  return prefs.digits(text);
}
