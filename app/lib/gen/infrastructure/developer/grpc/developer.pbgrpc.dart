// This is a generated file - do not edit.
//
// Generated from infrastructure/developer/grpc/developer.proto.

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

import 'developer.pb.dart' as $0;

export 'developer.pb.dart';

@$pb.GrpcServiceName('config.developer.ApiTokenController')
class ApiTokenControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ApiTokenControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CatalogAnswer> catalog(
    $0.CatalogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$catalog, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApiTokenCreated> create(
    $0.ApiTokenCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApiTokenList> list(
    $0.ApiTokenListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApiTokenAnswer> revoke(
    $0.ApiTokenRevokeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revoke, request, options: options);
  }

  // method descriptors

  static final _$catalog =
      $grpc.ClientMethod<$0.CatalogRequest, $0.CatalogAnswer>(
          '/config.developer.ApiTokenController/Catalog',
          ($0.CatalogRequest value) => value.writeToBuffer(),
          $0.CatalogAnswer.fromBuffer);
  static final _$create =
      $grpc.ClientMethod<$0.ApiTokenCreateRequest, $0.ApiTokenCreated>(
          '/config.developer.ApiTokenController/Create',
          ($0.ApiTokenCreateRequest value) => value.writeToBuffer(),
          $0.ApiTokenCreated.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.ApiTokenListRequest, $0.ApiTokenList>(
          '/config.developer.ApiTokenController/List',
          ($0.ApiTokenListRequest value) => value.writeToBuffer(),
          $0.ApiTokenList.fromBuffer);
  static final _$revoke =
      $grpc.ClientMethod<$0.ApiTokenRevokeRequest, $0.ApiTokenAnswer>(
          '/config.developer.ApiTokenController/Revoke',
          ($0.ApiTokenRevokeRequest value) => value.writeToBuffer(),
          $0.ApiTokenAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.developer.ApiTokenController')
abstract class ApiTokenControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.developer.ApiTokenController';

  ApiTokenControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CatalogRequest, $0.CatalogAnswer>(
        'Catalog',
        catalog_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CatalogRequest.fromBuffer(value),
        ($0.CatalogAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ApiTokenCreateRequest, $0.ApiTokenCreated>(
            'Create',
            create_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ApiTokenCreateRequest.fromBuffer(value),
            ($0.ApiTokenCreated value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApiTokenListRequest, $0.ApiTokenList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ApiTokenListRequest.fromBuffer(value),
        ($0.ApiTokenList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApiTokenRevokeRequest, $0.ApiTokenAnswer>(
        'Revoke',
        revoke_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ApiTokenRevokeRequest.fromBuffer(value),
        ($0.ApiTokenAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.CatalogAnswer> catalog_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CatalogRequest> $request) async {
    return catalog($call, await $request);
  }

  $async.Future<$0.CatalogAnswer> catalog(
      $grpc.ServiceCall call, $0.CatalogRequest request);

  $async.Future<$0.ApiTokenCreated> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApiTokenCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.ApiTokenCreated> create(
      $grpc.ServiceCall call, $0.ApiTokenCreateRequest request);

  $async.Future<$0.ApiTokenList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApiTokenListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.ApiTokenList> list(
      $grpc.ServiceCall call, $0.ApiTokenListRequest request);

  $async.Future<$0.ApiTokenAnswer> revoke_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApiTokenRevokeRequest> $request) async {
    return revoke($call, await $request);
  }

  $async.Future<$0.ApiTokenAnswer> revoke(
      $grpc.ServiceCall call, $0.ApiTokenRevokeRequest request);
}

@$pb.GrpcServiceName('config.developer.ServiceAccountController')
class ServiceAccountControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ServiceAccountControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ServiceAccountAnswer> create(
    $0.ServiceAccountCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.ServiceAccountDeleted> delete(
    $0.ServiceAccountDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.ServiceAccountList> list(
    $0.ServiceAccountListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.ServiceAccountAnswer> setRole(
    $0.ServiceAccountSetRoleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRole, request, options: options);
  }

  // method descriptors

  static final _$create = $grpc.ClientMethod<$0.ServiceAccountCreateRequest,
          $0.ServiceAccountAnswer>(
      '/config.developer.ServiceAccountController/Create',
      ($0.ServiceAccountCreateRequest value) => value.writeToBuffer(),
      $0.ServiceAccountAnswer.fromBuffer);
  static final _$delete = $grpc.ClientMethod<$0.ServiceAccountDeleteRequest,
          $0.ServiceAccountDeleted>(
      '/config.developer.ServiceAccountController/Delete',
      ($0.ServiceAccountDeleteRequest value) => value.writeToBuffer(),
      $0.ServiceAccountDeleted.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.ServiceAccountListRequest, $0.ServiceAccountList>(
          '/config.developer.ServiceAccountController/List',
          ($0.ServiceAccountListRequest value) => value.writeToBuffer(),
          $0.ServiceAccountList.fromBuffer);
  static final _$setRole = $grpc.ClientMethod<$0.ServiceAccountSetRoleRequest,
          $0.ServiceAccountAnswer>(
      '/config.developer.ServiceAccountController/SetRole',
      ($0.ServiceAccountSetRoleRequest value) => value.writeToBuffer(),
      $0.ServiceAccountAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.developer.ServiceAccountController')
abstract class ServiceAccountControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.developer.ServiceAccountController';

  ServiceAccountControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ServiceAccountCreateRequest,
            $0.ServiceAccountAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ServiceAccountCreateRequest.fromBuffer(value),
        ($0.ServiceAccountAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ServiceAccountDeleteRequest,
            $0.ServiceAccountDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ServiceAccountDeleteRequest.fromBuffer(value),
        ($0.ServiceAccountDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ServiceAccountListRequest,
            $0.ServiceAccountList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ServiceAccountListRequest.fromBuffer(value),
        ($0.ServiceAccountList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ServiceAccountSetRoleRequest,
            $0.ServiceAccountAnswer>(
        'SetRole',
        setRole_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ServiceAccountSetRoleRequest.fromBuffer(value),
        ($0.ServiceAccountAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.ServiceAccountAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServiceAccountCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.ServiceAccountAnswer> create(
      $grpc.ServiceCall call, $0.ServiceAccountCreateRequest request);

  $async.Future<$0.ServiceAccountDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServiceAccountDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.ServiceAccountDeleted> delete(
      $grpc.ServiceCall call, $0.ServiceAccountDeleteRequest request);

  $async.Future<$0.ServiceAccountList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServiceAccountListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.ServiceAccountList> list(
      $grpc.ServiceCall call, $0.ServiceAccountListRequest request);

  $async.Future<$0.ServiceAccountAnswer> setRole_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServiceAccountSetRoleRequest> $request) async {
    return setRole($call, await $request);
  }

  $async.Future<$0.ServiceAccountAnswer> setRole(
      $grpc.ServiceCall call, $0.ServiceAccountSetRoleRequest request);
}

@$pb.GrpcServiceName('config.developer.WebhookController')
class WebhookControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WebhookControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.WebhookAnswer> create(
    $0.WebhookCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.WebhookDeleted> delete(
    $0.WebhookDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeliveryList> deliveries(
    $0.DeliveriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deliveries, request, options: options);
  }

  $grpc.ResponseFuture<$0.WebhookList> list(
    $0.WebhookListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeliveryAnswer> redeliver(
    $0.RedeliverRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$redeliver, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeliveryAnswer> test(
    $0.WebhookTestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$test, request, options: options);
  }

  $grpc.ResponseFuture<$0.WebhookAnswer> update(
    $0.WebhookUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.WebhookCreateRequest, $0.WebhookAnswer>(
          '/config.developer.WebhookController/Create',
          ($0.WebhookCreateRequest value) => value.writeToBuffer(),
          $0.WebhookAnswer.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.WebhookDeleteRequest, $0.WebhookDeleted>(
          '/config.developer.WebhookController/Delete',
          ($0.WebhookDeleteRequest value) => value.writeToBuffer(),
          $0.WebhookDeleted.fromBuffer);
  static final _$deliveries =
      $grpc.ClientMethod<$0.DeliveriesRequest, $0.DeliveryList>(
          '/config.developer.WebhookController/Deliveries',
          ($0.DeliveriesRequest value) => value.writeToBuffer(),
          $0.DeliveryList.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.WebhookListRequest, $0.WebhookList>(
          '/config.developer.WebhookController/List',
          ($0.WebhookListRequest value) => value.writeToBuffer(),
          $0.WebhookList.fromBuffer);
  static final _$redeliver =
      $grpc.ClientMethod<$0.RedeliverRequest, $0.DeliveryAnswer>(
          '/config.developer.WebhookController/Redeliver',
          ($0.RedeliverRequest value) => value.writeToBuffer(),
          $0.DeliveryAnswer.fromBuffer);
  static final _$test =
      $grpc.ClientMethod<$0.WebhookTestRequest, $0.DeliveryAnswer>(
          '/config.developer.WebhookController/Test',
          ($0.WebhookTestRequest value) => value.writeToBuffer(),
          $0.DeliveryAnswer.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.WebhookUpdateRequest, $0.WebhookAnswer>(
          '/config.developer.WebhookController/Update',
          ($0.WebhookUpdateRequest value) => value.writeToBuffer(),
          $0.WebhookAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.developer.WebhookController')
abstract class WebhookControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.developer.WebhookController';

  WebhookControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WebhookCreateRequest, $0.WebhookAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WebhookCreateRequest.fromBuffer(value),
        ($0.WebhookAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WebhookDeleteRequest, $0.WebhookDeleted>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WebhookDeleteRequest.fromBuffer(value),
        ($0.WebhookDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeliveriesRequest, $0.DeliveryList>(
        'Deliveries',
        deliveries_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeliveriesRequest.fromBuffer(value),
        ($0.DeliveryList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WebhookListRequest, $0.WebhookList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WebhookListRequest.fromBuffer(value),
        ($0.WebhookList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RedeliverRequest, $0.DeliveryAnswer>(
        'Redeliver',
        redeliver_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RedeliverRequest.fromBuffer(value),
        ($0.DeliveryAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WebhookTestRequest, $0.DeliveryAnswer>(
        'Test',
        test_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WebhookTestRequest.fromBuffer(value),
        ($0.DeliveryAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WebhookUpdateRequest, $0.WebhookAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WebhookUpdateRequest.fromBuffer(value),
        ($0.WebhookAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.WebhookAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WebhookCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.WebhookAnswer> create(
      $grpc.ServiceCall call, $0.WebhookCreateRequest request);

  $async.Future<$0.WebhookDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WebhookDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.WebhookDeleted> delete(
      $grpc.ServiceCall call, $0.WebhookDeleteRequest request);

  $async.Future<$0.DeliveryList> deliveries_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeliveriesRequest> $request) async {
    return deliveries($call, await $request);
  }

  $async.Future<$0.DeliveryList> deliveries(
      $grpc.ServiceCall call, $0.DeliveriesRequest request);

  $async.Future<$0.WebhookList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WebhookListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.WebhookList> list(
      $grpc.ServiceCall call, $0.WebhookListRequest request);

  $async.Future<$0.DeliveryAnswer> redeliver_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RedeliverRequest> $request) async {
    return redeliver($call, await $request);
  }

  $async.Future<$0.DeliveryAnswer> redeliver(
      $grpc.ServiceCall call, $0.RedeliverRequest request);

  $async.Future<$0.DeliveryAnswer> test_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WebhookTestRequest> $request) async {
    return test($call, await $request);
  }

  $async.Future<$0.DeliveryAnswer> test(
      $grpc.ServiceCall call, $0.WebhookTestRequest request);

  $async.Future<$0.WebhookAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WebhookUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.WebhookAnswer> update(
      $grpc.ServiceCall call, $0.WebhookUpdateRequest request);
}
