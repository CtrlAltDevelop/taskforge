// This is a generated file - do not edit.
//
// Generated from infrastructure/sprints/grpc/sprints.proto.

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

import 'sprints.pb.dart' as $0;

export 'sprints.pb.dart';

@$pb.GrpcServiceName('config.sprints.BacklogController')
class BacklogControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  BacklogControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.BacklogList> list(
    $0.BacklogListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  // method descriptors

  static final _$list =
      $grpc.ClientMethod<$0.BacklogListRequest, $0.BacklogList>(
          '/config.sprints.BacklogController/List',
          ($0.BacklogListRequest value) => value.writeToBuffer(),
          $0.BacklogList.fromBuffer);
}

@$pb.GrpcServiceName('config.sprints.BacklogController')
abstract class BacklogControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.sprints.BacklogController';

  BacklogControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.BacklogListRequest, $0.BacklogList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BacklogListRequest.fromBuffer(value),
        ($0.BacklogList value) => value.writeToBuffer()));
  }

  $async.Future<$0.BacklogList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BacklogListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.BacklogList> list(
      $grpc.ServiceCall call, $0.BacklogListRequest request);
}

@$pb.GrpcServiceName('config.sprints.SprintController')
class SprintControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SprintControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SprintTasksChanged> addTasks(
    $0.SprintTasksChangeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addTasks, request, options: options);
  }

  $grpc.ResponseFuture<$0.BurndownAnswer> burndown(
    $0.BurndownRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$burndown, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintAnswer> complete(
    $0.SprintCompleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$complete, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintAnswer> create(
    $0.SprintCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintList> list(
    $0.SprintListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintTasksChanged> removeTasks(
    $0.SprintTasksChangeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeTasks, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintTask> setPoints(
    $0.PointsSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPoints, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintAnswer> start(
    $0.SprintStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintTaskList> tasks(
    $0.SprintTasksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$tasks, request, options: options);
  }

  $grpc.ResponseFuture<$0.SprintAnswer> update(
    $0.SprintUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$addTasks =
      $grpc.ClientMethod<$0.SprintTasksChangeRequest, $0.SprintTasksChanged>(
          '/config.sprints.SprintController/AddTasks',
          ($0.SprintTasksChangeRequest value) => value.writeToBuffer(),
          $0.SprintTasksChanged.fromBuffer);
  static final _$burndown =
      $grpc.ClientMethod<$0.BurndownRequest, $0.BurndownAnswer>(
          '/config.sprints.SprintController/Burndown',
          ($0.BurndownRequest value) => value.writeToBuffer(),
          $0.BurndownAnswer.fromBuffer);
  static final _$complete =
      $grpc.ClientMethod<$0.SprintCompleteRequest, $0.SprintAnswer>(
          '/config.sprints.SprintController/Complete',
          ($0.SprintCompleteRequest value) => value.writeToBuffer(),
          $0.SprintAnswer.fromBuffer);
  static final _$create =
      $grpc.ClientMethod<$0.SprintCreateRequest, $0.SprintAnswer>(
          '/config.sprints.SprintController/Create',
          ($0.SprintCreateRequest value) => value.writeToBuffer(),
          $0.SprintAnswer.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.SprintListRequest, $0.SprintList>(
      '/config.sprints.SprintController/List',
      ($0.SprintListRequest value) => value.writeToBuffer(),
      $0.SprintList.fromBuffer);
  static final _$removeTasks =
      $grpc.ClientMethod<$0.SprintTasksChangeRequest, $0.SprintTasksChanged>(
          '/config.sprints.SprintController/RemoveTasks',
          ($0.SprintTasksChangeRequest value) => value.writeToBuffer(),
          $0.SprintTasksChanged.fromBuffer);
  static final _$setPoints =
      $grpc.ClientMethod<$0.PointsSetRequest, $0.SprintTask>(
          '/config.sprints.SprintController/SetPoints',
          ($0.PointsSetRequest value) => value.writeToBuffer(),
          $0.SprintTask.fromBuffer);
  static final _$start =
      $grpc.ClientMethod<$0.SprintStartRequest, $0.SprintAnswer>(
          '/config.sprints.SprintController/Start',
          ($0.SprintStartRequest value) => value.writeToBuffer(),
          $0.SprintAnswer.fromBuffer);
  static final _$tasks =
      $grpc.ClientMethod<$0.SprintTasksRequest, $0.SprintTaskList>(
          '/config.sprints.SprintController/Tasks',
          ($0.SprintTasksRequest value) => value.writeToBuffer(),
          $0.SprintTaskList.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.SprintUpdateRequest, $0.SprintAnswer>(
          '/config.sprints.SprintController/Update',
          ($0.SprintUpdateRequest value) => value.writeToBuffer(),
          $0.SprintAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.sprints.SprintController')
abstract class SprintControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.sprints.SprintController';

  SprintControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.SprintTasksChangeRequest, $0.SprintTasksChanged>(
            'AddTasks',
            addTasks_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SprintTasksChangeRequest.fromBuffer(value),
            ($0.SprintTasksChanged value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BurndownRequest, $0.BurndownAnswer>(
        'Burndown',
        burndown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BurndownRequest.fromBuffer(value),
        ($0.BurndownAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintCompleteRequest, $0.SprintAnswer>(
        'Complete',
        complete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SprintCompleteRequest.fromBuffer(value),
        ($0.SprintAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintCreateRequest, $0.SprintAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SprintCreateRequest.fromBuffer(value),
        ($0.SprintAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintListRequest, $0.SprintList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SprintListRequest.fromBuffer(value),
        ($0.SprintList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SprintTasksChangeRequest, $0.SprintTasksChanged>(
            'RemoveTasks',
            removeTasks_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SprintTasksChangeRequest.fromBuffer(value),
            ($0.SprintTasksChanged value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PointsSetRequest, $0.SprintTask>(
        'SetPoints',
        setPoints_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PointsSetRequest.fromBuffer(value),
        ($0.SprintTask value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintStartRequest, $0.SprintAnswer>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SprintStartRequest.fromBuffer(value),
        ($0.SprintAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintTasksRequest, $0.SprintTaskList>(
        'Tasks',
        tasks_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SprintTasksRequest.fromBuffer(value),
        ($0.SprintTaskList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SprintUpdateRequest, $0.SprintAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SprintUpdateRequest.fromBuffer(value),
        ($0.SprintAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.SprintTasksChanged> addTasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintTasksChangeRequest> $request) async {
    return addTasks($call, await $request);
  }

  $async.Future<$0.SprintTasksChanged> addTasks(
      $grpc.ServiceCall call, $0.SprintTasksChangeRequest request);

  $async.Future<$0.BurndownAnswer> burndown_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BurndownRequest> $request) async {
    return burndown($call, await $request);
  }

  $async.Future<$0.BurndownAnswer> burndown(
      $grpc.ServiceCall call, $0.BurndownRequest request);

  $async.Future<$0.SprintAnswer> complete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintCompleteRequest> $request) async {
    return complete($call, await $request);
  }

  $async.Future<$0.SprintAnswer> complete(
      $grpc.ServiceCall call, $0.SprintCompleteRequest request);

  $async.Future<$0.SprintAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.SprintAnswer> create(
      $grpc.ServiceCall call, $0.SprintCreateRequest request);

  $async.Future<$0.SprintList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.SprintList> list(
      $grpc.ServiceCall call, $0.SprintListRequest request);

  $async.Future<$0.SprintTasksChanged> removeTasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintTasksChangeRequest> $request) async {
    return removeTasks($call, await $request);
  }

  $async.Future<$0.SprintTasksChanged> removeTasks(
      $grpc.ServiceCall call, $0.SprintTasksChangeRequest request);

  $async.Future<$0.SprintTask> setPoints_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PointsSetRequest> $request) async {
    return setPoints($call, await $request);
  }

  $async.Future<$0.SprintTask> setPoints(
      $grpc.ServiceCall call, $0.PointsSetRequest request);

  $async.Future<$0.SprintAnswer> start_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintStartRequest> $request) async {
    return start($call, await $request);
  }

  $async.Future<$0.SprintAnswer> start(
      $grpc.ServiceCall call, $0.SprintStartRequest request);

  $async.Future<$0.SprintTaskList> tasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintTasksRequest> $request) async {
    return tasks($call, await $request);
  }

  $async.Future<$0.SprintTaskList> tasks(
      $grpc.ServiceCall call, $0.SprintTasksRequest request);

  $async.Future<$0.SprintAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SprintUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.SprintAnswer> update(
      $grpc.ServiceCall call, $0.SprintUpdateRequest request);
}
