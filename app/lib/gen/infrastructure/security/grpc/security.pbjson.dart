// This is a generated file - do not edit.
//
// Generated from infrastructure/security/grpc/security.proto.

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

@$core.Deprecated('Use policyAnswerDescriptor instead')
const PolicyAnswer$json = {
  '1': 'PolicyAnswer',
  '2': [
    {'1': 'require_2fa', '3': 1, '4': 1, '5': 8, '10': 'require2fa'},
    {'1': 'grace_days', '3': 2, '4': 1, '5': 5, '10': 'graceDays'},
    {'1': 'enforced_from', '3': 3, '4': 1, '5': 9, '10': 'enforcedFrom'},
    {'1': 'in_grace', '3': 4, '4': 1, '5': 8, '10': 'inGrace'},
    {'1': 'enrolled', '3': 5, '4': 1, '5': 8, '10': 'enrolled'},
    {'1': 'blocked', '3': 6, '4': 1, '5': 8, '10': 'blocked'},
    {'1': 'version', '3': 7, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `PolicyAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyAnswerDescriptor = $convert.base64Decode(
    'CgxQb2xpY3lBbnN3ZXISHwoLcmVxdWlyZV8yZmEYASABKAhSCnJlcXVpcmUyZmESHQoKZ3JhY2'
    'VfZGF5cxgCIAEoBVIJZ3JhY2VEYXlzEiMKDWVuZm9yY2VkX2Zyb20YAyABKAlSDGVuZm9yY2Vk'
    'RnJvbRIZCghpbl9ncmFjZRgEIAEoCFIHaW5HcmFjZRIaCghlbnJvbGxlZBgFIAEoCFIIZW5yb2'
    'xsZWQSGAoHYmxvY2tlZBgGIAEoCFIHYmxvY2tlZBIYCgd2ZXJzaW9uGAcgASgFUgd2ZXJzaW9u');

@$core.Deprecated('Use policyGetRequestDescriptor instead')
const PolicyGetRequest$json = {
  '1': 'PolicyGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `PolicyGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policyGetRequestDescriptor = $convert.base64Decode(
    'ChBQb2xpY3lHZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQ=');

@$core.Deprecated('Use policySetRequestDescriptor instead')
const PolicySetRequest$json = {
  '1': 'PolicySetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'require_2fa', '3': 2, '4': 1, '5': 8, '10': 'require2fa'},
    {'1': 'grace_days', '3': 3, '4': 1, '5': 5, '10': 'graceDays'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `PolicySetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List policySetRequestDescriptor = $convert.base64Decode(
    'ChBQb2xpY3lTZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQSHw'
    'oLcmVxdWlyZV8yZmEYAiABKAhSCnJlcXVpcmUyZmESHQoKZ3JhY2VfZGF5cxgDIAEoBVIJZ3Jh'
    'Y2VEYXlzEikKEGV4cGVjdGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbg==');

@$core.Deprecated('Use providerDescriptor instead')
const Provider$json = {
  '1': 'Provider',
  '2': [
    {'1': 'configured', '3': 1, '4': 1, '5': 8, '10': 'configured'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'issuer', '3': 3, '4': 1, '5': 9, '10': 'issuer'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'has_secret', '3': 5, '4': 1, '5': 8, '10': 'hasSecret'},
    {'1': 'scopes', '3': 6, '4': 1, '5': 9, '10': 'scopes'},
    {'1': 'allowed_domains', '3': 7, '4': 3, '5': 9, '10': 'allowedDomains'},
    {'1': 'group_claim', '3': 8, '4': 1, '5': 9, '10': 'groupClaim'},
    {
      '1': 'group_roles',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.config.security.RoleMapping',
      '10': 'groupRoles'
    },
    {'1': 'default_role_id', '3': 10, '4': 1, '5': 9, '10': 'defaultRoleId'},
    {
      '1': 'auto_create_users',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'autoCreateUsers'
    },
    {'1': 'enabled', '3': 12, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'enforce_sso', '3': 13, '4': 1, '5': 8, '10': 'enforceSso'},
    {'1': 'version', '3': 14, '4': 1, '5': 5, '10': 'version'},
    {'1': 'redirect_uri', '3': 15, '4': 1, '5': 9, '10': 'redirectUri'},
  ],
};

/// Descriptor for `Provider`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerDescriptor = $convert.base64Decode(
    'CghQcm92aWRlchIeCgpjb25maWd1cmVkGAEgASgIUgpjb25maWd1cmVkEhIKBG5hbWUYAiABKA'
    'lSBG5hbWUSFgoGaXNzdWVyGAMgASgJUgZpc3N1ZXISGwoJY2xpZW50X2lkGAQgASgJUghjbGll'
    'bnRJZBIdCgpoYXNfc2VjcmV0GAUgASgIUgloYXNTZWNyZXQSFgoGc2NvcGVzGAYgASgJUgZzY2'
    '9wZXMSJwoPYWxsb3dlZF9kb21haW5zGAcgAygJUg5hbGxvd2VkRG9tYWlucxIfCgtncm91cF9j'
    'bGFpbRgIIAEoCVIKZ3JvdXBDbGFpbRI9Cgtncm91cF9yb2xlcxgJIAMoCzIcLmNvbmZpZy5zZW'
    'N1cml0eS5Sb2xlTWFwcGluZ1IKZ3JvdXBSb2xlcxImCg9kZWZhdWx0X3JvbGVfaWQYCiABKAlS'
    'DWRlZmF1bHRSb2xlSWQSKgoRYXV0b19jcmVhdGVfdXNlcnMYCyABKAhSD2F1dG9DcmVhdGVVc2'
    'VycxIYCgdlbmFibGVkGAwgASgIUgdlbmFibGVkEh8KC2VuZm9yY2Vfc3NvGA0gASgIUgplbmZv'
    'cmNlU3NvEhgKB3ZlcnNpb24YDiABKAVSB3ZlcnNpb24SIQoMcmVkaXJlY3RfdXJpGA8gASgJUg'
    'tyZWRpcmVjdFVyaQ==');

@$core.Deprecated('Use providerAnswerDescriptor instead')
const ProviderAnswer$json = {
  '1': 'ProviderAnswer',
  '2': [
    {
      '1': 'provider',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.security.Provider',
      '10': 'provider'
    },
  ],
};

/// Descriptor for `ProviderAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerAnswerDescriptor = $convert.base64Decode(
    'Cg5Qcm92aWRlckFuc3dlchI1Cghwcm92aWRlchgBIAEoCzIZLmNvbmZpZy5zZWN1cml0eS5Qcm'
    '92aWRlclIIcHJvdmlkZXI=');

@$core.Deprecated('Use revokeDeviceAnswerDescriptor instead')
const RevokeDeviceAnswer$json = {
  '1': 'RevokeDeviceAnswer',
  '2': [
    {'1': 'revoked', '3': 1, '4': 1, '5': 5, '10': 'revoked'},
  ],
};

/// Descriptor for `RevokeDeviceAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeDeviceAnswerDescriptor =
    $convert.base64Decode(
        'ChJSZXZva2VEZXZpY2VBbnN3ZXISGAoHcmV2b2tlZBgBIAEoBVIHcmV2b2tlZA==');

@$core.Deprecated('Use revokeDeviceRequestDescriptor instead')
const RevokeDeviceRequest$json = {
  '1': 'RevokeDeviceRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `RevokeDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeDeviceRequestDescriptor =
    $convert.base64Decode(
        'ChNSZXZva2VEZXZpY2VSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use roleMappingDescriptor instead')
const RoleMapping$json = {
  '1': 'RoleMapping',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 9, '10': 'group'},
    {'1': 'role_id', '3': 2, '4': 1, '5': 9, '10': 'roleId'},
  ],
};

/// Descriptor for `RoleMapping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List roleMappingDescriptor = $convert.base64Decode(
    'CgtSb2xlTWFwcGluZxIUCgVncm91cBgBIAEoCVIFZ3JvdXASFwoHcm9sZV9pZBgCIAEoCVIGcm'
    '9sZUlk');

@$core.Deprecated('Use secondFactorBeginRequestDescriptor instead')
const SecondFactorBeginRequest$json = {
  '1': 'SecondFactorBeginRequest',
};

/// Descriptor for `SecondFactorBeginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorBeginRequestDescriptor =
    $convert.base64Decode('ChhTZWNvbmRGYWN0b3JCZWdpblJlcXVlc3Q=');

@$core.Deprecated('Use secondFactorConfirmRequestDescriptor instead')
const SecondFactorConfirmRequest$json = {
  '1': 'SecondFactorConfirmRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `SecondFactorConfirmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorConfirmRequestDescriptor =
    $convert.base64Decode(
        'ChpTZWNvbmRGYWN0b3JDb25maXJtUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use secondFactorConfirmedDescriptor instead')
const SecondFactorConfirmed$json = {
  '1': 'SecondFactorConfirmed',
  '2': [
    {'1': 'recovery_codes', '3': 1, '4': 3, '5': 9, '10': 'recoveryCodes'},
  ],
};

/// Descriptor for `SecondFactorConfirmed`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorConfirmedDescriptor = $convert.base64Decode(
    'ChVTZWNvbmRGYWN0b3JDb25maXJtZWQSJQoOcmVjb3ZlcnlfY29kZXMYASADKAlSDXJlY292ZX'
    'J5Q29kZXM=');

@$core.Deprecated('Use secondFactorDisableRequestDescriptor instead')
const SecondFactorDisableRequest$json = {
  '1': 'SecondFactorDisableRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `SecondFactorDisableRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorDisableRequestDescriptor =
    $convert.base64Decode(
        'ChpTZWNvbmRGYWN0b3JEaXNhYmxlUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use secondFactorDisabledDescriptor instead')
const SecondFactorDisabled$json = {
  '1': 'SecondFactorDisabled',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `SecondFactorDisabled`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorDisabledDescriptor =
    $convert.base64Decode(
        'ChRTZWNvbmRGYWN0b3JEaXNhYmxlZBIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVk');

@$core.Deprecated('Use secondFactorEnrolmentDescriptor instead')
const SecondFactorEnrolment$json = {
  '1': 'SecondFactorEnrolment',
  '2': [
    {'1': 'secret', '3': 1, '4': 1, '5': 9, '10': 'secret'},
    {'1': 'otpauth_uri', '3': 2, '4': 1, '5': 9, '10': 'otpauthUri'},
  ],
};

/// Descriptor for `SecondFactorEnrolment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorEnrolmentDescriptor = $convert.base64Decode(
    'ChVTZWNvbmRGYWN0b3JFbnJvbG1lbnQSFgoGc2VjcmV0GAEgASgJUgZzZWNyZXQSHwoLb3RwYX'
    'V0aF91cmkYAiABKAlSCm90cGF1dGhVcmk=');

@$core.Deprecated('Use secondFactorRegenerateRequestDescriptor instead')
const SecondFactorRegenerateRequest$json = {
  '1': 'SecondFactorRegenerateRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `SecondFactorRegenerateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorRegenerateRequestDescriptor =
    $convert.base64Decode(
        'Ch1TZWNvbmRGYWN0b3JSZWdlbmVyYXRlUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use secondFactorRegeneratedDescriptor instead')
const SecondFactorRegenerated$json = {
  '1': 'SecondFactorRegenerated',
  '2': [
    {'1': 'recovery_codes', '3': 1, '4': 3, '5': 9, '10': 'recoveryCodes'},
  ],
};

/// Descriptor for `SecondFactorRegenerated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorRegeneratedDescriptor =
    $convert.base64Decode(
        'ChdTZWNvbmRGYWN0b3JSZWdlbmVyYXRlZBIlCg5yZWNvdmVyeV9jb2RlcxgBIAMoCVINcmVjb3'
        'ZlcnlDb2Rlcw==');

@$core.Deprecated('Use secondFactorStatusDescriptor instead')
const SecondFactorStatus$json = {
  '1': 'SecondFactorStatus',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'unused_recovery_codes',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'unusedRecoveryCodes'
    },
    {
      '1': 'trusted_devices',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.security.TrustedDevice',
      '10': 'trustedDevices'
    },
  ],
};

/// Descriptor for `SecondFactorStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorStatusDescriptor = $convert.base64Decode(
    'ChJTZWNvbmRGYWN0b3JTdGF0dXMSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZBIyChV1bnVzZW'
    'RfcmVjb3ZlcnlfY29kZXMYAiABKAVSE3VudXNlZFJlY292ZXJ5Q29kZXMSRwoPdHJ1c3RlZF9k'
    'ZXZpY2VzGAMgAygLMh4uY29uZmlnLnNlY3VyaXR5LlRydXN0ZWREZXZpY2VSDnRydXN0ZWREZX'
    'ZpY2Vz');

@$core.Deprecated('Use secondFactorStatusRequestDescriptor instead')
const SecondFactorStatusRequest$json = {
  '1': 'SecondFactorStatusRequest',
};

/// Descriptor for `SecondFactorStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secondFactorStatusRequestDescriptor =
    $convert.base64Decode('ChlTZWNvbmRGYWN0b3JTdGF0dXNSZXF1ZXN0');

@$core.Deprecated('Use ssoDeleteRequestDescriptor instead')
const SsoDeleteRequest$json = {
  '1': 'SsoDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `SsoDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoDeleteRequestDescriptor = $convert.base64Decode(
    'ChBTc29EZWxldGVSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQ=');

@$core.Deprecated('Use ssoDeletedDescriptor instead')
const SsoDeleted$json = {
  '1': 'SsoDeleted',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `SsoDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoDeletedDescriptor = $convert
    .base64Decode('CgpTc29EZWxldGVkEhgKB2RlbGV0ZWQYASABKAhSB2RlbGV0ZWQ=');

@$core.Deprecated('Use ssoGetRequestDescriptor instead')
const SsoGetRequest$json = {
  '1': 'SsoGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `SsoGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoGetRequestDescriptor = $convert.base64Decode(
    'Cg1Tc29HZXRSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSWQ=');

@$core.Deprecated('Use ssoSaveRequestDescriptor instead')
const SsoSaveRequest$json = {
  '1': 'SsoSaveRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'issuer', '3': 3, '4': 1, '5': 9, '10': 'issuer'},
    {'1': 'client_id', '3': 4, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'client_secret', '3': 5, '4': 1, '5': 9, '10': 'clientSecret'},
    {'1': 'scopes', '3': 6, '4': 1, '5': 9, '10': 'scopes'},
    {'1': 'allowed_domains', '3': 7, '4': 3, '5': 9, '10': 'allowedDomains'},
    {'1': 'group_claim', '3': 8, '4': 1, '5': 9, '10': 'groupClaim'},
    {
      '1': 'group_roles',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.config.security.RoleMapping',
      '10': 'groupRoles'
    },
    {'1': 'default_role_id', '3': 10, '4': 1, '5': 9, '10': 'defaultRoleId'},
    {
      '1': 'auto_create_users',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'autoCreateUsers'
    },
    {'1': 'enabled', '3': 12, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'enforce_sso', '3': 13, '4': 1, '5': 8, '10': 'enforceSso'},
    {'1': 'expected_version', '3': 14, '4': 1, '5': 5, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `SsoSaveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoSaveRequestDescriptor = $convert.base64Decode(
    'Cg5Tc29TYXZlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEhIKBG'
    '5hbWUYAiABKAlSBG5hbWUSFgoGaXNzdWVyGAMgASgJUgZpc3N1ZXISGwoJY2xpZW50X2lkGAQg'
    'ASgJUghjbGllbnRJZBIjCg1jbGllbnRfc2VjcmV0GAUgASgJUgxjbGllbnRTZWNyZXQSFgoGc2'
    'NvcGVzGAYgASgJUgZzY29wZXMSJwoPYWxsb3dlZF9kb21haW5zGAcgAygJUg5hbGxvd2VkRG9t'
    'YWlucxIfCgtncm91cF9jbGFpbRgIIAEoCVIKZ3JvdXBDbGFpbRI9Cgtncm91cF9yb2xlcxgJIA'
    'MoCzIcLmNvbmZpZy5zZWN1cml0eS5Sb2xlTWFwcGluZ1IKZ3JvdXBSb2xlcxImCg9kZWZhdWx0'
    'X3JvbGVfaWQYCiABKAlSDWRlZmF1bHRSb2xlSWQSKgoRYXV0b19jcmVhdGVfdXNlcnMYCyABKA'
    'hSD2F1dG9DcmVhdGVVc2VycxIYCgdlbmFibGVkGAwgASgIUgdlbmFibGVkEh8KC2VuZm9yY2Vf'
    'c3NvGA0gASgIUgplbmZvcmNlU3NvEikKEGV4cGVjdGVkX3ZlcnNpb24YDiABKAVSD2V4cGVjdG'
    'VkVmVyc2lvbg==');

@$core.Deprecated('Use ssoTestAnswerDescriptor instead')
const SsoTestAnswer$json = {
  '1': 'SsoTestAnswer',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'redirect_uri', '3': 3, '4': 1, '5': 9, '10': 'redirectUri'},
    {
      '1': 'authorization_endpoint',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'authorizationEndpoint'
    },
    {'1': 'token_endpoint', '3': 5, '4': 1, '5': 9, '10': 'tokenEndpoint'},
    {'1': 'jwks_uri', '3': 6, '4': 1, '5': 9, '10': 'jwksUri'},
    {'1': 'keys', '3': 7, '4': 1, '5': 5, '10': 'keys'},
  ],
};

/// Descriptor for `SsoTestAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoTestAnswerDescriptor = $convert.base64Decode(
    'Cg1Tc29UZXN0QW5zd2VyEg4KAm9rGAEgASgIUgJvaxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYW'
    'dlEiEKDHJlZGlyZWN0X3VyaRgDIAEoCVILcmVkaXJlY3RVcmkSNQoWYXV0aG9yaXphdGlvbl9l'
    'bmRwb2ludBgEIAEoCVIVYXV0aG9yaXphdGlvbkVuZHBvaW50EiUKDnRva2VuX2VuZHBvaW50GA'
    'UgASgJUg10b2tlbkVuZHBvaW50EhkKCGp3a3NfdXJpGAYgASgJUgdqd2tzVXJpEhIKBGtleXMY'
    'ByABKAVSBGtleXM=');

@$core.Deprecated('Use ssoTestRequestDescriptor instead')
const SsoTestRequest$json = {
  '1': 'SsoTestRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
  ],
};

/// Descriptor for `SsoTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ssoTestRequestDescriptor = $convert.base64Decode(
    'Cg5Tc29UZXN0UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlk');

@$core.Deprecated('Use trustedDeviceDescriptor instead')
const TrustedDevice$json = {
  '1': 'TrustedDevice',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'created_at', '3': 3, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'last_used_at', '3': 4, '4': 1, '5': 9, '10': 'lastUsedAt'},
    {'1': 'expires_at', '3': 5, '4': 1, '5': 9, '10': 'expiresAt'},
  ],
};

/// Descriptor for `TrustedDevice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trustedDeviceDescriptor = $convert.base64Decode(
    'Cg1UcnVzdGVkRGV2aWNlEg4KAmlkGAEgASgJUgJpZBIUCgVsYWJlbBgCIAEoCVIFbGFiZWwSHQ'
    'oKY3JlYXRlZF9hdBgDIAEoCVIJY3JlYXRlZEF0EiAKDGxhc3RfdXNlZF9hdBgEIAEoCVIKbGFz'
    'dFVzZWRBdBIdCgpleHBpcmVzX2F0GAUgASgJUglleHBpcmVzQXQ=');
