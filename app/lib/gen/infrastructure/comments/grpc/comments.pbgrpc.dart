// This is a generated file - do not edit.
//
// Generated from infrastructure/comments/grpc/comments.proto.

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

import 'comments.pb.dart' as $0;

export 'comments.pb.dart';

@$pb.GrpcServiceName('config.comments.CommentController')
class CommentControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CommentControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Comment> create(
    $0.CommentCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Comment> delete(
    $0.CommentDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.Comment> edit(
    $0.CommentEditRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$edit, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommentHistory> history(
    $0.CommentHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$history, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommentPage> list(
    $0.CommentListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommentMentionable> mentionable(
    $0.CommentMentionableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$mentionable, request, options: options);
  }

  $grpc.ResponseFuture<$0.Comment> pin(
    $0.CommentPinRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pin, request, options: options);
  }

  $grpc.ResponseFuture<$0.Comment> react(
    $0.CommentReactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$react, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommentSubtask> toSubtask(
    $0.CommentToSubtaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$toSubtask, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.CommentCreateRequest, $0.Comment>(
          '/config.comments.CommentController/Create',
          ($0.CommentCreateRequest value) => value.writeToBuffer(),
          $0.Comment.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.CommentDeleteRequest, $0.Comment>(
          '/config.comments.CommentController/Delete',
          ($0.CommentDeleteRequest value) => value.writeToBuffer(),
          $0.Comment.fromBuffer);
  static final _$edit = $grpc.ClientMethod<$0.CommentEditRequest, $0.Comment>(
      '/config.comments.CommentController/Edit',
      ($0.CommentEditRequest value) => value.writeToBuffer(),
      $0.Comment.fromBuffer);
  static final _$history =
      $grpc.ClientMethod<$0.CommentHistoryRequest, $0.CommentHistory>(
          '/config.comments.CommentController/History',
          ($0.CommentHistoryRequest value) => value.writeToBuffer(),
          $0.CommentHistory.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.CommentListRequest, $0.CommentPage>(
          '/config.comments.CommentController/List',
          ($0.CommentListRequest value) => value.writeToBuffer(),
          $0.CommentPage.fromBuffer);
  static final _$mentionable =
      $grpc.ClientMethod<$0.CommentMentionableRequest, $0.CommentMentionable>(
          '/config.comments.CommentController/Mentionable',
          ($0.CommentMentionableRequest value) => value.writeToBuffer(),
          $0.CommentMentionable.fromBuffer);
  static final _$pin = $grpc.ClientMethod<$0.CommentPinRequest, $0.Comment>(
      '/config.comments.CommentController/Pin',
      ($0.CommentPinRequest value) => value.writeToBuffer(),
      $0.Comment.fromBuffer);
  static final _$react = $grpc.ClientMethod<$0.CommentReactRequest, $0.Comment>(
      '/config.comments.CommentController/React',
      ($0.CommentReactRequest value) => value.writeToBuffer(),
      $0.Comment.fromBuffer);
  static final _$toSubtask =
      $grpc.ClientMethod<$0.CommentToSubtaskRequest, $0.CommentSubtask>(
          '/config.comments.CommentController/ToSubtask',
          ($0.CommentToSubtaskRequest value) => value.writeToBuffer(),
          $0.CommentSubtask.fromBuffer);
}

@$pb.GrpcServiceName('config.comments.CommentController')
abstract class CommentControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.comments.CommentController';

  CommentControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CommentCreateRequest, $0.Comment>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentCreateRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentDeleteRequest, $0.Comment>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentDeleteRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentEditRequest, $0.Comment>(
        'Edit',
        edit_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentEditRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentHistoryRequest, $0.CommentHistory>(
        'History',
        history_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentHistoryRequest.fromBuffer(value),
        ($0.CommentHistory value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentListRequest, $0.CommentPage>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentListRequest.fromBuffer(value),
        ($0.CommentPage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentMentionableRequest,
            $0.CommentMentionable>(
        'Mentionable',
        mentionable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentMentionableRequest.fromBuffer(value),
        ($0.CommentMentionable value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentPinRequest, $0.Comment>(
        'Pin',
        pin_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CommentPinRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommentReactRequest, $0.Comment>(
        'React',
        react_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CommentReactRequest.fromBuffer(value),
        ($0.Comment value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CommentToSubtaskRequest, $0.CommentSubtask>(
            'ToSubtask',
            toSubtask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CommentToSubtaskRequest.fromBuffer(value),
            ($0.CommentSubtask value) => value.writeToBuffer()));
  }

  $async.Future<$0.Comment> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Comment> create(
      $grpc.ServiceCall call, $0.CommentCreateRequest request);

  $async.Future<$0.Comment> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Comment> delete(
      $grpc.ServiceCall call, $0.CommentDeleteRequest request);

  $async.Future<$0.Comment> edit_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentEditRequest> $request) async {
    return edit($call, await $request);
  }

  $async.Future<$0.Comment> edit(
      $grpc.ServiceCall call, $0.CommentEditRequest request);

  $async.Future<$0.CommentHistory> history_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentHistoryRequest> $request) async {
    return history($call, await $request);
  }

  $async.Future<$0.CommentHistory> history(
      $grpc.ServiceCall call, $0.CommentHistoryRequest request);

  $async.Future<$0.CommentPage> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.CommentPage> list(
      $grpc.ServiceCall call, $0.CommentListRequest request);

  $async.Future<$0.CommentMentionable> mentionable_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentMentionableRequest> $request) async {
    return mentionable($call, await $request);
  }

  $async.Future<$0.CommentMentionable> mentionable(
      $grpc.ServiceCall call, $0.CommentMentionableRequest request);

  $async.Future<$0.Comment> pin_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentPinRequest> $request) async {
    return pin($call, await $request);
  }

  $async.Future<$0.Comment> pin(
      $grpc.ServiceCall call, $0.CommentPinRequest request);

  $async.Future<$0.Comment> react_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentReactRequest> $request) async {
    return react($call, await $request);
  }

  $async.Future<$0.Comment> react(
      $grpc.ServiceCall call, $0.CommentReactRequest request);

  $async.Future<$0.CommentSubtask> toSubtask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommentToSubtaskRequest> $request) async {
    return toSubtask($call, await $request);
  }

  $async.Future<$0.CommentSubtask> toSubtask(
      $grpc.ServiceCall call, $0.CommentToSubtaskRequest request);
}
