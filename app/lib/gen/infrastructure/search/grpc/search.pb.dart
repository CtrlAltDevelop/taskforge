// This is a generated file - do not edit.
//
// Generated from infrastructure/search/grpc/search.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Hit extends $pb.GeneratedMessage {
  factory Hit({
    $core.String? kind,
    $core.String? id,
    $core.String? taskId,
    $core.String? projectId,
    $core.String? key,
    $core.String? title,
    $core.Iterable<Span>? titleMarks,
    $core.String? snippet,
    $core.Iterable<Span>? snippetMarks,
    $core.String? projectName,
    $core.String? status,
    $core.String? author,
    $core.String? updatedAt,
  }) {
    final result = Hit._();
    if (kind != null) result.kind = kind;
    if (id != null) result.id = id;
    if (taskId != null) result.taskId = taskId;
    if (projectId != null) result.projectId = projectId;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (titleMarks != null) result.titleMarks.addAll(titleMarks);
    if (snippet != null) result.snippet = snippet;
    if (snippetMarks != null) result.snippetMarks.addAll(snippetMarks);
    if (projectName != null) result.projectName = projectName;
    if (status != null) result.status = status;
    if (author != null) result.author = author;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Hit._();

  factory Hit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hit()..mergeFromBuffer(data, registry);
  factory Hit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Hit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Hit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: Hit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'taskId')
    ..aOS(4, _omitFieldNames ? '' : 'projectId')
    ..aOS(5, _omitFieldNames ? '' : 'key')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..pPM<Span>(7, _omitFieldNames ? '' : 'titleMarks',
        subBuilder: Span.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'snippet')
    ..pPM<Span>(9, _omitFieldNames ? '' : 'snippetMarks',
        subBuilder: Span.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'projectName')
    ..aOS(11, _omitFieldNames ? '' : 'status')
    ..aOS(12, _omitFieldNames ? '' : 'author')
    ..aOS(13, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Hit copyWith(void Function(Hit) updates) =>
      super.copyWith((message) => updates(message as Hit)) as Hit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Hit() / Hit.new instead')
  static Hit create() => Hit._();
  static $pb.GeneratedMessage $_createMessage() => Hit._();
  @$core.override
  Hit createEmptyInstance() => Hit._();
  @$core.pragma('dart2js:noInline')
  static Hit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Hit>(Hit.$_createMessage);
  static Hit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kind => $_getSZ(0);
  @$pb.TagNumber(1)
  set kind($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get taskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set taskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get projectId => $_getSZ(3);
  @$pb.TagNumber(4)
  set projectId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProjectId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProjectId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get key => $_getSZ(4);
  @$pb.TagNumber(5)
  set key($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<Span> get titleMarks => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get snippet => $_getSZ(7);
  @$pb.TagNumber(8)
  set snippet($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSnippet() => $_has(7);
  @$pb.TagNumber(8)
  void clearSnippet() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<Span> get snippetMarks => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get projectName => $_getSZ(9);
  @$pb.TagNumber(10)
  set projectName($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasProjectName() => $_has(9);
  @$pb.TagNumber(10)
  void clearProjectName() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get status => $_getSZ(10);
  @$pb.TagNumber(11)
  set status($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearStatus() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get author => $_getSZ(11);
  @$pb.TagNumber(12)
  set author($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAuthor() => $_has(11);
  @$pb.TagNumber(12)
  void clearAuthor() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get updatedAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set updatedAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdatedAt() => $_clearField(13);
}

class SearchQueryRequest extends $pb.GeneratedMessage {
  factory SearchQueryRequest({
    $core.String? workspaceId,
    $core.String? text,
    $core.Iterable<$core.String>? types,
    $core.String? cursor,
    $core.int? pageSize,
  }) {
    final result = SearchQueryRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (text != null) result.text = text;
    if (types != null) result.types.addAll(types);
    if (cursor != null) result.cursor = cursor;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  SearchQueryRequest._();

  factory SearchQueryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchQueryRequest()..mergeFromBuffer(data, registry);
  factory SearchQueryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchQueryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchQueryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchQueryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..pPS(3, _omitFieldNames ? '' : 'types')
    ..aOS(4, _omitFieldNames ? '' : 'cursor')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchQueryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchQueryRequest copyWith(void Function(SearchQueryRequest) updates) =>
      super.copyWith((message) => updates(message as SearchQueryRequest))
          as SearchQueryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchQueryRequest() / SearchQueryRequest.new instead')
  static SearchQueryRequest create() => SearchQueryRequest._();
  static $pb.GeneratedMessage $_createMessage() => SearchQueryRequest._();
  @$core.override
  SearchQueryRequest createEmptyInstance() => SearchQueryRequest._();
  @$core.pragma('dart2js:noInline')
  static SearchQueryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchQueryRequest>(
          SearchQueryRequest.$_createMessage);
  static SearchQueryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get types => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get cursor => $_getSZ(3);
  @$pb.TagNumber(4)
  set cursor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);
}

class SearchRecent extends $pb.GeneratedMessage {
  factory SearchRecent({
    $core.Iterable<$core.String>? queries,
  }) {
    final result = SearchRecent._();
    if (queries != null) result.queries.addAll(queries);
    return result;
  }

  SearchRecent._();

  factory SearchRecent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRecent()..mergeFromBuffer(data, registry);
  factory SearchRecent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRecent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRecent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchRecent.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'queries')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRecent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRecent copyWith(void Function(SearchRecent) updates) =>
      super.copyWith((message) => updates(message as SearchRecent))
          as SearchRecent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchRecent() / SearchRecent.new instead')
  static SearchRecent create() => SearchRecent._();
  static $pb.GeneratedMessage $_createMessage() => SearchRecent._();
  @$core.override
  SearchRecent createEmptyInstance() => SearchRecent._();
  @$core.pragma('dart2js:noInline')
  static SearchRecent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchRecent>(
          SearchRecent.$_createMessage);
  static SearchRecent? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get queries => $_getList(0);
}

class SearchRecentRequest extends $pb.GeneratedMessage {
  factory SearchRecentRequest({
    $core.String? workspaceId,
  }) {
    final result = SearchRecentRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    return result;
  }

  SearchRecentRequest._();

  factory SearchRecentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRecentRequest()..mergeFromBuffer(data, registry);
  factory SearchRecentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRecentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRecentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchRecentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRecentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRecentRequest copyWith(void Function(SearchRecentRequest) updates) =>
      super.copyWith((message) => updates(message as SearchRecentRequest))
          as SearchRecentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use SearchRecentRequest() / SearchRecentRequest.new instead')
  static SearchRecentRequest create() => SearchRecentRequest._();
  static $pb.GeneratedMessage $_createMessage() => SearchRecentRequest._();
  @$core.override
  SearchRecentRequest createEmptyInstance() => SearchRecentRequest._();
  @$core.pragma('dart2js:noInline')
  static SearchRecentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchRecentRequest>(
          SearchRecentRequest.$_createMessage);
  static SearchRecentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);
}

class SearchRememberRequest extends $pb.GeneratedMessage {
  factory SearchRememberRequest({
    $core.String? workspaceId,
    $core.String? text,
  }) {
    final result = SearchRememberRequest._();
    if (workspaceId != null) result.workspaceId = workspaceId;
    if (text != null) result.text = text;
    return result;
  }

  SearchRememberRequest._();

  factory SearchRememberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRememberRequest()..mergeFromBuffer(data, registry);
  factory SearchRememberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRememberRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRememberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchRememberRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'workspaceId')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRememberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRememberRequest copyWith(
          void Function(SearchRememberRequest) updates) =>
      super.copyWith((message) => updates(message as SearchRememberRequest))
          as SearchRememberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SearchRememberRequest() / SearchRememberRequest.new instead')
  static SearchRememberRequest create() => SearchRememberRequest._();
  static $pb.GeneratedMessage $_createMessage() => SearchRememberRequest._();
  @$core.override
  SearchRememberRequest createEmptyInstance() => SearchRememberRequest._();
  @$core.pragma('dart2js:noInline')
  static SearchRememberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchRememberRequest>(
          SearchRememberRequest.$_createMessage);
  static SearchRememberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get workspaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workspaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWorkspaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkspaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
}

class SearchRemembered extends $pb.GeneratedMessage {
  factory SearchRemembered({
    $core.bool? ok,
  }) {
    final result = SearchRemembered._();
    if (ok != null) result.ok = ok;
    return result;
  }

  SearchRemembered._();

  factory SearchRemembered.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRemembered()..mergeFromBuffer(data, registry);
  factory SearchRemembered.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchRemembered()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRemembered',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchRemembered.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRemembered clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRemembered copyWith(void Function(SearchRemembered) updates) =>
      super.copyWith((message) => updates(message as SearchRemembered))
          as SearchRemembered;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchRemembered() / SearchRemembered.new instead')
  static SearchRemembered create() => SearchRemembered._();
  static $pb.GeneratedMessage $_createMessage() => SearchRemembered._();
  @$core.override
  SearchRemembered createEmptyInstance() => SearchRemembered._();
  @$core.pragma('dart2js:noInline')
  static SearchRemembered getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchRemembered>(
          SearchRemembered.$_createMessage);
  static SearchRemembered? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);
}

class SearchResults extends $pb.GeneratedMessage {
  factory SearchResults({
    $core.Iterable<Hit>? tasks,
    $core.Iterable<Hit>? comments,
    $core.Iterable<Hit>? projects,
    $core.Iterable<Hit>? members,
    Hit? jump,
    $core.String? nextCursor,
  }) {
    final result = SearchResults._();
    if (tasks != null) result.tasks.addAll(tasks);
    if (comments != null) result.comments.addAll(comments);
    if (projects != null) result.projects.addAll(projects);
    if (members != null) result.members.addAll(members);
    if (jump != null) result.jump = jump;
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  SearchResults._();

  factory SearchResults.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchResults()..mergeFromBuffer(data, registry);
  factory SearchResults.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchResults()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchResults',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: SearchResults.$_createMessage)
    ..pPM<Hit>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: Hit.$_createMessage)
    ..pPM<Hit>(2, _omitFieldNames ? '' : 'comments',
        subBuilder: Hit.$_createMessage)
    ..pPM<Hit>(3, _omitFieldNames ? '' : 'projects',
        subBuilder: Hit.$_createMessage)
    ..pPM<Hit>(4, _omitFieldNames ? '' : 'members',
        subBuilder: Hit.$_createMessage)
    ..aOM<Hit>(5, _omitFieldNames ? '' : 'jump',
        subBuilder: Hit.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'nextCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResults clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResults copyWith(void Function(SearchResults) updates) =>
      super.copyWith((message) => updates(message as SearchResults))
          as SearchResults;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchResults() / SearchResults.new instead')
  static SearchResults create() => SearchResults._();
  static $pb.GeneratedMessage $_createMessage() => SearchResults._();
  @$core.override
  SearchResults createEmptyInstance() => SearchResults._();
  @$core.pragma('dart2js:noInline')
  static SearchResults getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchResults>(
          SearchResults.$_createMessage);
  static SearchResults? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Hit> get tasks => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Hit> get comments => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Hit> get projects => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<Hit> get members => $_getList(3);

  @$pb.TagNumber(5)
  Hit get jump => $_getN(4);
  @$pb.TagNumber(5)
  set jump(Hit value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasJump() => $_has(4);
  @$pb.TagNumber(5)
  void clearJump() => $_clearField(5);
  @$pb.TagNumber(5)
  Hit ensureJump() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get nextCursor => $_getSZ(5);
  @$pb.TagNumber(6)
  set nextCursor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNextCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearNextCursor() => $_clearField(6);
}

class Span extends $pb.GeneratedMessage {
  factory Span({
    $core.int? start,
    $core.int? end,
  }) {
    final result = Span._();
    if (start != null) result.start = start;
    if (end != null) result.end = end;
    return result;
  }

  Span._();

  factory Span.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Span()..mergeFromBuffer(data, registry);
  factory Span.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Span()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Span',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'config.search'),
      createEmptyInstance: Span.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'start')
    ..aI(2, _omitFieldNames ? '' : 'end')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Span clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Span copyWith(void Function(Span) updates) =>
      super.copyWith((message) => updates(message as Span)) as Span;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Span() / Span.new instead')
  static Span create() => Span._();
  static $pb.GeneratedMessage $_createMessage() => Span._();
  @$core.override
  Span createEmptyInstance() => Span._();
  @$core.pragma('dart2js:noInline')
  static Span getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Span>(Span.$_createMessage);
  static Span? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get start => $_getIZ(0);
  @$pb.TagNumber(1)
  set start($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
