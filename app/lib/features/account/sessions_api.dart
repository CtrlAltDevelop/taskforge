import 'package:safe_json_cast/safe_json_cast.dart';

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/features/account/account_client.dart';

/// The signed-in account's sessions, over REST.
abstract interface class SessionsApi {
  Future<List<SessionInfo>> list();

  /// Returns the name the server saved (trimmed).
  Future<String> rename(String sessionId, String name);
}

class HttpSessionsApi implements SessionsApi {
  HttpSessionsApi(this.baseUrl, this._session, {http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final AuthSession _session;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  @override
  Future<List<SessionInfo>> list() async {
    final body = await _send('GET', '/api/v1/auth/token/sessions');
    final data = body.asMap('data');
    return [
      for (final item in (data['sessions'] as List? ?? const []))
        SessionInfo.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<String> rename(String sessionId, String name) async {
    final body = await _send(
      'PATCH',
      '/api/v1/auth/token/sessions/$sessionId',
      json: {'name': name},
    );
    return body.asMap('data').asString('name');
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? json,
  }) async {
    final token = await _session.accessToken();
    if (token == null) {
      throw const AuthApiException(
        status: 401,
        title: 'NOT_SIGNED_IN',
        message: 'Sign in again.',
      );
    }
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token';
    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    }
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
    Map<String, dynamic> body = const {};
    try {
      body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      // fall through to the status check
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    throw AuthApiException(
      status: response.statusCode,
      title: (body['title'] as String?) ?? 'ERROR',
      message: 'Request failed.',
    );
  }
}
