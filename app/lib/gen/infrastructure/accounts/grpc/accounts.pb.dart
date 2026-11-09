// This is a generated file - do not edit.
//
// Generated from infrastructure/accounts/grpc/accounts.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Account extends $pb.GeneratedMessage {
  factory Account({
    $core.String? id,
    $core.String? username,
    $core.String? email,
    $core.bool? emailVerified,
    $core.bool? isActive,
    $core.bool? isStaff,
    $core.String? dateJoined,
    $core.String? lastLogin,
    Profile? profile,
  }) {
    final result = Account._();
    if (id != null) result.id = id;
    if (username != null) result.username = username;
    if (email != null) result.email = email;
    if (emailVerified != null) result.emailVerified = emailVerified;
    if (isActive != null) result.isActive = isActive;
    if (isStaff != null) result.isStaff = isStaff;
    if (dateJoined != null) result.dateJoined = dateJoined;
    if (lastLogin != null) result.lastLogin = lastLogin;
    if (profile != null) result.profile = profile;
    return result;
  }

  Account._();

  factory Account.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Account()..mergeFromBuffer(data, registry);
  factory Account.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Account()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.accounts'),
      createEmptyInstance: Account.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOB(4, _omitFieldNames ? '' : 'emailVerified')
    ..aOB(5, _omitFieldNames ? '' : 'isActive')
    ..aOB(6, _omitFieldNames ? '' : 'isStaff')
    ..aOS(7, _omitFieldNames ? '' : 'dateJoined')
    ..aOS(8, _omitFieldNames ? '' : 'lastLogin')
    ..aOM<Profile>(9, _omitFieldNames ? '' : 'profile',
        subBuilder: Profile.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account copyWith(void Function(Account) updates) =>
      super.copyWith((message) => updates(message as Account)) as Account;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Account() / Account.new instead')
  static Account create() => Account._();
  static $pb.GeneratedMessage $_createMessage() => Account._();
  @$core.override
  Account createEmptyInstance() => Account._();
  @$core.pragma('dart2js:noInline')
  static Account getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account>(Account.$_createMessage);
  static Account? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get emailVerified => $_getBF(3);
  @$pb.TagNumber(4)
  set emailVerified($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmailVerified() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmailVerified() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isActive => $_getBF(4);
  @$pb.TagNumber(5)
  set isActive($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsActive() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsActive() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isStaff => $_getBF(5);
  @$pb.TagNumber(6)
  set isStaff($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsStaff() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsStaff() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get dateJoined => $_getSZ(6);
  @$pb.TagNumber(7)
  set dateJoined($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDateJoined() => $_has(6);
  @$pb.TagNumber(7)
  void clearDateJoined() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get lastLogin => $_getSZ(7);
  @$pb.TagNumber(8)
  set lastLogin($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLastLogin() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastLogin() => $_clearField(8);

  @$pb.TagNumber(9)
  Profile get profile => $_getN(8);
  @$pb.TagNumber(9)
  set profile(Profile value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasProfile() => $_has(8);
  @$pb.TagNumber(9)
  void clearProfile() => $_clearField(9);
  @$pb.TagNumber(9)
  Profile ensureProfile() => $_ensure(8);
}

class Profile extends $pb.GeneratedMessage {
  factory Profile({
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? bio,
    $core.String? locale,
    $core.String? timezone,
    $core.String? dateOfBirth,
    $core.bool? marketingOptIn,
  }) {
    final result = Profile._();
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (bio != null) result.bio = bio;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (marketingOptIn != null) result.marketingOptIn = marketingOptIn;
    return result;
  }

  Profile._();

  factory Profile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Profile()..mergeFromBuffer(data, registry);
  factory Profile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Profile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Profile',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.accounts'),
      createEmptyInstance: Profile.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'displayName')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'bio')
    ..aOS(4, _omitFieldNames ? '' : 'locale')
    ..aOS(5, _omitFieldNames ? '' : 'timezone')
    ..aOS(6, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOB(7, _omitFieldNames ? '' : 'marketingOptIn')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Profile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Profile copyWith(void Function(Profile) updates) =>
      super.copyWith((message) => updates(message as Profile)) as Profile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Profile() / Profile.new instead')
  static Profile create() => Profile._();
  static $pb.GeneratedMessage $_createMessage() => Profile._();
  @$core.override
  Profile createEmptyInstance() => Profile._();
  @$core.pragma('dart2js:noInline')
  static Profile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Profile>(Profile.$_createMessage);
  static Profile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get displayName => $_getSZ(0);
  @$pb.TagNumber(1)
  set displayName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDisplayName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisplayName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bio => $_getSZ(2);
  @$pb.TagNumber(3)
  set bio($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBio() => $_has(2);
  @$pb.TagNumber(3)
  void clearBio() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get locale => $_getSZ(3);
  @$pb.TagNumber(4)
  set locale($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocale() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocale() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get timezone => $_getSZ(4);
  @$pb.TagNumber(5)
  set timezone($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimezone() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimezone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get dateOfBirth => $_getSZ(5);
  @$pb.TagNumber(6)
  set dateOfBirth($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDateOfBirth() => $_has(5);
  @$pb.TagNumber(6)
  void clearDateOfBirth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get marketingOptIn => $_getBF(6);
  @$pb.TagNumber(7)
  set marketingOptIn($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMarketingOptIn() => $_has(6);
  @$pb.TagNumber(7)
  void clearMarketingOptIn() => $_clearField(7);
}

class ProfileUpdate extends $pb.GeneratedMessage {
  factory ProfileUpdate({
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? bio,
    $core.String? locale,
    $core.String? timezone,
    $core.String? dateOfBirth,
    $core.bool? marketingOptIn,
  }) {
    final result = ProfileUpdate._();
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (bio != null) result.bio = bio;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    if (dateOfBirth != null) result.dateOfBirth = dateOfBirth;
    if (marketingOptIn != null) result.marketingOptIn = marketingOptIn;
    return result;
  }

  ProfileUpdate._();

  factory ProfileUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProfileUpdate()..mergeFromBuffer(data, registry);
  factory ProfileUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProfileUpdate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProfileUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'config.accounts'),
      createEmptyInstance: ProfileUpdate.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'displayName')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'bio')
    ..aOS(4, _omitFieldNames ? '' : 'locale')
    ..aOS(5, _omitFieldNames ? '' : 'timezone')
    ..aOS(6, _omitFieldNames ? '' : 'dateOfBirth')
    ..aOB(7, _omitFieldNames ? '' : 'marketingOptIn')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProfileUpdate copyWith(void Function(ProfileUpdate) updates) =>
      super.copyWith((message) => updates(message as ProfileUpdate))
          as ProfileUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProfileUpdate() / ProfileUpdate.new instead')
  static ProfileUpdate create() => ProfileUpdate._();
  static $pb.GeneratedMessage $_createMessage() => ProfileUpdate._();
  @$core.override
  ProfileUpdate createEmptyInstance() => ProfileUpdate._();
  @$core.pragma('dart2js:noInline')
  static ProfileUpdate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileUpdate>(
          ProfileUpdate.$_createMessage);
  static ProfileUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get displayName => $_getSZ(0);
  @$pb.TagNumber(1)
  set displayName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDisplayName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisplayName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bio => $_getSZ(2);
  @$pb.TagNumber(3)
  set bio($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBio() => $_has(2);
  @$pb.TagNumber(3)
  void clearBio() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get locale => $_getSZ(3);
  @$pb.TagNumber(4)
  set locale($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocale() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocale() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get timezone => $_getSZ(4);
  @$pb.TagNumber(5)
  set timezone($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimezone() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimezone() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get dateOfBirth => $_getSZ(5);
  @$pb.TagNumber(6)
  set dateOfBirth($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDateOfBirth() => $_has(5);
  @$pb.TagNumber(6)
  void clearDateOfBirth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get marketingOptIn => $_getBF(6);
  @$pb.TagNumber(7)
  set marketingOptIn($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMarketingOptIn() => $_has(6);
  @$pb.TagNumber(7)
  void clearMarketingOptIn() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
