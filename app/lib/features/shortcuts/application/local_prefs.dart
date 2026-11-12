import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:taskforge/core/auth/secure_storage.dart';

/// Small per-device preferences (not secret): the recent actions, the theme.
abstract interface class LocalPrefs {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class MemoryPrefs implements LocalPrefs {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

/// The same storage as the tokens (it needs no second plugin). A device
/// without it just forgets: a preference is never worth an error.
class SecurePrefs implements LocalPrefs {
  SecurePrefs([FlutterSecureStorage? storage])
    : _storage = storage ?? appSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: 'pref.$key');
    } on Object catch (e) {
      debugPrint('prefs: cannot read $key ($e)');
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: 'pref.$key', value: value);
    } on Object catch (e) {
      debugPrint('prefs: cannot save $key ($e)');
    }
  }
}

final localPrefsProvider = Provider<LocalPrefs>((ref) => SecurePrefs());

/// Light, dark, or whatever the device says.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme.mode';

  @override
  ThemeMode build() {
    final prefs = ref.read(localPrefsProvider);
    prefs.read(_key).then((saved) {
      if (!ref.mounted || saved == null || state != ThemeMode.system) return;
      state =
          ThemeMode.values.where((m) => m.name == saved).firstOrNull ??
          ThemeMode.system;
    });
    return ThemeMode.system;
  }

  /// To the other theme than the one on screen now.
  void toggle(Brightness showing) {
    state = showing == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(localPrefsProvider).write(_key, state.name);
  }
}
