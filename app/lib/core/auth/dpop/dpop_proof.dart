import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:taskforge/core/auth/dpop/dpop_key.dart';

/// Builds DPoP proofs (RFC 9449): a small JWT, signed by the device key, saying which method and
/// URL it is for, when, a unique id, and (on resource calls) a hash of the access token. The
/// signature comes from the [DpopKeyStore]'s signer; this class only assembles the JWS.
class DpopProofBuilder {
  DpopProofBuilder(this._keys, {DateTime Function()? now, Random? random})
    : _now = now ?? DateTime.now,
      _random = random ?? Random.secure();

  final DpopKeyStore _keys;
  final DateTime Function() _now;
  final Random _random;

  /// Server time minus this device's time, learned from a `Date` header after a refused `iat`.
  Duration clockOffset = Duration.zero;

  /// A proof for [method] and [url] (query and fragment are dropped, as the spec says).
  /// [accessToken] adds `ath`; [nonce] adds the server's nonce when it asked for one.
  Future<String> build({
    required String method,
    required String url,
    String? accessToken,
    String? nonce,
    String? jti,
  }) async {
    final signer = await _keys.signer();
    final issuedAt =
        _now().add(clockOffset).millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond;
    final header = {'typ': 'dpop+jwt', 'alg': 'ES256', 'jwk': signer.publicJwk};
    final claims = <String, Object>{
      'jti': jti ?? _newId(),
      'htm': method,
      'htu': htuOf(url),
      'iat': issuedAt,
      'ath': ?(accessToken == null ? null : accessTokenHash(accessToken)),
      'nonce': ?((nonce == null || nonce.isEmpty) ? null : nonce),
    };
    final signingInput = '${_segment(header)}.${_segment(claims)}';
    final signature = await signer.sign(
      Uint8List.fromList(utf8.encode(signingInput)),
    );
    return '$signingInput.${base64UrlNoPad(signature)}';
  }

  String _newId() =>
      base64UrlNoPad([for (var i = 0; i < 18; i++) _random.nextInt(256)]);

  static String _segment(Object json) =>
      base64UrlNoPad(utf8.encode(jsonEncode(json)));
}

/// The `htu` claim for [url]: scheme, authority and path only.
String htuOf(String url) {
  final uri = Uri.parse(url);
  return '${uri.scheme}://${uri.authority}${uri.path}';
}

/// The `ath` claim: base64url SHA-256 of the exact access token.
String accessTokenHash(String token) =>
    base64UrlNoPad(sha256.convert(utf8.encode(token)).bytes);
