// This is a generated file - do not edit.
//
// Generated from infrastructure/attachments/grpc/attachments.proto.

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

import 'attachments.pb.dart' as $0;

export 'attachments.pb.dart';

@$pb.GrpcServiceName('config.attachments.AttachmentController')
class AttachmentControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AttachmentControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Attachment> delete(
    $0.AttachmentDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.AttachmentList> list(
    $0.AttachmentListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.StorageUsage> usage(
    $0.UsageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$usage, request, options: options);
  }

  // method descriptors

  static final _$delete =
      $grpc.ClientMethod<$0.AttachmentDeleteRequest, $0.Attachment>(
          '/config.attachments.AttachmentController/Delete',
          ($0.AttachmentDeleteRequest value) => value.writeToBuffer(),
          $0.Attachment.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.AttachmentListRequest, $0.AttachmentList>(
          '/config.attachments.AttachmentController/List',
          ($0.AttachmentListRequest value) => value.writeToBuffer(),
          $0.AttachmentList.fromBuffer);
  static final _$usage = $grpc.ClientMethod<$0.UsageRequest, $0.StorageUsage>(
      '/config.attachments.AttachmentController/Usage',
      ($0.UsageRequest value) => value.writeToBuffer(),
      $0.StorageUsage.fromBuffer);
}

@$pb.GrpcServiceName('config.attachments.AttachmentController')
abstract class AttachmentControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.attachments.AttachmentController';

  AttachmentControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AttachmentDeleteRequest, $0.Attachment>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AttachmentDeleteRequest.fromBuffer(value),
        ($0.Attachment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AttachmentListRequest, $0.AttachmentList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AttachmentListRequest.fromBuffer(value),
        ($0.AttachmentList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UsageRequest, $0.StorageUsage>(
        'Usage',
        usage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UsageRequest.fromBuffer(value),
        ($0.StorageUsage value) => value.writeToBuffer()));
  }

  $async.Future<$0.Attachment> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AttachmentDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Attachment> delete(
      $grpc.ServiceCall call, $0.AttachmentDeleteRequest request);

  $async.Future<$0.AttachmentList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AttachmentListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.AttachmentList> list(
      $grpc.ServiceCall call, $0.AttachmentListRequest request);

  $async.Future<$0.StorageUsage> usage_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UsageRequest> $request) async {
    return usage($call, await $request);
  }

  $async.Future<$0.StorageUsage> usage(
      $grpc.ServiceCall call, $0.UsageRequest request);
}
