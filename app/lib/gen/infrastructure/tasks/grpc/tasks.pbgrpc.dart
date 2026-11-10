// This is a generated file - do not edit.
//
// Generated from infrastructure/tasks/grpc/tasks.proto.

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

import 'tasks.pb.dart' as $0;

export 'tasks.pb.dart';

@$pb.GrpcServiceName('config.tasks.TaskController')
class TaskControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TaskControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Task> create(
    $0.TaskCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> delete(
    $0.TaskDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> get(
    $0.TaskGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseStream<$0.Task> list(
    $0.TaskListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$list, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.TaskChildren> listChildren(
    $0.TaskListChildrenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listChildren, request, options: options);
  }

  $grpc.ResponseFuture<$0.TaskTrash> listTrash(
    $0.TaskListTrashRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTrash, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> move(
    $0.TaskMoveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$move, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> restore(
    $0.TaskRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> setParent(
    $0.TaskSetParentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setParent, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> update(
    $0.TaskUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create = $grpc.ClientMethod<$0.TaskCreateRequest, $0.Task>(
      '/config.tasks.TaskController/Create',
      ($0.TaskCreateRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$delete = $grpc.ClientMethod<$0.TaskDeleteRequest, $0.Task>(
      '/config.tasks.TaskController/Delete',
      ($0.TaskDeleteRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.TaskGetRequest, $0.Task>(
      '/config.tasks.TaskController/Get',
      ($0.TaskGetRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.TaskListRequest, $0.Task>(
      '/config.tasks.TaskController/List',
      ($0.TaskListRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$listChildren =
      $grpc.ClientMethod<$0.TaskListChildrenRequest, $0.TaskChildren>(
          '/config.tasks.TaskController/ListChildren',
          ($0.TaskListChildrenRequest value) => value.writeToBuffer(),
          $0.TaskChildren.fromBuffer);
  static final _$listTrash =
      $grpc.ClientMethod<$0.TaskListTrashRequest, $0.TaskTrash>(
          '/config.tasks.TaskController/ListTrash',
          ($0.TaskListTrashRequest value) => value.writeToBuffer(),
          $0.TaskTrash.fromBuffer);
  static final _$move = $grpc.ClientMethod<$0.TaskMoveRequest, $0.Task>(
      '/config.tasks.TaskController/Move',
      ($0.TaskMoveRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$restore = $grpc.ClientMethod<$0.TaskRestoreRequest, $0.Task>(
      '/config.tasks.TaskController/Restore',
      ($0.TaskRestoreRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$setParent =
      $grpc.ClientMethod<$0.TaskSetParentRequest, $0.Task>(
          '/config.tasks.TaskController/SetParent',
          ($0.TaskSetParentRequest value) => value.writeToBuffer(),
          $0.Task.fromBuffer);
  static final _$update = $grpc.ClientMethod<$0.TaskUpdateRequest, $0.Task>(
      '/config.tasks.TaskController/Update',
      ($0.TaskUpdateRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
}

@$pb.GrpcServiceName('config.tasks.TaskController')
abstract class TaskControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.tasks.TaskController';

  TaskControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TaskCreateRequest, $0.Task>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskCreateRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskDeleteRequest, $0.Task>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskDeleteRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskGetRequest, $0.Task>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskGetRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskListRequest, $0.Task>(
        'List',
        list_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.TaskListRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskListChildrenRequest, $0.TaskChildren>(
        'ListChildren',
        listChildren_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TaskListChildrenRequest.fromBuffer(value),
        ($0.TaskChildren value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskListTrashRequest, $0.TaskTrash>(
        'ListTrash',
        listTrash_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TaskListTrashRequest.fromBuffer(value),
        ($0.TaskTrash value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskMoveRequest, $0.Task>(
        'Move',
        move_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskMoveRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskRestoreRequest, $0.Task>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TaskRestoreRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskSetParentRequest, $0.Task>(
        'SetParent',
        setParent_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TaskSetParentRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskUpdateRequest, $0.Task>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskUpdateRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
  }

  $async.Future<$0.Task> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Task> create(
      $grpc.ServiceCall call, $0.TaskCreateRequest request);

  $async.Future<$0.Task> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Task> delete(
      $grpc.ServiceCall call, $0.TaskDeleteRequest request);

  $async.Future<$0.Task> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.Task> get($grpc.ServiceCall call, $0.TaskGetRequest request);

  $async.Stream<$0.Task> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskListRequest> $request) async* {
    yield* list($call, await $request);
  }

  $async.Stream<$0.Task> list(
      $grpc.ServiceCall call, $0.TaskListRequest request);

  $async.Future<$0.TaskChildren> listChildren_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskListChildrenRequest> $request) async {
    return listChildren($call, await $request);
  }

  $async.Future<$0.TaskChildren> listChildren(
      $grpc.ServiceCall call, $0.TaskListChildrenRequest request);

  $async.Future<$0.TaskTrash> listTrash_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskListTrashRequest> $request) async {
    return listTrash($call, await $request);
  }

  $async.Future<$0.TaskTrash> listTrash(
      $grpc.ServiceCall call, $0.TaskListTrashRequest request);

  $async.Future<$0.Task> move_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskMoveRequest> $request) async {
    return move($call, await $request);
  }

  $async.Future<$0.Task> move(
      $grpc.ServiceCall call, $0.TaskMoveRequest request);

  $async.Future<$0.Task> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.Task> restore(
      $grpc.ServiceCall call, $0.TaskRestoreRequest request);

  $async.Future<$0.Task> setParent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskSetParentRequest> $request) async {
    return setParent($call, await $request);
  }

  $async.Future<$0.Task> setParent(
      $grpc.ServiceCall call, $0.TaskSetParentRequest request);

  $async.Future<$0.Task> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Task> update(
      $grpc.ServiceCall call, $0.TaskUpdateRequest request);
}
