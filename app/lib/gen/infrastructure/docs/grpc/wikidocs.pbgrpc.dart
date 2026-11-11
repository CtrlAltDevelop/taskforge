// This is a generated file - do not edit.
//
// Generated from infrastructure/docs/grpc/wikidocs.proto.

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

import 'wikidocs.pb.dart' as $0;

export 'wikidocs.pb.dart';

@$pb.GrpcServiceName('config.wikidocs.DocController')
class DocControllerClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DocControllerClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.DocAnswer> archive(
    $0.DocArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archive, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocTree> backlinks(
    $0.DocBacklinksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$backlinks, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> create(
    $0.DocCreateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$create, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocMarkdown> exportMarkdown(
    $0.DocExportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportMarkdown, request, options: options);
  }

  $grpc.ResponseFuture<$0.RelatedDocs> forTask(
    $0.DocForTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> get(
    $0.DocGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$get, request, options: options);
  }

  $grpc.ResponseFuture<$0.RelatedDocs> linkTask(
    $0.DocLinkTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$linkTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> move(
    $0.DocMoveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$move, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocPresence> presence(
    $0.DocPresenceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$presence, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> restore(
    $0.DocRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restore, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocRevisionAnswer> revisionGet(
    $0.DocRevisionGetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revisionGet, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocRevisionList> revisionList(
    $0.DocRevisionListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revisionList, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> revisionRestore(
    $0.DocRevisionRestoreRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revisionRestore, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> setAccess(
    $0.DocSetAccessRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setAccess, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocTaskCards> taskCards(
    $0.DocTaskCardsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$taskCards, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocTree> tree(
    $0.DocTreeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$tree, request, options: options);
  }

  $grpc.ResponseFuture<$0.RelatedDocs> unlinkTask(
    $0.DocLinkTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlinkTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.DocAnswer> update(
    $0.DocUpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  // method descriptors

  static final _$archive =
      $grpc.ClientMethod<$0.DocArchiveRequest, $0.DocAnswer>(
          '/config.wikidocs.DocController/Archive',
          ($0.DocArchiveRequest value) => value.writeToBuffer(),
          $0.DocAnswer.fromBuffer);
  static final _$backlinks =
      $grpc.ClientMethod<$0.DocBacklinksRequest, $0.DocTree>(
          '/config.wikidocs.DocController/Backlinks',
          ($0.DocBacklinksRequest value) => value.writeToBuffer(),
          $0.DocTree.fromBuffer);
  static final _$create = $grpc.ClientMethod<$0.DocCreateRequest, $0.DocAnswer>(
      '/config.wikidocs.DocController/Create',
      ($0.DocCreateRequest value) => value.writeToBuffer(),
      $0.DocAnswer.fromBuffer);
  static final _$exportMarkdown =
      $grpc.ClientMethod<$0.DocExportRequest, $0.DocMarkdown>(
          '/config.wikidocs.DocController/ExportMarkdown',
          ($0.DocExportRequest value) => value.writeToBuffer(),
          $0.DocMarkdown.fromBuffer);
  static final _$forTask =
      $grpc.ClientMethod<$0.DocForTaskRequest, $0.RelatedDocs>(
          '/config.wikidocs.DocController/ForTask',
          ($0.DocForTaskRequest value) => value.writeToBuffer(),
          $0.RelatedDocs.fromBuffer);
  static final _$get = $grpc.ClientMethod<$0.DocGetRequest, $0.DocAnswer>(
      '/config.wikidocs.DocController/Get',
      ($0.DocGetRequest value) => value.writeToBuffer(),
      $0.DocAnswer.fromBuffer);
  static final _$linkTask =
      $grpc.ClientMethod<$0.DocLinkTaskRequest, $0.RelatedDocs>(
          '/config.wikidocs.DocController/LinkTask',
          ($0.DocLinkTaskRequest value) => value.writeToBuffer(),
          $0.RelatedDocs.fromBuffer);
  static final _$move = $grpc.ClientMethod<$0.DocMoveRequest, $0.DocAnswer>(
      '/config.wikidocs.DocController/Move',
      ($0.DocMoveRequest value) => value.writeToBuffer(),
      $0.DocAnswer.fromBuffer);
  static final _$presence =
      $grpc.ClientMethod<$0.DocPresenceRequest, $0.DocPresence>(
          '/config.wikidocs.DocController/Presence',
          ($0.DocPresenceRequest value) => value.writeToBuffer(),
          $0.DocPresence.fromBuffer);
  static final _$restore =
      $grpc.ClientMethod<$0.DocRestoreRequest, $0.DocAnswer>(
          '/config.wikidocs.DocController/Restore',
          ($0.DocRestoreRequest value) => value.writeToBuffer(),
          $0.DocAnswer.fromBuffer);
  static final _$revisionGet =
      $grpc.ClientMethod<$0.DocRevisionGetRequest, $0.DocRevisionAnswer>(
          '/config.wikidocs.DocController/RevisionGet',
          ($0.DocRevisionGetRequest value) => value.writeToBuffer(),
          $0.DocRevisionAnswer.fromBuffer);
  static final _$revisionList =
      $grpc.ClientMethod<$0.DocRevisionListRequest, $0.DocRevisionList>(
          '/config.wikidocs.DocController/RevisionList',
          ($0.DocRevisionListRequest value) => value.writeToBuffer(),
          $0.DocRevisionList.fromBuffer);
  static final _$revisionRestore =
      $grpc.ClientMethod<$0.DocRevisionRestoreRequest, $0.DocAnswer>(
          '/config.wikidocs.DocController/RevisionRestore',
          ($0.DocRevisionRestoreRequest value) => value.writeToBuffer(),
          $0.DocAnswer.fromBuffer);
  static final _$setAccess =
      $grpc.ClientMethod<$0.DocSetAccessRequest, $0.DocAnswer>(
          '/config.wikidocs.DocController/SetAccess',
          ($0.DocSetAccessRequest value) => value.writeToBuffer(),
          $0.DocAnswer.fromBuffer);
  static final _$taskCards =
      $grpc.ClientMethod<$0.DocTaskCardsRequest, $0.DocTaskCards>(
          '/config.wikidocs.DocController/TaskCards',
          ($0.DocTaskCardsRequest value) => value.writeToBuffer(),
          $0.DocTaskCards.fromBuffer);
  static final _$tree = $grpc.ClientMethod<$0.DocTreeRequest, $0.DocTree>(
      '/config.wikidocs.DocController/Tree',
      ($0.DocTreeRequest value) => value.writeToBuffer(),
      $0.DocTree.fromBuffer);
  static final _$unlinkTask =
      $grpc.ClientMethod<$0.DocLinkTaskRequest, $0.RelatedDocs>(
          '/config.wikidocs.DocController/UnlinkTask',
          ($0.DocLinkTaskRequest value) => value.writeToBuffer(),
          $0.RelatedDocs.fromBuffer);
  static final _$update = $grpc.ClientMethod<$0.DocUpdateRequest, $0.DocAnswer>(
      '/config.wikidocs.DocController/Update',
      ($0.DocUpdateRequest value) => value.writeToBuffer(),
      $0.DocAnswer.fromBuffer);
}

@$pb.GrpcServiceName('config.wikidocs.DocController')
abstract class DocControllerServiceBase extends $grpc.Service {
  $core.String get $name => 'config.wikidocs.DocController';

  DocControllerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.DocArchiveRequest, $0.DocAnswer>(
        'Archive',
        archive_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocArchiveRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocBacklinksRequest, $0.DocTree>(
        'Backlinks',
        backlinks_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocBacklinksRequest.fromBuffer(value),
        ($0.DocTree value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocCreateRequest, $0.DocAnswer>(
        'Create',
        create_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocCreateRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocExportRequest, $0.DocMarkdown>(
        'ExportMarkdown',
        exportMarkdown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocExportRequest.fromBuffer(value),
        ($0.DocMarkdown value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocForTaskRequest, $0.RelatedDocs>(
        'ForTask',
        forTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocForTaskRequest.fromBuffer(value),
        ($0.RelatedDocs value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocGetRequest, $0.DocAnswer>(
        'Get',
        get_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocGetRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocLinkTaskRequest, $0.RelatedDocs>(
        'LinkTask',
        linkTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocLinkTaskRequest.fromBuffer(value),
        ($0.RelatedDocs value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocMoveRequest, $0.DocAnswer>(
        'Move',
        move_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocMoveRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocPresenceRequest, $0.DocPresence>(
        'Presence',
        presence_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocPresenceRequest.fromBuffer(value),
        ($0.DocPresence value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocRestoreRequest, $0.DocAnswer>(
        'Restore',
        restore_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocRestoreRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DocRevisionGetRequest, $0.DocRevisionAnswer>(
            'RevisionGet',
            revisionGet_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DocRevisionGetRequest.fromBuffer(value),
            ($0.DocRevisionAnswer value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DocRevisionListRequest, $0.DocRevisionList>(
            'RevisionList',
            revisionList_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DocRevisionListRequest.fromBuffer(value),
            ($0.DocRevisionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocRevisionRestoreRequest, $0.DocAnswer>(
        'RevisionRestore',
        revisionRestore_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocRevisionRestoreRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocSetAccessRequest, $0.DocAnswer>(
        'SetAccess',
        setAccess_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocSetAccessRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocTaskCardsRequest, $0.DocTaskCards>(
        'TaskCards',
        taskCards_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocTaskCardsRequest.fromBuffer(value),
        ($0.DocTaskCards value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocTreeRequest, $0.DocTree>(
        'Tree',
        tree_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocTreeRequest.fromBuffer(value),
        ($0.DocTree value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocLinkTaskRequest, $0.RelatedDocs>(
        'UnlinkTask',
        unlinkTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DocLinkTaskRequest.fromBuffer(value),
        ($0.RelatedDocs value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DocUpdateRequest, $0.DocAnswer>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DocUpdateRequest.fromBuffer(value),
        ($0.DocAnswer value) => value.writeToBuffer()));
  }

  $async.Future<$0.DocAnswer> archive_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocArchiveRequest> $request) async {
    return archive($call, await $request);
  }

  $async.Future<$0.DocAnswer> archive(
      $grpc.ServiceCall call, $0.DocArchiveRequest request);

  $async.Future<$0.DocTree> backlinks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocBacklinksRequest> $request) async {
    return backlinks($call, await $request);
  }

  $async.Future<$0.DocTree> backlinks(
      $grpc.ServiceCall call, $0.DocBacklinksRequest request);

  $async.Future<$0.DocAnswer> create_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocCreateRequest> $request) async {
    return create($call, await $request);
  }

  $async.Future<$0.DocAnswer> create(
      $grpc.ServiceCall call, $0.DocCreateRequest request);

  $async.Future<$0.DocMarkdown> exportMarkdown_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocExportRequest> $request) async {
    return exportMarkdown($call, await $request);
  }

  $async.Future<$0.DocMarkdown> exportMarkdown(
      $grpc.ServiceCall call, $0.DocExportRequest request);

  $async.Future<$0.RelatedDocs> forTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocForTaskRequest> $request) async {
    return forTask($call, await $request);
  }

  $async.Future<$0.RelatedDocs> forTask(
      $grpc.ServiceCall call, $0.DocForTaskRequest request);

  $async.Future<$0.DocAnswer> get_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DocGetRequest> $request) async {
    return get($call, await $request);
  }

  $async.Future<$0.DocAnswer> get(
      $grpc.ServiceCall call, $0.DocGetRequest request);

  $async.Future<$0.RelatedDocs> linkTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocLinkTaskRequest> $request) async {
    return linkTask($call, await $request);
  }

  $async.Future<$0.RelatedDocs> linkTask(
      $grpc.ServiceCall call, $0.DocLinkTaskRequest request);

  $async.Future<$0.DocAnswer> move_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocMoveRequest> $request) async {
    return move($call, await $request);
  }

  $async.Future<$0.DocAnswer> move(
      $grpc.ServiceCall call, $0.DocMoveRequest request);

  $async.Future<$0.DocPresence> presence_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocPresenceRequest> $request) async {
    return presence($call, await $request);
  }

  $async.Future<$0.DocPresence> presence(
      $grpc.ServiceCall call, $0.DocPresenceRequest request);

  $async.Future<$0.DocAnswer> restore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocRestoreRequest> $request) async {
    return restore($call, await $request);
  }

  $async.Future<$0.DocAnswer> restore(
      $grpc.ServiceCall call, $0.DocRestoreRequest request);

  $async.Future<$0.DocRevisionAnswer> revisionGet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocRevisionGetRequest> $request) async {
    return revisionGet($call, await $request);
  }

  $async.Future<$0.DocRevisionAnswer> revisionGet(
      $grpc.ServiceCall call, $0.DocRevisionGetRequest request);

  $async.Future<$0.DocRevisionList> revisionList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocRevisionListRequest> $request) async {
    return revisionList($call, await $request);
  }

  $async.Future<$0.DocRevisionList> revisionList(
      $grpc.ServiceCall call, $0.DocRevisionListRequest request);

  $async.Future<$0.DocAnswer> revisionRestore_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocRevisionRestoreRequest> $request) async {
    return revisionRestore($call, await $request);
  }

  $async.Future<$0.DocAnswer> revisionRestore(
      $grpc.ServiceCall call, $0.DocRevisionRestoreRequest request);

  $async.Future<$0.DocAnswer> setAccess_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocSetAccessRequest> $request) async {
    return setAccess($call, await $request);
  }

  $async.Future<$0.DocAnswer> setAccess(
      $grpc.ServiceCall call, $0.DocSetAccessRequest request);

  $async.Future<$0.DocTaskCards> taskCards_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocTaskCardsRequest> $request) async {
    return taskCards($call, await $request);
  }

  $async.Future<$0.DocTaskCards> taskCards(
      $grpc.ServiceCall call, $0.DocTaskCardsRequest request);

  $async.Future<$0.DocTree> tree_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocTreeRequest> $request) async {
    return tree($call, await $request);
  }

  $async.Future<$0.DocTree> tree(
      $grpc.ServiceCall call, $0.DocTreeRequest request);

  $async.Future<$0.RelatedDocs> unlinkTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocLinkTaskRequest> $request) async {
    return unlinkTask($call, await $request);
  }

  $async.Future<$0.RelatedDocs> unlinkTask(
      $grpc.ServiceCall call, $0.DocLinkTaskRequest request);

  $async.Future<$0.DocAnswer> update_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DocUpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$0.DocAnswer> update(
      $grpc.ServiceCall call, $0.DocUpdateRequest request);
}
