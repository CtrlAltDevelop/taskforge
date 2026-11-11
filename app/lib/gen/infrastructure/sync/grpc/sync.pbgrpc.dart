// This is a generated file - do not edit.
//
// Generated from infrastructure/sync/grpc/sync.proto.

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

import 'sync.pb.dart' as $0;

export 'sync.pb.dart';

@$pb.GrpcServiceName('config.sync.SyncController')
class SyncControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SyncControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SyncHead> head(
    $0.SyncHeadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$head, request, options: options);
  }

  $grpc.ResponseStream<$0.SyncEntry> since(
    $0.SyncSinceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$since, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$head = $grpc.ClientMethod<$0.SyncHeadRequest, $0.SyncHead>(
      '/config.sync.SyncController/Head',
      ($0.SyncHeadRequest value) => value.writeToBuffer(),
      $0.SyncHead.fromBuffer);
  static final _$since = $grpc.ClientMethod<$0.SyncSinceRequest, $0.SyncEntry>(
      '/config.sync.SyncController/Since',
      ($0.SyncSinceRequest value) => value.writeToBuffer(),
      $0.SyncEntry.fromBuffer);
}

@$pb.GrpcServiceName('config.sync.SyncController')
abstract class SyncControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.sync.SyncController';

  SyncControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SyncHeadRequest, $0.SyncHead>(
        'Head',
        head_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SyncHeadRequest.fromBuffer(value),
        ($0.SyncHead value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SyncSinceRequest, $0.SyncEntry>(
        'Since',
        since_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SyncSinceRequest.fromBuffer(value),
        ($0.SyncEntry value) => value.writeToBuffer()));
  }

  $async.Future<$0.SyncHead> head_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SyncHeadRequest> $request) async {
    return head($call, await $request);
  }

  $async.Future<$0.SyncHead> head(
      $grpc.ServiceCall call, $0.SyncHeadRequest request);

  $async.Stream<$0.SyncEntry> since_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SyncSinceRequest> $request) async* {
    yield* since($call, await $request);
  }

  $async.Stream<$0.SyncEntry> since(
      $grpc.ServiceCall call, $0.SyncSinceRequest request);
}
