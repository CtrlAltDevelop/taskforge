import 'dart:convert';

import 'package:dpop_client/dpop_client.dart';

/// The device's signing key. Nothing outside a signer ever holds the private half: on web it is a
/// non-extractable WebCrypto key, on native it stays in the platform keystore's storage.
/// The interface is `dpop_client`'s [DPoPSigner]: the public JWK and an ES256 `r || s` signature.
typedef DpopSigner = DPoPSigner;

/// Where the key lives between launches. Creation is lazy and silent: the first call makes the
/// pair, every later one (and every later launch) finds it.
abstract interface class DpopKeyStore {
  Future<DpopSigner> signer();

  /// Forgets the key (a new one is made on the next call).
  Future<void> reset();
}

String base64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// The `jkt` of a public JWK (RFC 7638).
String jwkThumbprint(Map<String, String> jwk) => dpopThumbprint(jwk);
