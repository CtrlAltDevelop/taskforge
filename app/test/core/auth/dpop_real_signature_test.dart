// A proof made through dpop_client's DPoPSignerClient, signed by the app's real (pointycastle)
// device signer, verifies against the public JWK in its own header: the check a server makes.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dpop_client/dpop_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:taskforge/core/auth/dpop/dpop_key_store_native.dart';

class _MemoryStorage implements FlutterSecureStorage {
  final _data = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    _data[key] = value!;
  }

  @override
  Future<void> delete({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BigInt _int(String b64) => BigInt.parse(
  base64Url
      .decode(base64Url.normalize(b64))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(),
  radix: 16,
);

void main() {
  test(
    'a proof from the real signer verifies against its header jwk',
    () async {
      final signer = await NativeDpopKeyStore(_MemoryStorage()).signer();
      final proof = await DPoPSignerClient(signer).createProof(
        url: Uri.parse('wss://api.example.com:443/ws/sync?x=1'),
        method: 'get',
        accessToken: 'token',
        nonce: 'n1',
      );

      final parts = proof.token.split('.');
      final header = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
      ) as Map<String, dynamic>;
      final jwk = header['jwk'] as Map<String, dynamic>;
      final curve = ECCurve_secp256r1();
      final pub = ECPublicKey(
        curve.curve.createPoint(
          _int(jwk['x'] as String),
          _int(jwk['y'] as String),
        ),
        curve,
      );
      final sig = base64Url.decode(base64Url.normalize(parts[2]));
      expect(sig.length, 64);
      final verifier = ECDSASigner(SHA256Digest())
        ..init(false, PublicKeyParameter<ECPublicKey>(pub));
      final ok = verifier.verifySignature(
        Uint8List.fromList(utf8.encode('${parts[0]}.${parts[1]}')),
        ECSignature(
          _int(base64Url.encode(sig.sublist(0, 32))),
          _int(base64Url.encode(sig.sublist(32))),
        ),
      );
      expect(ok, isTrue);
      expect(jwk.keys.toSet(), {'kty', 'crv', 'x', 'y'});
      expect(
        proof.thumbprint,
        dpopThumbprint({for (final e in jwk.entries) e.key: e.value as String}),
      );
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      expect(claims['htu'], 'wss://api.example.com/ws/sync');
      expect(claims['htm'], 'GET');
    },
  );
}
