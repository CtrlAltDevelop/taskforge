// This is a generated file - do not edit.
//
// Generated from infrastructure/forms/grpc/forms.proto.

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

@$core.Deprecated('Use fieldDefaultDescriptor instead')
const FieldDefault$json = {
  '1': 'FieldDefault',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `FieldDefault`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldDefaultDescriptor = $convert.base64Decode(
    'CgxGaWVsZERlZmF1bHQSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFAoFdmFsdWUYAiABKA'
    'lSBXZhbHVl');

@$core.Deprecated('Use formAnswerDescriptor instead')
const FormAnswer$json = {
  '1': 'FormAnswer',
  '2': [
    {
      '1': 'form',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.forms.IntakeForm',
      '10': 'form'
    },
  ],
};

/// Descriptor for `FormAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formAnswerDescriptor = $convert.base64Decode(
    'CgpGb3JtQW5zd2VyEiwKBGZvcm0YASABKAsyGC5jb25maWcuZm9ybXMuSW50YWtlRm9ybVIEZm'
    '9ybQ==');

@$core.Deprecated('Use formCreateRequestDescriptor instead')
const FormCreateRequest$json = {
  '1': 'FormCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'form_fields',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.config.forms.IntakeField',
      '10': 'formFields'
    },
    {'1': 'status_id', '3': 6, '4': 1, '5': 9, '10': 'statusId'},
    {'1': 'priority', '3': 7, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'assignee_ids', '3': 8, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'enabled', '3': 9, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'require_email', '3': 10, '4': 1, '5': 8, '10': 'requireEmail'},
    {
      '1': 'send_confirmation',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'sendConfirmation'
    },
    {'1': 'notify_status', '3': 12, '4': 1, '5': 8, '10': 'notifyStatus'},
    {'1': 'brand_color', '3': 13, '4': 1, '5': 9, '10': 'brandColor'},
    {'1': 'logo_url', '3': 14, '4': 1, '5': 9, '10': 'logoUrl'},
    {
      '1': 'field_defaults',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.config.forms.FieldDefault',
      '10': 'fieldDefaults'
    },
  ],
};

/// Descriptor for `FormCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formCreateRequestDescriptor = $convert.base64Decode(
    'ChFGb3JtQ3JlYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBISCgRuYW1lGAMgASgJUgRuYW1lEiAKC2Rl'
    'c2NyaXB0aW9uGAQgASgJUgtkZXNjcmlwdGlvbhI6Cgtmb3JtX2ZpZWxkcxgFIAMoCzIZLmNvbm'
    'ZpZy5mb3Jtcy5JbnRha2VGaWVsZFIKZm9ybUZpZWxkcxIbCglzdGF0dXNfaWQYBiABKAlSCHN0'
    'YXR1c0lkEhoKCHByaW9yaXR5GAcgASgJUghwcmlvcml0eRIhCgxhc3NpZ25lZV9pZHMYCCADKA'
    'lSC2Fzc2lnbmVlSWRzEhgKB2VuYWJsZWQYCSABKAhSB2VuYWJsZWQSIwoNcmVxdWlyZV9lbWFp'
    'bBgKIAEoCFIMcmVxdWlyZUVtYWlsEisKEXNlbmRfY29uZmlybWF0aW9uGAsgASgIUhBzZW5kQ2'
    '9uZmlybWF0aW9uEiMKDW5vdGlmeV9zdGF0dXMYDCABKAhSDG5vdGlmeVN0YXR1cxIfCgticmFu'
    'ZF9jb2xvchgNIAEoCVIKYnJhbmRDb2xvchIZCghsb2dvX3VybBgOIAEoCVIHbG9nb1VybBJBCg'
    '5maWVsZF9kZWZhdWx0cxgPIAMoCzIaLmNvbmZpZy5mb3Jtcy5GaWVsZERlZmF1bHRSDWZpZWxk'
    'RGVmYXVsdHM=');

@$core.Deprecated('Use formDeleteRequestDescriptor instead')
const FormDeleteRequest$json = {
  '1': 'FormDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'form_id', '3': 2, '4': 1, '5': 9, '10': 'formId'},
  ],
};

/// Descriptor for `FormDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formDeleteRequestDescriptor = $convert.base64Decode(
    'ChFGb3JtRGVsZXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB2Zvcm1faWQYAiABKAlSBmZvcm1JZA==');

