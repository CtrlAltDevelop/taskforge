// This is a generated file - do not edit.
//
// Generated from infrastructure/savedviews/grpc/savedviews.proto.

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

import 'savedviews.pb.dart' as $0;

export 'savedviews.pb.dart';

@$pb.GrpcServiceName('config.savedviews.ViewController')
class ViewControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ViewControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SavedView> delete(
    $0.ViewDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.ViewList> list(
    $0.ViewListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.SavedView> save(
    $0.ViewSaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$save, request, options: options);
  }

  // method descriptors

  static final _$delete =
      $grpc.ClientMethod<$0.ViewDeleteRequest, $0.SavedView>(
          '/config.savedviews.ViewController/Delete',
          ($0.ViewDeleteRequest value) => value.writeToBuffer(),
          $0.SavedView.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.ViewListRequest, $0.ViewList>(
      '/config.savedviews.ViewController/List',
      ($0.ViewListRequest value) => value.writeToBuffer(),
      $0.ViewList.fromBuffer);
  static final _$save = $grpc.ClientMethod<$0.ViewSaveRequest, $0.SavedView>(
      '/config.savedviews.ViewController/Save',
      ($0.ViewSaveRequest value) => value.writeToBuffer(),
      $0.SavedView.fromBuffer);
}

@$pb.GrpcServiceName('config.savedviews.ViewController')
abstract class ViewControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.savedviews.ViewController';

  ViewControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ViewDeleteRequest, $0.SavedView>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ViewDeleteRequest.fromBuffer(value),
        ($0.SavedView value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ViewListRequest, $0.ViewList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ViewListRequest.fromBuffer(value),
        ($0.ViewList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ViewSaveRequest, $0.SavedView>(
        'Save',
        save_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ViewSaveRequest.fromBuffer(value),
        ($0.SavedView value) => value.writeToBuffer()));
  }

  $async.Future<$0.SavedView> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ViewDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.SavedView> delete(
      $grpc.ServiceCall call, $0.ViewDeleteRequest request);

  $async.Future<$0.ViewList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ViewListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.ViewList> list(
      $grpc.ServiceCall call, $0.ViewListRequest request);

  $async.Future<$0.SavedView> save_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ViewSaveRequest> $request) async {
    return save($call, await $request);
  }

  $async.Future<$0.SavedView> save(
      $grpc.ServiceCall call, $0.ViewSaveRequest request);
}
