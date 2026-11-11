// This is a generated file - do not edit.
//
// Generated from infrastructure/automations/grpc/automations.proto.

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

import 'automations.pb.dart' as $0;

export 'automations.pb.dart';

@$pb.GrpcServiceName('config.automations.AutomationController')
class AutomationControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AutomationControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.AutomationAnswer> create(
    $0.AutomationCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationDeleted> delete(
    $0.AutomationDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationDryRunAnswer> dryRun(
    $0.AutomationDryRunRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dryRun, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationList> list(
    $0.AutomationListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationAnswer> toggle(
    $0.AutomationToggleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$toggle, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationAnswer> update(
    $0.AutomationUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.AutomationCreateRequest, $0.AutomationAnswer>(
          '/config.automations.AutomationController/Create',
          ($0.AutomationCreateRequest value) => value.writeToBuffer(),
          $0.AutomationAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.AutomationDeleteRequest, $0.AutomationDeleted>(
          '/config.automations.AutomationController/Delete',
          ($0.AutomationDeleteRequest value) => value.writeToBuffer(),
          $0.AutomationDeleted.fromBuffer);
  static final _$dryRun =
      $grpc.ClientMethod<$0.AutomationDryRunRequest, $0.AutomationDryRunAnswer>(
          '/config.automations.AutomationController/DryRun',
          ($0.AutomationDryRunRequest value) => value.writeToBuffer(),
          $0.AutomationDryRunAnswer.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.AutomationListRequest, $0.AutomationList>(
          '/config.automations.AutomationController/List',
          ($0.AutomationListRequest value) => value.writeToBuffer(),
          $0.AutomationList.fromBuffer);
  static final _$toggle =
      $grpc.ClientMethod<$0.AutomationToggleRequest, $0.AutomationAnswer>(
          '/config.automations.AutomationController/Toggle',
          ($0.AutomationToggleRequest value) => value.writeToBuffer(),
          $0.AutomationAnswer.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.AutomationUpdateRequest, $0.AutomationAnswer>(
          '/config.automations.AutomationController/Update',
          ($0.AutomationUpdateRequest value) => value.writeToBuffer(),
          $0.AutomationAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.automations.AutomationController')
abstract class AutomationControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.automations.AutomationController';

  AutomationControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationCreateRequest, $0.AutomationAnswer>(
            'Create',
            create_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationCreateRequest.fromBuffer(value),
            ($0.AutomationAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationDeleteRequest, $0.AutomationDeleted>(
            'Delete',
            delete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationDeleteRequest.fromBuffer(value),
            ($0.AutomationDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AutomationDryRunRequest,
            $0.AutomationDryRunAnswer>(
        'DryRun',
        dryRun_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AutomationDryRunRequest.fromBuffer(value),
        ($0.AutomationDryRunAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AutomationListRequest, $0.AutomationList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AutomationListRequest.fromBuffer(value),
        ($0.AutomationList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationToggleRequest, $0.AutomationAnswer>(
            'Toggle',
            toggle_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationToggleRequest.fromBuffer(value),
            ($0.AutomationAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationUpdateRequest, $0.AutomationAnswer>(
            'Update',
            update_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationUpdateRequest.fromBuffer(value),
            ($0.AutomationAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.AutomationAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.AutomationAnswer> create(
      $grpc.ServiceCall call, $0.AutomationCreateRequest request);

  $async.Future<$0.AutomationDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.AutomationDeleted> delete(
      $grpc.ServiceCall call, $0.AutomationDeleteRequest request);

  $async.Future<$0.AutomationDryRunAnswer> dryRun_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationDryRunRequest> $request) async {
    return dryRun($call, await $request);
  }

  $async.Future<$0.AutomationDryRunAnswer> dryRun(
      $grpc.ServiceCall call, $0.AutomationDryRunRequest request);

  $async.Future<$0.AutomationList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.AutomationList> list(
      $grpc.ServiceCall call, $0.AutomationListRequest request);

  $async.Future<$0.AutomationAnswer> toggle_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationToggleRequest> $request) async {
    return toggle($call, await $request);
  }

  $async.Future<$0.AutomationAnswer> toggle(
      $grpc.ServiceCall call, $0.AutomationToggleRequest request);

  $async.Future<$0.AutomationAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.AutomationAnswer> update(
      $grpc.ServiceCall call, $0.AutomationUpdateRequest request);
}

@$pb.GrpcServiceName('config.automations.AutomationRunController')
class AutomationRunControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AutomationRunControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.AutomationRunAnswer> get(
    $0.AutomationRunGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutomationRunList> list(
    $0.AutomationRunListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  // method descriptors

  static final _$get =
      $grpc.ClientMethod<$0.AutomationRunGetRequest, $0.AutomationRunAnswer>(
          '/config.automations.AutomationRunController/Get',
          ($0.AutomationRunGetRequest value) => value.writeToBuffer(),
          $0.AutomationRunAnswer.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.AutomationRunListRequest, $0.AutomationRunList>(
          '/config.automations.AutomationRunController/List',
          ($0.AutomationRunListRequest value) => value.writeToBuffer(),
          $0.AutomationRunList.fromBuffer);
}

@$pb.GrpcServiceName('config.automations.AutomationRunController')
abstract class AutomationRunControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.automations.AutomationRunController';

  AutomationRunControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationRunGetRequest, $0.AutomationRunAnswer>(
            'Get',
            get_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationRunGetRequest.fromBuffer(value),
            ($0.AutomationRunAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AutomationRunListRequest, $0.AutomationRunList>(
            'List',
            list_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutomationRunListRequest.fromBuffer(value),
            ($0.AutomationRunList value) => value.writeToBuffer()));
  }

  $async.Future<$0.AutomationRunAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationRunGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.AutomationRunAnswer> get(
      $grpc.ServiceCall call, $0.AutomationRunGetRequest request);

  $async.Future<$0.AutomationRunList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutomationRunListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.AutomationRunList> list(
      $grpc.ServiceCall call, $0.AutomationRunListRequest request);
}
