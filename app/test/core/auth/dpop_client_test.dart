import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/dpop/dpop_http_client.dart';
import 'package:taskforge/core/auth/dpop/dpop_key.dart';
import 'package:taskforge/core/auth/dpop/dpop_manager.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

class _Signer implements DpopSigner {
  @override
  Map<String, String> get publicJwk => {
    'kty': 'EC',
    'crv': 'P-256',
    'x': 'l8tFrhx-34tV3hRICRDY9zCkDlpBhF42UQUfWVAWBFs',
    'y': '9VE4jf_Ok_o64zbTTlcuNJajHmt6v9TDVrU0CdvGRDA',
  };

  @override
  Future<Uint8List> sign(Uint8List message) async =>
      Uint8List.fromList(List.filled(64, 7));
}

class _Keys implements DpopKeyStore {
  @override
  Future<DpopSigner> signer() async => _Signer();

  @override
  Future<void> reset() async {}
}

Map<String, dynamic> _claims(String jwt) {
  final raw = jwt.split('.')[1];
  return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(raw))))
      as Map<String, dynamic>;
}

final _now = DateTime.utc(2026, 11, 14, 10);

/// A client whose server answers [replies] in turn (the last one repeats) and
/// records the DPoP proof of every request it receives.
({DpopHttpClient client, DpopManager manager, List<String> proofs}) _rig(
  List<http.Response> replies,
) {
  final proofs = <String>[];
  var n = 0;
  final inner = MockClient((request) async {
    proofs.add(request.headers['DPoP'] ?? '');
    return replies[n++ < replies.length ? n - 1 : replies.length - 1];
  });
  final manager = DpopManager(
    keys: _Keys(),
    origin: 'http://x',
    now: () => _now,
  );
  return (
    client: DpopHttpClient(inner, manager),
    manager: manager,
    proofs: proofs,
  );
}

Uri get _url => Uri.parse('${AppConfig.restUrl}/api/v1/tasks');

http.Response _challenge(String error, Map<String, String> extra) =>
    http.Response(
      '{}',
      401,
      headers: {'www-authenticate': 'DPoP error="$error"', ...extra},
    );

void main() {
  test('a nonce demand is retried once with the nonce it taught', () async {
    final rig = _rig([
      _challenge('use_dpop_nonce', {'dpop-nonce': 'n-1'}),
      http.Response('{}', 200),
    ]);

    final response = await rig.client.get(
      _url,
      headers: {'Authorization': 'DPoP tok'},
    );

    expect(response.statusCode, 200);
    expect(rig.proofs, hasLength(2));
    expect(_claims(rig.proofs[0]).containsKey('nonce'), isFalse);
    expect(_claims(rig.proofs[1])['nonce'], 'n-1');
  });

  test('a second nonce demand is not retried again', () async {
    final rig = _rig([
      _challenge('use_dpop_nonce', {'dpop-nonce': 'n-1'}),
    ]);

    final response = await rig.client.get(_url);

    expect(response.statusCode, 401);
    expect(rig.proofs, hasLength(2));
  });

  test('a refused clock is corrected from Date and retried once', () async {
    final server = _now.add(const Duration(hours: 1));
    final rig = _rig([
      _challenge('invalid_dpop_proof', {
        'date': 'Sat, 14 Nov 2026 11:00:00 GMT',
      }),
      http.Response('{}', 200),
    ]);

    final response = await rig.client.get(_url);

    expect(response.statusCode, 200);
    expect(rig.proofs, hasLength(2));
    expect(rig.manager.clockOffset, server.difference(_now));
    expect(_claims(rig.proofs[0])['iat'], _now.millisecondsSinceEpoch ~/ 1000);
    expect(
      _claims(rig.proofs[1])['iat'],
      server.millisecondsSinceEpoch ~/ 1000,
    );
  });

  test('a refused proof with an unchanged clock is not retried', () async {
    final rig = _rig([_challenge('invalid_dpop_proof', {})]);

    final response = await rig.client.get(_url);

    expect(response.statusCode, 401);
    expect(rig.proofs, hasLength(1));
  });

  test('a lost key tells the user to sign in again', () {
    const lost = AuthApiException(
      status: 401,
      title: 'UNAUTHORIZED',
      message: 'Invalid token.',
      code: 'invalid_token',
    );
    final en = lookupAppLocalizations(const Locale('en'));

    expect(lost.keyChanged, isTrue);
    expect(authErrorMessage(lost, en), en.dpopKeyChanged);
    expect(en.dpopKeyChanged, contains('sign in again'));
  });
}
