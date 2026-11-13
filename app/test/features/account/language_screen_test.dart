import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/language_screen.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/features/auth/credentials_form.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

class _Accounts implements AccountClient {
  final saved = <LocalePrefs>[];

  @override
  Future<Account> me() async =>
      const Account(email: 'a@b.co', displayName: 'A');

  @override
  Future<void> updatePreferences(LocalePrefs prefs) async => saved.add(prefs);

  @override
  Future<List<SessionInfo>> sessions() async => const [];
}

class _Host extends ConsumerWidget {
  const _Host({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    locale: ref.watch(localePrefsProvider).locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      FallbackCupertinoDelegate(),
    ],
    home: home,
  );
}

Future<_Accounts> _pump(WidgetTester tester, Widget home) async {
  final accounts = _Accounts();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountClientProvider.overrideWithValue(accounts),
        localPrefsProvider.overrideWithValue(MemoryPrefs()),
      ],
      child: _Host(home: home),
    ),
  );
  await tester.pumpAndSettle();
  return accounts;
}

TextDirection _direction(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold)));

void main() {
  testWidgets(
    'choosing Persian switches text and direction without a restart',
    (tester) async {
      final accounts = await _pump(tester, const LanguageScreen());
      expect(find.text('Language and region'), findsOneWidget);
      expect(_direction(tester), TextDirection.ltr);

      await tester.tap(find.byKey(const Key('language-fa')));
      await tester.pumpAndSettle();

      expect(find.text('زبان و منطقه'), findsOneWidget);
      expect(_direction(tester), TextDirection.rtl);
      expect(accounts.saved.last.language, 'fa');
    },
  );

  testWidgets('each right-to-left language mirrors the layout', (tester) async {
    await _pump(tester, const LanguageScreen());
    for (final code in ['ar', 'ps']) {
      await tester.tap(find.byKey(Key('language-$code')));
      await tester.pumpAndSettle();
      expect(_direction(tester), TextDirection.rtl, reason: code);
    }
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();
    expect(_direction(tester), TextDirection.ltr);
  });

  testWidgets('the Jalali calendar and native digits change the preview', (
    tester,
  ) async {
    await _pump(tester, const LanguageScreen());
    await tester.tap(find.byKey(const Key('language-fa')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('جلالی (هجری شمسی)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ارقام فارسی (۰۱۲۳)'));
    await tester.pumpAndSettle();

    final previewFinder = find.byKey(const Key('date-preview'));
    await tester.scrollUntilVisible(previewFinder, 200);
    final preview = tester.widget<Text>(previewFinder);
    expect(preview.data, matches(RegExp(r'^[۰-۹]+ \S+ ۱[۰-۹]{3}$')));
  });

  testWidgets('validation messages follow the language on screen', (
    tester,
  ) async {
    await _pump(
      tester,
      CredentialsForm(
        title: 't',
        submitLabel: 's',
        passwordValidator: validatePassword,
        onSubmit: (_, _) async {},
        footer: const SizedBox(),
      ),
    );
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فارسی').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.text('نشانی ایمیل خود را وارد کنید.'), findsOneWidget);
  });
}
