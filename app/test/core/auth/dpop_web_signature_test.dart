@TestOn('browser')
library;

// The browser's non-extractable WebCrypto key signs a proof built by dpop_client, and the proof
// verifies against the public JWK in its header. Run: flutter test --platform chrome <this file>.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dpop_client/dpop_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:taskforge/core/auth/dpop/dpop_key_store_web.dart';

BigInt _int(List<int> bytes) => BigInt.parse(
  bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
  radix: 16,
);

List<int> _b64(String v) => base64Url.decode(base64Url.normalize(v));

void main() {
  test('a WebCrypto signed proof verifies against its header jwk', () async {
    final store = WebDpopKeyStore();
    await store.reset();
    final signer = await store.signer();
    final proof = await DPoPSignerClient(signer).createProof(
      url: Uri.parse('https://api.example.com/api/v1/x?q=1'),
      method: 'POST',
      accessToken: 'token',
    );
    final parts = proof.token.split('.');
    final jwk =
        (jsonDecode(utf8.decode(_b64(parts[0]))) as Map<String, dynamic>)['jwk']
            as Map<String, dynamic>;
    final curve = ECCurve_secp256r1();
    final pub = ECPublicKey(
      curve.curve.createPoint(
        _int(_b64(jwk['x'] as String)),
        _int(_b64(jwk['y'] as String)),
      ),
      curve,
    );
    final sig = _b64(parts[2]);
    expect(sig.length, 64);
    final verifier = ECDSASigner(SHA256Digest())
      ..init(false, PublicKeyParameter<ECPublicKey>(pub));
    expect(
      verifier.verifySignature(
        Uint8List.fromList(utf8.encode('${parts[0]}.${parts[1]}')),
        ECSignature(_int(sig.sublist(0, 32)), _int(sig.sublist(32))),
      ),
      isTrue,
    );
    await store.reset();
  });
}
