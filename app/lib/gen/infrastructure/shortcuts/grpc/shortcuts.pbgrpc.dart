// This is a generated file - do not edit.
//
// Generated from infrastructure/shortcuts/grpc/shortcuts.proto.

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

import 'shortcuts.pb.dart' as $0;

export 'shortcuts.pb.dart';

@$pb.GrpcServiceName('config.shortcuts.ShortcutController')
class ShortcutControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ShortcutControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ShortcutList> get(
    $0.ShortcutGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.ShortcutList> set(
    $0.ShortcutSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$set, request, options: options);
  }

  // method descriptors

  static final _$get =
      $grpc.ClientMethod<$0.ShortcutGetRequest, $0.ShortcutList>(
          '/config.shortcuts.ShortcutController/Get',
          ($0.ShortcutGetRequest value) => value.writeToBuffer(),
          $0.ShortcutList.fromBuffer);
  static final _$set =
      $grpc.ClientMethod<$0.ShortcutSetRequest, $0.ShortcutList>(
          '/config.shortcuts.ShortcutController/Set',
          ($0.ShortcutSetRequest value) => value.writeToBuffer(),
          $0.ShortcutList.fromBuffer);
}

@$pb.GrpcServiceName('config.shortcuts.ShortcutController')
abstract class ShortcutControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.shortcuts.ShortcutController';

  ShortcutControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ShortcutGetRequest, $0.ShortcutList>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ShortcutGetRequest.fromBuffer(value),
        ($0.ShortcutList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ShortcutSetRequest, $0.ShortcutList>(
        'Set',
        set_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ShortcutSetRequest.fromBuffer(value),
        ($0.ShortcutList value) => value.writeToBuffer()));
  }

  $async.Future<$0.ShortcutList> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ShortcutGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.ShortcutList> get(
      $grpc.ServiceCall call, $0.ShortcutGetRequest request);

  $async.Future<$0.ShortcutList> set_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ShortcutSetRequest> $request) async {
    return set($call, await $request);
  }

  $async.Future<$0.ShortcutList> set(
      $grpc.ServiceCall call, $0.ShortcutSetRequest request);
}
