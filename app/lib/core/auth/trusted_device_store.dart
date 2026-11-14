import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:taskforge/core/auth/secure_storage.dart';

/// Keeps the "trusted device" token the server hands out after a second-factor
/// check the person asked to remember. It is sent with the next password
/// sign-in (`X-Trusted-Device`), which then skips the code for 30 days.
abstract interface class TrustedDeviceStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class MemoryTrustedDeviceStore implements TrustedDeviceStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

class SecureTrustedDeviceStore implements TrustedDeviceStore {
  SecureTrustedDeviceStore([FlutterSecureStorage? storage])
    : _storage = storage ?? appSecureStorage();

  static const _key = 'auth.trusted_device';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on Object {
      return null; // an unreadable store just means the code is asked for
    }
  }

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
