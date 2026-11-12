// This is a generated file - do not edit.
//
// Generated from infrastructure/imports/grpc/imports.proto.

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

import 'imports.pb.dart' as $0;

export 'imports.pb.dart';

@$pb.GrpcServiceName('config.imports.ExportController')
class ExportControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ExportControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ExportStarted> start(
    $0.ExportStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$0.ExportStatus> status(
    $0.ExportStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$status, request, options: options);
  }

  // method descriptors

  static final _$start =
      $grpc.ClientMethod<$0.ExportStartRequest, $0.ExportStarted>(
          '/config.imports.ExportController/Start',
          ($0.ExportStartRequest value) => value.writeToBuffer(),
          $0.ExportStarted.fromBuffer);
  static final _$status =
      $grpc.ClientMethod<$0.ExportStatusRequest, $0.ExportStatus>(
          '/config.imports.ExportController/Status',
          ($0.ExportStatusRequest value) => value.writeToBuffer(),
          $0.ExportStatus.fromBuffer);
}

@$pb.GrpcServiceName('config.imports.ExportController')
abstract class ExportControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.imports.ExportController';

  ExportControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ExportStartRequest, $0.ExportStarted>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExportStartRequest.fromBuffer(value),
        ($0.ExportStarted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportStatusRequest, $0.ExportStatus>(
        'Status',
        status_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExportStatusRequest.fromBuffer(value),
        ($0.ExportStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.ExportStarted> start_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExportStartRequest> $request) async {
    return start($call, await $request);
  }

  $async.Future<$0.ExportStarted> start(
      $grpc.ServiceCall call, $0.ExportStartRequest request);

  $async.Future<$0.ExportStatus> status_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExportStatusRequest> $request) async {
    return status($call, await $request);
  }

  $async.Future<$0.ExportStatus> status(
      $grpc.ServiceCall call, $0.ExportStatusRequest request);
}

