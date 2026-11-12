// This is a generated file - do not edit.
//
// Generated from infrastructure/shortcuts/grpc/shortcuts.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Shortcut extends $pb.GeneratedMessage {
  factory Shortcut({
    $core.String? actionId,
    $core.String? keys,
  }) {
    final result = Shortcut._();
    if (actionId != null) result.actionId = actionId;
    if (keys != null) result.keys = keys;
    return result;
  }

  Shortcut._();

  factory Shortcut.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Shortcut()..mergeFromBuffer(data, registry);
  factory Shortcut.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Shortcut()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Shortcut',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.shortcuts'),
      createEmptyInstance: Shortcut.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'actionId')
    ..aOS(2, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shortcut clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shortcut copyWith(void Function(Shortcut) updates) =>
      super.copyWith((message) => updates(message as Shortcut)) as Shortcut;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Shortcut() / Shortcut.new instead')
  static Shortcut create() => Shortcut._();
  static $pb.GeneratedMessage $_createMessage() => Shortcut._();
  @$core.override
  Shortcut createEmptyInstance() => Shortcut._();
  @$core.pragma('dart2js:noInline')
  static Shortcut getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Shortcut>(Shortcut.$_createMessage);
  static Shortcut? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get actionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set actionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get keys => $_getSZ(1);
  @$pb.TagNumber(2)
  set keys($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeys() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeys() => $_clearField(2);
}

class ShortcutGetRequest extends $pb.GeneratedMessage {
  factory ShortcutGetRequest() => ShortcutGetRequest._();

  ShortcutGetRequest._();

  factory ShortcutGetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutGetRequest()..mergeFromBuffer(data, registry);
  factory ShortcutGetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutGetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShortcutGetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.shortcuts'),
      createEmptyInstance: ShortcutGetRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutGetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutGetRequest copyWith(void Function(ShortcutGetRequest) updates) =>
      super.copyWith((message) => updates(message as ShortcutGetRequest))
          as ShortcutGetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShortcutGetRequest() / ShortcutGetRequest.new instead')
  static ShortcutGetRequest create() => ShortcutGetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ShortcutGetRequest._();
  @$core.override
  ShortcutGetRequest createEmptyInstance() => ShortcutGetRequest._();
  @$core.pragma('dart2js:noInline')
  static ShortcutGetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ShortcutGetRequest>(
          ShortcutGetRequest.$_createMessage);
  static ShortcutGetRequest? _defaultInstance;
}

class ShortcutList extends $pb.GeneratedMessage {
  factory ShortcutList({
    $core.Iterable<Shortcut>? shortcuts,
  }) {
    final result = ShortcutList._();
    if (shortcuts != null) result.shortcuts.addAll(shortcuts);
    return result;
  }

  ShortcutList._();

  factory ShortcutList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutList()..mergeFromBuffer(data, registry);
  factory ShortcutList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShortcutList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.shortcuts'),
      createEmptyInstance: ShortcutList.$_createMessage)
    ..pPM<Shortcut>(1, _omitFieldNames ? '' : 'shortcuts',
        subBuilder: Shortcut.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutList copyWith(void Function(ShortcutList) updates) =>
      super.copyWith((message) => updates(message as ShortcutList))
          as ShortcutList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShortcutList() / ShortcutList.new instead')
  static ShortcutList create() => ShortcutList._();
  static $pb.GeneratedMessage $_createMessage() => ShortcutList._();
  @$core.override
  ShortcutList createEmptyInstance() => ShortcutList._();
  @$core.pragma('dart2js:noInline')
  static ShortcutList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShortcutList>(
          ShortcutList.$_createMessage);
  static ShortcutList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Shortcut> get shortcuts => $_getList(0);
}

class ShortcutSetRequest extends $pb.GeneratedMessage {
  factory ShortcutSetRequest({
    $core.String? actionId,
    $core.String? keys,
    $core.bool? reset,
  }) {
    final result = ShortcutSetRequest._();
    if (actionId != null) result.actionId = actionId;
    if (keys != null) result.keys = keys;
    if (reset != null) result.reset = reset;
    return result;
  }

  ShortcutSetRequest._();

  factory ShortcutSetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutSetRequest()..mergeFromBuffer(data, registry);
  factory ShortcutSetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShortcutSetRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShortcutSetRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.shortcuts'),
      createEmptyInstance: ShortcutSetRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'actionId')
    ..aOS(2, _omitFieldNames ? '' : 'keys')
    ..aOB(3, _omitFieldNames ? '' : 'reset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutSetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShortcutSetRequest copyWith(void Function(ShortcutSetRequest) updates) =>
      super.copyWith((message) => updates(message as ShortcutSetRequest))
          as ShortcutSetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShortcutSetRequest() / ShortcutSetRequest.new instead')
  static ShortcutSetRequest create() => ShortcutSetRequest._();
  static $pb.GeneratedMessage $_createMessage() => ShortcutSetRequest._();
  @$core.override
  ShortcutSetRequest createEmptyInstance() => ShortcutSetRequest._();
  @$core.pragma('dart2js:noInline')
  static ShortcutSetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ShortcutSetRequest>(
          ShortcutSetRequest.$_createMessage);
  static ShortcutSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get actionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set actionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get keys => $_getSZ(1);
  @$pb.TagNumber(2)
  set keys($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeys() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeys() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get reset => $_getBF(2);
  @$pb.TagNumber(3)
  set reset($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReset() => $_has(2);
  @$pb.TagNumber(3)
  void clearReset() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
