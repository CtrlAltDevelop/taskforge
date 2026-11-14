// This is a generated file - do not edit.
//
// Generated from infrastructure/goals/grpc/goals.proto.

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

import 'goals.pb.dart' as $0;

export 'goals.pb.dart';

@$pb.GrpcServiceName('config.goals.CheckInController')
class CheckInControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CheckInControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CheckInAnswer> add(
    $0.CheckInAddRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$add, request, options: options);
  }

  $grpc.ResponseFuture<$0.CheckInList> list(
    $0.CheckInListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  // method descriptors

  static final _$add =
      $grpc.ClientMethod<$0.CheckInAddRequest, $0.CheckInAnswer>(
          '/config.goals.CheckInController/Add',
          ($0.CheckInAddRequest value) => value.writeToBuffer(),
          $0.CheckInAnswer.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.CheckInListRequest, $0.CheckInList>(
          '/config.goals.CheckInController/List',
          ($0.CheckInListRequest value) => value.writeToBuffer(),
          $0.CheckInList.fromBuffer);
}

@$pb.GrpcServiceName('config.goals.CheckInController')
abstract class CheckInControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.goals.CheckInController';

  CheckInControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CheckInAddRequest, $0.CheckInAnswer>(
        'Add',
        add_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CheckInAddRequest.fromBuffer(value),
        ($0.CheckInAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckInListRequest, $0.CheckInList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CheckInListRequest.fromBuffer(value),
        ($0.CheckInList value) => value.writeToBuffer()));
  }

  $async.Future<$0.CheckInAnswer> add_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CheckInAddRequest> $request) async {
    return add($call, await $request);
  }

  $async.Future<$0.CheckInAnswer> add(
      $grpc.ServiceCall call, $0.CheckInAddRequest request);

  $async.Future<$0.CheckInList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CheckInListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.CheckInList> list(
      $grpc.ServiceCall call, $0.CheckInListRequest request);
}

