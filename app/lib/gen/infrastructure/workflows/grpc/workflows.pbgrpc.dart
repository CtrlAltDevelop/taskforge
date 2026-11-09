// This is a generated file - do not edit.
//
// Generated from infrastructure/workflows/grpc/workflows.proto.

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

import 'workflows.pb.dart' as $0;

export 'workflows.pb.dart';

@$pb.GrpcServiceName('config.workflows.WorkflowController')
class WorkflowControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WorkflowControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Workflow> get(
    $0.WorkflowGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workflow> update(
    $0.WorkflowUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkflowProblems> validate(
    $0.WorkflowValidateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validate, request, options: options);
  }

  // method descriptors

  static final _$get = $grpc.ClientMethod<$0.WorkflowGetRequest, $0.Workflow>(
      '/config.workflows.WorkflowController/Get',
      ($0.WorkflowGetRequest value) => value.writeToBuffer(),
      $0.Workflow.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.WorkflowUpdateRequest, $0.Workflow>(
          '/config.workflows.WorkflowController/Update',
          ($0.WorkflowUpdateRequest value) => value.writeToBuffer(),
          $0.Workflow.fromBuffer);
  static final _$validate =
      $grpc.ClientMethod<$0.WorkflowValidateRequest, $0.WorkflowProblems>(
          '/config.workflows.WorkflowController/Validate',
          ($0.WorkflowValidateRequest value) => value.writeToBuffer(),
          $0.WorkflowProblems.fromBuffer);
}

@$pb.GrpcServiceName('config.workflows.WorkflowController')
abstract class WorkflowControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workflows.WorkflowController';

  WorkflowControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WorkflowGetRequest, $0.Workflow>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkflowGetRequest.fromBuffer(value),
        ($0.Workflow value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkflowUpdateRequest, $0.Workflow>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkflowUpdateRequest.fromBuffer(value),
        ($0.Workflow value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.WorkflowValidateRequest, $0.WorkflowProblems>(
            'Validate',
            validate_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.WorkflowValidateRequest.fromBuffer(value),
            ($0.WorkflowProblems value) => value.writeToBuffer()));
  }

  $async.Future<$0.Workflow> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkflowGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.Workflow> get(
      $grpc.ServiceCall call, $0.WorkflowGetRequest request);

  $async.Future<$0.Workflow> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkflowUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Workflow> update(
      $grpc.ServiceCall call, $0.WorkflowUpdateRequest request);

  $async.Future<$0.WorkflowProblems> validate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkflowValidateRequest> $request) async {
    return validate($call, await $request);
  }

  $async.Future<$0.WorkflowProblems> validate(
      $grpc.ServiceCall call, $0.WorkflowValidateRequest request);
}
