// This is a generated file - do not edit.
//
// Generated from infrastructure/search/grpc/search.proto.

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

import 'search.pb.dart' as $0;

export 'search.pb.dart';

@$pb.GrpcServiceName('config.search.SearchController')
class SearchControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SearchControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SearchResults> query(
    $0.SearchQueryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$query, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchRecent> recent(
    $0.SearchRecentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recent, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchRemembered> remember(
    $0.SearchRememberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$remember, request, options: options);
  }

  // method descriptors

  static final _$query =
      $grpc.ClientMethod<$0.SearchQueryRequest, $0.SearchResults>(
          '/config.search.SearchController/Query',
          ($0.SearchQueryRequest value) => value.writeToBuffer(),
          $0.SearchResults.fromBuffer);
  static final _$recent =
      $grpc.ClientMethod<$0.SearchRecentRequest, $0.SearchRecent>(
          '/config.search.SearchController/Recent',
          ($0.SearchRecentRequest value) => value.writeToBuffer(),
          $0.SearchRecent.fromBuffer);
  static final _$remember =
      $grpc.ClientMethod<$0.SearchRememberRequest, $0.SearchRemembered>(
          '/config.search.SearchController/Remember',
          ($0.SearchRememberRequest value) => value.writeToBuffer(),
          $0.SearchRemembered.fromBuffer);
}

@$pb.GrpcServiceName('config.search.SearchController')
abstract class SearchControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.search.SearchController';

  SearchControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SearchQueryRequest, $0.SearchResults>(
        'Query',
        query_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SearchQueryRequest.fromBuffer(value),
        ($0.SearchResults value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchRecentRequest, $0.SearchRecent>(
        'Recent',
        recent_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SearchRecentRequest.fromBuffer(value),
        ($0.SearchRecent value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SearchRememberRequest, $0.SearchRemembered>(
            'Remember',
            remember_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SearchRememberRequest.fromBuffer(value),
            ($0.SearchRemembered value) => value.writeToBuffer()));
  }

  $async.Future<$0.SearchResults> query_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SearchQueryRequest> $request) async {
    return query($call, await $request);
  }

  $async.Future<$0.SearchResults> query(
      $grpc.ServiceCall call, $0.SearchQueryRequest request);

  $async.Future<$0.SearchRecent> recent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SearchRecentRequest> $request) async {
    return recent($call, await $request);
  }

  $async.Future<$0.SearchRecent> recent(
      $grpc.ServiceCall call, $0.SearchRecentRequest request);

  $async.Future<$0.SearchRemembered> remember_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SearchRememberRequest> $request) async {
    return remember($call, await $request);
  }

  $async.Future<$0.SearchRemembered> remember(
      $grpc.ServiceCall call, $0.SearchRememberRequest request);
}
