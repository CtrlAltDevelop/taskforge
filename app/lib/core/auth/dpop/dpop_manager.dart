import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/dpop/dpop_key.dart';
import 'package:taskforge/core/auth/dpop/dpop_key_store.dart';
import 'package:taskforge/core/auth/dpop/dpop_proof.dart';
import 'package:taskforge/core/config.dart';

/// Everything about DPoP the transports share: the key, the proof builder, the server's nonce and
/// this device's clock offset. REST, gRPC and the WebSocket each ask it for a proof; none of them
/// signs anything itself.
class DpopManager {
  DpopManager({
    required DpopKeyStore keys,
    required this.origin,
    this.probe,
    DateTime Function()? now,
  }) : _keys = keys,
       _now = now ?? DateTime.now,
       _builder = DpopProofBuilder(keys, now: now);

  static DpopManager? _shared;

  /// The app's one manager, built on first use from [AppConfig].
  static DpopManager get shared => _shared ??= DpopManager(
    keys: createDpopKeyStore(),
    origin: AppConfig.dpopOrigin,
  );

  /// Replaces the shared manager (tests, and `main` for the platform probe client).
  static set shared(DpopManager manager) => _shared = manager;

  /// The origin proofs are signed for (see `AppConfig.dpopOrigin`).
  final String origin;

  /// A plain client (no proofs) for the one-off GET that learns the nonce and the server's clock.
  final http.Client? probe;

  final DpopKeyStore _keys;
  final DateTime Function() _now;
  final DpopProofBuilder _builder;

  String? _nonce;
  DateTime? _learnedAt;
  Future<void>? _probing;

  static const _nonceLife = Duration(minutes: 4);

  /// The thumbprint of this device's key.
  Future<String> thumbprint() async =>
      jwkThumbprint((await _keys.signer()).publicJwk);

  /// Forgets the key: the next sign-in binds a new one.
  Future<void> forgetKey() => _keys.reset();

  String htu(String path) => '${origin.replaceFirst(RegExp(r'/+$'), '')}$path';

  /// A proof for an HTTP-style call: [path] is the URL path (or the gRPC method path).
  Future<String> proof({
    required String method,
    required String path,
    String? accessToken,
  }) => _builder.build(
    method: method,
    url: htu(path),
    accessToken: accessToken,
    nonce: _nonce,
  );

  /// A proof for the sync socket's `authenticate` frame: `GET` for the socket's own URL.
  Future<String> socketProof(Uri socketUrl, String accessToken) async {
    await ensureFresh();
    final base = Uri.parse(origin);
    final wsScheme = base.scheme == 'https' ? 'wss' : 'ws';
    return _builder.build(
      method: 'GET',
      url: '$wsScheme://${base.authority}${socketUrl.path}',
      accessToken: accessToken,
      nonce: _nonce,
    );
  }

  /// Makes sure the nonce and the clock offset are recent: one cheap GET when they are not, so
  /// a call that cannot be retried (gRPC, a stream) is not the first to find out.
  Future<void> ensureFresh() {
    final client = probe;
    final at = _learnedAt;
    if (client == null) return Future.value();
    if (at != null && _now().difference(at) < _nonceLife) {
      return Future.value();
    }
    return _probing ??= _probe(client).whenComplete(() => _probing = null);
  }

  Future<void> _probe(http.Client client) async {
    try {
      final response = await client
          .get(Uri.parse('${AppConfig.restUrl}/api/version'))
          .timeout(const Duration(seconds: 5));
      learn(response.headers);
      _learnedAt = _now();
    } on Object {
      // Offline or slow: proofs go out as they are; the server's answer teaches the rest.
    }
  }

  /// Takes the nonce and the server's clock from response headers (lowercase keys).
  void learn(Map<String, String> headers) {
    final nonce = headers['dpop-nonce'];
    if (nonce != null && nonce.isNotEmpty) {
      _nonce = nonce;
      _learnedAt = _now();
    }
    final date = parseHttpDate(headers['date']);
    if (date != null) {
      final offset = date.difference(_now());
      // Within a few seconds the difference is only network time: leave the clock alone.
      if (offset.abs() > const Duration(seconds: 5)) {
        _builder.clockOffset = offset;
      } else {
        _builder.clockOffset = Duration.zero;
      }
    }
  }

  /// Takes the nonce and clock from a refused socket or gRPC frame.
  void learnFromFrame(Map<String, dynamic> frame) {
    final nonce = frame['nonce'];
    if (nonce is String && nonce.isNotEmpty) {
      _nonce = nonce;
      _learnedAt = _now();
    }
    final clock = frame['clock'];
    if (clock is int) {
      _builder.clockOffset = DateTime.fromMillisecondsSinceEpoch(
        clock * 1000,
        isUtc: true,
      ).difference(_now());
    }
  }

  /// The current nonce, for tests.
  String? get nonce => _nonce;

  /// The clock offset in use, for tests.
  Duration get clockOffset => _builder.clockOffset;
}

const _months = {
  'Jan': 1,
  'Feb': 2,
  'Mar': 3,
  'Apr': 4,
  'May': 5,
  'Jun': 6,
  'Jul': 7,
  'Aug': 8,
  'Sep': 9,
  'Oct': 10,
  'Nov': 11,
  'Dec': 12,
};

/// Reads an HTTP date (`Sat, 14 Nov 2026 05:15:32 GMT`) without `dart:io`, so it works on web.
DateTime? parseHttpDate(String? value) {
  if (value == null) return null;
  final match = RegExp(r'(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})')
      .firstMatch(value);
  final month = match == null ? null : _months[match.group(2)];
  if (match == null || month == null) return null;
  int part(int i) => int.parse(match.group(i)!);
  return DateTime.utc(part(3), month, part(1), part(4), part(5), part(6));
}
