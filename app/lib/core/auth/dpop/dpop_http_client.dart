import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/dpop/dpop_manager.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/public_routes.dart';

/// Adds a DPoP proof to every request this app makes to its own API, and sends the access token
/// under the `DPoP` scheme. Wrapped around `http.Client()` once (see `main`), so every REST
/// client gets it and none has to know. The public routes (health, public forms, docs) and any
/// other host stay as they were.
///
/// A 401 that asks for a nonce, or that says the proof's clock is off, is retried once with what
/// the answer taught (the nonce, the server's `Date`).
class DpopHttpClient extends http.BaseClient {
  DpopHttpClient(this._inner, this._dpop);

  final http.Client _inner;
  final DpopManager _dpop;

  bool _isApi(Uri url) {
    final api = Uri.parse(AppConfig.restUrl);
    return url.scheme == api.scheme &&
        url.host == api.host &&
        url.port == api.port &&
        dpopApplies(url.path);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_isApi(request.url)) return _inner.send(request);
    final token = _bearerOf(request);
    if (request is! http.Request) return _attempt(request, token);
    final first = await _attempt(_copy(request), token);
    if (!_shouldRetry(first)) return first;
    await first.stream.drain<void>();
    return _attempt(_copy(request), token);
  }

  Future<http.StreamedResponse> _attempt(
    http.BaseRequest request,
    String? token,
  ) async {
    await _dpop.ensureFresh();
    request.headers['DPoP'] = await _dpop.proof(
      method: request.method,
      path: request.url.path,
      accessToken: token,
    );
    if (token != null) request.headers['Authorization'] = 'DPoP $token';
    final response = await _inner.send(request);
    _dpop.learn(response.headers);
    return response;
  }

  bool _shouldRetry(http.StreamedResponse response) {
    if (response.statusCode != 401) return false;
    final challenge = response.headers['www-authenticate'] ?? '';
    if (!challenge.startsWith('DPoP')) return false;
    // A nonce was demanded (and is now known), or the proof's `iat` was refused and the clock
    // offset has just been corrected from the `Date` header.
    return challenge.contains('use_dpop_nonce') ||
        (challenge.contains('invalid_dpop_proof') &&
            _dpop.clockOffset != Duration.zero);
  }

  String? _bearerOf(http.BaseRequest request) {
    final header = request.headers['Authorization'];
    if (header == null) return null;
    final space = header.indexOf(' ');
    if (space < 0) return null;
    final scheme = header.substring(0, space).toLowerCase();
    return (scheme == 'bearer' || scheme == 'dpop')
        ? header.substring(space + 1)
        : null;
  }

  http.Request _copy(http.Request original) =>
      http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..bodyBytes = original.bodyBytes
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;

  @override
  void close() => _inner.close();
}
