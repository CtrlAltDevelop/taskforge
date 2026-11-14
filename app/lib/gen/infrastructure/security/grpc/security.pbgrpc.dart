// This is a generated file - do not edit.
//
// Generated from infrastructure/security/grpc/security.proto.

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

import 'security.pb.dart' as $0;

export 'security.pb.dart';

@$pb.GrpcServiceName('config.security.SecondFactorController')
class SecondFactorControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SecondFactorControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SecondFactorEnrolment> begin(
    $0.SecondFactorBeginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$begin, request, options: options);
  }

  $grpc.ResponseFuture<$0.SecondFactorConfirmed> confirm(
    $0.SecondFactorConfirmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirm, request, options: options);
  }

  $grpc.ResponseFuture<$0.SecondFactorDisabled> disable(
    $0.SecondFactorDisableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disable, request, options: options);
  }

  $grpc.ResponseFuture<$0.SecondFactorRegenerated> regenerateCodes(
    $0.SecondFactorRegenerateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$regenerateCodes, request, options: options);
  }

  $grpc.ResponseFuture<$0.RevokeDeviceAnswer> revokeDevice(
    $0.RevokeDeviceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeDevice, request, options: options);
  }

  $grpc.ResponseFuture<$0.SecondFactorStatus> status(
    $0.SecondFactorStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$status, request, options: options);
  }

  // method descriptors

  static final _$begin =
      $grpc.ClientMethod<$0.SecondFactorBeginRequest, $0.SecondFactorEnrolment>(
          '/config.security.SecondFactorController/Begin',
          ($0.SecondFactorBeginRequest value) => value.writeToBuffer(),
          $0.SecondFactorEnrolment.fromBuffer);
  static final _$confirm = $grpc.ClientMethod<$0.SecondFactorConfirmRequest,
          $0.SecondFactorConfirmed>(
      '/config.security.SecondFactorController/Confirm',
      ($0.SecondFactorConfirmRequest value) => value.writeToBuffer(),
      $0.SecondFactorConfirmed.fromBuffer);
  static final _$disable = $grpc.ClientMethod<$0.SecondFactorDisableRequest,
          $0.SecondFactorDisabled>(
      '/config.security.SecondFactorController/Disable',
      ($0.SecondFactorDisableRequest value) => value.writeToBuffer(),
      $0.SecondFactorDisabled.fromBuffer);
  static final _$regenerateCodes = $grpc.ClientMethod<
          $0.SecondFactorRegenerateRequest, $0.SecondFactorRegenerated>(
      '/config.security.SecondFactorController/RegenerateCodes',
      ($0.SecondFactorRegenerateRequest value) => value.writeToBuffer(),
      $0.SecondFactorRegenerated.fromBuffer);
  static final _$revokeDevice =
      $grpc.ClientMethod<$0.RevokeDeviceRequest, $0.RevokeDeviceAnswer>(
          '/config.security.SecondFactorController/RevokeDevice',
          ($0.RevokeDeviceRequest value) => value.writeToBuffer(),
          $0.RevokeDeviceAnswer.fromBuffer);
  static final _$status =
      $grpc.ClientMethod<$0.SecondFactorStatusRequest, $0.SecondFactorStatus>(
          '/config.security.SecondFactorController/Status',
          ($0.SecondFactorStatusRequest value) => value.writeToBuffer(),
          $0.SecondFactorStatus.fromBuffer);
}

