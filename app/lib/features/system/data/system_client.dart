import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/gen/infrastructure/system/grpc/system.pbgrpc.dart'
    as pb;

/// Reads the server's version (public REST, no sign-in needed: a too-old app must be able to
/// learn it is too old) and, for administrators, the System page (gRPC).
abstract interface class SystemClient {
  Future<ServerVersion> serverVersion();
  Future<SystemInfo> info();

  /// Admin only: turns device-info collection on or off; returns the refreshed page data.
  Future<SystemInfo> setCollectDeviceInfo({required bool enabled});
}

class GrpcSystemClient implements SystemClient {
  GrpcSystemClient(
    ClientChannelBase channel,
    this._session,
    this._restUrl, {
    http.Client? httpClient,
  }) : _system = pb.SystemControllerClient(channel),
       _http = httpClient ?? http.Client();

  final pb.SystemControllerClient _system;
  final AuthSession _session;
  final String _restUrl;
  final http.Client _http;

  late final _options = scopedCallOptions(_session, () => null);

  @override
  Future<ServerVersion> serverVersion() async {
    try {
      final response = await _http
          .get(Uri.parse('$_restUrl/api/version'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw const SystemException(SystemFailure.other);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ServerVersion(
        version: json['version'] as String? ?? '',
        minClientVersion: json['min_client_version'] as String? ?? '0.0.0',
        commit: json['commit'] as String? ?? '',
      );
    } on SystemException {
      rethrow;
    } on Object {
      throw const SystemException(SystemFailure.network);
    }
  }

  @override
  Future<SystemInfo> info() =>
      _read(() => _call(() => _system.info(Empty(), options: _options)));

  @override
  Future<SystemInfo> setCollectDeviceInfo({required bool enabled}) => _read(
    () => _call(
      () => _system.setCollectDeviceInfo(
        pb.SetCollectDeviceInfoRequest(enabled: enabled),
        options: _options,
      ),
    ),
  );

  Future<SystemInfo> _read(Future<pb.SystemInfo> Function() call) async {
    try {
      final r = await call();
      return SystemInfo(
        version: r.version,
        minClientVersion: r.minClientVersion,
        api: r.api,
        commit: r.commit,
        redis: r.redis,
        broker: r.broker,
        eager: r.eager,
        workers: r.workers,
        backlog: Map.unmodifiable(r.backlog),
        collectDeviceInfo: r.collectDeviceInfo,
        devicePepperSet: r.devicePepperSet,
      );
    } on GrpcError catch (e) {
      throw SystemException(switch (e.code) {
        StatusCode.permissionDenied => SystemFailure.denied,
        StatusCode.alreadyExists => SystemFailure.pepperMissing,
        StatusCode.unavailable ||
        StatusCode.deadlineExceeded => SystemFailure.network,
        _ => SystemFailure.other,
      });
    }
  }

  Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      if (e.code != StatusCode.unauthenticated) rethrow;
      if (await _session.forceRefresh() == null) rethrow;
      return call();
    }
  }
}