@$pb.GrpcServiceName('config.goals.GoalController')
class GoalControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GoalControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GoalAnswer> create(
    $0.GoalCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalDeleted> delete(
    $0.GoalDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.FolderDeleted> deleteFolder(
    $0.FolderDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteFolder, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalAnswer> get(
    $0.GoalGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalList> list(
    $0.GoalListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.FolderAnswer> saveFolder(
    $0.FolderSaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveFolder, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalAnswer> update(
    $0.GoalUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.GoalCreateRequest, $0.GoalAnswer>(
          '/config.goals.GoalController/Create',
          ($0.GoalCreateRequest value) => value.writeToBuffer(),
          $0.GoalAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.GoalDeleteRequest, $0.GoalDeleted>(
          '/config.goals.GoalController/Delete',
          ($0.GoalDeleteRequest value) => value.writeToBuffer(),
          $0.GoalDeleted.fromBuffer);
  static final _$deleteFolder =
      $grpc.ClientMethod<$0.FolderDeleteRequest, $0.FolderDeleted>(
          '/config.goals.GoalController/DeleteFolder',
          ($0.FolderDeleteRequest value) => value.writeToBuffer(),
          $0.FolderDeleted.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.GoalGetRequest, $0.GoalAnswer>(
      '/config.goals.GoalController/Get',
      ($0.GoalGetRequest value) => value.writeToBuffer(),
      $0.GoalAnswer.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.GoalListRequest, $0.GoalList>(
      '/config.goals.GoalController/List',
      ($0.GoalListRequest value) => value.writeToBuffer(),
      $0.GoalList.fromBuffer);
  static final _$saveFolder =
      $grpc.ClientMethod<$0.FolderSaveRequest, $0.FolderAnswer>(
          '/config.goals.GoalController/SaveFolder',
          ($0.FolderSaveRequest value) => value.writeToBuffer(),
          $0.FolderAnswer.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.GoalUpdateRequest, $0.GoalAnswer>(
          '/config.goals.GoalController/Update',
          ($0.GoalUpdateRequest value) => value.writeToBuffer(),
          $0.GoalAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.goals.GoalController')
abstract class GoalControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.goals.GoalController';

  GoalControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GoalCreateRequest, $0.GoalAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GoalCreateRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GoalDeleteRequest, $0.GoalDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GoalDeleteRequest.fromBuffer(value),
        ($0.GoalDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FolderDeleteRequest, $0.FolderDeleted>(
        'DeleteFolder',
        deleteFolder_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FolderDeleteRequest.fromBuffer(value),
        ($0.FolderDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GoalGetRequest, $0.GoalAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GoalGetRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GoalListRequest, $0.GoalList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GoalListRequest.fromBuffer(value),
        ($0.GoalList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FolderSaveRequest, $0.FolderAnswer>(
        'SaveFolder',
        saveFolder_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FolderSaveRequest.fromBuffer(value),
        ($0.FolderAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GoalUpdateRequest, $0.GoalAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GoalUpdateRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.GoalAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GoalCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.GoalAnswer> create(
      $grpc.ServiceCall call, $0.GoalCreateRequest request);

  $async.Future<$0.GoalDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GoalDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.GoalDeleted> delete(
      $grpc.ServiceCall call, $0.GoalDeleteRequest request);

  $async.Future<$0.FolderDeleted> deleteFolder_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FolderDeleteRequest> $request) async {
    return deleteFolder($call, await $request);
  }

  $async.Future<$0.FolderDeleted> deleteFolder(
      $grpc.ServiceCall call, $0.FolderDeleteRequest request);

  $async.Future<$0.GoalAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GoalGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.GoalAnswer> get(
      $grpc.ServiceCall call, $0.GoalGetRequest request);

  $async.Future<$0.GoalList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GoalListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.GoalList> list(
      $grpc.ServiceCall call, $0.GoalListRequest request);

  $async.Future<$0.FolderAnswer> saveFolder_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FolderSaveRequest> $request) async {
    return saveFolder($call, await $request);
  }

  $async.Future<$0.FolderAnswer> saveFolder(
      $grpc.ServiceCall call, $0.FolderSaveRequest request);

  $async.Future<$0.GoalAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GoalUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.GoalAnswer> update(
      $grpc.ServiceCall call, $0.GoalUpdateRequest request);
}

@$pb.GrpcServiceName('config.goals.KeyResultController')
class KeyResultControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  KeyResultControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GoalAnswer> create(
    $0.KeyResultCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalAnswer> delete(
    $0.KeyResultDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.ForTaskList> forTask(
    $0.ForTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.GoalAnswer> update(
    $0.KeyResultUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.KeyResultCreateRequest, $0.GoalAnswer>(
          '/config.goals.KeyResultController/Create',
          ($0.KeyResultCreateRequest value) => value.writeToBuffer(),
          $0.GoalAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.KeyResultDeleteRequest, $0.GoalAnswer>(
          '/config.goals.KeyResultController/Delete',
          ($0.KeyResultDeleteRequest value) => value.writeToBuffer(),
          $0.GoalAnswer.fromBuffer);
  static final _$forTask =
      $grpc.ClientMethod<$0.ForTaskRequest, $0.ForTaskList>(
          '/config.goals.KeyResultController/ForTask',
          ($0.ForTaskRequest value) => value.writeToBuffer(),
          $0.ForTaskList.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.KeyResultUpdateRequest, $0.GoalAnswer>(
          '/config.goals.KeyResultController/Update',
          ($0.KeyResultUpdateRequest value) => value.writeToBuffer(),
          $0.GoalAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.goals.KeyResultController')
abstract class KeyResultControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.goals.KeyResultController';

  KeyResultControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.KeyResultCreateRequest, $0.GoalAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.KeyResultCreateRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.KeyResultDeleteRequest, $0.GoalAnswer>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.KeyResultDeleteRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ForTaskRequest, $0.ForTaskList>(
        'ForTask',
        forTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ForTaskRequest.fromBuffer(value),
        ($0.ForTaskList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.KeyResultUpdateRequest, $0.GoalAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.KeyResultUpdateRequest.fromBuffer(value),
        ($0.GoalAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.GoalAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.KeyResultCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.GoalAnswer> create(
      $grpc.ServiceCall call, $0.KeyResultCreateRequest request);

  $async.Future<$0.GoalAnswer> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.KeyResultDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.GoalAnswer> delete(
      $grpc.ServiceCall call, $0.KeyResultDeleteRequest request);

  $async.Future<$0.ForTaskList> forTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ForTaskRequest> $request) async {
    return forTask($call, await $request);
  }

  $async.Future<$0.ForTaskList> forTask(
      $grpc.ServiceCall call, $0.ForTaskRequest request);

  $async.Future<$0.GoalAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.KeyResultUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.GoalAnswer> update(
      $grpc.ServiceCall call, $0.KeyResultUpdateRequest request);
}
