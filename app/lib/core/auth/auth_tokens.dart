import 'dart:convert';

import 'package:flutter/foundation.dart';

/// The credentials a sign-in hands back. Immutable: renewing makes a new value.
@immutable
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    this.pendingRefreshId,
  });

  final String accessToken;
  final String refreshToken;
  final String sessionId;

  /// The id of a refresh that has been sent but not yet answered. It is stored
  /// *before* the request goes out, so a retry after a lost response (or an app
  /// restart) repeats the same id and the server can safely reissue the answer.
  final String? pendingRefreshId;

  AuthTokens withPendingRefresh(String id) => AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
    sessionId: sessionId,
    pendingRefreshId: id,
  );

  /// When the access token stops being accepted, read from its (unverified) `exp`
  /// claim. Only used to decide when to refresh early; the server is the judge.
  DateTime? get accessExpiresAt {
    final parts = accessToken.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      return exp is int
          ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          : null;
    } on FormatException {
      return null;
    }
  }

  /// True when the access token is gone or will be within [margin].
  bool expiresWithin(Duration margin) {
    final expiresAt = accessExpiresAt;
    return expiresAt == null || expiresAt.difference(DateTime.now()) <= margin;
  }

  @override
  bool operator ==(Object other) =>
      other is AuthTokens &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.sessionId == sessionId &&
      other.pendingRefreshId == pendingRefreshId;

  @override
  int get hashCode =>
      Object.hash(accessToken, refreshToken, sessionId, pendingRefreshId);
}
