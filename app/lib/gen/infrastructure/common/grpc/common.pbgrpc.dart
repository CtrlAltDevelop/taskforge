// This is a generated file - do not edit.
//
// Generated from infrastructure/common/grpc/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'common.pb.dart' as $1;

export 'common.pb.dart';

@$pb.GrpcServiceName('config.common.HealthController')
class HealthControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  HealthControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.Health> liveness(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$liveness, request, options: options);
  }

  $grpc.ResponseFuture<$1.Health> readiness(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$readiness, request, options: options);
  }

  // method descriptors

  static final _$liveness = $grpc.ClientMethod<$0.Empty, $1.Health>(
      '/config.common.HealthController/Liveness',
      ($0.Empty value) => value.writeToBuffer(),
      $1.Health.fromBuffer);
  static final _$readiness = $grpc.ClientMethod<$0.Empty, $1.Health>(
      '/config.common.HealthController/Readiness',
      ($0.Empty value) => value.writeToBuffer(),
      $1.Health.fromBuffer);
}

@$pb.GrpcServiceName('config.common.HealthController')
abstract class HealthControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.common.HealthController';

  HealthControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Health>(
        'Liveness',
        liveness_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Health value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Health>(
        'Readiness',
        readiness_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Health value) => value.writeToBuffer()));
  }

  $async.Future<$1.Health> liveness_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return liveness($call, await $request);
  }

  $async.Future<$1.Health> liveness($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.Health> readiness_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return readiness($call, await $request);
  }

  $async.Future<$1.Health> readiness($grpc.ServiceCall call, $0.Empty request);
}
