// This is a generated file - do not edit.
//
// Generated from infrastructure/dashboards/grpc/dashboards.proto.

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

import 'dashboards.pb.dart' as $0;

export 'dashboards.pb.dart';

@$pb.GrpcServiceName('config.dashboards.DashboardController')
class DashboardControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DashboardControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.DashboardDeleted> delete(
    $0.DashboardDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.DashboardAnswer> fromTemplate(
    $0.DashboardFromTemplateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$fromTemplate, request, options: options);
  }

  $grpc.ResponseFuture<$0.DashboardAnswer> get(
    $0.DashboardGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.DashboardList> list(
    $0.DashboardListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.DashboardAnswer> save(
    $0.DashboardSaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$save, request, options: options);
  }

  // method descriptors

  static final _$delete =
      $grpc.ClientMethod<$0.DashboardDeleteRequest, $0.DashboardDeleted>(
          '/config.dashboards.DashboardController/Delete',
          ($0.DashboardDeleteRequest value) => value.writeToBuffer(),
          $0.DashboardDeleted.fromBuffer);
  static final _$fromTemplate =
      $grpc.ClientMethod<$0.DashboardFromTemplateRequest, $0.DashboardAnswer>(
          '/config.dashboards.DashboardController/FromTemplate',
          ($0.DashboardFromTemplateRequest value) => value.writeToBuffer(),
          $0.DashboardAnswer.fromBuffer);
  static final _$get =
      $grpc.ClientMethod<$0.DashboardGetRequest, $0.DashboardAnswer>(
          '/config.dashboards.DashboardController/Get',
          ($0.DashboardGetRequest value) => value.writeToBuffer(),
          $0.DashboardAnswer.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.DashboardListRequest, $0.DashboardList>(
          '/config.dashboards.DashboardController/List',
          ($0.DashboardListRequest value) => value.writeToBuffer(),
          $0.DashboardList.fromBuffer);
  static final _$save =
      $grpc.ClientMethod<$0.DashboardSaveRequest, $0.DashboardAnswer>(
          '/config.dashboards.DashboardController/Save',
          ($0.DashboardSaveRequest value) => value.writeToBuffer(),
          $0.DashboardAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.dashboards.DashboardController')
abstract class DashboardControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.dashboards.DashboardController';

  DashboardControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.DashboardDeleteRequest, $0.DashboardDeleted>(
            'Delete',
            delete_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DashboardDeleteRequest.fromBuffer(value),
            ($0.DashboardDeleted value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DashboardFromTemplateRequest,
            $0.DashboardAnswer>(
        'FromTemplate',
        fromTemplate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DashboardFromTemplateRequest.fromBuffer(value),
        ($0.DashboardAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DashboardGetRequest, $0.DashboardAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DashboardGetRequest.fromBuffer(value),
        ($0.DashboardAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DashboardListRequest, $0.DashboardList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DashboardListRequest.fromBuffer(value),
        ($0.DashboardList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DashboardSaveRequest, $0.DashboardAnswer>(
        'Save',
        save_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DashboardSaveRequest.fromBuffer(value),
        ($0.DashboardAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.DashboardDeleted> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DashboardDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.DashboardDeleted> delete(
      $grpc.ServiceCall call, $0.DashboardDeleteRequest request);

  $async.Future<$0.DashboardAnswer> fromTemplate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DashboardFromTemplateRequest> $request) async {
    return fromTemplate($call, await $request);
  }

  $async.Future<$0.DashboardAnswer> fromTemplate(
      $grpc.ServiceCall call, $0.DashboardFromTemplateRequest request);

  $async.Future<$0.DashboardAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DashboardGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.DashboardAnswer> get(
      $grpc.ServiceCall call, $0.DashboardGetRequest request);

  $async.Future<$0.DashboardList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DashboardListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.DashboardList> list(
      $grpc.ServiceCall call, $0.DashboardListRequest request);

  $async.Future<$0.DashboardAnswer> save_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DashboardSaveRequest> $request) async {
    return save($call, await $request);
  }

  $async.Future<$0.DashboardAnswer> save(
      $grpc.ServiceCall call, $0.DashboardSaveRequest request);
}

@$pb.GrpcServiceName('config.dashboards.WidgetController')
class WidgetControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WidgetControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.WidgetData> data(
    $0.WidgetDataRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$data, request, options: options);
  }

  $grpc.ResponseStream<$0.DrilledTask> drilldown(
    $0.WidgetDrilldownRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$drilldown, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.WidgetExport> export(
    $0.WidgetExportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$export, request, options: options);
  }

  $grpc.ResponseFuture<$0.WidgetData> preview(
    $0.WidgetPreviewRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$preview, request, options: options);
  }

  // method descriptors

  static final _$data = $grpc.ClientMethod<$0.WidgetDataRequest, $0.WidgetData>(
      '/config.dashboards.WidgetController/Data',
      ($0.WidgetDataRequest value) => value.writeToBuffer(),
      $0.WidgetData.fromBuffer);
  static final _$drilldown =
      $grpc.ClientMethod<$0.WidgetDrilldownRequest, $0.DrilledTask>(
          '/config.dashboards.WidgetController/Drilldown',
          ($0.WidgetDrilldownRequest value) => value.writeToBuffer(),
          $0.DrilledTask.fromBuffer);
  static final _$export =
      $grpc.ClientMethod<$0.WidgetExportRequest, $0.WidgetExport>(
          '/config.dashboards.WidgetController/Export',
          ($0.WidgetExportRequest value) => value.writeToBuffer(),
          $0.WidgetExport.fromBuffer);
  static final _$preview =
      $grpc.ClientMethod<$0.WidgetPreviewRequest, $0.WidgetData>(
          '/config.dashboards.WidgetController/Preview',
          ($0.WidgetPreviewRequest value) => value.writeToBuffer(),
          $0.WidgetData.fromBuffer);
}

@$pb.GrpcServiceName('config.dashboards.WidgetController')
abstract class WidgetControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.dashboards.WidgetController';

  WidgetControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WidgetDataRequest, $0.WidgetData>(
        'Data',
        data_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WidgetDataRequest.fromBuffer(value),
        ($0.WidgetData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WidgetDrilldownRequest, $0.DrilledTask>(
        'Drilldown',
        drilldown_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.WidgetDrilldownRequest.fromBuffer(value),
        ($0.DrilledTask value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WidgetExportRequest, $0.WidgetExport>(
        'Export',
        export_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WidgetExportRequest.fromBuffer(value),
        ($0.WidgetExport value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WidgetPreviewRequest, $0.WidgetData>(
        'Preview',
        preview_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WidgetPreviewRequest.fromBuffer(value),
        ($0.WidgetData value) => value.writeToBuffer()));
  }

  $async.Future<$0.WidgetData> data_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WidgetDataRequest> $request) async {
    return data($call, await $request);
  }

  $async.Future<$0.WidgetData> data(
      $grpc.ServiceCall call, $0.WidgetDataRequest request);

  $async.Stream<$0.DrilledTask> drilldown_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WidgetDrilldownRequest> $request) async* {
    yield* drilldown($call, await $request);
  }

  $async.Stream<$0.DrilledTask> drilldown(
      $grpc.ServiceCall call, $0.WidgetDrilldownRequest request);

  $async.Future<$0.WidgetExport> export_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WidgetExportRequest> $request) async {
    return export($call, await $request);
  }

  $async.Future<$0.WidgetExport> export(
      $grpc.ServiceCall call, $0.WidgetExportRequest request);

  $async.Future<$0.WidgetData> preview_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WidgetPreviewRequest> $request) async {
    return preview($call, await $request);
  }

  $async.Future<$0.WidgetData> preview(
      $grpc.ServiceCall call, $0.WidgetPreviewRequest request);
}
