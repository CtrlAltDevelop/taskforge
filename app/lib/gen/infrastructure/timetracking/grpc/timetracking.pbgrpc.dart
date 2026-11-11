// This is a generated file - do not edit.
//
// Generated from infrastructure/timetracking/grpc/timetracking.proto.

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

import 'timetracking.pb.dart' as $0;

export 'timetracking.pb.dart';

@$pb.GrpcServiceName('config.timetracking.TimeController')
class TimeControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TimeControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Entry> createEntry(
    $0.EntryCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createEntry, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimerState> current(
    $0.TimeCurrentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$current, request, options: options);
  }

  $grpc.ResponseFuture<$0.EntryDeleted> deleteEntry(
    $0.EntryDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteEntry, request, options: options);
  }

  $grpc.ResponseFuture<$0.EntryList> entries(
    $0.EntriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$entries, request, options: options);
  }

  $grpc.ResponseFuture<$0.EstimateSet> setEstimate(
    $0.EstimateSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setEstimate, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimerStarted> start(
    $0.TimeStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$start, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimerStopped> stop(
    $0.TimeStopRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stop, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimeSummary> summary(
    $0.TimeSummaryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$summary, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimesheetAnswer> timesheet(
    $0.TimesheetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$timesheet, request, options: options);
  }

  $grpc.ResponseFuture<$0.TotalsAnswer> totals(
    $0.TotalsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$totals, request, options: options);
  }

  $grpc.ResponseFuture<$0.Entry> updateEntry(
    $0.EntryUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateEntry, request, options: options);
  }

  // method descriptors

  static final _$createEntry =
      $grpc.ClientMethod<$0.EntryCreateRequest, $0.Entry>(
          '/config.timetracking.TimeController/CreateEntry',
          ($0.EntryCreateRequest value) => value.writeToBuffer(),
          $0.Entry.fromBuffer);
  static final _$current =
      $grpc.ClientMethod<$0.TimeCurrentRequest, $0.TimerState>(
          '/config.timetracking.TimeController/Current',
          ($0.TimeCurrentRequest value) => value.writeToBuffer(),
          $0.TimerState.fromBuffer);
  static final _$deleteEntry =
      $grpc.ClientMethod<$0.EntryDeleteRequest, $0.EntryDeleted>(
          '/config.timetracking.TimeController/DeleteEntry',
          ($0.EntryDeleteRequest value) => value.writeToBuffer(),
          $0.EntryDeleted.fromBuffer);
  static final _$entries = $grpc.ClientMethod<$0.EntriesRequest, $0.EntryList>(
      '/config.timetracking.TimeController/Entries',
      ($0.EntriesRequest value) => value.writeToBuffer(),
      $0.EntryList.fromBuffer);
  static final _$setEstimate =
      $grpc.ClientMethod<$0.EstimateSetRequest, $0.EstimateSet>(
          '/config.timetracking.TimeController/SetEstimate',
          ($0.EstimateSetRequest value) => value.writeToBuffer(),
          $0.EstimateSet.fromBuffer);
  static final _$start =
      $grpc.ClientMethod<$0.TimeStartRequest, $0.TimerStarted>(
          '/config.timetracking.TimeController/Start',
          ($0.TimeStartRequest value) => value.writeToBuffer(),
          $0.TimerStarted.fromBuffer);
  static final _$stop = $grpc.ClientMethod<$0.TimeStopRequest, $0.TimerStopped>(
      '/config.timetracking.TimeController/Stop',
      ($0.TimeStopRequest value) => value.writeToBuffer(),
      $0.TimerStopped.fromBuffer);
  static final _$summary =
      $grpc.ClientMethod<$0.TimeSummaryRequest, $0.TimeSummary>(
          '/config.timetracking.TimeController/Summary',
          ($0.TimeSummaryRequest value) => value.writeToBuffer(),
          $0.TimeSummary.fromBuffer);
  static final _$timesheet =
      $grpc.ClientMethod<$0.TimesheetRequest, $0.TimesheetAnswer>(
          '/config.timetracking.TimeController/Timesheet',
          ($0.TimesheetRequest value) => value.writeToBuffer(),
          $0.TimesheetAnswer.fromBuffer);
  static final _$totals = $grpc.ClientMethod<$0.TotalsRequest, $0.TotalsAnswer>(
      '/config.timetracking.TimeController/Totals',
      ($0.TotalsRequest value) => value.writeToBuffer(),
      $0.TotalsAnswer.fromBuffer);
  static final _$updateEntry =
      $grpc.ClientMethod<$0.EntryUpdateRequest, $0.Entry>(
          '/config.timetracking.TimeController/UpdateEntry',
          ($0.EntryUpdateRequest value) => value.writeToBuffer(),
          $0.Entry.fromBuffer);
}

