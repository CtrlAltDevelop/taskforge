import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/dpop/dpop_key.dart';
import 'package:taskforge/core/auth/dpop/dpop_proof.dart';

class _FakeSigner implements DpopSigner {
  Uint8List? signed;

  @override
  Map<String, String> get publicJwk => {
    'kty': 'EC',
    'crv': 'P-256',
    'x': 'l8tFrhx-34tV3hRICRDY9zCkDlpBhF42UQUfWVAWBFs',
    'y': '9VE4jf_Ok_o64zbTTlcuNJajHmt6v9TDVrU0CdvGRDA',
  };

  @override
  Future<Uint8List> sign(Uint8List message) async {
    signed = message;
    return Uint8List.fromList(List.filled(64, 7));
  }
}

class _FakeKeys implements DpopKeyStore {
  _FakeKeys(this.signerValue);
  final DpopSigner signerValue;

  @override
  Future<DpopSigner> signer() async => signerValue;

  @override
  Future<void> reset() async {}
}

Map<String, dynamic> _part(String jwt, int index) {
  final raw = jwt.split('.')[index];
  return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(raw))))
      as Map<String, dynamic>;
}

void main() {
  // RFC 9449 section 7.1 example token and its ath.
  const rfcToken = 'Kz~8mXK1EalYznwH-LC-1fBAo.4Ljp~zsPE_NeO.gxU';
  const rfcAth = 'fUHyO2r2Z3DZ53EsNrWBb0xWXoaNy59IiKCAqksmQEo';

  test('jwkThumbprint is 43 base64url characters without padding', () {
    final t = jwkThumbprint(_FakeSigner().publicJwk);
    expect(t.length, 43);
    expect(t.contains('='), isFalse);
  });

  group('DpopProofBuilder', () {
    late _FakeSigner signer;
    late DpopProofBuilder builder;

    setUp(() {
      signer = _FakeSigner();
      builder = DpopProofBuilder(
        _FakeKeys(signer),
        now: () =>
            DateTime.fromMillisecondsSinceEpoch(1562262616000, isUtc: true),
      );
    });

    test('header is dpop+jwt ES256 with the public jwk only', () async {
      final jwt = await builder.build(method: 'POST', url: 'https://x.test/a');
      final header = _part(jwt, 0);
      expect(header['typ'], 'dpop+jwt');
      expect(header['alg'], 'ES256');
      final jwk = header['jwk'] as Map<String, dynamic>;
      expect(jwk.keys.toSet(), {'kty', 'crv', 'x', 'y'});
      expect(jwk.containsKey('d'), isFalse);
    });

    test('claims carry htm, htu without query, iat, jti, ath', () async {
      final jwt = await builder.build(
        method: 'GET',
        url: 'https://server.example.com/resource?x=1',
        accessToken: rfcToken,
        jti: 'fixed',
      );
      final claims = _part(jwt, 1);
      expect(claims['htm'], 'GET');
      expect(claims['htu'], 'https://server.example.com/resource');
      expect(claims['iat'], 1562262616);
      expect(claims['jti'], 'fixed');
      expect(claims['ath'], rfcAth);
      expect(claims.containsKey('nonce'), isFalse);
    });

    test('no token means no ath; nonce only when non-empty', () async {
      final plain = _part(
        await builder.build(method: 'POST', url: 'https://x.test/a', nonce: ''),
        1,
      );
      expect(plain.containsKey('ath'), isFalse);
      expect(plain.containsKey('nonce'), isFalse);
      final withNonce = _part(
        await builder.build(
          method: 'POST',
          url: 'https://x.test/a',
          nonce: 'n1',
        ),
        1,
      );
      expect(withNonce['nonce'], 'n1');
    });

    test('clockOffset shifts iat and jti is unique per proof', () async {
      builder.clockOffset = const Duration(seconds: 90);
      final a = _part(
        await builder.build(method: 'GET', url: 'https://x.test/a'),
        1,
      );
      final b = _part(
        await builder.build(method: 'GET', url: 'https://x.test/a'),
        1,
      );
      expect(a['iat'], 1562262706);
      expect(a['jti'], isNot(b['jti']));
    });

    test(
      'signs header.payload and appends the raw 64-byte signature',
      () async {
        final jwt = await builder.build(method: 'GET', url: 'https://x.test/a');
        final parts = jwt.split('.');
        expect(parts, hasLength(3));
        expect(utf8.decode(signer.signed!), '${parts[0]}.${parts[1]}');
        expect(base64Url.decode(base64Url.normalize(parts[2])), hasLength(64));
        expect(jwt.contains('='), isFalse);
      },
    );
  });
}