@$pb.GrpcServiceName('config.imports.ImportController')
class ImportControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ImportControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ImportProposal> analyze(
    $0.ImportAnalyzeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$analyze, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportCancelled> cancel(
    $0.ImportCancelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancel, request, options: options);
  }

  $grpc.ResponseFuture<$0.PlaceholderClaimed> claimPlaceholder(
    $0.PlaceholderClaimRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$claimPlaceholder, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportDiscarded> discard(
    $0.ImportDiscardRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$discard, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportReport> dryRun(
    $0.ImportDryRunRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dryRun, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportDetail> get(
    $0.ImportGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportList> list(
    $0.ImportListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.PlaceholderList> listPlaceholders(
    $0.PlaceholderListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPlaceholders, request, options: options);
  }

  $grpc.ResponseStream<$0.ImportProgress> progress(
    $0.ImportProgressRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$progress, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.ImportStarted> start(
    $0.ImportStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportUndone> undo(
    $0.ImportUndoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$undo, request, options: options);
  }

  // method descriptors

  static final _$analyze =
      $grpc.ClientMethod<$0.ImportAnalyzeRequest, $0.ImportProposal>(
          '/config.imports.ImportController/Analyze',
          ($0.ImportAnalyzeRequest value) => value.writeToBuffer(),
          $0.ImportProposal.fromBuffer);
  static final _$cancel =
      $grpc.ClientMethod<$0.ImportCancelRequest, $0.ImportCancelled>(
          '/config.imports.ImportController/Cancel',
          ($0.ImportCancelRequest value) => value.writeToBuffer(),
          $0.ImportCancelled.fromBuffer);
  static final _$claimPlaceholder =
      $grpc.ClientMethod<$0.PlaceholderClaimRequest, $0.PlaceholderClaimed>(
          '/config.imports.ImportController/ClaimPlaceholder',
          ($0.PlaceholderClaimRequest value) => value.writeToBuffer(),
          $0.PlaceholderClaimed.fromBuffer);
  static final _$discard =
      $grpc.ClientMethod<$0.ImportDiscardRequest, $0.ImportDiscarded>(
          '/config.imports.ImportController/Discard',
          ($0.ImportDiscardRequest value) => value.writeToBuffer(),
          $0.ImportDiscarded.fromBuffer);
  static final _$dryRun =
      $grpc.ClientMethod<$0.ImportDryRunRequest, $0.ImportReport>(
          '/config.imports.ImportController/DryRun',
          ($0.ImportDryRunRequest value) => value.writeToBuffer(),
          $0.ImportReport.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.ImportGetRequest, $0.ImportDetail>(
      '/config.imports.ImportController/Get',
      ($0.ImportGetRequest value) => value.writeToBuffer(),
      $0.ImportDetail.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.ImportListRequest, $0.ImportList>(
      '/config.imports.ImportController/List',
      ($0.ImportListRequest value) => value.writeToBuffer(),
      $0.ImportList.fromBuffer);
  static final _$listPlaceholders =
      $grpc.ClientMethod<$0.PlaceholderListRequest, $0.PlaceholderList>(
          '/config.imports.ImportController/ListPlaceholders',
          ($0.PlaceholderListRequest value) => value.writeToBuffer(),
          $0.PlaceholderList.fromBuffer);
  static final _$progress =
      $grpc.ClientMethod<$0.ImportProgressRequest, $0.ImportProgress>(
          '/config.imports.ImportController/Progress',
          ($0.ImportProgressRequest value) => value.writeToBuffer(),
          $0.ImportProgress.fromBuffer);
  static final _$start =
      $grpc.ClientMethod<$0.ImportStartRequest, $0.ImportStarted>(
          '/config.imports.ImportController/Start',
          ($0.ImportStartRequest value) => value.writeToBuffer(),
          $0.ImportStarted.fromBuffer);
  static final _$undo =
      $grpc.ClientMethod<$0.ImportUndoRequest, $0.ImportUndone>(
          '/config.imports.ImportController/Undo',
          ($0.ImportUndoRequest value) => value.writeToBuffer(),
          $0.ImportUndone.fromBuffer);
}

@$pb.GrpcServiceName('config.imports.ImportController')
abstract class ImportControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.imports.ImportController';

  ImportControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ImportAnalyzeRequest, $0.ImportProposal>(
        'Analyze',
        analyze_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportAnalyzeRequest.fromBuffer(value),
        ($0.ImportProposal value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportCancelRequest, $0.ImportCancelled>(
        'Cancel',
        cancel_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportCancelRequest.fromBuffer(value),
        ($0.ImportCancelled value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PlaceholderClaimRequest, $0.PlaceholderClaimed>(
            'ClaimPlaceholder',
            claimPlaceholder_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PlaceholderClaimRequest.fromBuffer(value),
            ($0.PlaceholderClaimed value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportDiscardRequest, $0.ImportDiscarded>(
        'Discard',
        discard_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportDiscardRequest.fromBuffer(value),
        ($0.ImportDiscarded value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportDryRunRequest, $0.ImportReport>(
        'DryRun',
        dryRun_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportDryRunRequest.fromBuffer(value),
        ($0.ImportReport value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportGetRequest, $0.ImportDetail>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ImportGetRequest.fromBuffer(value),
        ($0.ImportDetail value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportListRequest, $0.ImportList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ImportListRequest.fromBuffer(value),
        ($0.ImportList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PlaceholderListRequest, $0.PlaceholderList>(
            'ListPlaceholders',
            listPlaceholders_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PlaceholderListRequest.fromBuffer(value),
            ($0.PlaceholderList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportProgressRequest, $0.ImportProgress>(
        'Progress',
        progress_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ImportProgressRequest.fromBuffer(value),
        ($0.ImportProgress value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportStartRequest, $0.ImportStarted>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportStartRequest.fromBuffer(value),
        ($0.ImportStarted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportUndoRequest, $0.ImportUndone>(
        'Undo',
        undo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ImportUndoRequest.fromBuffer(value),
        ($0.ImportUndone value) => value.writeToBuffer()));
  }

  $async.Future<$0.ImportProposal> analyze_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportAnalyzeRequest> $request) async {
    return analyze($call, await $request);
  }

  $async.Future<$0.ImportProposal> analyze(
      $grpc.ServiceCall call, $0.ImportAnalyzeRequest request);

  $async.Future<$0.ImportCancelled> cancel_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportCancelRequest> $request) async {
    return cancel($call, await $request);
  }

  $async.Future<$0.ImportCancelled> cancel(
      $grpc.ServiceCall call, $0.ImportCancelRequest request);

  $async.Future<$0.PlaceholderClaimed> claimPlaceholder_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PlaceholderClaimRequest> $request) async {
    return claimPlaceholder($call, await $request);
  }

  $async.Future<$0.PlaceholderClaimed> claimPlaceholder(
      $grpc.ServiceCall call, $0.PlaceholderClaimRequest request);

  $async.Future<$0.ImportDiscarded> discard_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportDiscardRequest> $request) async {
    return discard($call, await $request);
  }

  $async.Future<$0.ImportDiscarded> discard(
      $grpc.ServiceCall call, $0.ImportDiscardRequest request);

  $async.Future<$0.ImportReport> dryRun_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportDryRunRequest> $request) async {
    return dryRun($call, await $request);
  }

  $async.Future<$0.ImportReport> dryRun(
      $grpc.ServiceCall call, $0.ImportDryRunRequest request);

  $async.Future<$0.ImportDetail> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.ImportDetail> get(
      $grpc.ServiceCall call, $0.ImportGetRequest request);

  $async.Future<$0.ImportList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.ImportList> list(
      $grpc.ServiceCall call, $0.ImportListRequest request);

  $async.Future<$0.PlaceholderList> listPlaceholders_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PlaceholderListRequest> $request) async {
    return listPlaceholders($call, await $request);
  }

  $async.Future<$0.PlaceholderList> listPlaceholders(
      $grpc.ServiceCall call, $0.PlaceholderListRequest request);

  $async.Stream<$0.ImportProgress> progress_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportProgressRequest> $request) async* {
    yield* progress($call, await $request);
  }

  $async.Stream<$0.ImportProgress> progress(
      $grpc.ServiceCall call, $0.ImportProgressRequest request);

  $async.Future<$0.ImportStarted> start_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportStartRequest> $request) async {
    return start($call, await $request);
  }

  $async.Future<$0.ImportStarted> start(
      $grpc.ServiceCall call, $0.ImportStartRequest request);

  $async.Future<$0.ImportUndone> undo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImportUndoRequest> $request) async {
    return undo($call, await $request);
  }

  $async.Future<$0.ImportUndone> undo(
      $grpc.ServiceCall call, $0.ImportUndoRequest request);
}
