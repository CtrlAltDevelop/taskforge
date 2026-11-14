import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The device's signing key. Nothing outside a signer ever holds the private half: on web it is a
/// non-extractable WebCrypto key, on native it stays in the platform keystore's storage.
abstract interface class DpopSigner {
  /// The public key as a JWK: `kty`, `crv`, `x`, `y` (what goes into every proof's header).
  Map<String, String> get publicJwk;

  /// ES256 signature of [message]: the raw 64-byte `r || s` that a JWS carries.
  Future<Uint8List> sign(Uint8List message);
}

/// Where the key lives between launches. Creation is lazy and silent: the first call makes the
/// pair, every later one (and every later launch) finds it.
abstract interface class DpopKeyStore {
  Future<DpopSigner> signer();

  /// Forgets the key (a new one is made on the next call).
  Future<void> reset();
}

String base64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// The RFC 7638 thumbprint of an EC public JWK: base64url SHA-256 of its canonical form.
String jwkThumbprint(Map<String, String> jwk) {
  final canonical = jsonEncode({
    'crv': jwk['crv'],
    'kty': jwk['kty'],
    'x': jwk['x'],
    'y': jwk['y'],
  });
  return base64UrlNoPad(sha256.convert(utf8.encode(canonical)).bytes);
}
