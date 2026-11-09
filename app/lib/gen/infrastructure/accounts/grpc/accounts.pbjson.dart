// This is a generated file - do not edit.
//
// Generated from infrastructure/accounts/grpc/accounts.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'email_verified', '3': 4, '4': 1, '5': 8, '10': 'emailVerified'},
    {'1': 'is_active', '3': 5, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'is_staff', '3': 6, '4': 1, '5': 8, '10': 'isStaff'},
    {'1': 'date_joined', '3': 7, '4': 1, '5': 9, '10': 'dateJoined'},
    {'1': 'last_login', '3': 8, '4': 1, '5': 9, '10': 'lastLogin'},
    {
      '1': 'profile',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.config.accounts.Profile',
      '10': 'profile'
    },
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50Eg4KAmlkGAEgASgJUgJpZBIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSFA'
    'oFZW1haWwYAyABKAlSBWVtYWlsEiUKDmVtYWlsX3ZlcmlmaWVkGAQgASgIUg1lbWFpbFZlcmlm'
    'aWVkEhsKCWlzX2FjdGl2ZRgFIAEoCFIIaXNBY3RpdmUSGQoIaXNfc3RhZmYYBiABKAhSB2lzU3'
    'RhZmYSHwoLZGF0ZV9qb2luZWQYByABKAlSCmRhdGVKb2luZWQSHQoKbGFzdF9sb2dpbhgIIAEo'
    'CVIJbGFzdExvZ2luEjIKB3Byb2ZpbGUYCSABKAsyGC5jb25maWcuYWNjb3VudHMuUHJvZmlsZV'
    'IHcHJvZmlsZQ==');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'display_name', '3': 1, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 2, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'bio', '3': 3, '4': 1, '5': 9, '10': 'bio'},
    {'1': 'locale', '3': 4, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'timezone', '3': 5, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'date_of_birth', '3': 6, '4': 1, '5': 9, '10': 'dateOfBirth'},
    {'1': 'marketing_opt_in', '3': 7, '4': 1, '5': 8, '10': 'marketingOptIn'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEiEKDGRpc3BsYXlfbmFtZRgBIAEoCVILZGlzcGxheU5hbWUSHQoKYXZhdGFyX3'
    'VybBgCIAEoCVIJYXZhdGFyVXJsEhAKA2JpbxgDIAEoCVIDYmlvEhYKBmxvY2FsZRgEIAEoCVIG'
    'bG9jYWxlEhoKCHRpbWV6b25lGAUgASgJUgh0aW1lem9uZRIiCg1kYXRlX29mX2JpcnRoGAYgAS'
    'gJUgtkYXRlT2ZCaXJ0aBIoChBtYXJrZXRpbmdfb3B0X2luGAcgASgIUg5tYXJrZXRpbmdPcHRJ'
    'bg==');

@$core.Deprecated('Use profileUpdateDescriptor instead')
const ProfileUpdate$json = {
  '1': 'ProfileUpdate',
  '2': [
    {
      '1': 'display_name',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'avatar_url',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'avatarUrl',
      '17': true
    },
    {'1': 'bio', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'bio', '17': true},
    {'1': 'locale', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'locale', '17': true},
    {
      '1': 'timezone',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'timezone',
      '17': true
    },
    {
      '1': 'date_of_birth',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'dateOfBirth',
      '17': true
    },
    {
      '1': 'marketing_opt_in',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'marketingOptIn',
      '17': true
    },
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_avatar_url'},
    {'1': '_bio'},
    {'1': '_locale'},
    {'1': '_timezone'},
    {'1': '_date_of_birth'},
    {'1': '_marketing_opt_in'},
  ],
};

/// Descriptor for `ProfileUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileUpdateDescriptor = $convert.base64Decode(
    'Cg1Qcm9maWxlVXBkYXRlEiYKDGRpc3BsYXlfbmFtZRgBIAEoCUgAUgtkaXNwbGF5TmFtZYgBAR'
    'IiCgphdmF0YXJfdXJsGAIgASgJSAFSCWF2YXRhclVybIgBARIVCgNiaW8YAyABKAlIAlIDYmlv'
    'iAEBEhsKBmxvY2FsZRgEIAEoCUgDUgZsb2NhbGWIAQESHwoIdGltZXpvbmUYBSABKAlIBFIIdG'
    'ltZXpvbmWIAQESJwoNZGF0ZV9vZl9iaXJ0aBgGIAEoCUgFUgtkYXRlT2ZCaXJ0aIgBARItChBt'
    'YXJrZXRpbmdfb3B0X2luGAcgASgISAZSDm1hcmtldGluZ09wdEluiAEBQg8KDV9kaXNwbGF5X2'
    '5hbWVCDQoLX2F2YXRhcl91cmxCBgoEX2Jpb0IJCgdfbG9jYWxlQgsKCV90aW1lem9uZUIQCg5f'
    'ZGF0ZV9vZl9iaXJ0aEITChFfbWFya2V0aW5nX29wdF9pbg==');
