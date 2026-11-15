import 'package:dpop_client/dpop_client.dart';

import 'package:taskforge/core/auth/dpop/dpop_key.dart';

/// Builds DPoP proofs (RFC 9449) with the device key. The claims and the JWS come from
/// `dpop_client`; the signature comes from the [DpopKeyStore]'s signer, so the private key is
/// never read. This class only adds the server clock offset to `iat`.
class DpopProofBuilder {
  DpopProofBuilder(this._keys, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DpopKeyStore _keys;
  final DateTime Function() _now;

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
    final client = DPoPSignerClient(await _keys.signer());
    final proof = await client.createProof(
      url: Uri.parse(url),
      method: method,
      accessToken: accessToken,
      nonce: nonce,
      issuedAt: _now().add(clockOffset),
      jwtId: jti,
    );
    return proof.token;
  }
}
