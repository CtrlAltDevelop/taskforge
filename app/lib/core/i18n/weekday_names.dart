import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Short weekday names, Monday first, in the language of [AppLocalizations].
extension WeekdayNames on AppLocalizations {
  List<String> get weekdayShortNames => [
    weekdayShortMon,
    weekdayShortTue,
    weekdayShortWed,
    weekdayShortThu,
    weekdayShortFri,
    weekdayShortSat,
    weekdayShortSun,
  ];
}
