import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

void main() {
  group('digits', () {
    test('Persian and Pashto use the extended Arabic-Indic digits', () {
      expect(localizeDigits('2025-03-21', 'fa'), '۲۰۲۵-۰۳-۲۱');
      expect(localizeDigits('12', 'ps'), '۱۲');
    });

    test('Arabic uses the Arabic-Indic digits', () {
      expect(localizeDigits('0123456789', 'ar'), '٠١٢٣٤٥٦٧٨٩');
    });

    test('English has no native digits and letters are left alone', () {
      expect(localizeDigits('WEB-12', 'en'), 'WEB-12');
      expect(localizeDigits('a1b', 'fa'), 'a۱b');
    });
  });

  group('LocalePrefs', () {
    test('digits follow the language only when native digits are chosen', () {
      const latin = LocalePrefs(language: 'fa');
      const native = LocalePrefs(language: 'fa', numerals: 'native');
      expect(latin.digits('5'), '5');
      expect(native.digits('5'), '۵');
    });

    test('an unset week start falls back to the language default', () {
      expect(const LocalePrefs(language: 'fa').weekStartDay, DateTime.saturday);
      expect(const LocalePrefs(language: 'ar').weekStartDay, DateTime.saturday);
      expect(const LocalePrefs(language: 'en').weekStartDay, DateTime.sunday);
      expect(
        const LocalePrefs(language: 'en', weekStart: 'mon').weekStartDay,
        DateTime.monday,
      );
    });

    test('the locale is the language, and the text direction follows it', () {
      expect(const LocalePrefs(language: 'ps').locale, const Locale('ps'));
      expect(const LocalePrefs().locale, const Locale('en'));
      expect(const LocalePrefs(language: 'ar').isRtl, isTrue);
      expect(const LocalePrefs(language: 'en').isRtl, isFalse);
    });

    test('an unknown stored value reads as the default, never as an error', () {
      final prefs = LocalePrefs.fromStored(
        language: 'xx-YY',
        calendar: 'lunar',
        weekStart: 'friday',
        numerals: 'roman',
      );
      expect(prefs, const LocalePrefs());
    });

    test('a region on a stored language is dropped', () {
      expect(LocalePrefs.fromStored(language: 'fa-AF').language, 'fa');
    });
  });

  group('formatDate', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final fa = lookupAppLocalizations(const Locale('fa'));

    test('Gregorian shows ISO-like numbers in the chosen digits', () {
      const prefs = LocalePrefs(language: 'fa', numerals: 'native');
      expect(formatDate(DateTime(2025, 3, 21), prefs, fa), '۲۰۲۵/۰۳/۲۱');
    });

    test('Jalali converts the day and names the month in the language', () {
      const prefs = LocalePrefs(language: 'fa', calendar: 'jalali');
      expect(
        formatDate(DateTime(2025, 3, 21), prefs, fa, long: true),
        '1 فروردین 1404',
      );
      const english = LocalePrefs(language: 'en', calendar: 'jalali');
      expect(
        formatDate(DateTime(2025, 3, 21), english, en, long: true),
        '1 Farvardin 1404',
      );
      expect(formatDate(DateTime(2025, 3, 21), english, en), '1404/01/01');
    });

    test('a time of day is not part of the date', () {
      const prefs = LocalePrefs(language: 'en', calendar: 'jalali');
      expect(
        formatDate(DateTime(2025, 3, 21, 23, 59), prefs, en),
        formatDate(DateTime(2025, 3, 21), prefs, en),
      );
    });
  });

  group('bidi isolation', () {
    test('a task id inside right-to-left text is wrapped as one left-to-right unit', () {
      final wrapped = isolateLtr('WEB-12');
      expect(wrapped.startsWith(String.fromCharCode(0x2066)), isTrue);
      expect(wrapped.endsWith(String.fromCharCode(0x2069)), isTrue);
      expect(wrapped.contains('WEB-12'), isTrue);
    });

    test('an empty string stays empty', () {
      expect(isolateLtr(''), '');
    });

    test('wrapping twice does not nest isolates', () {
      expect(isolateLtr(isolateLtr('WEB-12')), isolateLtr('WEB-12'));
    });
  });
}
