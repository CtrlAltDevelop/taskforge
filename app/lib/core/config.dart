import 'package:flutter/foundation.dart';

/// Server addresses, overridable per run, e.g.
/// `flutter run --dart-define=REST_URL=http://192.168.1.20:8010` on a real phone.
///
/// The defaults assume the backend runs on the development machine (`make serve`,
/// `make grpc`, `make dev`). An Android emulator reaches that machine at 10.0.2.2,
/// not localhost, so the default host depends on the platform.
class AppConfig {
  const AppConfig._();

  static String get _host =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';

  /// The production web build is served from the same origin as the API, Envoy and the
  /// sockets (`--dart-define=SAME_ORIGIN=true`): one image then works on any domain.
  static const _sameOrigin = bool.fromEnvironment('SAME_ORIGIN');

  static bool get _useOrigin => kIsWeb && _sameOrigin;

  static String get _wsOrigin =>
      Uri.base.origin.replaceFirst(RegExp('^http'), 'ws');

  static String get restUrl =>
      _env('REST_URL', _useOrigin ? Uri.base.origin : 'http://$_host:8010');

  /// Native gRPC (mobile/desktop) talks straight to the gRPC server.
  static String get grpcHost => _env('GRPC_HOST', _host);
  static int get grpcPort =>
      const int.fromEnvironment('GRPC_PORT', defaultValue: 50051);

  /// Browsers cannot speak native gRPC, so web goes through Envoy (gRPC-Web).
  static String get grpcWebUrl =>
      _env('GRPC_WEB_URL', _useOrigin ? Uri.base.origin : 'http://$_host:8081');

  static String get wsUrl => _env(
    'WS_URL',
    _useOrigin ? '$_wsOrigin/ws/ping/' : 'ws://$_host:8010/ws/ping/',
  );

  /// The live-sync socket (see `core/sync`).
  static String get syncUrl => _env(
    'SYNC_WS_URL',
    _useOrigin ? '$_wsOrigin/ws/sync' : 'ws://$_host:8010/ws/sync',
  );

  /// Public address of the web app, used to build shareable invite links.
  static String get webUrl =>
      _env('WEB_URL', kIsWeb ? Uri.base.origin : 'http://localhost:5173');

  static String inviteUrl(String token) => '$webUrl/invite/$token';

  static String _env(String key, String fallback) {
    // `fromEnvironment` only accepts a literal key, so each name is read here.
    final value = switch (key) {
      'REST_URL' => const String.fromEnvironment('REST_URL'),
      'GRPC_HOST' => const String.fromEnvironment('GRPC_HOST'),
      'GRPC_WEB_URL' => const String.fromEnvironment('GRPC_WEB_URL'),
      'WEB_URL' => const String.fromEnvironment('WEB_URL'),
      'WS_URL' => const String.fromEnvironment('WS_URL'),
      'SYNC_WS_URL' => const String.fromEnvironment('SYNC_WS_URL'),
      _ => '',
    };
    return value.isEmpty ? fallback : value;
  }
}
