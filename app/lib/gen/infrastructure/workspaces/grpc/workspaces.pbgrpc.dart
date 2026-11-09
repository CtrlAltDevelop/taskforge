// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

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

import 'workspaces.pb.dart' as $0;

export 'workspaces.pb.dart';

@$pb.GrpcServiceName('config.workspaces.WorkspaceController')
class WorkspaceControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WorkspaceControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Workspace> create(
    $0.WorkspaceCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> delete(
    $0.WorkspaceDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkspaceList> list(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkspaceList> listDeleted(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listDeleted, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> restore(
    $0.WorkspaceRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> update(
    $0.WorkspaceUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.WorkspaceCreateRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Create',
          ($0.WorkspaceCreateRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.WorkspaceDeleteRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Delete',
          ($0.WorkspaceDeleteRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$list = $grpc.ClientMethod<$1.Empty, $0.WorkspaceList>(
      '/config.workspaces.WorkspaceController/List',
      ($1.Empty value) => value.writeToBuffer(),
      $0.WorkspaceList.fromBuffer);
  static final _$listDeleted = $grpc.ClientMethod<$1.Empty, $0.WorkspaceList>(
      '/config.workspaces.WorkspaceController/ListDeleted',
      ($1.Empty value) => value.writeToBuffer(),
      $0.WorkspaceList.fromBuffer);
  static final _$restore =
      $grpc.ClientMethod<$0.WorkspaceRestoreRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Restore',
          ($0.WorkspaceRestoreRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.WorkspaceUpdateRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Update',
          ($0.WorkspaceUpdateRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.WorkspaceController')
abstract class WorkspaceControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.WorkspaceController';

  WorkspaceControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WorkspaceCreateRequest, $0.Workspace>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceCreateRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceDeleteRequest, $0.Workspace>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceDeleteRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.WorkspaceList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.WorkspaceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.WorkspaceList>(
        'ListDeleted',
        listDeleted_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.WorkspaceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceRestoreRequest, $0.Workspace>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceRestoreRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceUpdateRequest, $0.Workspace>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceUpdateRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
  }

  $async.Future<$0.Workspace> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Workspace> create(
      $grpc.ServiceCall call, $0.WorkspaceCreateRequest request);

  $async.Future<$0.Workspace> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Workspace> delete(
      $grpc.ServiceCall call, $0.WorkspaceDeleteRequest request);

  $async.Future<$0.WorkspaceList> list_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.WorkspaceList> list(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.WorkspaceList> listDeleted_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listDeleted($call, await $request);
  }

  $async.Future<$0.WorkspaceList> listDeleted(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.Workspace> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.Workspace> restore(
      $grpc.ServiceCall call, $0.WorkspaceRestoreRequest request);

  $async.Future<$0.Workspace> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Workspace> update(
      $grpc.ServiceCall call, $0.WorkspaceUpdateRequest request);
}