@$pb.GrpcServiceName('config.security.SecondFactorController')
abstract class SecondFactorControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.security.SecondFactorController';

  SecondFactorControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SecondFactorBeginRequest,
            $0.SecondFactorEnrolment>(
        'Begin',
        begin_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SecondFactorBeginRequest.fromBuffer(value),
        ($0.SecondFactorEnrolment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SecondFactorConfirmRequest,
            $0.SecondFactorConfirmed>(
        'Confirm',
        confirm_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SecondFactorConfirmRequest.fromBuffer(value),
        ($0.SecondFactorConfirmed value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SecondFactorDisableRequest,
            $0.SecondFactorDisabled>(
        'Disable',
        disable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SecondFactorDisableRequest.fromBuffer(value),
        ($0.SecondFactorDisabled value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SecondFactorRegenerateRequest,
            $0.SecondFactorRegenerated>(
        'RegenerateCodes',
        regenerateCodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SecondFactorRegenerateRequest.fromBuffer(value),
        ($0.SecondFactorRegenerated value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RevokeDeviceRequest, $0.RevokeDeviceAnswer>(
            'RevokeDevice',
            revokeDevice_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RevokeDeviceRequest.fromBuffer(value),
            ($0.RevokeDeviceAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SecondFactorStatusRequest,
            $0.SecondFactorStatus>(
        'Status',
        status_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SecondFactorStatusRequest.fromBuffer(value),
        ($0.SecondFactorStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.SecondFactorEnrolment> begin_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SecondFactorBeginRequest> $request) async {
    return begin($call, await $request);
  }

  $async.Future<$0.SecondFactorEnrolment> begin(
      $grpc.ServiceCall call, $0.SecondFactorBeginRequest request);

  $async.Future<$0.SecondFactorConfirmed> confirm_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SecondFactorConfirmRequest> $request) async {
    return confirm($call, await $request);
  }

  $async.Future<$0.SecondFactorConfirmed> confirm(
      $grpc.ServiceCall call, $0.SecondFactorConfirmRequest request);

  $async.Future<$0.SecondFactorDisabled> disable_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SecondFactorDisableRequest> $request) async {
    return disable($call, await $request);
  }

  $async.Future<$0.SecondFactorDisabled> disable(
      $grpc.ServiceCall call, $0.SecondFactorDisableRequest request);

  $async.Future<$0.SecondFactorRegenerated> regenerateCodes_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SecondFactorRegenerateRequest> $request) async {
    return regenerateCodes($call, await $request);
  }

  $async.Future<$0.SecondFactorRegenerated> regenerateCodes(
      $grpc.ServiceCall call, $0.SecondFactorRegenerateRequest request);

  $async.Future<$0.RevokeDeviceAnswer> revokeDevice_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RevokeDeviceRequest> $request) async {
    return revokeDevice($call, await $request);
  }

  $async.Future<$0.RevokeDeviceAnswer> revokeDevice(
      $grpc.ServiceCall call, $0.RevokeDeviceRequest request);

  $async.Future<$0.SecondFactorStatus> status_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SecondFactorStatusRequest> $request) async {
    return status($call, await $request);
  }

  $async.Future<$0.SecondFactorStatus> status(
      $grpc.ServiceCall call, $0.SecondFactorStatusRequest request);
}

@$pb.GrpcServiceName('config.security.SecurityPolicyController')
class SecurityPolicyControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SecurityPolicyControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.PolicyAnswer> get(
    $0.PolicyGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.PolicyAnswer> set(
    $0.PolicySetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$set, request, options: options);
  }

  // method descriptors

  static final _$get = $grpc.ClientMethod<$0.PolicyGetRequest, $0.PolicyAnswer>(
      '/config.security.SecurityPolicyController/Get',
      ($0.PolicyGetRequest value) => value.writeToBuffer(),
      $0.PolicyAnswer.fromBuffer);
  static final _$set = $grpc.ClientMethod<$0.PolicySetRequest, $0.PolicyAnswer>(
      '/config.security.SecurityPolicyController/Set',
      ($0.PolicySetRequest value) => value.writeToBuffer(),
      $0.PolicyAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.security.SecurityPolicyController')
abstract class SecurityPolicyControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.security.SecurityPolicyController';

  SecurityPolicyControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PolicyGetRequest, $0.PolicyAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PolicyGetRequest.fromBuffer(value),
        ($0.PolicyAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PolicySetRequest, $0.PolicyAnswer>(
        'Set',
        set_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PolicySetRequest.fromBuffer(value),
        ($0.PolicyAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.PolicyAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PolicyGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.PolicyAnswer> get(
      $grpc.ServiceCall call, $0.PolicyGetRequest request);

  $async.Future<$0.PolicyAnswer> set_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PolicySetRequest> $request) async {
    return set($call, await $request);
  }

  $async.Future<$0.PolicyAnswer> set(
      $grpc.ServiceCall call, $0.PolicySetRequest request);
}

@$pb.GrpcServiceName('config.security.SsoController')
class SsoControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SsoControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SsoDeleted> delete(
    $0.SsoDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProviderAnswer> get(
    $0.SsoGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProviderAnswer> save(
    $0.SsoSaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$save, request, options: options);
  }

  $grpc.ResponseFuture<$0.SsoTestAnswer> test(
    $0.SsoTestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$test, request, options: options);
  }

  // method descriptors

  static final _$delete =
      $grpc.ClientMethod<$0.SsoDeleteRequest, $0.SsoDeleted>(
          '/config.security.SsoController/Delete',
          ($0.SsoDeleteRequest value) => value.writeToBuffer(),
          $0.SsoDeleted.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.SsoGetRequest, $0.ProviderAnswer>(
      '/config.security.SsoController/Get',
      ($0.SsoGetRequest value) => value.writeToBuffer(),
      $0.ProviderAnswer.fromBuffer);
  static final _$save =
      $grpc.ClientMethod<$0.SsoSaveRequest, $0.ProviderAnswer>(
          '/config.security.SsoController/Save',
          ($0.SsoSaveRequest value) => value.writeToBuffer(),
          $0.ProviderAnswer.fromBuffer);
  static final _$test = $grpc.ClientMethod<$0.SsoTestRequest, $0.SsoTestAnswer>(
      '/config.security.SsoController/Test',
      ($0.SsoTestRequest value) => value.writeToBuffer(),
      $0.SsoTestAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.security.SsoController')
abstract class SsoControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.security.SsoController';

  SsoControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SsoDeleteRequest, $0.SsoDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SsoDeleteRequest.fromBuffer(value),
        ($0.SsoDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SsoGetRequest, $0.ProviderAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SsoGetRequest.fromBuffer(value),
        ($0.ProviderAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SsoSaveRequest, $0.ProviderAnswer>(
        'Save',
        save_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SsoSaveRequest.fromBuffer(value),
        ($0.ProviderAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SsoTestRequest, $0.SsoTestAnswer>(
        'Test',
        test_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SsoTestRequest.fromBuffer(value),
        ($0.SsoTestAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.SsoDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SsoDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.SsoDeleted> delete(
      $grpc.ServiceCall call, $0.SsoDeleteRequest request);

  $async.Future<$0.ProviderAnswer> get_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SsoGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.ProviderAnswer> get(
      $grpc.ServiceCall call, $0.SsoGetRequest request);

  $async.Future<$0.ProviderAnswer> save_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SsoSaveRequest> $request) async {
    return save($call, await $request);
  }

  $async.Future<$0.ProviderAnswer> save(
      $grpc.ServiceCall call, $0.SsoSaveRequest request);

  $async.Future<$0.SsoTestAnswer> test_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SsoTestRequest> $request) async {
    return test($call, await $request);
  }

  $async.Future<$0.SsoTestAnswer> test(
      $grpc.ServiceCall call, $0.SsoTestRequest request);
}
