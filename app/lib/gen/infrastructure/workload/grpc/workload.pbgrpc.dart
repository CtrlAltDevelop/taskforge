// This is a generated file - do not edit.
//
// Generated from infrastructure/workload/grpc/workload.proto.

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

import 'workload.pb.dart' as $0;

export 'workload.pb.dart';

@$pb.GrpcServiceName('config.workload.CapacityController')
class CapacityControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CapacityControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CapacityList> get(
    $0.CapacityGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.CapacityAnswer> set(
    $0.CapacitySetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$set, request, options: options);
  }

  // method descriptors

  static final _$get =
      $grpc.ClientMethod<$0.CapacityGetRequest, $0.CapacityList>(
          '/config.workload.CapacityController/Get',
          ($0.CapacityGetRequest value) => value.writeToBuffer(),
          $0.CapacityList.fromBuffer);
  static final _$set =
      $grpc.ClientMethod<$0.CapacitySetRequest, $0.CapacityAnswer>(
          '/config.workload.CapacityController/Set',
          ($0.CapacitySetRequest value) => value.writeToBuffer(),
          $0.CapacityAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.workload.CapacityController')
abstract class CapacityControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workload.CapacityController';

  CapacityControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CapacityGetRequest, $0.CapacityList>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CapacityGetRequest.fromBuffer(value),
        ($0.CapacityList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CapacitySetRequest, $0.CapacityAnswer>(
        'Set',
        set_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CapacitySetRequest.fromBuffer(value),
        ($0.CapacityAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.CapacityList> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CapacityGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.CapacityList> get(
      $grpc.ServiceCall call, $0.CapacityGetRequest request);

  $async.Future<$0.CapacityAnswer> set_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CapacitySetRequest> $request) async {
    return set($call, await $request);
  }

  $async.Future<$0.CapacityAnswer> set(
      $grpc.ServiceCall call, $0.CapacitySetRequest request);
}

@$pb.GrpcServiceName('config.workload.HolidayController')
class HolidayControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  HolidayControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.HolidayAnswer> create(
    $0.HolidayCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.HolidayDeleted> delete(
    $0.HolidayDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.HolidayList> list(
    $0.HolidayListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.HolidayAnswer> update(
    $0.HolidayUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.HolidayCreateRequest, $0.HolidayAnswer>(
          '/config.workload.HolidayController/Create',
          ($0.HolidayCreateRequest value) => value.writeToBuffer(),
          $0.HolidayAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.HolidayDeleteRequest, $0.HolidayDeleted>(
          '/config.workload.HolidayController/Delete',
          ($0.HolidayDeleteRequest value) => value.writeToBuffer(),
          $0.HolidayDeleted.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.HolidayListRequest, $0.HolidayList>(
          '/config.workload.HolidayController/List',
          ($0.HolidayListRequest value) => value.writeToBuffer(),
          $0.HolidayList.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.HolidayUpdateRequest, $0.HolidayAnswer>(
          '/config.workload.HolidayController/Update',
          ($0.HolidayUpdateRequest value) => value.writeToBuffer(),
          $0.HolidayAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.workload.HolidayController')
abstract class HolidayControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workload.HolidayController';

  HolidayControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HolidayCreateRequest, $0.HolidayAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HolidayCreateRequest.fromBuffer(value),
        ($0.HolidayAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HolidayDeleteRequest, $0.HolidayDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HolidayDeleteRequest.fromBuffer(value),
        ($0.HolidayDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HolidayListRequest, $0.HolidayList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HolidayListRequest.fromBuffer(value),
        ($0.HolidayList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HolidayUpdateRequest, $0.HolidayAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HolidayUpdateRequest.fromBuffer(value),
        ($0.HolidayAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.HolidayAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HolidayCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.HolidayAnswer> create(
      $grpc.ServiceCall call, $0.HolidayCreateRequest request);

  $async.Future<$0.HolidayDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HolidayDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.HolidayDeleted> delete(
      $grpc.ServiceCall call, $0.HolidayDeleteRequest request);

  $async.Future<$0.HolidayList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HolidayListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.HolidayList> list(
      $grpc.ServiceCall call, $0.HolidayListRequest request);

  $async.Future<$0.HolidayAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HolidayUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.HolidayAnswer> update(
      $grpc.ServiceCall call, $0.HolidayUpdateRequest request);
}

@$pb.GrpcServiceName('config.workload.TimeOffController')
class TimeOffControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TimeOffControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.TimeOffAnswer> create(
    $0.TimeOffCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimeOffDeleted> delete(
    $0.TimeOffDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimeOffList> list(
    $0.TimeOffListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimeOffAnswer> update(
    $0.TimeOffUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.TimeOffCreateRequest, $0.TimeOffAnswer>(
          '/config.workload.TimeOffController/Create',
          ($0.TimeOffCreateRequest value) => value.writeToBuffer(),
          $0.TimeOffAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.TimeOffDeleteRequest, $0.TimeOffDeleted>(
          '/config.workload.TimeOffController/Delete',
          ($0.TimeOffDeleteRequest value) => value.writeToBuffer(),
          $0.TimeOffDeleted.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.TimeOffListRequest, $0.TimeOffList>(
          '/config.workload.TimeOffController/List',
          ($0.TimeOffListRequest value) => value.writeToBuffer(),
          $0.TimeOffList.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.TimeOffUpdateRequest, $0.TimeOffAnswer>(
          '/config.workload.TimeOffController/Update',
          ($0.TimeOffUpdateRequest value) => value.writeToBuffer(),
          $0.TimeOffAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.workload.TimeOffController')
abstract class TimeOffControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workload.TimeOffController';

  TimeOffControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TimeOffCreateRequest, $0.TimeOffAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeOffCreateRequest.fromBuffer(value),
        ($0.TimeOffAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeOffDeleteRequest, $0.TimeOffDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeOffDeleteRequest.fromBuffer(value),
        ($0.TimeOffDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeOffListRequest, $0.TimeOffList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeOffListRequest.fromBuffer(value),
        ($0.TimeOffList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeOffUpdateRequest, $0.TimeOffAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeOffUpdateRequest.fromBuffer(value),
        ($0.TimeOffAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.TimeOffAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeOffCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.TimeOffAnswer> create(
      $grpc.ServiceCall call, $0.TimeOffCreateRequest request);

  $async.Future<$0.TimeOffDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeOffDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.TimeOffDeleted> delete(
      $grpc.ServiceCall call, $0.TimeOffDeleteRequest request);

  $async.Future<$0.TimeOffList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeOffListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.TimeOffList> list(
      $grpc.ServiceCall call, $0.TimeOffListRequest request);

  $async.Future<$0.TimeOffAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeOffUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.TimeOffAnswer> update(
      $grpc.ServiceCall call, $0.TimeOffUpdateRequest request);
}

@$pb.GrpcServiceName('config.workload.WorkloadController')
class WorkloadControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WorkloadControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.WorkloadAnswer> get(
    $0.WorkloadGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.AssigneeEstimateAnswer> setAssigneeEstimate(
    $0.AssigneeEstimateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setAssigneeEstimate, request, options: options);
  }

  // method descriptors

  static final _$get =
      $grpc.ClientMethod<$0.WorkloadGetRequest, $0.WorkloadAnswer>(
          '/config.workload.WorkloadController/Get',
          ($0.WorkloadGetRequest value) => value.writeToBuffer(),
          $0.WorkloadAnswer.fromBuffer);
  static final _$setAssigneeEstimate =
      $grpc.ClientMethod<$0.AssigneeEstimateRequest, $0.AssigneeEstimateAnswer>(
          '/config.workload.WorkloadController/SetAssigneeEstimate',
          ($0.AssigneeEstimateRequest value) => value.writeToBuffer(),
          $0.AssigneeEstimateAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.workload.WorkloadController')
abstract class WorkloadControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workload.WorkloadController';

  WorkloadControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WorkloadGetRequest, $0.WorkloadAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkloadGetRequest.fromBuffer(value),
        ($0.WorkloadAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AssigneeEstimateRequest,
            $0.AssigneeEstimateAnswer>(
        'SetAssigneeEstimate',
        setAssigneeEstimate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AssigneeEstimateRequest.fromBuffer(value),
        ($0.AssigneeEstimateAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.WorkloadAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkloadGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.WorkloadAnswer> get(
      $grpc.ServiceCall call, $0.WorkloadGetRequest request);

  $async.Future<$0.AssigneeEstimateAnswer> setAssigneeEstimate_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AssigneeEstimateRequest> $request) async {
    return setAssigneeEstimate($call, await $request);
  }

  $async.Future<$0.AssigneeEstimateAnswer> setAssigneeEstimate(
      $grpc.ServiceCall call, $0.AssigneeEstimateRequest request);
}
