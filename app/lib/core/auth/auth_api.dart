import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taskforge/core/auth/http_client.dart';

import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/device_info.dart';
import 'package:taskforge/core/auth/trusted_device_store.dart';

/// The server refused or failed a request. [title] is the response `title`
/// (e.g. `INVALID_CREDENTIALS`, `REFRESH_RACE`) for code to branch on.
/// The message of an error the server sent without any text of its own;
/// `authErrorMessage` shows it in the language on screen.
const requestFailedMessage = 'Request failed.';

class AuthApiException implements Exception {
  const AuthApiException({
    required this.status,
    required this.title,
    required this.message,
    this.code = '',
  });

  final int status;
  final String title;
  final String message;

  /// The RFC 9449 error the server named (`invalid_token`, `invalid_dpop_proof`,
  /// `use_dpop_nonce`) when a proof or key was the problem, otherwise empty.
  final String code;

  /// The session's key is gone or is not this device's: the user must sign in again here.
  bool get keyChanged => code == 'invalid_token';

  @override
  String toString() => message;
}

/// A sign-in that stopped after the first factor: the password was right and
/// the account has two-step verification on. [loginTicket] is the short-lived
/// challenge token to present with the code.
class SecondFactorRequired extends AuthApiException {
  const SecondFactorRequired({
    required this.loginTicket,
    this.methods = const [],
  }) : super(
         status: 400,
         title: 'SECOND_FACTOR_REQUIRED',
         message: 'Second factor required.',
       );

  final String loginTicket;
  final List<String> methods;
}

/// The server could not be reached; the user's session is untouched.
class NetworkUnavailable implements Exception {
  const NetworkUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthApi {
  Future<AuthTokens> signUp(String email, String password);
  Future<AuthTokens> signIn(String email, String password);

  /// [requestId] identifies this refresh attempt: repeat it when retrying a
  /// refresh whose response was lost.
  Future<AuthTokens> refresh(String refreshToken, {String? requestId});
  Future<void> logout(String refreshToken);
  Future<void> revokeSession(String accessToken, String sessionId);

  /// The server ends every session of the account on success, this one included.
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  );

  /// Emails a one-time code; returns the ticket to present with it.
  Future<String> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String ticket,
    required String code,
    required String newPassword,
  });
}

class HttpAuthApi implements AuthApi {
  /// [cookieMode] is for browsers: the server keeps the refresh token in an
  /// HttpOnly cookie, so no script (and no stored value) ever holds it.
  HttpAuthApi(
    this.baseUrl, {
    http.Client? client,
    this.cookieMode = false,
    this.trustedDevices,
    this.deviceInfo,
  }) : _client =
           client ?? (cookieMode ? createAuthHttpClient() : http.Client());

  /// Where the remembered-device token lives; sent with a password sign-in so
  /// a device that already passed the second factor skips it.
  final TrustedDeviceStore? trustedDevices;

  /// Phase 40: the `X-Device-Info` header, sent on sign-in, sign-up and refresh only (and
  /// built in one place, so every request carries the same set of fields).
  final DeviceInfoSource? deviceInfo;

  final bool cookieMode;
  final String baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  @override
  Future<AuthTokens> signUp(String email, String password) async {
    // The account's login name is its email address.
    final body = await _send(
      'POST',
      '/api/v1/auth/password/signup',
      json: {'identifier': email, 'email': email, 'password': password},
      withDeviceInfo: true,
    );
    return _credentials(body['data']['credentials'] as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> signIn(String email, String password) async {
    final body = await _send(
      'POST',
      '/api/v1/auth/password/login',
      json: {'identifier': email, 'password': password},
      trustedDevice: await trustedDevices?.read(),
      withDeviceInfo: true,
    );
    final data = body['data'] as Map<String, dynamic>;
    if (data['requires_second_factor'] == true) {
      throw SecondFactorRequired(
        loginTicket: (data['login_ticket'] as String?) ?? '',
        methods: [...((data['methods'] as List?) ?? const []).cast<String>()],
      );
    }
    return _credentials(data['credentials'] as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken, {String? requestId}) async {
    final body = await _send(
      'POST',
      '/api/v1/auth/token/refresh',
      json: {'refresh_token': refreshToken, 'request_id': ?requestId},
      withDeviceInfo: true,
    );
    return _credentials(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _send(
      'POST',
      '/api/v1/auth/password/logout',
      json: {'token': refreshToken},
    );
  }

  @override
  Future<void> revokeSession(String accessToken, String sessionId) async {
    await _send(
      'DELETE',
      '/api/v1/auth/token/sessions/$sessionId',
      bearer: accessToken,
    );
  }

  @override
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) async {
    await _send(
      'POST',
      '/api/v1/auth/password/change',
      bearer: accessToken,
      json: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    final body = await _send(
      'POST',
      '/api/v1/auth/password/forgot',
      json: {'email': email},
    );
    return (body['data'] as Map<String, dynamic>)['ticket'] as String;
  }

  @override
  Future<void> resetPassword({
    required String ticket,
    required String code,
    required String newPassword,
  }) async {
    await _send(
      'POST',
      '/api/v1/auth/password/reset',
      json: {'ticket': ticket, 'code': code, 'password': newPassword},
    );
  }

  AuthTokens _credentials(Map<String, dynamic> data) => AuthTokens(
    accessToken: data['access_token'] as String,
    refreshToken: data['refresh_token'] as String,
    sessionId: data['session_id'] as String,
  );

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? json,
    String? bearer,
    String? trustedDevice,
    bool withDeviceInfo = false,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (cookieMode) request.headers['X-Refresh-Transport'] = 'cookie';
    if (bearer != null) request.headers['Authorization'] = 'Bearer $bearer';
    if (trustedDevice != null && trustedDevice.isNotEmpty) {
      request.headers['X-Trusted-Device'] = trustedDevice;
    }
    if (withDeviceInfo) {
      final info = await deviceInfo?.header();
      if (info != null) request.headers['X-Device-Info'] = info;
    }
    if (json != null) request.body = jsonEncode(json);

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(_timeout),
      );
    } on http.ClientException catch (e) {
      throw NetworkUnavailable(e.message);
    } on TimeoutException {
      throw const NetworkUnavailable('The server did not answer in time.');
    }

    final Map<String, dynamic> body;
    try {
      body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw AuthApiException(
        status: response.statusCode,
        title: 'BAD_RESPONSE',
        message: 'Unexpected server answer.',
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final errors =
        (body['errors'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
    final data = body['data'];
    throw AuthApiException(
      status: response.statusCode,
      code: data is Map ? (data['error'] as String? ?? '') : '',
      title: (body['title'] as String?) ?? 'ERROR',
      message: errors.isNotEmpty
          ? errors.join('\n')
          : ((body['description'] as String?) ?? requestFailedMessage),
    );
  }
}
