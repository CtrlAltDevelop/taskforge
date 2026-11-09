// This is a generated file - do not edit.
//
// Generated from infrastructure/accounts/grpc/accounts.proto.

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

import 'accounts.pb.dart' as $1;

export 'accounts.pb.dart';

@$pb.GrpcServiceName('config.accounts.AccountController')
class AccountControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AccountControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.Account> me(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$me, request, options: options);
  }

  $grpc.ResponseFuture<$1.Account> updateProfile(
    $1.ProfileUpdate request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateProfile, request, options: options);
  }

  // method descriptors

  static final _$me = $grpc.ClientMethod<$0.Empty, $1.Account>(
      '/config.accounts.AccountController/Me',
      ($0.Empty value) => value.writeToBuffer(),
      $1.Account.fromBuffer);
  static final _$updateProfile =
      $grpc.ClientMethod<$1.ProfileUpdate, $1.Account>(
          '/config.accounts.AccountController/UpdateProfile',
          ($1.ProfileUpdate value) => value.writeToBuffer(),
          $1.Account.fromBuffer);
}

@$pb.GrpcServiceName('config.accounts.AccountController')
abstract class AccountControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.accounts.AccountController';

  AccountControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Account>(
        'Me',
        me_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Account value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.ProfileUpdate, $1.Account>(
        'UpdateProfile',
        updateProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.ProfileUpdate.fromBuffer(value),
        ($1.Account value) => value.writeToBuffer()));
  }

  $async.Future<$1.Account> me_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return me($call, await $request);
  }

  $async.Future<$1.Account> me($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.Account> updateProfile_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.ProfileUpdate> $request) async {
    return updateProfile($call, await $request);
  }

  $async.Future<$1.Account> updateProfile(
      $grpc.ServiceCall call, $1.ProfileUpdate request);
}
