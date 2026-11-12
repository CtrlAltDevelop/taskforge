// This is a generated file - do not edit.
//
// Generated from infrastructure/audit/grpc/audit.proto.

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

import 'audit.pb.dart' as $0;

export 'audit.pb.dart';

@$pb.GrpcServiceName('config.audit.ActivityController')
class ActivityControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ActivityControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.AuditPage> forTask(
    $0.ActivityForTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forTask, request, options: options);
  }

  // method descriptors

  static final _$forTask =
      $grpc.ClientMethod<$0.ActivityForTaskRequest, $0.AuditPage>(
          '/config.audit.ActivityController/ForTask',
          ($0.ActivityForTaskRequest value) => value.writeToBuffer(),
          $0.AuditPage.fromBuffer);
}

@$pb.GrpcServiceName('config.audit.ActivityController')
abstract class ActivityControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.audit.ActivityController';

  ActivityControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ActivityForTaskRequest, $0.AuditPage>(
        'ForTask',
        forTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ActivityForTaskRequest.fromBuffer(value),
        ($0.AuditPage value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuditPage> forTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ActivityForTaskRequest> $request) async {
    return forTask($call, await $request);
  }

  $async.Future<$0.AuditPage> forTask(
      $grpc.ServiceCall call, $0.ActivityForTaskRequest request);
}

@$pb.GrpcServiceName('config.audit.AuditController')
class AuditControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuditControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.AuditExportChunk> export(
    $0.AuditExportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$export, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.AuditPage> list(
    $0.AuditListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  // method descriptors

  static final _$export =
      $grpc.ClientMethod<$0.AuditExportRequest, $0.AuditExportChunk>(
          '/config.audit.AuditController/Export',
          ($0.AuditExportRequest value) => value.writeToBuffer(),
          $0.AuditExportChunk.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.AuditListRequest, $0.AuditPage>(
      '/config.audit.AuditController/List',
      ($0.AuditListRequest value) => value.writeToBuffer(),
      $0.AuditPage.fromBuffer);
}

@$pb.GrpcServiceName('config.audit.AuditController')
abstract class AuditControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.audit.AuditController';

  AuditControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuditExportRequest, $0.AuditExportChunk>(
        'Export',
        export_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.AuditExportRequest.fromBuffer(value),
        ($0.AuditExportChunk value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AuditListRequest, $0.AuditPage>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuditListRequest.fromBuffer(value),
        ($0.AuditPage value) => value.writeToBuffer()));
  }

  $async.Stream<$0.AuditExportChunk> export_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AuditExportRequest> $request) async* {
    yield* export($call, await $request);
  }

  $async.Stream<$0.AuditExportChunk> export(
      $grpc.ServiceCall call, $0.AuditExportRequest request);

  $async.Future<$0.AuditPage> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AuditListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.AuditPage> list(
      $grpc.ServiceCall call, $0.AuditListRequest request);
}
