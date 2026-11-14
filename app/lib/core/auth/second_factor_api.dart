import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/device_info.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_tokens.dart';
import 'package:taskforge/core/auth/http_client.dart';

/// Tokens from a finished sign-in, and the device token when the person asked
/// to skip the code on this device for a while.
class SignInResult {
  const SignInResult(this.tokens, {this.trustedDeviceToken = ''});

  final AuthTokens tokens;
  final String trustedDeviceToken;
}

/// The two sign-in steps that come after the first factor: the second-factor
/// code and the single-sign-on ticket. Neither has a bearer token yet.
abstract interface class SecondFactorApi {
  Future<SignInResult> verify({
    required String loginTicket,
    required String code,
    bool recovery = false,
    bool rememberDevice = false,
    String deviceLabel = '',
  });

  /// Trades the one-time [ticket] (and the PKCE [verifier] only this app
  /// holds) for the usual credentials.
  Future<SignInResult> ssoExchange({
    required String ticket,
    required String verifier,
  });

  /// Where to send the browser to sign in through a workspace's provider.
  Uri ssoStartUri({
    required String workspaceSlug,
    required String returnTo,
    required String codeChallenge,
  });
}

/// A PKCE pair for one SSO attempt: keep [verifier], send [challenge].
class SsoPkce {
  SsoPkce._(this.verifier, this.challenge);

  factory SsoPkce.generate([Random? random]) {
    final r = random ?? Random.secure();
    final verifier = base64Url
        .encode([for (var i = 0; i < 48; i++) r.nextInt(256)])
        .replaceAll('=', '');
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    return SsoPkce._(verifier, challenge);
  }

  final String verifier;
  final String challenge;
}

class HttpSecondFactorApi implements SecondFactorApi {
  HttpSecondFactorApi(
    this.baseUrl, {
    http.Client? client,
    this.cookieMode = false,
    this.deviceInfo,
  }) : _client =
           client ?? (cookieMode ? createAuthHttpClient() : http.Client());

  final String baseUrl;
  final bool cookieMode;

  /// Phase 40: these two steps complete a sign-in, so they carry the same header as one.
  final DeviceInfoSource? deviceInfo;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  @override
  Future<SignInResult> verify({
    required String loginTicket,
    required String code,
    bool recovery = false,
    bool rememberDevice = false,
    String deviceLabel = '',
  }) async {
    final data = await _post('/api/v1/auth/2fa/verify', {
      'login_ticket': loginTicket,
      'code': code,
      'method': recovery ? 'recovery' : 'totp',
      'remember_device': rememberDevice,
      'device_label': deviceLabel,
    });
    return _result(data);
  }

  @override
  Future<SignInResult> ssoExchange({
    required String ticket,
    required String verifier,
  }) async => _result(
    await _post('/api/v1/auth/sso/exchange', {
      'ticket': ticket,
      'code_verifier': verifier,
    }),
  );

  @override
  Uri ssoStartUri({
    required String workspaceSlug,
    required String returnTo,
    required String codeChallenge,
  }) =>
      Uri.parse(
        '$baseUrl/api/v1/auth/sso/${Uri.encodeComponent(workspaceSlug)}/start',
      ).replace(
        queryParameters: {
          'return_to': returnTo,
          'code_challenge': codeChallenge,
        },
      );

  SignInResult _result(Map<String, dynamic> data) {
    final credentials = data['credentials'] as Map<String, dynamic>?;
    if (credentials == null) {
      throw const AuthApiException(
        status: 400,
        title: 'BAD_RESPONSE',
        message: 'Unexpected server answer.',
      );
    }
    return SignInResult(
      AuthTokens(
        accessToken: credentials['access_token'] as String,
        refreshToken: credentials['refresh_token'] as String,
        sessionId: credentials['session_id'] as String,
      ),
      trustedDeviceToken: (data['trusted_device_token'] as String?) ?? '',
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> json,
  ) async {
    final request = http.Request('POST', Uri.parse('$baseUrl$path'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json'
      ..body = jsonEncode(json);
    if (cookieMode) request.headers['X-Refresh-Transport'] = 'cookie';
    final info = await deviceInfo?.header();
    if (info != null) request.headers['X-Device-Info'] = info;
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'] as Map<String, dynamic>;
    }
    final errors =
        (body['errors'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
    throw AuthApiException(
      status: response.statusCode,
      title: (body['title'] as String?) ?? 'ERROR',
      message: errors.isNotEmpty
          ? errors.join('\n')
          : ((body['description'] as String?) ?? requestFailedMessage),
    );
  }
}
