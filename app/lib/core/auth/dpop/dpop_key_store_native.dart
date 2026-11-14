import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

import 'package:taskforge/core/auth/dpop/dpop_key.dart';
import 'package:taskforge/core/auth/secure_storage.dart';

DpopKeyStore createDpopKeyStore() => NativeDpopKeyStore();

/// Mobile and desktop: a P-256 keypair made on first use and kept in the platform keystore
/// through `flutter_secure_storage` (Keychain, Android Keystore-wrapped storage, the OS secret
/// store). Signing is done by pointycastle; nothing here implements the curve or ECDSA.
class NativeDpopKeyStore implements DpopKeyStore {
  NativeDpopKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? appSecureStorage();

  static const _entry = 'dpop.key.v1';

  final FlutterSecureStorage _storage;
  Future<DpopSigner>? _loading;

  @override
  Future<DpopSigner> signer() => _loading ??= _loadOrCreate();

  @override
  Future<void> reset() async {
    _loading = null;
    await _storage.delete(key: _entry);
  }

  Future<DpopSigner> _loadOrCreate() async {
    final stored = await _storage.read(key: _entry);
    if (stored != null) {
      final signer = _parse(stored);
      if (signer != null) return signer;
    }
    final signer = _generate();
    await _storage.write(key: _entry, value: signer.serialise());
    return signer;
  }

  _PointySigner? _parse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _PointySigner(
        d: _bigInt(json['d'] as String),
        x: json['x'] as String,
        y: json['y'] as String,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  _PointySigner _generate() {
    final generator = ECKeyGenerator()
      ..init(
        ParametersWithRandom(
          ECKeyGeneratorParameters(ECCurve_secp256r1()),
          _secureRandom(),
        ),
      );
    final pair = generator.generateKeyPair();
    final private = pair.privateKey;
    final point = pair.publicKey.Q!;
    return _PointySigner(
      d: private.d!,
      x: base64UrlNoPad(_fixed(point.x!.toBigInteger()!)),
      y: base64UrlNoPad(_fixed(point.y!.toBigInteger()!)),
    );
  }
}

SecureRandom _secureRandom() {
  final random = Random.secure();
  return FortunaRandom()..seed(
    KeyParameter(
      Uint8List.fromList([for (var i = 0; i < 32; i++) random.nextInt(256)]),
    ),
  );
}

class _PointySigner implements DpopSigner {
  _PointySigner({required this.d, required String x, required String y})
    : publicJwk = {'kty': 'EC', 'crv': 'P-256', 'x': x, 'y': y};

  final BigInt d;

  @override
  final Map<String, String> publicJwk;

  String serialise() => jsonEncode({
    'd': base64UrlNoPad(_fixed(d)),
    'x': publicJwk['x'],
    'y': publicJwk['y'],
  });

  @override
  Future<Uint8List> sign(Uint8List message) async {
    final signer = ECDSASigner(SHA256Digest())
      ..init(
        true,
        ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(
            ECPrivateKey(d, ECCurve_secp256r1()),
          ),
          _secureRandom(),
        ),
      );
    final signature = signer.generateSignature(message) as ECSignature;
    return Uint8List.fromList([..._fixed(signature.r), ..._fixed(signature.s)]);
  }
}

/// [value] as exactly 32 big-endian bytes (a P-256 coordinate, scalar or signature half).
Uint8List _fixed(BigInt value) {
  final bytes = Uint8List(32);
  var rest = value;
  for (var i = 31; i >= 0; i--) {
    bytes[i] = (rest & BigInt.from(0xff)).toInt();
    rest >>= 8;
  }
  return bytes;
}

BigInt _bigInt(String base64UrlValue) {
  final bytes = base64Url.decode(base64Url.normalize(base64UrlValue));
  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }
  return value;
}
