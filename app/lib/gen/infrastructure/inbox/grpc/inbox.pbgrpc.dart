// This is a generated file - do not edit.
//
// Generated from infrastructure/inbox/grpc/inbox.proto.

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

import 'inbox.pb.dart' as $0;

export 'inbox.pb.dart';

@$pb.GrpcServiceName('config.inbox.DeviceController')
class DeviceControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DeviceControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.DeviceAnswer> register(
    $0.DeviceRegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeviceAnswer> unregister(
    $0.DeviceUnregisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unregister, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.DeviceRegisterRequest, $0.DeviceAnswer>(
          '/config.inbox.DeviceController/Register',
          ($0.DeviceRegisterRequest value) => value.writeToBuffer(),
          $0.DeviceAnswer.fromBuffer);
  static final _$unregister =
      $grpc.ClientMethod<$0.DeviceUnregisterRequest, $0.DeviceAnswer>(
          '/config.inbox.DeviceController/Unregister',
          ($0.DeviceUnregisterRequest value) => value.writeToBuffer(),
          $0.DeviceAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.inbox.DeviceController')
abstract class DeviceControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.inbox.DeviceController';

  DeviceControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.DeviceRegisterRequest, $0.DeviceAnswer>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeviceRegisterRequest.fromBuffer(value),
        ($0.DeviceAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeviceUnregisterRequest, $0.DeviceAnswer>(
        'Unregister',
        unregister_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeviceUnregisterRequest.fromBuffer(value),
        ($0.DeviceAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.DeviceAnswer> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeviceRegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.DeviceAnswer> register(
      $grpc.ServiceCall call, $0.DeviceRegisterRequest request);

  $async.Future<$0.DeviceAnswer> unregister_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeviceUnregisterRequest> $request) async {
    return unregister($call, await $request);
  }

  $async.Future<$0.DeviceAnswer> unregister(
      $grpc.ServiceCall call, $0.DeviceUnregisterRequest request);
}

@$pb.GrpcServiceName('config.inbox.InboxController')
class InboxControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  InboxControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.UnreadTotal> archive(
    $0.ArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archive, request, options: options);
  }

  $grpc.ResponseFuture<$0.InboxPage> list(
    $0.InboxListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.UnreadTotal> markRead(
    $0.MarkReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markRead, request, options: options);
  }

  $grpc.ResponseFuture<$0.Notification> snooze(
    $0.SnoozeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$snooze, request, options: options);
  }

  $grpc.ResponseFuture<$0.UnreadTotal> unreadCount(
    $0.UnreadCountRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unreadCount, request, options: options);
  }

  // method descriptors

  static final _$archive =
      $grpc.ClientMethod<$0.ArchiveRequest, $0.UnreadTotal>(
          '/config.inbox.InboxController/Archive',
          ($0.ArchiveRequest value) => value.writeToBuffer(),
          $0.UnreadTotal.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.InboxListRequest, $0.InboxPage>(
      '/config.inbox.InboxController/List',
      ($0.InboxListRequest value) => value.writeToBuffer(),
      $0.InboxPage.fromBuffer);
  static final _$markRead =
      $grpc.ClientMethod<$0.MarkReadRequest, $0.UnreadTotal>(
          '/config.inbox.InboxController/MarkRead',
          ($0.MarkReadRequest value) => value.writeToBuffer(),
          $0.UnreadTotal.fromBuffer);
  static final _$snooze = $grpc.ClientMethod<$0.SnoozeRequest, $0.Notification>(
      '/config.inbox.InboxController/Snooze',
      ($0.SnoozeRequest value) => value.writeToBuffer(),
      $0.Notification.fromBuffer);
  static final _$unreadCount =
      $grpc.ClientMethod<$0.UnreadCountRequest, $0.UnreadTotal>(
          '/config.inbox.InboxController/UnreadCount',
          ($0.UnreadCountRequest value) => value.writeToBuffer(),
          $0.UnreadTotal.fromBuffer);
}

@$pb.GrpcServiceName('config.inbox.InboxController')
abstract class InboxControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.inbox.InboxController';

  InboxControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ArchiveRequest, $0.UnreadTotal>(
        'Archive',
        archive_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ArchiveRequest.fromBuffer(value),
        ($0.UnreadTotal value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InboxListRequest, $0.InboxPage>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.InboxListRequest.fromBuffer(value),
        ($0.InboxPage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkReadRequest, $0.UnreadTotal>(
        'MarkRead',
        markRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MarkReadRequest.fromBuffer(value),
        ($0.UnreadTotal value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SnoozeRequest, $0.Notification>(
        'Snooze',
        snooze_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SnoozeRequest.fromBuffer(value),
        ($0.Notification value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnreadCountRequest, $0.UnreadTotal>(
        'UnreadCount',
        unreadCount_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UnreadCountRequest.fromBuffer(value),
        ($0.UnreadTotal value) => value.writeToBuffer()));
  }

  $async.Future<$0.UnreadTotal> archive_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ArchiveRequest> $request) async {
    return archive($call, await $request);
  }

  $async.Future<$0.UnreadTotal> archive(
      $grpc.ServiceCall call, $0.ArchiveRequest request);

  $async.Future<$0.InboxPage> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InboxListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.InboxPage> list(
      $grpc.ServiceCall call, $0.InboxListRequest request);

  $async.Future<$0.UnreadTotal> markRead_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MarkReadRequest> $request) async {
    return markRead($call, await $request);
  }

  $async.Future<$0.UnreadTotal> markRead(
      $grpc.ServiceCall call, $0.MarkReadRequest request);

  $async.Future<$0.Notification> snooze_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SnoozeRequest> $request) async {
    return snooze($call, await $request);
  }

  $async.Future<$0.Notification> snooze(
      $grpc.ServiceCall call, $0.SnoozeRequest request);

  $async.Future<$0.UnreadTotal> unreadCount_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnreadCountRequest> $request) async {
    return unreadCount($call, await $request);
  }

  $async.Future<$0.UnreadTotal> unreadCount(
      $grpc.ServiceCall call, $0.UnreadCountRequest request);
}

@$pb.GrpcServiceName('config.inbox.PrefController')
class PrefControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PrefControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.PrefsAnswer> get(
    $0.PrefsGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.PrefsAnswer> set(
    $0.PrefSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$set, request, options: options);
  }

  $grpc.ResponseFuture<$0.PrefsAnswer> setSettings(
    $0.SettingsSetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setSettings, request, options: options);
  }

  // method descriptors

  static final _$get = $grpc.ClientMethod<$0.PrefsGetRequest, $0.PrefsAnswer>(
      '/config.inbox.PrefController/Get',
      ($0.PrefsGetRequest value) => value.writeToBuffer(),
      $0.PrefsAnswer.fromBuffer);
  static final _$set = $grpc.ClientMethod<$0.PrefSetRequest, $0.PrefsAnswer>(
      '/config.inbox.PrefController/Set',
      ($0.PrefSetRequest value) => value.writeToBuffer(),
      $0.PrefsAnswer.fromBuffer);
  static final _$setSettings =
      $grpc.ClientMethod<$0.SettingsSetRequest, $0.PrefsAnswer>(
          '/config.inbox.PrefController/SetSettings',
          ($0.SettingsSetRequest value) => value.writeToBuffer(),
          $0.PrefsAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.inbox.PrefController')
abstract class PrefControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.inbox.PrefController';

  PrefControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PrefsGetRequest, $0.PrefsAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PrefsGetRequest.fromBuffer(value),
        ($0.PrefsAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PrefSetRequest, $0.PrefsAnswer>(
        'Set',
        set_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PrefSetRequest.fromBuffer(value),
        ($0.PrefsAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SettingsSetRequest, $0.PrefsAnswer>(
        'SetSettings',
        setSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SettingsSetRequest.fromBuffer(value),
        ($0.PrefsAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.PrefsAnswer> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PrefsGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.PrefsAnswer> get(
      $grpc.ServiceCall call, $0.PrefsGetRequest request);

  $async.Future<$0.PrefsAnswer> set_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PrefSetRequest> $request) async {
    return set($call, await $request);
  }

  $async.Future<$0.PrefsAnswer> set(
      $grpc.ServiceCall call, $0.PrefSetRequest request);

  $async.Future<$0.PrefsAnswer> setSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SettingsSetRequest> $request) async {
    return setSettings($call, await $request);
  }

  $async.Future<$0.PrefsAnswer> setSettings(
      $grpc.ServiceCall call, $0.SettingsSetRequest request);
}

@$pb.GrpcServiceName('config.inbox.WatcherController')
class WatcherControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WatcherControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.WatchState> add(
    $0.WatchAddRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$add, request, options: options);
  }

  $grpc.ResponseFuture<$0.WatchState> get(
    $0.WatchGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.WatchState> remove(
    $0.WatchRemoveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$remove, request, options: options);
  }

  // method descriptors

  static final _$add = $grpc.ClientMethod<$0.WatchAddRequest, $0.WatchState>(
      '/config.inbox.WatcherController/Add',
      ($0.WatchAddRequest value) => value.writeToBuffer(),
      $0.WatchState.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.WatchGetRequest, $0.WatchState>(
      '/config.inbox.WatcherController/Get',
      ($0.WatchGetRequest value) => value.writeToBuffer(),
      $0.WatchState.fromBuffer);
  static final _$remove =
      $grpc.ClientMethod<$0.WatchRemoveRequest, $0.WatchState>(
          '/config.inbox.WatcherController/Remove',
          ($0.WatchRemoveRequest value) => value.writeToBuffer(),
          $0.WatchState.fromBuffer);
}

@$pb.GrpcServiceName('config.inbox.WatcherController')
abstract class WatcherControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.inbox.WatcherController';

  WatcherControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WatchAddRequest, $0.WatchState>(
        'Add',
        add_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WatchAddRequest.fromBuffer(value),
        ($0.WatchState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WatchGetRequest, $0.WatchState>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WatchGetRequest.fromBuffer(value),
        ($0.WatchState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WatchRemoveRequest, $0.WatchState>(
        'Remove',
        remove_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WatchRemoveRequest.fromBuffer(value),
        ($0.WatchState value) => value.writeToBuffer()));
  }

  $async.Future<$0.WatchState> add_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchAddRequest> $request) async {
    return add($call, await $request);
  }

  $async.Future<$0.WatchState> add(
      $grpc.ServiceCall call, $0.WatchAddRequest request);

  $async.Future<$0.WatchState> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.WatchState> get(
      $grpc.ServiceCall call, $0.WatchGetRequest request);

  $async.Future<$0.WatchState> remove_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchRemoveRequest> $request) async {
    return remove($call, await $request);
  }

  $async.Future<$0.WatchState> remove(
      $grpc.ServiceCall call, $0.WatchRemoveRequest request);
}
