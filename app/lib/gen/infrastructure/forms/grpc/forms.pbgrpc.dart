// This is a generated file - do not edit.
//
// Generated from infrastructure/forms/grpc/forms.proto.

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

import 'forms.pb.dart' as $0;

export 'forms.pb.dart';

@$pb.GrpcServiceName('config.forms.FormController')
class FormControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FormControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.FormAnswer> create(
    $0.FormCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.FormDeleted> delete(
    $0.FormDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.FormList> list(
    $0.FormListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.SubmissionList> submissions(
    $0.SubmissionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$submissions, request, options: options);
  }

  $grpc.ResponseFuture<$0.FormAnswer> update(
    $0.FormUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.FormCreateRequest, $0.FormAnswer>(
          '/config.forms.FormController/Create',
          ($0.FormCreateRequest value) => value.writeToBuffer(),
          $0.FormAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.FormDeleteRequest, $0.FormDeleted>(
          '/config.forms.FormController/Delete',
          ($0.FormDeleteRequest value) => value.writeToBuffer(),
          $0.FormDeleted.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.FormListRequest, $0.FormList>(
      '/config.forms.FormController/List',
      ($0.FormListRequest value) => value.writeToBuffer(),
      $0.FormList.fromBuffer);
  static final _$submissions =
      $grpc.ClientMethod<$0.SubmissionsRequest, $0.SubmissionList>(
          '/config.forms.FormController/Submissions',
          ($0.SubmissionsRequest value) => value.writeToBuffer(),
          $0.SubmissionList.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.FormUpdateRequest, $0.FormAnswer>(
          '/config.forms.FormController/Update',
          ($0.FormUpdateRequest value) => value.writeToBuffer(),
          $0.FormAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.forms.FormController')
abstract class FormControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.forms.FormController';

  FormControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FormCreateRequest, $0.FormAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FormCreateRequest.fromBuffer(value),
        ($0.FormAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FormDeleteRequest, $0.FormDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FormDeleteRequest.fromBuffer(value),
        ($0.FormDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FormListRequest, $0.FormList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FormListRequest.fromBuffer(value),
        ($0.FormList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubmissionsRequest, $0.SubmissionList>(
        'Submissions',
        submissions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SubmissionsRequest.fromBuffer(value),
        ($0.SubmissionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FormUpdateRequest, $0.FormAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FormUpdateRequest.fromBuffer(value),
        ($0.FormAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.FormAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FormCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.FormAnswer> create(
      $grpc.ServiceCall call, $0.FormCreateRequest request);

  $async.Future<$0.FormDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FormDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.FormDeleted> delete(
      $grpc.ServiceCall call, $0.FormDeleteRequest request);

  $async.Future<$0.FormList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FormListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.FormList> list(
      $grpc.ServiceCall call, $0.FormListRequest request);

  $async.Future<$0.SubmissionList> submissions_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SubmissionsRequest> $request) async {
    return submissions($call, await $request);
  }

  $async.Future<$0.SubmissionList> submissions(
      $grpc.ServiceCall call, $0.SubmissionsRequest request);

  $async.Future<$0.FormAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FormUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.FormAnswer> update(
      $grpc.ServiceCall call, $0.FormUpdateRequest request);
}
