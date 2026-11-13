import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Cupertino strings for every language the app offers.
///
/// Flutter ships Cupertino translations for Persian and Arabic but not Pashto;
/// without this the framework reports an unsupported locale. Pashto borrows the
/// Persian ones, which share the script, direction and most of the vocabulary.
class FallbackCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoDelegate();

  static const _fallback = Locale('fa');

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    const inner = GlobalCupertinoLocalizations.delegate;
    return inner.load(inner.isSupported(locale) ? locale : _fallback);
  }

  @override
  bool shouldReload(FallbackCupertinoDelegate old) => false;
}
