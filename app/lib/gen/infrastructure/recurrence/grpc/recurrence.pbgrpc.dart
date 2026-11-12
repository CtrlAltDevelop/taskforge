// This is a generated file - do not edit.
//
// Generated from infrastructure/recurrence/grpc/recurrence.proto.

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

import 'recurrence.pb.dart' as $0;

export 'recurrence.pb.dart';

@$pb.GrpcServiceName('config.recurrence.RecurrenceController')
class RecurrenceControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RecurrenceControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.RecurrenceCleared> clear(
    $0.RecurrenceClearRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clear, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrenceAnswer> get(
    $0.RecurrenceGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrenceSeriesAnswer> pause(
    $0.RecurrencePauseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pause, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrencePreview> preview(
    $0.RecurrencePreviewRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$preview, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrenceSeriesAnswer> set(
    $0.RecurrenceSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$set, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrenceUpcoming> upcoming(
    $0.RecurrenceUpcomingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$upcoming, request, options: options);
  }

  $grpc.ResponseFuture<$0.RecurrenceFutureUpdated> updateFuture(
    $0.RecurrenceUpdateFutureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateFuture, request, options: options);
  }

  // method descriptors

  static final _$clear =
      $grpc.ClientMethod<$0.RecurrenceClearRequest, $0.RecurrenceCleared>(
          '/config.recurrence.RecurrenceController/Clear',
          ($0.RecurrenceClearRequest value) => value.writeToBuffer(),
          $0.RecurrenceCleared.fromBuffer);
  static final _$get =
      $grpc.ClientMethod<$0.RecurrenceGetRequest, $0.RecurrenceAnswer>(
          '/config.recurrence.RecurrenceController/Get',
          ($0.RecurrenceGetRequest value) => value.writeToBuffer(),
          $0.RecurrenceAnswer.fromBuffer);
  static final _$pause =
      $grpc.ClientMethod<$0.RecurrencePauseRequest, $0.RecurrenceSeriesAnswer>(
          '/config.recurrence.RecurrenceController/Pause',
          ($0.RecurrencePauseRequest value) => value.writeToBuffer(),
          $0.RecurrenceSeriesAnswer.fromBuffer);
  static final _$preview =
      $grpc.ClientMethod<$0.RecurrencePreviewRequest, $0.RecurrencePreview>(
          '/config.recurrence.RecurrenceController/Preview',
          ($0.RecurrencePreviewRequest value) => value.writeToBuffer(),
          $0.RecurrencePreview.fromBuffer);
  static final _$set =
      $grpc.ClientMethod<$0.RecurrenceSetRequest, $0.RecurrenceSeriesAnswer>(
          '/config.recurrence.RecurrenceController/Set',
          ($0.RecurrenceSetRequest value) => value.writeToBuffer(),
          $0.RecurrenceSeriesAnswer.fromBuffer);
  static final _$upcoming =
      $grpc.ClientMethod<$0.RecurrenceUpcomingRequest, $0.RecurrenceUpcoming>(
          '/config.recurrence.RecurrenceController/Upcoming',
          ($0.RecurrenceUpcomingRequest value) => value.writeToBuffer(),
          $0.RecurrenceUpcoming.fromBuffer);
  static final _$updateFuture = $grpc.ClientMethod<
          $0.RecurrenceUpdateFutureRequest, $0.RecurrenceFutureUpdated>(
      '/config.recurrence.RecurrenceController/UpdateFuture',
      ($0.RecurrenceUpdateFutureRequest value) => value.writeToBuffer(),
      $0.RecurrenceFutureUpdated.fromBuffer);
}

@$pb.GrpcServiceName('config.recurrence.RecurrenceController')
abstract class RecurrenceControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.recurrence.RecurrenceController';

  RecurrenceControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.RecurrenceClearRequest, $0.RecurrenceCleared>(
            'Clear',
            clear_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RecurrenceClearRequest.fromBuffer(value),
            ($0.RecurrenceCleared value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RecurrenceGetRequest, $0.RecurrenceAnswer>(
            'Get',
            get_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RecurrenceGetRequest.fromBuffer(value),
            ($0.RecurrenceAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecurrencePauseRequest,
            $0.RecurrenceSeriesAnswer>(
        'Pause',
        pause_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RecurrencePauseRequest.fromBuffer(value),
        ($0.RecurrenceSeriesAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RecurrencePreviewRequest, $0.RecurrencePreview>(
            'Preview',
            preview_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RecurrencePreviewRequest.fromBuffer(value),
            ($0.RecurrencePreview value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RecurrenceSetRequest, $0.RecurrenceSeriesAnswer>(
            'Set',
            set_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RecurrenceSetRequest.fromBuffer(value),
            ($0.RecurrenceSeriesAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecurrenceUpcomingRequest,
            $0.RecurrenceUpcoming>(
        'Upcoming',
        upcoming_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RecurrenceUpcomingRequest.fromBuffer(value),
        ($0.RecurrenceUpcoming value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecurrenceUpdateFutureRequest,
            $0.RecurrenceFutureUpdated>(
        'UpdateFuture',
        updateFuture_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RecurrenceUpdateFutureRequest.fromBuffer(value),
        ($0.RecurrenceFutureUpdated value) => value.writeToBuffer()));
  }

  $async.Future<$0.RecurrenceCleared> clear_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrenceClearRequest> $request) async {
    return clear($call, await $request);
  }

  $async.Future<$0.RecurrenceCleared> clear(
      $grpc.ServiceCall call, $0.RecurrenceClearRequest request);

  $async.Future<$0.RecurrenceAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrenceGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.RecurrenceAnswer> get(
      $grpc.ServiceCall call, $0.RecurrenceGetRequest request);

  $async.Future<$0.RecurrenceSeriesAnswer> pause_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrencePauseRequest> $request) async {
    return pause($call, await $request);
  }

  $async.Future<$0.RecurrenceSeriesAnswer> pause(
      $grpc.ServiceCall call, $0.RecurrencePauseRequest request);

  $async.Future<$0.RecurrencePreview> preview_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrencePreviewRequest> $request) async {
    return preview($call, await $request);
  }

  $async.Future<$0.RecurrencePreview> preview(
      $grpc.ServiceCall call, $0.RecurrencePreviewRequest request);

  $async.Future<$0.RecurrenceSeriesAnswer> set_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrenceSetRequest> $request) async {
    return set($call, await $request);
  }

  $async.Future<$0.RecurrenceSeriesAnswer> set(
      $grpc.ServiceCall call, $0.RecurrenceSetRequest request);

  $async.Future<$0.RecurrenceUpcoming> upcoming_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RecurrenceUpcomingRequest> $request) async {
    return upcoming($call, await $request);
  }

  $async.Future<$0.RecurrenceUpcoming> upcoming(
      $grpc.ServiceCall call, $0.RecurrenceUpcomingRequest request);

  $async.Future<$0.RecurrenceFutureUpdated> updateFuture_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RecurrenceUpdateFutureRequest> $request) async {
    return updateFuture($call, await $request);
  }

  $async.Future<$0.RecurrenceFutureUpdated> updateFuture(
      $grpc.ServiceCall call, $0.RecurrenceUpdateFutureRequest request);
}
