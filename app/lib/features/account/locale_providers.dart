import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

/// The person's language, calendar, week start and digits.
///
/// A change shows at once and is kept on the device (so it works signed out and
/// offline); it is then sent to the account so the other devices follow.
final localePrefsProvider = NotifierProvider<LocalePrefsNotifier, LocalePrefs>(
  LocalePrefsNotifier.new,
);

class LocalePrefsNotifier extends Notifier<LocalePrefs> {
  static const _keys = {
    'language': 'locale.language',
    'calendar': 'locale.calendar',
    'weekStart': 'locale.weekStart',
    'numerals': 'locale.numerals',
  };

  bool _touched = false; // the person changed something before the read ended

  // The language the person chose ('' = never). `state.language` shows it, or
  // the workspace default while it is empty; only this value is ever saved.
  String _ownLanguage = '';
  String _workspaceDefault = '';

  LocalePrefs _shown(LocalePrefs own) =>
      own.language.isEmpty ? own.copyWith(language: _workspaceDefault) : own;

  /// Starts a person who chose no language in the workspace's default; never
  /// saved as their choice, never overrides one.
  void applyWorkspaceDefault(String raw) {
    _workspaceDefault = normalizeLanguage(raw) ?? '';
    if (_ownLanguage.isEmpty) state = _shown(state.copyWith(language: ''));
  }

  @override
  LocalePrefs build() {
    _load();
    return const LocalePrefs();
  }

  Future<void> _load() async {
    final store = ref.read(localPrefsProvider);
    final saved = LocalePrefs.fromStored(
      language: await store.read(_keys['language']!),
      calendar: await store.read(_keys['calendar']!),
      weekStart: await store.read(_keys['weekStart']!),
      numerals: await store.read(_keys['numerals']!),
    );
    if (ref.mounted && !_touched) {
      _ownLanguage = saved.language;
      state = _shown(saved);
    }
  }

  Future<void> _persist(LocalePrefs prefs) async {
    final store = ref.read(localPrefsProvider);
    await store.write(_keys['language']!, prefs.language);
    await store.write(_keys['calendar']!, prefs.calendar);
    await store.write(_keys['weekStart']!, prefs.weekStart);
    await store.write(_keys['numerals']!, prefs.numerals);
  }

  /// Applies [change]; true when the account has it too, false when only this
  /// device does (offline or signed out).
  Future<bool> update(LocalePrefs Function(LocalePrefs) change) async {
    _touched = true;
    final next = change(state);
    if (next.language != state.language) _ownLanguage = next.language;
    state = next;
    final own = next.copyWith(language: _ownLanguage);
    await _persist(own);
    try {
      await ref.read(accountClientProvider).updatePreferences(own);
      return true;
    } on Object catch (e) {
      debugPrint('locale: not saved to the account ($e)');
      return false;
    }
  }

  /// Takes what the account holds, unless this device already has a choice.
  Future<void> adopt(Account account) async {
    if (_touched ||
        state.copyWith(language: _ownLanguage) != const LocalePrefs()) {
      return;
    }
    final remote = account.prefs;
    if (remote == const LocalePrefs()) return;
    _touched = true;
    _ownLanguage = remote.language;
    state = _shown(remote);
    await _persist(remote);
  }
}
