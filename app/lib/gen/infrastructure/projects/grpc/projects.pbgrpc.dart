// This is a generated file - do not edit.
//
// Generated from infrastructure/projects/grpc/projects.proto.

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

import 'projects.pb.dart' as $0;

export 'projects.pb.dart';

@$pb.GrpcServiceName('config.projects.ProjectController')
class ProjectControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ProjectControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ProjectMember> addMember(
    $0.ProjectAddMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> archive(
    $0.ProjectArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archive, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> create(
    $0.ProjectCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> favorite(
    $0.ProjectFavoriteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$favorite, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> get(
    $0.ProjectGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProjectList> list(
    $0.ProjectListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$list, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProjectMemberList> listMembers(
    $0.ProjectListMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMembers, request, options: options);
  }

  $grpc.ResponseFuture<$0.PrivateProjectList> listPrivate(
    $0.ProjectListPrivateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPrivate, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProjectEmpty> removeMember(
    $0.ProjectRemoveMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> restore(
    $0.ProjectRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> setFeatures(
    $0.ProjectSetFeaturesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setFeatures, request, options: options);
  }

  $grpc.ResponseFuture<$0.Project> update(
    $0.ProjectUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$addMember =
      $grpc.ClientMethod<$0.ProjectAddMemberRequest, $0.ProjectMember>(
          '/config.projects.ProjectController/AddMember',
          ($0.ProjectAddMemberRequest value) => value.writeToBuffer(),
          $0.ProjectMember.fromBuffer);
  static final _$archive =
      $grpc.ClientMethod<$0.ProjectArchiveRequest, $0.Project>(
          '/config.projects.ProjectController/Archive',
          ($0.ProjectArchiveRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$create =
      $grpc.ClientMethod<$0.ProjectCreateRequest, $0.Project>(
          '/config.projects.ProjectController/Create',
          ($0.ProjectCreateRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$favorite =
      $grpc.ClientMethod<$0.ProjectFavoriteRequest, $0.Project>(
          '/config.projects.ProjectController/Favorite',
          ($0.ProjectFavoriteRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.ProjectGetRequest, $0.Project>(
      '/config.projects.ProjectController/Get',
      ($0.ProjectGetRequest value) => value.writeToBuffer(),
      $0.Project.fromBuffer);
  static final _$list =
      $grpc.ClientMethod<$0.ProjectListRequest, $0.ProjectList>(
          '/config.projects.ProjectController/List',
          ($0.ProjectListRequest value) => value.writeToBuffer(),
          $0.ProjectList.fromBuffer);
  static final _$listMembers =
      $grpc.ClientMethod<$0.ProjectListMembersRequest, $0.ProjectMemberList>(
          '/config.projects.ProjectController/ListMembers',
          ($0.ProjectListMembersRequest value) => value.writeToBuffer(),
          $0.ProjectMemberList.fromBuffer);
  static final _$listPrivate =
      $grpc.ClientMethod<$0.ProjectListPrivateRequest, $0.PrivateProjectList>(
          '/config.projects.ProjectController/ListPrivate',
          ($0.ProjectListPrivateRequest value) => value.writeToBuffer(),
          $0.PrivateProjectList.fromBuffer);
  static final _$removeMember =
      $grpc.ClientMethod<$0.ProjectRemoveMemberRequest, $0.ProjectEmpty>(
          '/config.projects.ProjectController/RemoveMember',
          ($0.ProjectRemoveMemberRequest value) => value.writeToBuffer(),
          $0.ProjectEmpty.fromBuffer);
  static final _$restore =
      $grpc.ClientMethod<$0.ProjectRestoreRequest, $0.Project>(
          '/config.projects.ProjectController/Restore',
          ($0.ProjectRestoreRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$setFeatures =
      $grpc.ClientMethod<$0.ProjectSetFeaturesRequest, $0.Project>(
          '/config.projects.ProjectController/SetFeatures',
          ($0.ProjectSetFeaturesRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$0.ProjectUpdateRequest, $0.Project>(
          '/config.projects.ProjectController/Update',
          ($0.ProjectUpdateRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
}

@$pb.GrpcServiceName('config.projects.ProjectController')
abstract class ProjectControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.projects.ProjectController';

  ProjectControllerServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.ProjectAddMemberRequest, $0.ProjectMember>(
            'AddMember',
            addMember_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ProjectAddMemberRequest.fromBuffer(value),
            ($0.ProjectMember value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectArchiveRequest, $0.Project>(
        'Archive',
        archive_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectArchiveRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectCreateRequest, $0.Project>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectCreateRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectFavoriteRequest, $0.Project>(
        'Favorite',
        favorite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectFavoriteRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectGetRequest, $0.Project>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProjectGetRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectListRequest, $0.ProjectList>(
        'List',
        list_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectListRequest.fromBuffer(value),
        ($0.ProjectList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ProjectListMembersRequest, $0.ProjectMemberList>(
            'ListMembers',
            listMembers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ProjectListMembersRequest.fromBuffer(value),
            ($0.ProjectMemberList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectListPrivateRequest,
            $0.PrivateProjectList>(
        'ListPrivate',
        listPrivate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectListPrivateRequest.fromBuffer(value),
        ($0.PrivateProjectList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ProjectRemoveMemberRequest, $0.ProjectEmpty>(
            'RemoveMember',
            removeMember_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ProjectRemoveMemberRequest.fromBuffer(value),
            ($0.ProjectEmpty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectRestoreRequest, $0.Project>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectRestoreRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectSetFeaturesRequest, $0.Project>(
        'SetFeatures',
        setFeatures_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectSetFeaturesRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectUpdateRequest, $0.Project>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProjectUpdateRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
  }

  $async.Future<$0.ProjectMember> addMember_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectAddMemberRequest> $request) async {
    return addMember($call, await $request);
  }

  $async.Future<$0.ProjectMember> addMember(
      $grpc.ServiceCall call, $0.ProjectAddMemberRequest request);

  $async.Future<$0.Project> archive_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectArchiveRequest> $request) async {
    return archive($call, await $request);
  }

  $async.Future<$0.Project> archive(
      $grpc.ServiceCall call, $0.ProjectArchiveRequest request);

  $async.Future<$0.Project> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.Project> create(
      $grpc.ServiceCall call, $0.ProjectCreateRequest request);

  $async.Future<$0.Project> favorite_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectFavoriteRequest> $request) async {
    return favorite($call, await $request);
  }

  $async.Future<$0.Project> favorite(
      $grpc.ServiceCall call, $0.ProjectFavoriteRequest request);

  $async.Future<$0.Project> get_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.Project> get(
      $grpc.ServiceCall call, $0.ProjectGetRequest request);

  $async.Future<$0.ProjectList> list_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectListRequest> $request) async {
    return list($call, await $request);
  }

  $async.Future<$0.ProjectList> list(
      $grpc.ServiceCall call, $0.ProjectListRequest request);

  $async.Future<$0.ProjectMemberList> listMembers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectListMembersRequest> $request) async {
    return listMembers($call, await $request);
  }

  $async.Future<$0.ProjectMemberList> listMembers(
      $grpc.ServiceCall call, $0.ProjectListMembersRequest request);

  $async.Future<$0.PrivateProjectList> listPrivate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectListPrivateRequest> $request) async {
    return listPrivate($call, await $request);
  }

  $async.Future<$0.PrivateProjectList> listPrivate(
      $grpc.ServiceCall call, $0.ProjectListPrivateRequest request);

  $async.Future<$0.ProjectEmpty> removeMember_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectRemoveMemberRequest> $request) async {
    return removeMember($call, await $request);
  }

  $async.Future<$0.ProjectEmpty> removeMember(
      $grpc.ServiceCall call, $0.ProjectRemoveMemberRequest request);

  $async.Future<$0.Project> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.Project> restore(
      $grpc.ServiceCall call, $0.ProjectRestoreRequest request);

  $async.Future<$0.Project> setFeatures_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectSetFeaturesRequest> $request) async {
    return setFeatures($call, await $request);
  }

  $async.Future<$0.Project> setFeatures(
      $grpc.ServiceCall call, $0.ProjectSetFeaturesRequest request);

  $async.Future<$0.Project> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProjectUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.Project> update(
      $grpc.ServiceCall call, $0.ProjectUpdateRequest request);
}
