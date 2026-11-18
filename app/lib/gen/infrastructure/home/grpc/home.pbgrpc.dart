// This is a generated file - do not edit.
//
// Generated from infrastructure/home/grpc/home.proto.

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

import 'home.pb.dart' as $0;

export 'home.pb.dart';

@$pb.GrpcServiceName('config.home.HomeController')
class HomeControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  HomeControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.HomeMyWork> myWork(
    $0.HomeMyWorkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$myWork, request, options: options);
  }

  $grpc.ResponseFuture<$0.HomePinned> pinDashboard(
    $0.HomePinDashboardRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pinDashboard, request, options: options);
  }

  $grpc.ResponseFuture<$0.HomeRecorded> recordRecent(
    $0.HomeRecordRecentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recordRecent, request, options: options);
  }

  $grpc.ResponseFuture<$0.HomeSummary> summary(
    $0.HomeSummaryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$summary, request, options: options);
  }

  // method descriptors

  static final _$myWork =
      $grpc.ClientMethod<$0.HomeMyWorkRequest, $0.HomeMyWork>(
          '/config.home.HomeController/MyWork',
          ($0.HomeMyWorkRequest value) => value.writeToBuffer(),
          $0.HomeMyWork.fromBuffer);
  static final _$pinDashboard =
      $grpc.ClientMethod<$0.HomePinDashboardRequest, $0.HomePinned>(
          '/config.home.HomeController/PinDashboard',
          ($0.HomePinDashboardRequest value) => value.writeToBuffer(),
          $0.HomePinned.fromBuffer);
  static final _$recordRecent =
      $grpc.ClientMethod<$0.HomeRecordRecentRequest, $0.HomeRecorded>(
          '/config.home.HomeController/RecordRecent',
          ($0.HomeRecordRecentRequest value) => value.writeToBuffer(),
          $0.HomeRecorded.fromBuffer);
  static final _$summary =
      $grpc.ClientMethod<$0.HomeSummaryRequest, $0.HomeSummary>(
          '/config.home.HomeController/Summary',
          ($0.HomeSummaryRequest value) => value.writeToBuffer(),
          $0.HomeSummary.fromBuffer);
}

@$pb.GrpcServiceName('config.home.HomeController')
abstract class HomeControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.home.HomeController';

  HomeControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HomeMyWorkRequest, $0.HomeMyWork>(
        'MyWork',
        myWork_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HomeMyWorkRequest.fromBuffer(value),
        ($0.HomeMyWork value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HomePinDashboardRequest, $0.HomePinned>(
        'PinDashboard',
        pinDashboard_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HomePinDashboardRequest.fromBuffer(value),
        ($0.HomePinned value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HomeRecordRecentRequest, $0.HomeRecorded>(
        'RecordRecent',
        recordRecent_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HomeRecordRecentRequest.fromBuffer(value),
        ($0.HomeRecorded value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HomeSummaryRequest, $0.HomeSummary>(
        'Summary',
        summary_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.HomeSummaryRequest.fromBuffer(value),
        ($0.HomeSummary value) => value.writeToBuffer()));
  }

  $async.Future<$0.HomeMyWork> myWork_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HomeMyWorkRequest> $request) async {
    return myWork($call, await $request);
  }

  $async.Future<$0.HomeMyWork> myWork(
      $grpc.ServiceCall call, $0.HomeMyWorkRequest request);

  $async.Future<$0.HomePinned> pinDashboard_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HomePinDashboardRequest> $request) async {
    return pinDashboard($call, await $request);
  }

  $async.Future<$0.HomePinned> pinDashboard(
      $grpc.ServiceCall call, $0.HomePinDashboardRequest request);

  $async.Future<$0.HomeRecorded> recordRecent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HomeRecordRecentRequest> $request) async {
    return recordRecent($call, await $request);
  }

  $async.Future<$0.HomeRecorded> recordRecent(
      $grpc.ServiceCall call, $0.HomeRecordRecentRequest request);

  $async.Future<$0.HomeSummary> summary_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HomeSummaryRequest> $request) async {
    return summary($call, await $request);
  }

  $async.Future<$0.HomeSummary> summary(
      $grpc.ServiceCall call, $0.HomeSummaryRequest request);
}

