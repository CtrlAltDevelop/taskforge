import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations, GlobalCupertinoLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

class _Prefs extends LocalePrefsNotifier {
  _Prefs(this.initial);

  final LocalePrefs initial;

  @override
  LocalePrefs build() => initial;
}

Future<void> _open(
  WidgetTester tester,
  LocalePrefs prefs,
  void Function(DateTime?) onResult, {
  DateTime? first,
  DateTime? last,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [localePrefsProvider.overrideWith(() => _Prefs(prefs))],
      child: MaterialApp(
        locale: prefs.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FallbackCupertinoDelegate(),
        ],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => onResult(
              await showAppDatePicker(
                context: context,
                initialDate: DateTime(2025, 3, 21),
                firstDate: first ?? DateTime(2020),
                lastDate: last ?? DateTime(2030),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  const jalali = LocalePrefs(language: 'fa', calendar: 'jalali');

  testWidgets('the Jalali picker opens on the month of the initial day', (
    tester,
  ) async {
    await _open(tester, jalali, (_) {});
    expect(find.text('فروردین 1404'), findsOneWidget);
  });

  testWidgets('picking a Jalali day returns the matching Gregorian date', (
    tester,
  ) async {
    DateTime? result;
    await _open(tester, jalali, (d) => result = d);

    await tester.tap(find.byKey(const Key('jalali-day-10')));
    await tester.tap(find.text('تأیید'));
    await tester.pumpAndSettle();

    // 10 Farvardin 1404 is 30 March 2025.
    expect(result, DateTime(2025, 3, 30));
  });

  testWidgets('the next-month button moves to Ordibehesht', (tester) async {
    await _open(tester, jalali, (_) {});
    await tester.tap(find.byKey(const Key('jalali-next')));
    await tester.pumpAndSettle();
    expect(find.text('اردیبهشت 1404'), findsOneWidget);
  });

  testWidgets('days outside the allowed range cannot be picked', (
    tester,
  ) async {
    DateTime? result;
    await _open(
      tester,
      jalali,
      (d) => result = d,
      first: DateTime(2025, 3, 25),
    );

    await tester.tap(find.byKey(const Key('jalali-day-3')));
    await tester.tap(find.text('تأیید'));
    await tester.pumpAndSettle();

    // The tap on a disabled day did nothing, so OK confirms the initial day
    // clamped into range.
    expect(result, DateTime(2025, 3, 25));
  });

  testWidgets('cancel returns nothing', (tester) async {
    var called = false;
    DateTime? result = DateTime(1999);
    await _open(tester, jalali, (d) {
      called = true;
      result = d;
    });
    await tester.tap(find.text('لغو'));
    await tester.pumpAndSettle();
    expect(called, isTrue);
    expect(result, isNull);
  });

  testWidgets('with the Gregorian calendar the Material picker is used', (
    tester,
  ) async {
    await _open(tester, const LocalePrefs(), (_) {});
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('range picker asks for a start then an end in Jalali', (
    tester,
  ) async {
    DateTimeRange? result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localePrefsProvider.overrideWith(() => _Prefs(jalali))],
        child: MaterialApp(
          locale: jalali.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackCupertinoDelegate(),
          ],
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showAppDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: DateTimeRange(
                  start: DateTime(2025, 3, 21),
                  end: DateTime(2025, 3, 21),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    final ok = lookupAppLocalizations(const Locale('fa')).pickDateOk;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('jalali-day-5')));
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('jalali-day-9')));
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    expect(result?.start, DateTime(2025, 3, 25));
    expect(result?.end, DateTime(2025, 3, 29));
  });
}
