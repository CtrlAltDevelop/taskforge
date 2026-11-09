// This is a generated file - do not edit.
//
// Generated from infrastructure/oauth/rotation/grpc/oauth_rotation.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'oauth_rotation.pb.dart' as $0;

export 'oauth_rotation.pb.dart';

@$pb.GrpcServiceName('config.oauth_rotation.RotationTokenRpcController')
class RotationTokenRpcControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RotationTokenRpcControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Message> endSession(
    $0.EndSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$endSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.Credentials> refresh(
    $0.RefreshRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refresh, request, options: options);
  }

  $grpc.ResponseFuture<$0.Message> revoke(
    $0.RevokeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revoke, request, options: options);
  }

  $grpc.ResponseFuture<$0.SessionList> sessions(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sessions, request, options: options);
  }

  // method descriptors

  static final _$endSession =
      $grpc.ClientMethod<$0.EndSessionRequest, $0.Message>(
          '/config.oauth_rotation.RotationTokenRpcController/EndSession',
          ($0.EndSessionRequest value) => value.writeToBuffer(),
          $0.Message.fromBuffer);
  static final _$refresh =
      $grpc.ClientMethod<$0.RefreshRequest, $0.Credentials>(
          '/config.oauth_rotation.RotationTokenRpcController/Refresh',
          ($0.RefreshRequest value) => value.writeToBuffer(),
          $0.Credentials.fromBuffer);
  static final _$revoke = $grpc.ClientMethod<$0.RevokeRequest, $0.Message>(
      '/config.oauth_rotation.RotationTokenRpcController/Revoke',
      ($0.RevokeRequest value) => value.writeToBuffer(),
      $0.Message.fromBuffer);
  static final _$sessions = $grpc.ClientMethod<$1.Empty, $0.SessionList>(
      '/config.oauth_rotation.RotationTokenRpcController/Sessions',
      ($1.Empty value) => value.writeToBuffer(),
      $0.SessionList.fromBuffer);
}

@$pb.GrpcServiceName('config.oauth_rotation.RotationTokenRpcController')
abstract class RotationTokenRpcControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.oauth_rotation.RotationTokenRpcController';

  RotationTokenRpcControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EndSessionRequest, $0.Message>(
        'EndSession',
        endSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EndSessionRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshRequest, $0.Credentials>(
        'Refresh',
        refresh_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshRequest.fromBuffer(value),
        ($0.Credentials value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeRequest, $0.Message>(
        'Revoke',
        revoke_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.SessionList>(
        'Sessions',
        sessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.SessionList value) => value.writeToBuffer()));
  }

  $async.Future<$0.Message> endSession_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EndSessionRequest> $request) async {
    return endSession($call, await $request);
  }

  $async.Future<$0.Message> endSession(
      $grpc.ServiceCall call, $0.EndSessionRequest request);

  $async.Future<$0.Credentials> refresh_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RefreshRequest> $request) async {
    return refresh($call, await $request);
  }

  $async.Future<$0.Credentials> refresh(
      $grpc.ServiceCall call, $0.RefreshRequest request);

  $async.Future<$0.Message> revoke_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RevokeRequest> $request) async {
    return revoke($call, await $request);
  }

  $async.Future<$0.Message> revoke(
      $grpc.ServiceCall call, $0.RevokeRequest request);

  $async.Future<$0.SessionList> sessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return sessions($call, await $request);
  }

  $async.Future<$0.SessionList> sessions(
      $grpc.ServiceCall call, $1.Empty request);
}