@$pb.GrpcServiceName('config.home.OnboardingController')
class OnboardingControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  OnboardingControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.OnboardingStarterApplied> applyStarter(
    $0.OnboardingApplyStarterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$applyStarter, request, options: options);
  }

  $grpc.ResponseFuture<$0.OnboardingState> completeStep(
    $0.OnboardingCompleteStepRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completeStep, request, options: options);
  }

  $grpc.ResponseFuture<$0.OnboardingSamplesDeleted> deleteSamples(
    $0.OnboardingDeleteSamplesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteSamples, request, options: options);
  }

  $grpc.ResponseFuture<$0.OnboardingState> dismiss(
    $0.OnboardingDismissRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dismiss, request, options: options);
  }

  $grpc.ResponseFuture<$0.OnboardingState> get(
    $0.OnboardingGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  // method descriptors

  static final _$applyStarter = $grpc.ClientMethod<
          $0.OnboardingApplyStarterRequest, $0.OnboardingStarterApplied>(
      '/config.home.OnboardingController/ApplyStarter',
      ($0.OnboardingApplyStarterRequest value) => value.writeToBuffer(),
      $0.OnboardingStarterApplied.fromBuffer);
  static final _$completeStep =
      $grpc.ClientMethod<$0.OnboardingCompleteStepRequest, $0.OnboardingState>(
          '/config.home.OnboardingController/CompleteStep',
          ($0.OnboardingCompleteStepRequest value) => value.writeToBuffer(),
          $0.OnboardingState.fromBuffer);
  static final _$deleteSamples = $grpc.ClientMethod<
          $0.OnboardingDeleteSamplesRequest, $0.OnboardingSamplesDeleted>(
      '/config.home.OnboardingController/DeleteSamples',
      ($0.OnboardingDeleteSamplesRequest value) => value.writeToBuffer(),
      $0.OnboardingSamplesDeleted.fromBuffer);
  static final _$dismiss =
      $grpc.ClientMethod<$0.OnboardingDismissRequest, $0.OnboardingState>(
          '/config.home.OnboardingController/Dismiss',
          ($0.OnboardingDismissRequest value) => value.writeToBuffer(),
          $0.OnboardingState.fromBuffer);
  static final _$get =
      $grpc.ClientMethod<$0.OnboardingGetRequest, $0.OnboardingState>(
          '/config.home.OnboardingController/Get',
          ($0.OnboardingGetRequest value) => value.writeToBuffer(),
          $0.OnboardingState.fromBuffer);
}

@$pb.GrpcServiceName('config.home.OnboardingController')
abstract class OnboardingControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.home.OnboardingController';

  OnboardingControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.OnboardingApplyStarterRequest,
            $0.OnboardingStarterApplied>(
        'ApplyStarter',
        applyStarter_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OnboardingApplyStarterRequest.fromBuffer(value),
        ($0.OnboardingStarterApplied value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OnboardingCompleteStepRequest,
            $0.OnboardingState>(
        'CompleteStep',
        completeStep_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OnboardingCompleteStepRequest.fromBuffer(value),
        ($0.OnboardingState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OnboardingDeleteSamplesRequest,
            $0.OnboardingSamplesDeleted>(
        'DeleteSamples',
        deleteSamples_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OnboardingDeleteSamplesRequest.fromBuffer(value),
        ($0.OnboardingSamplesDeleted value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.OnboardingDismissRequest, $0.OnboardingState>(
            'Dismiss',
            dismiss_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.OnboardingDismissRequest.fromBuffer(value),
            ($0.OnboardingState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OnboardingGetRequest, $0.OnboardingState>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.OnboardingGetRequest.fromBuffer(value),
        ($0.OnboardingState value) => value.writeToBuffer()));
  }

  $async.Future<$0.OnboardingStarterApplied> applyStarter_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.OnboardingApplyStarterRequest> $request) async {
    return applyStarter($call, await $request);
  }

  $async.Future<$0.OnboardingStarterApplied> applyStarter(
      $grpc.ServiceCall call, $0.OnboardingApplyStarterRequest request);

  $async.Future<$0.OnboardingState> completeStep_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OnboardingCompleteStepRequest> $request) async {
    return completeStep($call, await $request);
  }

  $async.Future<$0.OnboardingState> completeStep(
      $grpc.ServiceCall call, $0.OnboardingCompleteStepRequest request);

  $async.Future<$0.OnboardingSamplesDeleted> deleteSamples_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.OnboardingDeleteSamplesRequest> $request) async {
    return deleteSamples($call, await $request);
  }

  $async.Future<$0.OnboardingSamplesDeleted> deleteSamples(
      $grpc.ServiceCall call, $0.OnboardingDeleteSamplesRequest request);

  $async.Future<$0.OnboardingState> dismiss_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OnboardingDismissRequest> $request) async {
    return dismiss($call, await $request);
  }

  $async.Future<$0.OnboardingState> dismiss(
      $grpc.ServiceCall call, $0.OnboardingDismissRequest request);

  $async.Future<$0.OnboardingState> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OnboardingGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.OnboardingState> get(
      $grpc.ServiceCall call, $0.OnboardingGetRequest request);
}
