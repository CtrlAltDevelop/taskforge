import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

class _Accounts implements AccountClient {
  _Accounts({this.server = const LocalePrefs(), this.failSave = false});

  LocalePrefs server;
  bool failSave;
  final saved = <LocalePrefs>[];

  @override
  Future<Account> me() async =>
      Account(email: 'z@x.org', displayName: 'Z', prefs: server);

  @override
  Future<void> updatePreferences(LocalePrefs prefs) async {
    if (failSave) throw StateError('offline');
    saved.add(prefs);
  }

  @override
  Future<List<SessionInfo>> sessions() async => const [];
}

ProviderContainer _container(_Accounts accounts, MemoryPrefs prefs) {
  final c = ProviderContainer(
    overrides: [
      accountClientProvider.overrideWithValue(accounts),
      localPrefsProvider.overrideWithValue(prefs),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  workspaceDefaultTests();
  test(
    'a change shows at once, is kept on the device and sent to the server',
    () async {
      final accounts = _Accounts();
      final store = MemoryPrefs();
      final c = _container(accounts, store);

      final synced = await c
          .read(localePrefsProvider.notifier)
          .update((p) => p.copyWith(language: 'fa', calendar: 'jalali'));

      expect(synced, isTrue);
      expect(c.read(localePrefsProvider).language, 'fa');
      expect(accounts.saved.single.calendar, 'jalali');
      expect(await store.read('locale.language'), 'fa');
    },
  );

  test(
    'a server that cannot be reached still keeps the device choice',
    () async {
      final accounts = _Accounts(failSave: true);
      final c = _container(accounts, MemoryPrefs());

      final synced = await c
          .read(localePrefsProvider.notifier)
          .update((p) => p.copyWith(language: 'ar'));

      expect(synced, isFalse);
      expect(c.read(localePrefsProvider).language, 'ar');
    },
  );

  test('the saved choice is read back when the app starts', () async {
    final store = MemoryPrefs();
    await store.write('locale.language', 'ps');
    await store.write('locale.calendar', 'jalali');
    final c = _container(_Accounts(), store);

    c.read(localePrefsProvider);
    await Future<void>.delayed(Duration.zero);

    expect(c.read(localePrefsProvider).language, 'ps');
    expect(c.read(localePrefsProvider).isJalali, isTrue);
  });

  test(
    'the account\'s choices are adopted on a device that has none',
    () async {
      final c = _container(
        _Accounts(
          server: const LocalePrefs(language: 'fa', weekStart: 'sat'),
        ),
        MemoryPrefs(),
      );

      await c
          .read(localePrefsProvider.notifier)
          .adopt(await c.read(accountProvider.future));

      expect(c.read(localePrefsProvider).language, 'fa');
      expect(c.read(localePrefsProvider).weekStart, 'sat');
    },
  );
}

void workspaceDefaultTests() {
  group('workspace default language', () {
    test('starts a person with no saved language, without saving it', () async {
      final accounts = _Accounts();
      final store = MemoryPrefs();
      final c = _container(accounts, store);
      final n = c.read(localePrefsProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      n.applyWorkspaceDefault('fa-AF');
      expect(c.read(localePrefsProvider).language, 'fa');
      expect(await store.read('locale.language'), isNull);

      await n.update((p) => p.copyWith(calendar: 'jalali'));
      expect(accounts.saved.single.language, '', reason: 'default not saved');
      expect(c.read(localePrefsProvider).language, 'fa');
    });

    test('never overrides a language the person chose', () async {
      final store = MemoryPrefs();
      await store.write('locale.language', 'ps');
      final c = _container(_Accounts(), store);
      final n = c.read(localePrefsProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      n.applyWorkspaceDefault('ar');
      expect(c.read(localePrefsProvider).language, 'ps');
    });

    test('an explicit choice replaces it and is saved', () async {
      final accounts = _Accounts();
      final c = _container(accounts, MemoryPrefs());
      final n = c.read(localePrefsProvider.notifier);
      n.applyWorkspaceDefault('ar');

      await n.update((p) => p.copyWith(language: 'en'));
      expect(c.read(localePrefsProvider).language, 'en');
      expect(accounts.saved.single.language, 'en');
    });

    test('the account language beats the default when adopted', () async {
      final c = _container(
        _Accounts(server: const LocalePrefs(language: 'fa')),
        MemoryPrefs(),
      );
      final n = c.read(localePrefsProvider.notifier);
      n.applyWorkspaceDefault('ar');
      await n.adopt(await c.read(accountProvider.future));
      expect(c.read(localePrefsProvider).language, 'fa');
    });

    test('an unsupported default is ignored', () {
      final c = _container(_Accounts(), MemoryPrefs());
      final n = c.read(localePrefsProvider.notifier);
      n.applyWorkspaceDefault('xx');
      expect(c.read(localePrefsProvider).language, '');
    });
  });
}
