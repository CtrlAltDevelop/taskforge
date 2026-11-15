import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/cupertino_fallback.dart';
import 'package:taskforge/core/i18n/directional_icon.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/language_screen.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/features/auth/credentials_form.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

import 'tolerant_golden.dart';

/// Right-to-left checks on real screens: where things sit, not only the text.
/// The golden images pin the whole picture; the position checks say why when
/// one of them breaks.

class _Accounts implements AccountClient {
  @override
  Future<Account> me() async =>
      const Account(email: 'a@b.co', displayName: 'A');

  @override
  Future<void> updatePreferences(LocalePrefs prefs) async {}

  @override
  Future<List<SessionInfo>> sessions() async => const [];
}

class _Prefs extends LocalePrefsNotifier {
  _Prefs(this.initial);

  final LocalePrefs initial;

  @override
  LocalePrefs build() => initial;
}

Future<void> _pump(WidgetTester tester, String language, Widget home) async {
  tester.view
    ..physicalSize = const Size(420, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        accountClientProvider.overrideWithValue(_Accounts()),
        localPrefsProvider.overrideWithValue(MemoryPrefs()),
        localePrefsProvider.overrideWith(
          () => _Prefs(LocalePrefs(language: language)),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: ref.watch(localePrefsProvider).locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackCupertinoDelegate(),
          ],
          home: home,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _signIn() => CredentialsForm(
  title: 't',
  submitLabel: 's',
  passwordValidator: validateSignInPassword,
  onSubmit: (_, _) async {},
  footer: const SizedBox(),
);

void main() {
  setUpAll(useTolerantGoldens);

  group('the language screen', () {
    for (final language in ['en', 'fa', 'ar', 'ps']) {
      testWidgets('looks the same every run in $language', (tester) async {
        await _pump(tester, language, const LanguageScreen());
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/language_screen_$language.png'),
        );
      });
    }
  });

  group('mirroring', () {
    testWidgets(
      'a language row puts its radio button at the right in Persian',
      (tester) async {
        double radioX() => tester
            .getCenter(
              find.descendant(
                of: find.byKey(const Key('language-en')),
                matching: find.byType(Radio<String>),
              ),
            )
            .dx;
        await _pump(tester, 'en', const LanguageScreen());
        final ltr = radioX();
        await _pump(tester, 'fa', const LanguageScreen());
        final rtl = radioX();
        expect(ltr, lessThan(210));
        expect(rtl, greaterThan(210));
      },
    );

    testWidgets('a field label sits at the right edge in Arabic', (
      tester,
    ) async {
      await _pump(tester, 'ar', _signIn());
      final field = tester.getRect(find.byKey(const Key('email')));
      final hint = tester.getRect(find.byType(Text).first);
      expect(field.right, greaterThan(210));
      expect(hint.center.dx, greaterThan(210));
    });

    testWidgets('a directional icon turns around in right-to-left only', (
      tester,
    ) async {
      Future<bool> flipped(String language) async {
        await _pump(
          tester,
          language,
          const Scaffold(body: DirectionalIcon(Icons.chevron_right)),
        );
        final flip = tester.widget<Transform>(
          find
              .descendant(
                of: find.byType(DirectionalIcon),
                matching: find.byType(Transform),
              )
              .first,
        );
        return flip.transform.storage[0] < 0;
      }

      expect(await flipped('en'), isFalse);
      expect(await flipped('ps'), isTrue);
    });
  });
}
