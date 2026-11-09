// This is a generated file - do not edit.
//
// Generated from infrastructure/workspaces/grpc/workspaces.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'workspaces.pb.dart' as $0;

export 'workspaces.pb.dart';

@$pb.GrpcServiceName('config.workspaces.InvitationController')
class InvitationControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  InvitationControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Workspace> accept(
    $0.InvitationAcceptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$accept, request, options: options);
  }

  $grpc.ResponseFuture<$0.InvitationCreateResponse> create(
    $0.InvitationCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Invitation> createLink(
    $0.InvitationCreateLinkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createLink, request, options: options);
  }

  $grpc.ResponseFuture<$0.InvitationEmpty> decline(
    $0.InvitationDeclineRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$decline, request, options: options);
  }

  $grpc.ResponseFuture<$0.InvitationList> list(
    $0.InvitationListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.Invitation> resend(
    $0.InvitationResendRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resend, request, options: options);
  }

  $grpc.ResponseFuture<$0.Invitation> revoke(
    $0.InvitationRevokeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revoke, request, options: options);
  }

  // method descriptors

  static final _$accept =
      $grpc.ClientMethod<$0.InvitationAcceptRequest, $0.Workspace>(
          '/config.workspaces.InvitationController/Accept',
          ($0.InvitationAcceptRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$create = $grpc.ClientMethod<$0.InvitationCreateRequest,
          $0.InvitationCreateResponse>(
      '/config.workspaces.InvitationController/Create',
      ($0.InvitationCreateRequest value) => value.writeToBuffer(),
      $0.InvitationCreateResponse.fromBuffer);
  static final _$createLink =
      $grpc.ClientMethod<$0.InvitationCreateLinkRequest, $0.Invitation>(
          '/config.workspaces.InvitationController/CreateLink',
          ($0.InvitationCreateLinkRequest value) => value.writeToBuffer(),
          $0.Invitation.fromBuffer);
  static final _$decline =
      $grpc.ClientMethod<$0.InvitationDeclineRequest, $0.InvitationEmpty>(
          '/config.workspaces.InvitationController/Decline',
          ($0.InvitationDeclineRequest value) => value.writeToBuffer(),
          $0.InvitationEmpty.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.InvitationListRequest, $0.InvitationList>(
          '/config.workspaces.InvitationController/List',
          ($0.InvitationListRequest value) => value.writeToBuffer(),
          $0.InvitationList.fromBuffer);
  static final _$resend =
      $grpc.ClientMethod<$0.InvitationResendRequest, $0.Invitation>(
          '/config.workspaces.InvitationController/Resend',
          ($0.InvitationResendRequest value) => value.writeToBuffer(),
          $0.Invitation.fromBuffer);
  static final _$revoke =
      $grpc.ClientMethod<$0.InvitationRevokeRequest, $0.Invitation>(
          '/config.workspaces.InvitationController/Revoke',
          ($0.InvitationRevokeRequest value) => value.writeToBuffer(),
          $0.Invitation.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.InvitationController')
abstract class InvitationControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.InvitationController';

  InvitationControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.InvitationAcceptRequest, $0.Workspace>(
        'Accept',
        accept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InvitationAcceptRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InvitationCreateRequest,
            $0.InvitationCreateResponse>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InvitationCreateRequest.fromBuffer(value),
        ($0.InvitationCreateResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.InvitationCreateLinkRequest, $0.Invitation>(
            'CreateLink',
            createLink_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.InvitationCreateLinkRequest.fromBuffer(value),
            ($0.Invitation value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.InvitationDeclineRequest, $0.InvitationEmpty>(
            'Decline',
            decline_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.InvitationDeclineRequest.fromBuffer(value),
            ($0.InvitationEmpty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InvitationListRequest, $0.InvitationList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InvitationListRequest.fromBuffer(value),
        ($0.InvitationList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InvitationResendRequest, $0.Invitation>(
        'Resend',
        resend_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InvitationResendRequest.fromBuffer(value),
        ($0.Invitation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InvitationRevokeRequest, $0.Invitation>(
        'Revoke',
        revoke_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InvitationRevokeRequest.fromBuffer(value),
        ($0.Invitation value) => value.writeToBuffer()));
  }

  $async.Future<$0.Workspace> accept_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationAcceptRequest> $request) async {
    return accept($call, await $request);
  }

  $async.Future<$0.Workspace> accept(
      $grpc.ServiceCall call, $0.InvitationAcceptRequest request);

  $async.Future<$0.InvitationCreateResponse> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.InvitationCreateResponse> create(
      $grpc.ServiceCall call, $0.InvitationCreateRequest request);

  $async.Future<$0.Invitation> createLink_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationCreateLinkRequest> $request) async {
    return createLink($call, await $request);
  }

  $async.Future<$0.Invitation> createLink(
      $grpc.ServiceCall call, $0.InvitationCreateLinkRequest request);

  $async.Future<$0.InvitationEmpty> decline_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationDeclineRequest> $request) async {
    return decline($call, await $request);
  }

  $async.Future<$0.InvitationEmpty> decline(
      $grpc.ServiceCall call, $0.InvitationDeclineRequest request);

  $async.Future<$0.InvitationList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.InvitationList> list(
      $grpc.ServiceCall call, $0.InvitationListRequest request);

  $async.Future<$0.Invitation> resend_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationResendRequest> $request) async {
    return resend($call, await $request);
  }

  $async.Future<$0.Invitation> resend(
      $grpc.ServiceCall call, $0.InvitationResendRequest request);

  $async.Future<$0.Invitation> revoke_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InvitationRevokeRequest> $request) async {
    return revoke($call, await $request);
  }

  $async.Future<$0.Invitation> revoke(
      $grpc.ServiceCall call, $0.InvitationRevokeRequest request);
}

@$pb.GrpcServiceName('config.workspaces.MemberController')
class MemberControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MemberControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.MemberEmpty> leave(
    $0.MemberLeaveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$leave, request, options: options);
  }

  $grpc.ResponseFuture<$0.MemberList> list(
    $0.MemberListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.MemberEmpty> remove(
    $0.MemberRemoveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$remove, request, options: options);
  }

  $grpc.ResponseFuture<$0.Member> setRole(
    $0.MemberSetRoleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRole, request, options: options);
  }

  // method descriptors

  static final _$leave =
      $grpc.ClientMethod<$0.MemberLeaveRequest, $0.MemberEmpty>(
          '/config.workspaces.MemberController/Leave',
          ($0.MemberLeaveRequest value) => value.writeToBuffer(),
          $0.MemberEmpty.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.MemberListRequest, $0.MemberList>(
      '/config.workspaces.MemberController/List',
      ($0.MemberListRequest value) => value.writeToBuffer(),
      $0.MemberList.fromBuffer);
  static final _$remove =
      $grpc.ClientMethod<$0.MemberRemoveRequest, $0.MemberEmpty>(
          '/config.workspaces.MemberController/Remove',
          ($0.MemberRemoveRequest value) => value.writeToBuffer(),
          $0.MemberEmpty.fromBuffer);
  static final _$setRole =
      $grpc.ClientMethod<$0.MemberSetRoleRequest, $0.Member>(
          '/config.workspaces.MemberController/SetRole',
          ($0.MemberSetRoleRequest value) => value.writeToBuffer(),
          $0.Member.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.MemberController')
abstract class MemberControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.MemberController';

  MemberControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.MemberLeaveRequest, $0.MemberEmpty>(
        'Leave',
        leave_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MemberLeaveRequest.fromBuffer(value),
        ($0.MemberEmpty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MemberListRequest, $0.MemberList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MemberListRequest.fromBuffer(value),
        ($0.MemberList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MemberRemoveRequest, $0.MemberEmpty>(
        'Remove',
        remove_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MemberRemoveRequest.fromBuffer(value),
        ($0.MemberEmpty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MemberSetRoleRequest, $0.Member>(
        'SetRole',
        setRole_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MemberSetRoleRequest.fromBuffer(value),
        ($0.Member value) => value.writeToBuffer()));
  }

  $async.Future<$0.MemberEmpty> leave_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MemberLeaveRequest> $request) async {
    return leave($call, await $request);
  }

  $async.Future<$0.MemberEmpty> leave(
      $grpc.ServiceCall call, $0.MemberLeaveRequest request);

  $async.Future<$0.MemberList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MemberListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.MemberList> list(
      $grpc.ServiceCall call, $0.MemberListRequest request);

  $async.Future<$0.MemberEmpty> remove_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MemberRemoveRequest> $request) async {
    return remove($call, await $request);
  }

  $async.Future<$0.MemberEmpty> remove(
      $grpc.ServiceCall call, $0.MemberRemoveRequest request);

  $async.Future<$0.Member> setRole_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MemberSetRoleRequest> $request) async {
    return setRole($call, await $request);
  }

  $async.Future<$0.Member> setRole(
      $grpc.ServiceCall call, $0.MemberSetRoleRequest request);
}

@$pb.GrpcServiceName('config.workspaces.PermissionController')
class PermissionControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PermissionControllerClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.PermissionCheckResponse> check(
    $0.PermissionCheckRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$check, request, options: options);
  }

  // method descriptors

  static final _$check =
      $grpc.ClientMethod<$0.PermissionCheckRequest, $0.PermissionCheckResponse>(
          '/config.workspaces.PermissionController/Check',
          ($0.PermissionCheckRequest value) => value.writeToBuffer(),
          $0.PermissionCheckResponse.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.PermissionController')
abstract class PermissionControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.PermissionController';

  PermissionControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PermissionCheckRequest,
            $0.PermissionCheckResponse>(
        'Check',
        check_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PermissionCheckRequest.fromBuffer(value),
        ($0.PermissionCheckResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PermissionCheckResponse> check_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PermissionCheckRequest> $request) async {
    return check($call, await $request);
  }

  $async.Future<$0.PermissionCheckResponse> check(
      $grpc.ServiceCall call, $0.PermissionCheckRequest request);
}

@$pb.GrpcServiceName('config.workspaces.RoleController')
class RoleControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RoleControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Role> create(
    $0.RoleCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.RoleEmpty> delete(
    $0.RoleDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.RoleList> list(
    $0.RoleListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.Role> update(
    $0.RoleUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create = $grpc.ClientMethod<$0.RoleCreateRequest, $0.Role>(
      '/config.workspaces.RoleController/Create',
      ($0.RoleCreateRequest value) => value.writeToBuffer(),
      $0.Role.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.RoleDeleteRequest, $0.RoleEmpty>(
          '/config.workspaces.RoleController/Delete',
          ($0.RoleDeleteRequest value) => value.writeToBuffer(),
          $0.RoleEmpty.fromBuffer);
  static final _$list = $grpc.ClientMethod<$0.RoleListRequest, $0.RoleList>(
      '/config.workspaces.RoleController/List',
      ($0.RoleListRequest value) => value.writeToBuffer(),
      $0.RoleList.fromBuffer);
  static final _$update = $grpc.ClientMethod<$0.RoleUpdateRequest, $0.Role>(
      '/config.workspaces.RoleController/Update',
      ($0.RoleUpdateRequest value) => value.writeToBuffer(),
      $0.Role.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.RoleController')
abstract class RoleControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.RoleController';

  RoleControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RoleCreateRequest, $0.Role>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RoleCreateRequest.fromBuffer(value),
        ($0.Role value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RoleDeleteRequest, $0.RoleEmpty>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RoleDeleteRequest.fromBuffer(value),
        ($0.RoleEmpty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RoleListRequest, $0.RoleList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RoleListRequest.fromBuffer(value),
        ($0.RoleList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RoleUpdateRequest, $0.Role>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RoleUpdateRequest.fromBuffer(value),
        ($0.Role value) => value.writeToBuffer()));
  }

  $async.Future<$0.Role> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RoleCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Role> create(
      $grpc.ServiceCall call, $0.RoleCreateRequest request);

  $async.Future<$0.RoleEmpty> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RoleDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.RoleEmpty> delete(
      $grpc.ServiceCall call, $0.RoleDeleteRequest request);

  $async.Future<$0.RoleList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RoleListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.RoleList> list(
      $grpc.ServiceCall call, $0.RoleListRequest request);

  $async.Future<$0.Role> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RoleUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Role> update(
      $grpc.ServiceCall call, $0.RoleUpdateRequest request);
}

@$pb.GrpcServiceName('config.workspaces.WorkspaceController')
class WorkspaceControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WorkspaceControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Workspace> create(
    $0.WorkspaceCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> delete(
    $0.WorkspaceDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkspaceList> list(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.WorkspaceList> listDeleted(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listDeleted, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> restore(
    $0.WorkspaceRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.Workspace> update(
    $0.WorkspaceUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$create =
      $grpc.ClientMethod<$0.WorkspaceCreateRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Create',
          ($0.WorkspaceCreateRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$delete =
      $grpc.ClientMethod<$0.WorkspaceDeleteRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Delete',
          ($0.WorkspaceDeleteRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$list = $grpc.ClientMethod<$1.Empty, $0.WorkspaceList>(
      '/config.workspaces.WorkspaceController/List',
      ($1.Empty value) => value.writeToBuffer(),
      $0.WorkspaceList.fromBuffer);
  static final _$listDeleted = $grpc.ClientMethod<$1.Empty, $0.WorkspaceList>(
      '/config.workspaces.WorkspaceController/ListDeleted',
      ($1.Empty value) => value.writeToBuffer(),
      $0.WorkspaceList.fromBuffer);
  static final _$restore =
      $grpc.ClientMethod<$0.WorkspaceRestoreRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Restore',
          ($0.WorkspaceRestoreRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.WorkspaceUpdateRequest, $0.Workspace>(
          '/config.workspaces.WorkspaceController/Update',
          ($0.WorkspaceUpdateRequest value) => value.writeToBuffer(),
          $0.Workspace.fromBuffer);
}

@$pb.GrpcServiceName('config.workspaces.WorkspaceController')
abstract class WorkspaceControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.workspaces.WorkspaceController';

  WorkspaceControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WorkspaceCreateRequest, $0.Workspace>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceCreateRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceDeleteRequest, $0.Workspace>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceDeleteRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.WorkspaceList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.WorkspaceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.WorkspaceList>(
        'ListDeleted',
        listDeleted_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.WorkspaceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceRestoreRequest, $0.Workspace>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceRestoreRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WorkspaceUpdateRequest, $0.Workspace>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WorkspaceUpdateRequest.fromBuffer(value),
        ($0.Workspace value) => value.writeToBuffer()));
  }

  $async.Future<$0.Workspace> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Workspace> create(
      $grpc.ServiceCall call, $0.WorkspaceCreateRequest request);

  $async.Future<$0.Workspace> delete_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceDeleteRequest> $request) async {
    return delete($call, await $request);
  }

  $async.Future<$0.Workspace> delete(
      $grpc.ServiceCall call, $0.WorkspaceDeleteRequest request);

  $async.Future<$0.WorkspaceList> list_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.WorkspaceList> list(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.WorkspaceList> listDeleted_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listDeleted($call, await $request);
  }

  $async.Future<$0.WorkspaceList> listDeleted(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.Workspace> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.Workspace> restore(
      $grpc.ServiceCall call, $0.WorkspaceRestoreRequest request);

  $async.Future<$0.Workspace> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WorkspaceUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Workspace> update(
      $grpc.ServiceCall call, $0.WorkspaceUpdateRequest request);
}
