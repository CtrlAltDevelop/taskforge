// This is a generated file - do not edit.
//
// Generated from infrastructure/chat/grpc/chat.proto.

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

import 'chat.pb.dart' as $0;

export 'chat.pb.dart';

@$pb.GrpcServiceName('config.chat.ChatController')
class ChatControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ChatControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Space> addMembers(
    $0.ChatAddMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMembers, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> createSpace(
    $0.ChatCreateSpaceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSpace, request, options: options);
  }

  $grpc.ResponseFuture<$0.Message> delete(
    $0.ChatDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.Message> edit(
    $0.ChatEditRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$edit, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> join(
    $0.ChatJoinRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$join, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatDone> leave(
    $0.ChatLeaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$leave, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatMessagePage> listMessages(
    $0.ChatListMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMessages, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatSpaceList> listSpaces(
    $0.ChatListSpacesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSpaces, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> markRead(
    $0.ChatMarkReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markRead, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatMentionable> mentionable(
    $0.ChatMentionableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$mentionable, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> mute(
    $0.ChatMuteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$mute, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> notify(
    $0.ChatNotifyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$notify, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> openDm(
    $0.ChatOpenDmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$openDm, request, options: options);
  }

  $grpc.ResponseFuture<$0.Message> react(
    $0.ChatReactRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$react, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatDone> removeMember(
    $0.ChatRemoveMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.Message> send(
    $0.ChatSendRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$send, request, options: options);
  }

  $grpc.ResponseFuture<$0.Space> updateSpace(
    $0.ChatUpdateSpaceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSpace, request, options: options);
  }

  // method descriptors

  static final _$addMembers =
      $grpc.ClientMethod<$0.ChatAddMembersRequest, $0.Space>(
          '/config.chat.ChatController/AddMembers',
          ($0.ChatAddMembersRequest value) => value.writeToBuffer(),
          $0.Space.fromBuffer);
  static final _$createSpace =
      $grpc.ClientMethod<$0.ChatCreateSpaceRequest, $0.Space>(
          '/config.chat.ChatController/CreateSpace',
          ($0.ChatCreateSpaceRequest value) => value.writeToBuffer(),
          $0.Space.fromBuffer);
  static final _$delete = $grpc.ClientMethod<$0.ChatDeleteRequest, $0.Message>(
      '/config.chat.ChatController/Delete',
      ($0.ChatDeleteRequest value) => value.writeToBuffer(),
      $0.Message.fromBuffer);
  static final _$edit = $grpc.ClientMethod<$0.ChatEditRequest, $0.Message>(
      '/config.chat.ChatController/Edit',
      ($0.ChatEditRequest value) => value.writeToBuffer(),
      $0.Message.fromBuffer);
  static final _$join = $grpc.ClientMethod<$0.ChatJoinRequest, $0.Space>(
      '/config.chat.ChatController/Join',
      ($0.ChatJoinRequest value) => value.writeToBuffer(),
      $0.Space.fromBuffer);
  static final _$leave = $grpc.ClientMethod<$0.ChatLeaveRequest, $0.ChatDone>(
      '/config.chat.ChatController/Leave',
      ($0.ChatLeaveRequest value) => value.writeToBuffer(),
      $0.ChatDone.fromBuffer);
  static final _$listMessages =
      $grpc.ClientMethod<$0.ChatListMessagesRequest, $0.ChatMessagePage>(
          '/config.chat.ChatController/ListMessages',
          ($0.ChatListMessagesRequest value) => value.writeToBuffer(),
          $0.ChatMessagePage.fromBuffer);
  static final _$listSpaces =
      $grpc.ClientMethod<$0.ChatListSpacesRequest, $0.ChatSpaceList>(
          '/config.chat.ChatController/ListSpaces',
          ($0.ChatListSpacesRequest value) => value.writeToBuffer(),
          $0.ChatSpaceList.fromBuffer);
  static final _$markRead =
      $grpc.ClientMethod<$0.ChatMarkReadRequest, $0.Space>(
          '/config.chat.ChatController/MarkRead',
          ($0.ChatMarkReadRequest value) => value.writeToBuffer(),
          $0.Space.fromBuffer);
  static final _$mentionable =
      $grpc.ClientMethod<$0.ChatMentionableRequest, $0.ChatMentionable>(
          '/config.chat.ChatController/Mentionable',
          ($0.ChatMentionableRequest value) => value.writeToBuffer(),
          $0.ChatMentionable.fromBuffer);
  static final _$mute = $grpc.ClientMethod<$0.ChatMuteRequest, $0.Space>(
      '/config.chat.ChatController/Mute',
      ($0.ChatMuteRequest value) => value.writeToBuffer(),
      $0.Space.fromBuffer);
  static final _$notify = $grpc.ClientMethod<$0.ChatNotifyRequest, $0.Space>(
      '/config.chat.ChatController/Notify',
      ($0.ChatNotifyRequest value) => value.writeToBuffer(),
      $0.Space.fromBuffer);
  static final _$openDm = $grpc.ClientMethod<$0.ChatOpenDmRequest, $0.Space>(
      '/config.chat.ChatController/OpenDm',
      ($0.ChatOpenDmRequest value) => value.writeToBuffer(),
      $0.Space.fromBuffer);
  static final _$react = $grpc.ClientMethod<$0.ChatReactRequest, $0.Message>(
      '/config.chat.ChatController/React',
      ($0.ChatReactRequest value) => value.writeToBuffer(),
      $0.Message.fromBuffer);
  static final _$removeMember =
      $grpc.ClientMethod<$0.ChatRemoveMemberRequest, $0.ChatDone>(
          '/config.chat.ChatController/RemoveMember',
          ($0.ChatRemoveMemberRequest value) => value.writeToBuffer(),
          $0.ChatDone.fromBuffer);
  static final _$send = $grpc.ClientMethod<$0.ChatSendRequest, $0.Message>(
      '/config.chat.ChatController/Send',
      ($0.ChatSendRequest value) => value.writeToBuffer(),
      $0.Message.fromBuffer);
  static final _$updateSpace =
      $grpc.ClientMethod<$0.ChatUpdateSpaceRequest, $0.Space>(
          '/config.chat.ChatController/UpdateSpace',
          ($0.ChatUpdateSpaceRequest value) => value.writeToBuffer(),
          $0.Space.fromBuffer);
}

@$pb.GrpcServiceName('config.chat.ChatController')
abstract class ChatControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.chat.ChatController';

  ChatControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ChatAddMembersRequest, $0.Space>(
        'AddMembers',
        addMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatAddMembersRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatCreateSpaceRequest, $0.Space>(
        'CreateSpace',
        createSpace_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatCreateSpaceRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatDeleteRequest, $0.Message>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatDeleteRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatEditRequest, $0.Message>(
        'Edit',
        edit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatEditRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatJoinRequest, $0.Space>(
        'Join',
        join_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatJoinRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatLeaveRequest, $0.ChatDone>(
        'Leave',
        leave_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatLeaveRequest.fromBuffer(value),
        ($0.ChatDone value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ChatListMessagesRequest, $0.ChatMessagePage>(
            'ListMessages',
            listMessages_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ChatListMessagesRequest.fromBuffer(value),
            ($0.ChatMessagePage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatListSpacesRequest, $0.ChatSpaceList>(
        'ListSpaces',
        listSpaces_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatListSpacesRequest.fromBuffer(value),
        ($0.ChatSpaceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatMarkReadRequest, $0.Space>(
        'MarkRead',
        markRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatMarkReadRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ChatMentionableRequest, $0.ChatMentionable>(
            'Mentionable',
            mentionable_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ChatMentionableRequest.fromBuffer(value),
            ($0.ChatMentionable value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatMuteRequest, $0.Space>(
        'Mute',
        mute_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatMuteRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatNotifyRequest, $0.Space>(
        'Notify',
        notify_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatNotifyRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatOpenDmRequest, $0.Space>(
        'OpenDm',
        openDm_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatOpenDmRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatReactRequest, $0.Message>(
        'React',
        react_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatReactRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatRemoveMemberRequest, $0.ChatDone>(
        'RemoveMember',
        removeMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatRemoveMemberRequest.fromBuffer(value),
        ($0.ChatDone value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatSendRequest, $0.Message>(
        'Send',
        send_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatSendRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatUpdateSpaceRequest, $0.Space>(
        'UpdateSpace',
        updateSpace_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChatUpdateSpaceRequest.fromBuffer(value),
        ($0.Space value) => value.writeToBuffer()));
  }

  $async.Future<$0.Space> addMembers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatAddMembersRequest> $request) async {
    return addMembers($call, await $request);
  }

  $async.Future<$0.Space> addMembers(
      $grpc.ServiceCall call, $0.ChatAddMembersRequest request);

  $async.Future<$0.Space> createSpace_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatCreateSpaceRequest> $request) async {
    return createSpace($call, await $request);
  }

  $async.Future<$0.Space> createSpace(
      $grpc.ServiceCall call, $0.ChatCreateSpaceRequest request);

  $async.Future<$0.Message> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Message> delete(
      $grpc.ServiceCall call, $0.ChatDeleteRequest request);

  $async.Future<$0.Message> edit_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatEditRequest> $request) async {
    return edit($call, await $request);
  }

  $async.Future<$0.Message> edit(
      $grpc.ServiceCall call, $0.ChatEditRequest request);

  $async.Future<$0.Space> join_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatJoinRequest> $request) async {
    return join($call, await $request);
  }

  $async.Future<$0.Space> join(
      $grpc.ServiceCall call, $0.ChatJoinRequest request);

  $async.Future<$0.ChatDone> leave_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatLeaveRequest> $request) async {
    return leave($call, await $request);
  }

  $async.Future<$0.ChatDone> leave(
      $grpc.ServiceCall call, $0.ChatLeaveRequest request);

  $async.Future<$0.ChatMessagePage> listMessages_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatListMessagesRequest> $request) async {
    return listMessages($call, await $request);
  }

  $async.Future<$0.ChatMessagePage> listMessages(
      $grpc.ServiceCall call, $0.ChatListMessagesRequest request);

  $async.Future<$0.ChatSpaceList> listSpaces_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatListSpacesRequest> $request) async {
    return listSpaces($call, await $request);
  }

  $async.Future<$0.ChatSpaceList> listSpaces(
      $grpc.ServiceCall call, $0.ChatListSpacesRequest request);

  $async.Future<$0.Space> markRead_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatMarkReadRequest> $request) async {
    return markRead($call, await $request);
  }

  $async.Future<$0.Space> markRead(
      $grpc.ServiceCall call, $0.ChatMarkReadRequest request);

  $async.Future<$0.ChatMentionable> mentionable_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatMentionableRequest> $request) async {
    return mentionable($call, await $request);
  }

  $async.Future<$0.ChatMentionable> mentionable(
      $grpc.ServiceCall call, $0.ChatMentionableRequest request);

  $async.Future<$0.Space> mute_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatMuteRequest> $request) async {
    return mute($call, await $request);
  }

  $async.Future<$0.Space> mute(
      $grpc.ServiceCall call, $0.ChatMuteRequest request);

  $async.Future<$0.Space> notify_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatNotifyRequest> $request) async {
    return notify($call, await $request);
  }

  $async.Future<$0.Space> notify(
      $grpc.ServiceCall call, $0.ChatNotifyRequest request);

  $async.Future<$0.Space> openDm_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatOpenDmRequest> $request) async {
    return openDm($call, await $request);
  }

  $async.Future<$0.Space> openDm(
      $grpc.ServiceCall call, $0.ChatOpenDmRequest request);

  $async.Future<$0.Message> react_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatReactRequest> $request) async {
    return react($call, await $request);
  }

  $async.Future<$0.Message> react(
      $grpc.ServiceCall call, $0.ChatReactRequest request);

  $async.Future<$0.ChatDone> removeMember_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatRemoveMemberRequest> $request) async {
    return removeMember($call, await $request);
  }

  $async.Future<$0.ChatDone> removeMember(
      $grpc.ServiceCall call, $0.ChatRemoveMemberRequest request);

  $async.Future<$0.Message> send_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatSendRequest> $request) async {
    return send($call, await $request);
  }

  $async.Future<$0.Message> send(
      $grpc.ServiceCall call, $0.ChatSendRequest request);

  $async.Future<$0.Space> updateSpace_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChatUpdateSpaceRequest> $request) async {
    return updateSpace($call, await $request);
  }

  $async.Future<$0.Space> updateSpace(
      $grpc.ServiceCall call, $0.ChatUpdateSpaceRequest request);
}
