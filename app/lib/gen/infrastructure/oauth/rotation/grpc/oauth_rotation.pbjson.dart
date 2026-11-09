// This is a generated file - do not edit.
//
// Generated from infrastructure/oauth/rotation/grpc/oauth_rotation.proto.

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

@$core.Deprecated('Use credentialsDescriptor instead')
const Credentials$json = {
  '1': 'Credentials',
  '2': [
    {'1': 'token_type', '3': 1, '4': 1, '5': 9, '10': 'tokenType'},
    {'1': 'access_token', '3': 2, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 3, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'expires_in', '3': 4, '4': 1, '5': 5, '10': 'expiresIn'},
    {'1': 'session_id', '3': 5, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `Credentials`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List credentialsDescriptor = $convert.base64Decode(
    'CgtDcmVkZW50aWFscxIdCgp0b2tlbl90eXBlGAEgASgJUgl0b2tlblR5cGUSIQoMYWNjZXNzX3'
    'Rva2VuGAIgASgJUgthY2Nlc3NUb2tlbhIjCg1yZWZyZXNoX3Rva2VuGAMgASgJUgxyZWZyZXNo'
    'VG9rZW4SHQoKZXhwaXJlc19pbhgEIAEoBVIJZXhwaXJlc0luEh0KCnNlc3Npb25faWQYBSABKA'
    'lSCXNlc3Npb25JZA==');

@$core.Deprecated('Use endSessionRequestDescriptor instead')
const EndSessionRequest$json = {
  '1': 'EndSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `EndSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endSessionRequestDescriptor = $convert.base64Decode(
    'ChFFbmRTZXNzaW9uUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQ=');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'detail', '3': 1, '4': 1, '5': 9, '10': 'detail'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor =
    $convert.base64Decode('CgdNZXNzYWdlEhYKBmRldGFpbBgBIAEoCVIGZGV0YWls');

@$core.Deprecated('Use refreshRequestDescriptor instead')
const RefreshRequest$json = {
  '1': 'RefreshRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshRequestDescriptor = $convert.base64Decode(
    'Cg5SZWZyZXNoUmVxdWVzdBIjCg1yZWZyZXNoX3Rva2VuGAEgASgJUgxyZWZyZXNoVG9rZW4=');

@$core.Deprecated('Use revokeRequestDescriptor instead')
const RevokeRequest$json = {
  '1': 'RevokeRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `RevokeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeRequestDescriptor = $convert
    .base64Decode('Cg1SZXZva2VSZXF1ZXN0EhQKBXRva2VuGAEgASgJUgV0b2tlbg==');

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'created_at', '3': 2, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'last_used_at', '3': 3, '4': 1, '5': 9, '10': 'lastUsedAt'},
    {'1': 'expires_at', '3': 4, '4': 1, '5': 9, '10': 'expiresAt'},
    {'1': 'ip_address', '3': 5, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'user_agent', '3': 6, '4': 1, '5': 9, '10': 'userAgent'},
    {'1': 'auth_method', '3': 7, '4': 1, '5': 9, '10': 'authMethod'},
    {'1': 'current', '3': 8, '4': 1, '5': 8, '10': 'current'},
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIdCgpjcmVhdGVkX2F0GA'
    'IgASgJUgljcmVhdGVkQXQSIAoMbGFzdF91c2VkX2F0GAMgASgJUgpsYXN0VXNlZEF0Eh0KCmV4'
    'cGlyZXNfYXQYBCABKAlSCWV4cGlyZXNBdBIdCgppcF9hZGRyZXNzGAUgASgJUglpcEFkZHJlc3'
    'MSHQoKdXNlcl9hZ2VudBgGIAEoCVIJdXNlckFnZW50Eh8KC2F1dGhfbWV0aG9kGAcgASgJUgph'
    'dXRoTWV0aG9kEhgKB2N1cnJlbnQYCCABKAhSB2N1cnJlbnQ=');

@$core.Deprecated('Use sessionListDescriptor instead')
const SessionList$json = {
  '1': 'SessionList',
  '2': [
    {'1': 'mode', '3': 1, '4': 1, '5': 9, '10': 'mode'},
    {
      '1': 'sessions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.config.oauth_rotation.Session',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `SessionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionListDescriptor = $convert.base64Decode(
    'CgtTZXNzaW9uTGlzdBISCgRtb2RlGAEgASgJUgRtb2RlEjoKCHNlc3Npb25zGAIgAygLMh4uY2'
    '9uZmlnLm9hdXRoX3JvdGF0aW9uLlNlc3Npb25SCHNlc3Npb25z');
