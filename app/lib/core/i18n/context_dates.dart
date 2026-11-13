import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/locale_providers.dart';

/// The person's calendar and numerals, from whatever scope [BuildContext] is in.
/// Falls back to English/Gregorian/Latin when there is no provider scope.
extension LocalizedDates on BuildContext {
  LocalePrefs get localePrefs {
    try {
      return ProviderScope.containerOf(this).read(localePrefsProvider);
    } on Object {
      return const LocalePrefs();
    }
  }

  /// [date] in the chosen calendar and digits.
  String localDate(DateTime date, {bool long = false}) =>
      formatDate(date, localePrefs, l10n, long: long);

  /// A compact date that stays `YYYY-MM-DD` in the Gregorian calendar (only the
  /// numerals follow the person's choice) and is Jalali when they chose that.
  String localIso(DateTime date) =>
      dateOrIso(date, prefs: localePrefs, l10n: l10n);

  /// Like [localDate] for a local-time instant that may be missing ('').
  String localDateOrEmpty(DateTime? date) =>
      date == null ? '' : localIso(date.toLocal());

  /// [text] with digits in the chosen numerals.
  String localDigits(String text) => localePrefs.digits(text);
}