@$pb.GrpcServiceName('config.timetracking.TimeController')
abstract class TimeControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.timetracking.TimeController';

  TimeControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EntryCreateRequest, $0.Entry>(
        'CreateEntry',
        createEntry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EntryCreateRequest.fromBuffer(value),
        ($0.Entry value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeCurrentRequest, $0.TimerState>(
        'Current',
        current_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeCurrentRequest.fromBuffer(value),
        ($0.TimerState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EntryDeleteRequest, $0.EntryDeleted>(
        'DeleteEntry',
        deleteEntry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EntryDeleteRequest.fromBuffer(value),
        ($0.EntryDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EntriesRequest, $0.EntryList>(
        'Entries',
        entries_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EntriesRequest.fromBuffer(value),
        ($0.EntryList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EstimateSetRequest, $0.EstimateSet>(
        'SetEstimate',
        setEstimate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EstimateSetRequest.fromBuffer(value),
        ($0.EstimateSet value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeStartRequest, $0.TimerStarted>(
        'Start',
        start_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TimeStartRequest.fromBuffer(value),
        ($0.TimerStarted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeStopRequest, $0.TimerStopped>(
        'Stop',
        stop_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TimeStopRequest.fromBuffer(value),
        ($0.TimerStopped value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimeSummaryRequest, $0.TimeSummary>(
        'Summary',
        summary_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TimeSummaryRequest.fromBuffer(value),
        ($0.TimeSummary value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimesheetRequest, $0.TimesheetAnswer>(
        'Timesheet',
        timesheet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TimesheetRequest.fromBuffer(value),
        ($0.TimesheetAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TotalsRequest, $0.TotalsAnswer>(
        'Totals',
        totals_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TotalsRequest.fromBuffer(value),
        ($0.TotalsAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EntryUpdateRequest, $0.Entry>(
        'UpdateEntry',
        updateEntry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EntryUpdateRequest.fromBuffer(value),
        ($0.Entry value) => value.writeToBuffer()));
  }

  $async.Future<$0.Entry> createEntry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EntryCreateRequest> $request) async {
    return createEntry($call, await $request);
  }

  $async.Future<$0.Entry> createEntry(
      $grpc.ServiceCall call, $0.EntryCreateRequest request);

  $async.Future<$0.TimerState> current_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeCurrentRequest> $request) async {
    return current($call, await $request);
  }

  $async.Future<$0.TimerState> current(
      $grpc.ServiceCall call, $0.TimeCurrentRequest request);

  $async.Future<$0.EntryDeleted> deleteEntry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EntryDeleteRequest> $request) async {
    return deleteEntry($call, await $request);
  }

  $async.Future<$0.EntryDeleted> deleteEntry(
      $grpc.ServiceCall call, $0.EntryDeleteRequest request);

  $async.Future<$0.EntryList> entries_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EntriesRequest> $request) async {
    return entries($call, await $request);
  }

  $async.Future<$0.EntryList> entries(
      $grpc.ServiceCall call, $0.EntriesRequest request);

  $async.Future<$0.EstimateSet> setEstimate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EstimateSetRequest> $request) async {
    return setEstimate($call, await $request);
  }

  $async.Future<$0.EstimateSet> setEstimate(
      $grpc.ServiceCall call, $0.EstimateSetRequest request);

  $async.Future<$0.TimerStarted> start_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeStartRequest> $request) async {
    return start($call, await $request);
  }

  $async.Future<$0.TimerStarted> start(
      $grpc.ServiceCall call, $0.TimeStartRequest request);

  $async.Future<$0.TimerStopped> stop_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeStopRequest> $request) async {
    return stop($call, await $request);
  }

  $async.Future<$0.TimerStopped> stop(
      $grpc.ServiceCall call, $0.TimeStopRequest request);

  $async.Future<$0.TimeSummary> summary_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimeSummaryRequest> $request) async {
    return summary($call, await $request);
  }

  $async.Future<$0.TimeSummary> summary(
      $grpc.ServiceCall call, $0.TimeSummaryRequest request);

  $async.Future<$0.TimesheetAnswer> timesheet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimesheetRequest> $request) async {
    return timesheet($call, await $request);
  }

  $async.Future<$0.TimesheetAnswer> timesheet(
      $grpc.ServiceCall call, $0.TimesheetRequest request);

  $async.Future<$0.TotalsAnswer> totals_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.TotalsRequest> $request) async {
    return totals($call, await $request);
  }

  $async.Future<$0.TotalsAnswer> totals(
      $grpc.ServiceCall call, $0.TotalsRequest request);

  $async.Future<$0.Entry> updateEntry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EntryUpdateRequest> $request) async {
    return updateEntry($call, await $request);
  }

  $async.Future<$0.Entry> updateEntry(
      $grpc.ServiceCall call, $0.EntryUpdateRequest request);
}
