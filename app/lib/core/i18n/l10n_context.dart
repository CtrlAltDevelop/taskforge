import 'package:flutter/widgets.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's strings in the language on screen. Falls back to English when no
  /// localization is installed above (a widget test with a bare MaterialApp).
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));
}