@$core.Deprecated('Use formDeletedDescriptor instead')
const FormDeleted$json = {
  '1': 'FormDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `FormDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formDeletedDescriptor =
    $convert.base64Decode('CgtGb3JtRGVsZXRlZBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use formListDescriptor instead')
const FormList$json = {
  '1': 'FormList',
  '2': [
    {
      '1': 'forms',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.forms.IntakeForm',
      '10': 'forms'
    },
  ],
};

/// Descriptor for `FormList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formListDescriptor = $convert.base64Decode(
    'CghGb3JtTGlzdBIuCgVmb3JtcxgBIAMoCzIYLmNvbmZpZy5mb3Jtcy5JbnRha2VGb3JtUgVmb3'
    'Jtcw==');

@$core.Deprecated('Use formListRequestDescriptor instead')
const FormListRequest$json = {
  '1': 'FormListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `FormListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formListRequestDescriptor = $convert.base64Decode(
    'Cg9Gb3JtTGlzdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use formUpdateRequestDescriptor instead')
const FormUpdateRequest$json = {
  '1': 'FormUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'form_id', '3': 2, '4': 1, '5': 9, '10': 'formId'},
    {'1': 'changed', '3': 3, '4': 3, '5': 9, '10': 'changed'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'rotate_token', '3': 5, '4': 1, '5': 8, '10': 'rotateToken'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'form_fields',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.config.forms.IntakeField',
      '10': 'formFields'
    },
    {'1': 'status_id', '3': 9, '4': 1, '5': 9, '10': 'statusId'},
    {'1': 'priority', '3': 10, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'assignee_ids', '3': 11, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'enabled', '3': 12, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'require_email', '3': 13, '4': 1, '5': 8, '10': 'requireEmail'},
    {
      '1': 'send_confirmation',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'sendConfirmation'
    },
    {'1': 'notify_status', '3': 15, '4': 1, '5': 8, '10': 'notifyStatus'},
    {'1': 'brand_color', '3': 16, '4': 1, '5': 9, '10': 'brandColor'},
    {'1': 'logo_url', '3': 17, '4': 1, '5': 9, '10': 'logoUrl'},
    {
      '1': 'field_defaults',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.config.forms.FieldDefault',
      '10': 'fieldDefaults'
    },
  ],
};

/// Descriptor for `FormUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List formUpdateRequestDescriptor = $convert.base64Decode(
    'ChFGb3JtVXBkYXRlUmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZUlkEh'
    'cKB2Zvcm1faWQYAiABKAlSBmZvcm1JZBIYCgdjaGFuZ2VkGAMgAygJUgdjaGFuZ2VkEikKEGV4'
    'cGVjdGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhIhCgxyb3RhdGVfdG9rZW4YBS'
    'ABKAhSC3JvdGF0ZVRva2VuEhIKBG5hbWUYBiABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YByAB'
    'KAlSC2Rlc2NyaXB0aW9uEjoKC2Zvcm1fZmllbGRzGAggAygLMhkuY29uZmlnLmZvcm1zLkludG'
    'FrZUZpZWxkUgpmb3JtRmllbGRzEhsKCXN0YXR1c19pZBgJIAEoCVIIc3RhdHVzSWQSGgoIcHJp'
    'b3JpdHkYCiABKAlSCHByaW9yaXR5EiEKDGFzc2lnbmVlX2lkcxgLIAMoCVILYXNzaWduZWVJZH'
    'MSGAoHZW5hYmxlZBgMIAEoCFIHZW5hYmxlZBIjCg1yZXF1aXJlX2VtYWlsGA0gASgIUgxyZXF1'
    'aXJlRW1haWwSKwoRc2VuZF9jb25maXJtYXRpb24YDiABKAhSEHNlbmRDb25maXJtYXRpb24SIw'
    'oNbm90aWZ5X3N0YXR1cxgPIAEoCFIMbm90aWZ5U3RhdHVzEh8KC2JyYW5kX2NvbG9yGBAgASgJ'
    'UgpicmFuZENvbG9yEhkKCGxvZ29fdXJsGBEgASgJUgdsb2dvVXJsEkEKDmZpZWxkX2RlZmF1bH'
    'RzGBIgAygLMhouY29uZmlnLmZvcm1zLkZpZWxkRGVmYXVsdFINZmllbGREZWZhdWx0cw==');

