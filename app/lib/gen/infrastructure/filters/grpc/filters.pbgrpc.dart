// This is a generated file - do not edit.
//
// Generated from infrastructure/filters/grpc/filters.proto.

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

import 'filters.pb.dart' as $0;

export 'filters.pb.dart';

@$pb.GrpcServiceName('config.filters.FilterController')
class FilterControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FilterControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Filter> delete(
    $0.FilterDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.FilterList> list(
    $0.FilterListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.Filter> save(
    $0.FilterSaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$save, request, options: options);
  }

  // method descriptors

  static final _$delete = $grpc.ClientMethod<$0.FilterDeleteRequest, $0.Filter>(
      '/config.filters.FilterController/Delete',
      ($0.FilterDeleteRequest value) => value.writeToBuffer(),
      $0.Filter.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.FilterListRequest, $0.FilterList>(
      '/config.filters.FilterController/List',
      ($0.FilterListRequest value) => value.writeToBuffer(),
      $0.FilterList.fromBuffer);
  static final _$save = $grpc.ClientMethod<$0.FilterSaveRequest, $0.Filter>(
      '/config.filters.FilterController/Save',
      ($0.FilterSaveRequest value) => value.writeToBuffer(),
      $0.Filter.fromBuffer);
}

@$pb.GrpcServiceName('config.filters.FilterController')
abstract class FilterControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.filters.FilterController';

  FilterControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FilterDeleteRequest, $0.Filter>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FilterDeleteRequest.fromBuffer(value),
        ($0.Filter value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FilterListRequest, $0.FilterList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FilterListRequest.fromBuffer(value),
        ($0.FilterList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FilterSaveRequest, $0.Filter>(
        'Save',
        save_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FilterSaveRequest.fromBuffer(value),
        ($0.Filter value) => value.writeToBuffer()));
  }

  $async.Future<$0.Filter> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilterDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Filter> delete(
      $grpc.ServiceCall call, $0.FilterDeleteRequest request);

  $async.Future<$0.FilterList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilterListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.FilterList> list(
      $grpc.ServiceCall call, $0.FilterListRequest request);

  $async.Future<$0.Filter> save_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FilterSaveRequest> $request) async {
    return save($call, await $request);
  }

  $async.Future<$0.Filter> save(
      $grpc.ServiceCall call, $0.FilterSaveRequest request);
}

@$pb.GrpcServiceName('config.filters.QueryController')
class QueryControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  QueryControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.QuerySuggestions> suggest(
    $0.QuerySuggestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$suggest, request, options: options);
  }

  $grpc.ResponseFuture<$0.QueryChecked> validate(
    $0.QueryValidateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validate, request, options: options);
  }

  // method descriptors

  static final _$suggest =
      $grpc.ClientMethod<$0.QuerySuggestRequest, $0.QuerySuggestions>(
          '/config.filters.QueryController/Suggest',
          ($0.QuerySuggestRequest value) => value.writeToBuffer(),
          $0.QuerySuggestions.fromBuffer);
  static final _$validate =
      $grpc.ClientMethod<$0.QueryValidateRequest, $0.QueryChecked>(
          '/config.filters.QueryController/Validate',
          ($0.QueryValidateRequest value) => value.writeToBuffer(),
          $0.QueryChecked.fromBuffer);
}

@$pb.GrpcServiceName('config.filters.QueryController')
abstract class QueryControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.filters.QueryController';

  QueryControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.QuerySuggestRequest, $0.QuerySuggestions>(
        'Suggest',
        suggest_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.QuerySuggestRequest.fromBuffer(value),
        ($0.QuerySuggestions value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.QueryValidateRequest, $0.QueryChecked>(
        'Validate',
        validate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.QueryValidateRequest.fromBuffer(value),
        ($0.QueryChecked value) => value.writeToBuffer()));
  }

  $async.Future<$0.QuerySuggestions> suggest_Pre($grpc.ServiceCall $call,
      $async.Future<$0.QuerySuggestRequest> $request) async {
    return suggest($call, await $request);
  }

  $async.Future<$0.QuerySuggestions> suggest(
      $grpc.ServiceCall call, $0.QuerySuggestRequest request);

  $async.Future<$0.QueryChecked> validate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.QueryValidateRequest> $request) async {
    return validate($call, await $request);
  }

  $async.Future<$0.QueryChecked> validate(
      $grpc.ServiceCall call, $0.QueryValidateRequest request);
}
