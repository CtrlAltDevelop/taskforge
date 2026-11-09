import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:taskforge/core/auth/auth_tokens.dart';

/// Where tokens live between launches.
abstract interface class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

class MemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

/// Keychain / Keystore on mobile and desktop. On web the browser has no secret
/// store: the package keeps the value AES-encrypted in localStorage with the key
/// beside it, which hides tokens from casual inspection but not from script
/// running on the page (see docs/phases/phase-01-authentication.md).
///
/// All three values live in one entry so a crash can never leave a new access
/// token next to an already-spent refresh token.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth.tokens';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthTokens(
        accessToken: json['access'] as String,
        refreshToken: json['refresh'] as String,
        sessionId: json['session'] as String,
        pendingRefreshId: json['pending'] as String?,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens tokens) => _storage.write(
    key: _key,
    value: jsonEncode({
      'access': tokens.accessToken,
      'refresh': tokens.refreshToken,
      'session': tokens.sessionId,
      'pending': tokens.pendingRefreshId,
    }),
  );

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