@$core.Deprecated('Use intakeFieldDescriptor instead')
const IntakeField$json = {
  '1': 'IntakeField',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'help', '3': 4, '4': 1, '5': 9, '10': 'help'},
    {'1': 'required', '3': 5, '4': 1, '5': 8, '10': 'required'},
    {'1': 'custom_field_id', '3': 6, '4': 1, '5': 9, '10': 'customFieldId'},
    {'1': 'max_files', '3': 7, '4': 1, '5': 5, '10': 'maxFiles'},
  ],
};

/// Descriptor for `IntakeField`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List intakeFieldDescriptor = $convert.base64Decode(
    'CgtJbnRha2VGaWVsZBIOCgJpZBgBIAEoCVICaWQSEgoEa2luZBgCIAEoCVIEa2luZBIUCgVsYW'
    'JlbBgDIAEoCVIFbGFiZWwSEgoEaGVscBgEIAEoCVIEaGVscBIaCghyZXF1aXJlZBgFIAEoCFII'
    'cmVxdWlyZWQSJgoPY3VzdG9tX2ZpZWxkX2lkGAYgASgJUg1jdXN0b21GaWVsZElkEhsKCW1heF'
    '9maWxlcxgHIAEoBVIIbWF4RmlsZXM=');

@$core.Deprecated('Use intakeFormDescriptor instead')
const IntakeForm$json = {
  '1': 'IntakeForm',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workspace_id', '3': 2, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'token', '3': 6, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'form_fields',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.config.forms.IntakeField',
      '10': 'formFields'
    },
    {'1': 'status_id', '3': 8, '4': 1, '5': 9, '10': 'statusId'},
    {'1': 'priority', '3': 9, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'assignee_ids', '3': 10, '4': 3, '5': 9, '10': 'assigneeIds'},
    {'1': 'enabled', '3': 11, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'require_email', '3': 12, '4': 1, '5': 8, '10': 'requireEmail'},
    {
      '1': 'send_confirmation',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'sendConfirmation'
    },
    {'1': 'notify_status', '3': 14, '4': 1, '5': 8, '10': 'notifyStatus'},
    {'1': 'brand_color', '3': 15, '4': 1, '5': 9, '10': 'brandColor'},
    {'1': 'logo_url', '3': 16, '4': 1, '5': 9, '10': 'logoUrl'},
    {'1': 'version', '3': 17, '4': 1, '5': 5, '10': 'version'},
    {'1': 'submission_count', '3': 18, '4': 1, '5': 5, '10': 'submissionCount'},
    {'1': 'problem', '3': 19, '4': 1, '5': 9, '10': 'problem'},
    {'1': 'owner_id', '3': 20, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'created_at', '3': 21, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 22, '4': 1, '5': 9, '10': 'updatedAt'},
    {
      '1': 'field_defaults',
      '3': 23,
      '4': 3,
      '5': 11,
      '6': '.config.forms.FieldDefault',
      '10': 'fieldDefaults'
    },
  ],
};

/// Descriptor for `IntakeForm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List intakeFormDescriptor = $convert.base64Decode(
    'CgpJbnRha2VGb3JtEg4KAmlkGAEgASgJUgJpZBIhCgx3b3Jrc3BhY2VfaWQYAiABKAlSC3dvcm'
    'tzcGFjZUlkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJZBISCgRuYW1lGAQgASgJUgRu'
    'YW1lEiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcmlwdGlvbhIUCgV0b2tlbhgGIAEoCVIFdG'
    '9rZW4SOgoLZm9ybV9maWVsZHMYByADKAsyGS5jb25maWcuZm9ybXMuSW50YWtlRmllbGRSCmZv'
    'cm1GaWVsZHMSGwoJc3RhdHVzX2lkGAggASgJUghzdGF0dXNJZBIaCghwcmlvcml0eRgJIAEoCV'
    'IIcHJpb3JpdHkSIQoMYXNzaWduZWVfaWRzGAogAygJUgthc3NpZ25lZUlkcxIYCgdlbmFibGVk'
    'GAsgASgIUgdlbmFibGVkEiMKDXJlcXVpcmVfZW1haWwYDCABKAhSDHJlcXVpcmVFbWFpbBIrCh'
    'FzZW5kX2NvbmZpcm1hdGlvbhgNIAEoCFIQc2VuZENvbmZpcm1hdGlvbhIjCg1ub3RpZnlfc3Rh'
    'dHVzGA4gASgIUgxub3RpZnlTdGF0dXMSHwoLYnJhbmRfY29sb3IYDyABKAlSCmJyYW5kQ29sb3'
    'ISGQoIbG9nb191cmwYECABKAlSB2xvZ29VcmwSGAoHdmVyc2lvbhgRIAEoBVIHdmVyc2lvbhIp'
    'ChBzdWJtaXNzaW9uX2NvdW50GBIgASgFUg9zdWJtaXNzaW9uQ291bnQSGAoHcHJvYmxlbRgTIA'
    'EoCVIHcHJvYmxlbRIZCghvd25lcl9pZBgUIAEoCVIHb3duZXJJZBIdCgpjcmVhdGVkX2F0GBUg'
    'ASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgWIAEoCVIJdXBkYXRlZEF0EkEKDmZpZWxkX2'
    'RlZmF1bHRzGBcgAygLMhouY29uZmlnLmZvcm1zLkZpZWxkRGVmYXVsdFINZmllbGREZWZhdWx0'
    'cw==');

