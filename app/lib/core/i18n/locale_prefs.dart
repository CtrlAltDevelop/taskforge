import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

/// The languages the app is translated into, in the order the picker lists them.
const supportedLanguages = ['en', 'fa', 'ar', 'ps'];
const _rtlLanguages = {'fa', 'ar', 'ps'};
const calendarSystems = ['gregorian', 'jalali'];
const weekStarts = ['sat', 'sun', 'mon'];
const numeralChoices = ['latin', 'native'];

/// The language alone (`fa-AF` becomes `fa`), or null when it is not supported.
String? normalizeLanguage(String raw) {
  final language = raw
      .replaceAll('_', '-')
      .split('-')
      .first
      .trim()
      .toLowerCase();
  return supportedLanguages.contains(language) ? language : null;
}

/// Persian and Pashto share the extended Arabic-Indic digits; Arabic has its
/// own. A "." or "," between two digits becomes the Arabic decimal ("٫") or
/// thousands ("٬") separator.
String localizeDigits(String text, String language) {
  final zero = switch (language) {
    'fa' || 'ps' => 0x06F0,
    'ar' => 0x0660,
    _ => null,
  };
  if (zero == null) return text;
  bool isDigit(int unit) => unit >= 0x30 && unit <= 0x39;
  final units = text.codeUnits;
  return String.fromCharCodes([
    for (var i = 0; i < units.length; i++)
      if (isDigit(units[i]))
        zero + (units[i] - 0x30)
      else if ((units[i] == 0x2E || units[i] == 0x2C) &&
          i > 0 &&
          i < units.length - 1 &&
          isDigit(units[i - 1]) &&
          isDigit(units[i + 1]))
        units[i] == 0x2E ? 0x066B : 0x066C
      else
        units[i],
  ]);
}

/// A person's language, calendar, week start and digits.
///
/// An empty [language], [weekStart] or [numerals] means "not chosen": English,
/// the language's own week start and Western digits. Display only -- stored
/// dates never change with any of it.
@immutable
class LocalePrefs {
  const LocalePrefs({
    this.language = '',
    this.calendar = 'gregorian',
    this.weekStart = '',
    this.numerals = '',
  });

  /// Reads values saved on the device or sent by the server; anything it does
  /// not know reads as the default rather than failing.
  factory LocalePrefs.fromStored({
    String? language,
    String? calendar,
    String? weekStart,
    String? numerals,
  }) => LocalePrefs(
    language: normalizeLanguage(language ?? '') ?? '',
    calendar: calendarSystems.contains(calendar) ? calendar! : 'gregorian',
    weekStart: weekStarts.contains(weekStart) ? weekStart! : '',
    numerals: numeralChoices.contains(numerals) ? numerals! : '',
  );

  final String language;
  final String calendar;
  final String weekStart;
  final String numerals;

  /// The language in effect (English until one is chosen).
  String get effectiveLanguage => language.isEmpty ? 'en' : language;

  Locale get locale => Locale(effectiveLanguage);

  bool get isRtl => _rtlLanguages.contains(effectiveLanguage);

  bool get isJalali => calendar == 'jalali';

  /// ISO weekday (`DateTime.monday` ... `DateTime.sunday`) a week begins on.
  int get weekStartDay => switch (weekStart) {
    'sat' => DateTime.saturday,
    'sun' => DateTime.sunday,
    'mon' => DateTime.monday,
    _ => isRtl ? DateTime.saturday : DateTime.sunday,
  };

  /// [text] with its digits in the chosen numerals.
  String digits(String text) =>
      numerals == 'native' ? localizeDigits(text, effectiveLanguage) : text;

  LocalePrefs copyWith({
    String? language,
    String? calendar,
    String? weekStart,
    String? numerals,
  }) => LocalePrefs(
    language: language ?? this.language,
    calendar: calendar ?? this.calendar,
    weekStart: weekStart ?? this.weekStart,
    numerals: numerals ?? this.numerals,
  );

  @override
  bool operator ==(Object other) =>
      other is LocalePrefs &&
      other.language == language &&
      other.calendar == calendar &&
      other.weekStart == weekStart &&
      other.numerals == numerals;

  @override
  int get hashCode => Object.hash(language, calendar, weekStart, numerals);
}
