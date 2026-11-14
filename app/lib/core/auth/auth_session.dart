import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/token_store.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Who is signed in, and a valid access token for whoever asks.
///
/// Every transport (REST, gRPC, WebSocket) gets its token from [accessToken],
/// which refreshes at most once at a time no matter how many callers are waiting.
class AuthSession extends ChangeNotifier {
  AuthSession({
    required this._api,
    required this._store,
    this.refreshMargin = const Duration(seconds: 30),
    this.raceRetryDelay = const Duration(milliseconds: 300),
    this.cookieSession = false,
    String Function()? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? _randomRequestId;

  final AuthApi _api;
  final TokenStore _store;
  final String Function() _requestIdFactory;

  /// Refresh this long before the access token actually expires.
  final Duration refreshMargin;

  /// Web: the refresh token lives in an HttpOnly cookie, so nothing is stored here
  /// and a page load signs back in by refreshing through the cookie.
  final bool cookieSession;

  /// How long to wait for another window's refresh to land after a 409 race.
  final Duration raceRetryDelay;

  AuthStatus _status = AuthStatus.unknown;
  Future<AuthTokens?>? _refreshing;

  /// Bumped whenever the signed-in identity changes (sign-in, sign-out, session
  /// ended). A refresh that started under an older epoch must not write its result.
  int _epoch = 0;

  AuthStatus get status => _status;

  Future<void> restore() async {
    if (cookieSession && await _store.read() == null) {
      await _restoreThroughCookie();
      return;
    }
    _setStatus(
      await _store.read() == null ? AuthStatus.signedOut : AuthStatus.signedIn,
    );
  }

  Future<void> _restoreThroughCookie() async {
    try {
      await _adopt(await _api.refresh('', requestId: _requestIdFactory()));
    } on AuthApiException {
      _setStatus(AuthStatus.signedOut); // no cookie, or the session ended
    } on NetworkUnavailable {
      _setStatus(AuthStatus.signedOut);
    }
  }

  Future<void> signIn(String email, String password) async =>
      _adopt(await _api.signIn(email, password));

  /// Finishes a sign-in whose last step happened elsewhere (the second-factor
  /// code, a single-sign-on ticket): the tokens are the same as a password's.
  Future<void> adoptTokens(AuthTokens tokens) => _adopt(tokens);

  Future<void> signUp(String email, String password) async =>
      _adopt(await _api.signUp(email, password));

  Future<void> signOut() async {
    _epoch++;
    _refreshing = null;
    final tokens = await _store.read();
    await _store.clear();
    _setStatus(AuthStatus.signedOut);
    if (tokens == null) return;
    try {
      await _api.logout(
        tokens.refreshToken,
      ); // best effort: the local session is already gone
    } on NetworkUnavailable {
      // Offline sign-out still signs out here; the server session expires on its own.
    } on AuthApiException {
      // Already ended server-side.
    }
  }

  /// The server-side id of this device's session, or null when signed out.
  Future<String?> currentSessionId() async => (await _store.read())?.sessionId;

  /// Changes the password. The server then ends every session of the account,
  /// including this one, so the local session ends too (no logout call needed).
  Future<void> changePassword(String current, String next) async {
    final token = await accessToken();
    if (token == null) return;
    await _api.changePassword(token, current, next);
    await _endSession();
  }

  Future<String> requestPasswordReset(String email) =>
      _api.requestPasswordReset(email);

  Future<void> resetPassword({
    required String ticket,
    required String code,
    required String newPassword,
  }) =>
      _api.resetPassword(ticket: ticket, code: code, newPassword: newPassword);

  /// Ends one of the signed-in user's sessions (a device) on the server.
  Future<void> revokeSession(String sessionId) async {
    final token = await accessToken();
    if (token == null) return;
    await _api.revokeSession(token, sessionId);
  }

  /// A usable access token, refreshed if needed; `null` when signed out.
  /// Throws [NetworkUnavailable] when a needed refresh cannot reach the server.
  Future<String?> accessToken() async {
    final tokens = await _store.read();
    if (tokens == null) {
      _setStatus(AuthStatus.signedOut);
      return null;
    }
    if (!tokens.expiresWithin(refreshMargin)) return tokens.accessToken;
    return forceRefresh();
  }

  /// Renews the tokens now, even if the access token still looks valid (the
  /// server may have rejected it, e.g. because another device ended this session).
  /// Returns the new access token, or `null` when the session is over.
  Future<String?> forceRefresh() async {
    final renewed = await (_refreshing ??= _refresh().whenComplete(
      () => _refreshing = null,
    ));
    return renewed?.accessToken;
  }

  Future<AuthTokens?> _refresh() async {
    final tokens = await _store.read();
    if (tokens == null) return null;
    final epoch = _epoch;
    // Remember the request id *before* sending, so a retry repeats it (see AuthTokens).
    var current = tokens;
    if (tokens.pendingRefreshId == null) {
      current = tokens.withPendingRefresh(_requestIdFactory());
      if (epoch != _epoch) return null;
      await _store.write(current);
    }
    try {
      return await _renew(current, epoch);
    } on AuthApiException catch (e) {
      if (epoch != _epoch) return null; // the identity changed while we waited
      if (e.title == 'REFRESH_RACE') return _afterRace(tokens, e);
      if (e.status == 401) {
        await _endSession();
        return null;
      }
      rethrow;
    }
  }

  Future<AuthTokens?> _renew(AuthTokens tokens, int epoch) async {
    final renewed = await _api.refresh(
      tokens.refreshToken,
      requestId: tokens.pendingRefreshId,
    );
    // Signed out (or in as someone else) while the request was in flight.
    if (epoch != _epoch) return null;
    await _store.write(renewed);
    return renewed;
  }

  /// Another window refreshed with the same token a moment ago. Its result lands
  /// in shared storage; adopt it instead of treating the 409 as a failure.
  Future<AuthTokens?> _afterRace(AuthTokens sent, AuthApiException race) async {
    if (cookieSession) {
      // Another tab's refresh rotated the shared cookie; ours then carries the new one.
      await Future<void>.delayed(raceRetryDelay);
      return _renew(sent, _epoch);
    }
    for (var attempt = 0; attempt < 2; attempt++) {
      final stored = await _store.read();
      if (stored == null) return null;
      if (stored.refreshToken != sent.refreshToken) return stored;
      await Future<void>.delayed(raceRetryDelay);
    }
    throw race;
  }

  Future<void> _adopt(AuthTokens tokens) async {
    _epoch++;
    await _store.write(tokens);
    _setStatus(AuthStatus.signedIn);
  }

  Future<void> _endSession() async {
    _epoch++;
    await _store.clear();
    _setStatus(AuthStatus.signedOut);
  }

  void _setStatus(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }
}

String _randomRequestId() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