@$core.Deprecated('Use intakeSubmissionDescriptor instead')
const IntakeSubmission$json = {
  '1': 'IntakeSubmission',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'form_id', '3': 2, '4': 1, '5': 9, '10': 'formId'},
    {'1': 'reference', '3': 3, '4': 1, '5': 9, '10': 'reference'},
    {'1': 'project_id', '3': 4, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 5, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'task_key', '3': 6, '4': 1, '5': 9, '10': 'taskKey'},
    {'1': 'task_title', '3': 7, '4': 1, '5': 9, '10': 'taskTitle'},
    {'1': 'status_name', '3': 8, '4': 1, '5': 9, '10': 'statusName'},
    {'1': 'submitter_email', '3': 9, '4': 1, '5': 9, '10': 'submitterEmail'},
    {'1': 'at', '3': 10, '4': 1, '5': 9, '10': 'at'},
  ],
};

/// Descriptor for `IntakeSubmission`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List intakeSubmissionDescriptor = $convert.base64Decode(
    'ChBJbnRha2VTdWJtaXNzaW9uEg4KAmlkGAEgASgJUgJpZBIXCgdmb3JtX2lkGAIgASgJUgZmb3'
    'JtSWQSHAoJcmVmZXJlbmNlGAMgASgJUglyZWZlcmVuY2USHQoKcHJvamVjdF9pZBgEIAEoCVIJ'
    'cHJvamVjdElkEhcKB3Rhc2tfaWQYBSABKAlSBnRhc2tJZBIZCgh0YXNrX2tleRgGIAEoCVIHdG'
    'Fza0tleRIdCgp0YXNrX3RpdGxlGAcgASgJUgl0YXNrVGl0bGUSHwoLc3RhdHVzX25hbWUYCCAB'
    'KAlSCnN0YXR1c05hbWUSJwoPc3VibWl0dGVyX2VtYWlsGAkgASgJUg5zdWJtaXR0ZXJFbWFpbB'
    'IOCgJhdBgKIAEoCVICYXQ=');

@$core.Deprecated('Use submissionListDescriptor instead')
const SubmissionList$json = {
  '1': 'SubmissionList',
  '2': [
    {
      '1': 'submissions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.forms.IntakeSubmission',
      '10': 'submissions'
    },
    {'1': 'cursor', '3': 2, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `SubmissionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submissionListDescriptor = $convert.base64Decode(
    'Cg5TdWJtaXNzaW9uTGlzdBJACgtzdWJtaXNzaW9ucxgBIAMoCzIeLmNvbmZpZy5mb3Jtcy5Jbn'
    'Rha2VTdWJtaXNzaW9uUgtzdWJtaXNzaW9ucxIWCgZjdXJzb3IYAiABKAlSBmN1cnNvcg==');

@$core.Deprecated('Use submissionsRequestDescriptor instead')
const SubmissionsRequest$json = {
  '1': 'SubmissionsRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'form_id', '3': 2, '4': 1, '5': 9, '10': 'formId'},
    {'1': 'before', '3': 3, '4': 1, '5': 9, '10': 'before'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `SubmissionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submissionsRequestDescriptor = $convert.base64Decode(
    'ChJTdWJtaXNzaW9uc1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IXCgdmb3JtX2lkGAIgASgJUgZmb3JtSWQSFgoGYmVmb3JlGAMgASgJUgZiZWZvcmUSFAoFbGlt'
    'aXQYBCABKAVSBWxpbWl0');
