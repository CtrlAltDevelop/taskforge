// This is a generated file - do not edit.
//
// Generated from infrastructure/templates/grpc/templates.proto.

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

import 'templates.pb.dart' as $0;

export 'templates.pb.dart';

@$pb.GrpcServiceName('config.templates.TemplateController')
class TemplateControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TemplateControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.TemplateApplied> apply(
    $0.TemplateApplyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$apply, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateAnswer> create(
    $0.TemplateCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateDeleted> delete(
    $0.TemplateDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateAnswer> get(
    $0.TemplateGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateList> list(
    $0.TemplateListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateAnswer> saveFromProject(
    $0.TemplateSaveFromProjectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveFromProject, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateAnswer> saveFromTask(
    $0.TemplateSaveFromTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveFromTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateAnswer> update(
    $0.TemplateUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$apply =
      $grpc.ClientMethod<$0.TemplateApplyRequest, $0.TemplateApplied>(
          '/config.templates.TemplateController/Apply',
          ($0.TemplateApplyRequest value) => value.writeToBuffer(),
          $0.TemplateApplied.fromBuffer);
  static final _$create =
      $grpc.ClientMethod<$0.TemplateCreateRequest, $0.TemplateAnswer>(
          '/config.templates.TemplateController/Create',
          ($0.TemplateCreateRequest value) => value.writeToBuffer(),
          $0.TemplateAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.TemplateDeleteRequest, $0.TemplateDeleted>(
          '/config.templates.TemplateController/Delete',
          ($0.TemplateDeleteRequest value) => value.writeToBuffer(),
          $0.TemplateDeleted.fromBuffer);
  static final _$get =
      $grpc.ClientMethod<$0.TemplateGetRequest, $0.TemplateAnswer>(
          '/config.templates.TemplateController/Get',
          ($0.TemplateGetRequest value) => value.writeToBuffer(),
          $0.TemplateAnswer.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.TemplateListRequest, $0.TemplateList>(
          '/config.templates.TemplateController/List',
          ($0.TemplateListRequest value) => value.writeToBuffer(),
          $0.TemplateList.fromBuffer);
  static final _$saveFromProject =
      $grpc.ClientMethod<$0.TemplateSaveFromProjectRequest, $0.TemplateAnswer>(
          '/config.templates.TemplateController/SaveFromProject',
          ($0.TemplateSaveFromProjectRequest value) => value.writeToBuffer(),
          $0.TemplateAnswer.fromBuffer);
  static final _$saveFromTask =
      $grpc.ClientMethod<$0.TemplateSaveFromTaskRequest, $0.TemplateAnswer>(
          '/config.templates.TemplateController/SaveFromTask',
          ($0.TemplateSaveFromTaskRequest value) => value.writeToBuffer(),
          $0.TemplateAnswer.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.TemplateUpdateRequest, $0.TemplateAnswer>(
          '/config.templates.TemplateController/Update',
          ($0.TemplateUpdateRequest value) => value.writeToBuffer(),
          $0.TemplateAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.templates.TemplateController')
abstract class TemplateControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.templates.TemplateController';

  TemplateControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TemplateApplyRequest, $0.TemplateApplied>(
        'Apply',
        apply_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateApplyRequest.fromBuffer(value),
        ($0.TemplateApplied value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TemplateCreateRequest, $0.TemplateAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateCreateRequest.fromBuffer(value),
        ($0.TemplateAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.TemplateDeleteRequest, $0.TemplateDeleted>(
            'Delete',
            delete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.TemplateDeleteRequest.fromBuffer(value),
            ($0.TemplateDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TemplateGetRequest, $0.TemplateAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateGetRequest.fromBuffer(value),
        ($0.TemplateAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TemplateListRequest, $0.TemplateList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateListRequest.fromBuffer(value),
        ($0.TemplateList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TemplateSaveFromProjectRequest,
            $0.TemplateAnswer>(
        'SaveFromProject',
        saveFromProject_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateSaveFromProjectRequest.fromBuffer(value),
        ($0.TemplateAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.TemplateSaveFromTaskRequest, $0.TemplateAnswer>(
            'SaveFromTask',
            saveFromTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.TemplateSaveFromTaskRequest.fromBuffer(value),
            ($0.TemplateAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TemplateUpdateRequest, $0.TemplateAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TemplateUpdateRequest.fromBuffer(value),
        ($0.TemplateAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.TemplateApplied> apply_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateApplyRequest> $request) async {
    return apply($call, await $request);
  }

  $async.Future<$0.TemplateApplied> apply(
      $grpc.ServiceCall call, $0.TemplateApplyRequest request);

  $async.Future<$0.TemplateAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.TemplateAnswer> create(
      $grpc.ServiceCall call, $0.TemplateCreateRequest request);

  $async.Future<$0.TemplateDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.TemplateDeleted> delete(
      $grpc.ServiceCall call, $0.TemplateDeleteRequest request);

  $async.Future<$0.TemplateAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.TemplateAnswer> get(
      $grpc.ServiceCall call, $0.TemplateGetRequest request);

  $async.Future<$0.TemplateList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.TemplateList> list(
      $grpc.ServiceCall call, $0.TemplateListRequest request);

  $async.Future<$0.TemplateAnswer> saveFromProject_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateSaveFromProjectRequest> $request) async {
    return saveFromProject($call, await $request);
  }

  $async.Future<$0.TemplateAnswer> saveFromProject(
      $grpc.ServiceCall call, $0.TemplateSaveFromProjectRequest request);

  $async.Future<$0.TemplateAnswer> saveFromTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateSaveFromTaskRequest> $request) async {
    return saveFromTask($call, await $request);
  }

  $async.Future<$0.TemplateAnswer> saveFromTask(
      $grpc.ServiceCall call, $0.TemplateSaveFromTaskRequest request);

  $async.Future<$0.TemplateAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemplateUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.TemplateAnswer> update(
      $grpc.ServiceCall call, $0.TemplateUpdateRequest request);
}
