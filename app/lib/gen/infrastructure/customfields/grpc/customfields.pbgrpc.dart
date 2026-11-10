// This is a generated file - do not edit.
//
// Generated from infrastructure/customfields/grpc/customfields.proto.

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

import 'customfields.pb.dart' as $0;

export 'customfields.pb.dart';

@$pb.GrpcServiceName('config.customfields.FieldController')
class FieldControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FieldControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Field> archive(
    $0.FieldArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archive, request, options: options);
  }

  $grpc.ResponseFuture<$0.Field> create(
    $0.FieldCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.FieldList> list(
    $0.FieldListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.FieldList> reorder(
    $0.FieldReorderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reorder, request, options: options);
  }

  $grpc.ResponseFuture<$0.Field> restore(
    $0.FieldRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.Field> update(
    $0.FieldUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$archive = $grpc.ClientMethod<$0.FieldArchiveRequest, $0.Field>(
      '/config.customfields.FieldController/Archive',
      ($0.FieldArchiveRequest value) => value.writeToBuffer(),
      $0.Field.fromBuffer);
  static final _$create = $grpc.ClientMethod<$0.FieldCreateRequest, $0.Field>(
      '/config.customfields.FieldController/Create',
      ($0.FieldCreateRequest value) => value.writeToBuffer(),
      $0.Field.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.FieldListRequest, $0.FieldList>(
      '/config.customfields.FieldController/List',
      ($0.FieldListRequest value) => value.writeToBuffer(),
      $0.FieldList.fromBuffer);
  static final _$reorder =
      $grpc.ClientMethod<$0.FieldReorderRequest, $0.FieldList>(
          '/config.customfields.FieldController/Reorder',
          ($0.FieldReorderRequest value) => value.writeToBuffer(),
          $0.FieldList.fromBuffer);
  static final _$restore = $grpc.ClientMethod<$0.FieldRestoreRequest, $0.Field>(
      '/config.customfields.FieldController/Restore',
      ($0.FieldRestoreRequest value) => value.writeToBuffer(),
      $0.Field.fromBuffer);
  static final _$update = $grpc.ClientMethod<$0.FieldUpdateRequest, $0.Field>(
      '/config.customfields.FieldController/Update',
      ($0.FieldUpdateRequest value) => value.writeToBuffer(),
      $0.Field.fromBuffer);
}

@$pb.GrpcServiceName('config.customfields.FieldController')
abstract class FieldControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.customfields.FieldController';

  FieldControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FieldArchiveRequest, $0.Field>(
        'Archive',
        archive_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FieldArchiveRequest.fromBuffer(value),
        ($0.Field value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FieldCreateRequest, $0.Field>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FieldCreateRequest.fromBuffer(value),
        ($0.Field value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FieldListRequest, $0.FieldList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FieldListRequest.fromBuffer(value),
        ($0.FieldList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FieldReorderRequest, $0.FieldList>(
        'Reorder',
        reorder_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FieldReorderRequest.fromBuffer(value),
        ($0.FieldList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FieldRestoreRequest, $0.Field>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FieldRestoreRequest.fromBuffer(value),
        ($0.Field value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FieldUpdateRequest, $0.Field>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FieldUpdateRequest.fromBuffer(value),
        ($0.Field value) => value.writeToBuffer()));
  }

  $async.Future<$0.Field> archive_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldArchiveRequest> $request) async {
    return archive($call, await $request);
  }

  $async.Future<$0.Field> archive(
      $grpc.ServiceCall call, $0.FieldArchiveRequest request);

  $async.Future<$0.Field> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Field> create(
      $grpc.ServiceCall call, $0.FieldCreateRequest request);

  $async.Future<$0.FieldList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.FieldList> list(
      $grpc.ServiceCall call, $0.FieldListRequest request);

  $async.Future<$0.FieldList> reorder_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldReorderRequest> $request) async {
    return reorder($call, await $request);
  }

  $async.Future<$0.FieldList> reorder(
      $grpc.ServiceCall call, $0.FieldReorderRequest request);

  $async.Future<$0.Field> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.Field> restore(
      $grpc.ServiceCall call, $0.FieldRestoreRequest request);

  $async.Future<$0.Field> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FieldUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Field> update(
      $grpc.ServiceCall call, $0.FieldUpdateRequest request);
}
