// This is a generated file - do not edit.
//
// Generated from infrastructure/templates/grpc/templates.proto.

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

@$core.Deprecated('Use templateDescriptor instead')
const Template$json = {
  '1': 'Template',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visibility', '3': 5, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'builtin', '3': 6, '4': 1, '5': 8, '10': 'builtin'},
    {'1': 'created_by', '3': 7, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {'1': 'task_count', '3': 11, '4': 1, '5': 5, '10': 'taskCount'},
    {'1': 'variables', '3': 12, '4': 3, '5': 9, '10': 'variables'},
    {'1': 'includes', '3': 13, '4': 3, '5': 9, '10': 'includes'},
    {'1': 'status_names', '3': 14, '4': 3, '5': 9, '10': 'statusNames'},
    {'1': 'can_edit', '3': 15, '4': 1, '5': 8, '10': 'canEdit'},
    {'1': 'content_json', '3': 16, '4': 1, '5': 9, '10': 'contentJson'},
  ],
};

/// Descriptor for `Template`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateDescriptor = $convert.base64Decode(
    'CghUZW1wbGF0ZRIOCgJpZBgBIAEoCVICaWQSEgoEa2luZBgCIAEoCVIEa2luZBISCgRuYW1lGA'
    'MgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAQgASgJUgtkZXNjcmlwdGlvbhIeCgp2aXNpYmls'
    'aXR5GAUgASgJUgp2aXNpYmlsaXR5EhgKB2J1aWx0aW4YBiABKAhSB2J1aWx0aW4SHQoKY3JlYX'
    'RlZF9ieRgHIAEoCVIJY3JlYXRlZEJ5Eh0KCmNyZWF0ZWRfYXQYCCABKAlSCWNyZWF0ZWRBdBId'
    'Cgp1cGRhdGVkX2F0GAkgASgJUgl1cGRhdGVkQXQSGAoHdmVyc2lvbhgKIAEoBVIHdmVyc2lvbh'
    'IdCgp0YXNrX2NvdW50GAsgASgFUgl0YXNrQ291bnQSHAoJdmFyaWFibGVzGAwgAygJUgl2YXJp'
    'YWJsZXMSGgoIaW5jbHVkZXMYDSADKAlSCGluY2x1ZGVzEiEKDHN0YXR1c19uYW1lcxgOIAMoCV'
    'ILc3RhdHVzTmFtZXMSGQoIY2FuX2VkaXQYDyABKAhSB2NhbkVkaXQSIQoMY29udGVudF9qc29u'
    'GBAgASgJUgtjb250ZW50SnNvbg==');

@$core.Deprecated('Use templateAnswerDescriptor instead')
const TemplateAnswer$json = {
  '1': 'TemplateAnswer',
  '2': [
    {
      '1': 'template',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.config.templates.Template',
      '10': 'template'
    },
  ],
};

/// Descriptor for `TemplateAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateAnswerDescriptor = $convert.base64Decode(
    'Cg5UZW1wbGF0ZUFuc3dlchI2Cgh0ZW1wbGF0ZRgBIAEoCzIaLmNvbmZpZy50ZW1wbGF0ZXMuVG'
    'VtcGxhdGVSCHRlbXBsYXRl');

@$core.Deprecated('Use templateAppliedDescriptor instead')
const TemplateApplied$json = {
  '1': 'TemplateApplied',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_ids', '3': 2, '4': 3, '5': 9, '10': 'taskIds'},
    {
      '1': 'warnings',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.config.templates.Warning',
      '10': 'warnings'
    },
  ],
};

/// Descriptor for `TemplateApplied`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateAppliedDescriptor = $convert.base64Decode(
    'Cg9UZW1wbGF0ZUFwcGxpZWQSHQoKcHJvamVjdF9pZBgBIAEoCVIJcHJvamVjdElkEhkKCHRhc2'
    'tfaWRzGAIgAygJUgd0YXNrSWRzEjUKCHdhcm5pbmdzGAMgAygLMhkuY29uZmlnLnRlbXBsYXRl'
    'cy5XYXJuaW5nUgh3YXJuaW5ncw==');

@$core.Deprecated('Use templateApplyRequestDescriptor instead')
const TemplateApplyRequest$json = {
  '1': 'TemplateApplyRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'template_id', '3': 2, '4': 1, '5': 9, '10': 'templateId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'parent_task_id', '3': 4, '4': 1, '5': 9, '10': 'parentTaskId'},
    {'1': 'project_name', '3': 5, '4': 1, '5': 9, '10': 'projectName'},
    {'1': 'project_key', '3': 6, '4': 1, '5': 9, '10': 'projectKey'},
    {
      '1': 'project_description',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'projectDescription'
    },
    {'1': 'project_icon', '3': 8, '4': 1, '5': 9, '10': 'projectIcon'},
    {'1': 'project_color', '3': 9, '4': 1, '5': 9, '10': 'projectColor'},
    {
      '1': 'project_visibility',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'projectVisibility'
    },
    {'1': 'start_date', '3': 11, '4': 1, '5': 9, '10': 'startDate'},
    {
      '1': 'variables',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.config.templates.Variable',
      '10': 'variables'
    },
  ],
};

/// Descriptor for `TemplateApplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateApplyRequestDescriptor = $convert.base64Decode(
    'ChRUZW1wbGF0ZUFwcGx5UmVxdWVzdBIhCgx3b3Jrc3BhY2VfaWQYASABKAlSC3dvcmtzcGFjZU'
    'lkEh8KC3RlbXBsYXRlX2lkGAIgASgJUgp0ZW1wbGF0ZUlkEh0KCnByb2plY3RfaWQYAyABKAlS'
    'CXByb2plY3RJZBIkCg5wYXJlbnRfdGFza19pZBgEIAEoCVIMcGFyZW50VGFza0lkEiEKDHByb2'
    'plY3RfbmFtZRgFIAEoCVILcHJvamVjdE5hbWUSHwoLcHJvamVjdF9rZXkYBiABKAlSCnByb2pl'
    'Y3RLZXkSLwoTcHJvamVjdF9kZXNjcmlwdGlvbhgHIAEoCVIScHJvamVjdERlc2NyaXB0aW9uEi'
    'EKDHByb2plY3RfaWNvbhgIIAEoCVILcHJvamVjdEljb24SIwoNcHJvamVjdF9jb2xvchgJIAEo'
    'CVIMcHJvamVjdENvbG9yEi0KEnByb2plY3RfdmlzaWJpbGl0eRgKIAEoCVIRcHJvamVjdFZpc2'
    'liaWxpdHkSHQoKc3RhcnRfZGF0ZRgLIAEoCVIJc3RhcnREYXRlEjgKCXZhcmlhYmxlcxgMIAMo'
    'CzIaLmNvbmZpZy50ZW1wbGF0ZXMuVmFyaWFibGVSCXZhcmlhYmxlcw==');

@$core.Deprecated('Use templateCreateRequestDescriptor instead')
const TemplateCreateRequest$json = {
  '1': 'TemplateCreateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visibility', '3': 5, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'content_json', '3': 6, '4': 1, '5': 9, '10': 'contentJson'},
  ],
};

/// Descriptor for `TemplateCreateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateCreateRequestDescriptor = $convert.base64Decode(
    'ChVUZW1wbGF0ZUNyZWF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBISCgRraW5kGAIgASgJUgRraW5kEhIKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRp'
    'b24YBCABKAlSC2Rlc2NyaXB0aW9uEh4KCnZpc2liaWxpdHkYBSABKAlSCnZpc2liaWxpdHkSIQ'
    'oMY29udGVudF9qc29uGAYgASgJUgtjb250ZW50SnNvbg==');

@$core.Deprecated('Use templateDeleteRequestDescriptor instead')
const TemplateDeleteRequest$json = {
  '1': 'TemplateDeleteRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'template_id', '3': 2, '4': 1, '5': 9, '10': 'templateId'},
  ],
};

/// Descriptor for `TemplateDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateDeleteRequestDescriptor = $convert.base64Decode(
    'ChVUZW1wbGF0ZURlbGV0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIfCgt0ZW1wbGF0ZV9pZBgCIAEoCVIKdGVtcGxhdGVJZA==');

@$core.Deprecated('Use templateDeletedDescriptor instead')
const TemplateDeleted$json = {
  '1': 'TemplateDeleted',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `TemplateDeleted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateDeletedDescriptor =
    $convert.base64Decode('Cg9UZW1wbGF0ZURlbGV0ZWQSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use templateGetRequestDescriptor instead')
const TemplateGetRequest$json = {
  '1': 'TemplateGetRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'template_id', '3': 2, '4': 1, '5': 9, '10': 'templateId'},
  ],
};

/// Descriptor for `TemplateGetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateGetRequestDescriptor = $convert.base64Decode(
    'ChJUZW1wbGF0ZUdldFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2VJZB'
    'IfCgt0ZW1wbGF0ZV9pZBgCIAEoCVIKdGVtcGxhdGVJZA==');

@$core.Deprecated('Use templateListDescriptor instead')
const TemplateList$json = {
  '1': 'TemplateList',
  '2': [
    {
      '1': 'templates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.config.templates.Template',
      '10': 'templates'
    },
  ],
};

/// Descriptor for `TemplateList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateListDescriptor = $convert.base64Decode(
    'CgxUZW1wbGF0ZUxpc3QSOAoJdGVtcGxhdGVzGAEgAygLMhouY29uZmlnLnRlbXBsYXRlcy5UZW'
    '1wbGF0ZVIJdGVtcGxhdGVz');

@$core.Deprecated('Use templateListRequestDescriptor instead')
const TemplateListRequest$json = {
  '1': 'TemplateListRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `TemplateListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateListRequestDescriptor = $convert.base64Decode(
    'ChNUZW1wbGF0ZUxpc3RSZXF1ZXN0EiEKDHdvcmtzcGFjZV9pZBgBIAEoCVILd29ya3NwYWNlSW'
    'QSFAoFcXVlcnkYAiABKAlSBXF1ZXJ5EhIKBGtpbmQYAyABKAlSBGtpbmQ=');

@$core.Deprecated('Use templateSaveFromProjectRequestDescriptor instead')
const TemplateSaveFromProjectRequest$json = {
  '1': 'TemplateSaveFromProjectRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visibility', '3': 5, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'include', '3': 6, '4': 3, '5': 9, '10': 'include'},
    {
      '1': 'include_assignees',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'includeAssignees'
    },
  ],
};

/// Descriptor for `TemplateSaveFromProjectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateSaveFromProjectRequestDescriptor = $convert.base64Decode(
    'Ch5UZW1wbGF0ZVNhdmVGcm9tUHJvamVjdFJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUg'
    't3b3Jrc3BhY2VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSEgoEbmFtZRgDIAEo'
    'CVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SHgoKdmlzaWJpbGl0eR'
    'gFIAEoCVIKdmlzaWJpbGl0eRIYCgdpbmNsdWRlGAYgAygJUgdpbmNsdWRlEisKEWluY2x1ZGVf'
    'YXNzaWduZWVzGAcgASgIUhBpbmNsdWRlQXNzaWduZWVz');

@$core.Deprecated('Use templateSaveFromTaskRequestDescriptor instead')
const TemplateSaveFromTaskRequest$json = {
  '1': 'TemplateSaveFromTaskRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'task_id', '3': 3, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visibility', '3': 6, '4': 1, '5': 9, '10': 'visibility'},
    {
      '1': 'include_assignees',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'includeAssignees'
    },
  ],
};

/// Descriptor for `TemplateSaveFromTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateSaveFromTaskRequestDescriptor = $convert.base64Decode(
    'ChtUZW1wbGF0ZVNhdmVGcm9tVGFza1JlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3'
    'Jrc3BhY2VJZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSFwoHdGFza19pZBgDIAEo'
    'CVIGdGFza0lkEhIKBG5hbWUYBCABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBSABKAlSC2Rlc2'
    'NyaXB0aW9uEh4KCnZpc2liaWxpdHkYBiABKAlSCnZpc2liaWxpdHkSKwoRaW5jbHVkZV9hc3Np'
    'Z25lZXMYByABKAhSEGluY2x1ZGVBc3NpZ25lZXM=');

@$core.Deprecated('Use templateUpdateRequestDescriptor instead')
const TemplateUpdateRequest$json = {
  '1': 'TemplateUpdateRequest',
  '2': [
    {'1': 'workspace_id', '3': 1, '4': 1, '5': 9, '10': 'workspaceId'},
    {'1': 'template_id', '3': 2, '4': 1, '5': 9, '10': 'templateId'},
    {'1': 'changed', '3': 3, '4': 3, '5': 9, '10': 'changed'},
    {'1': 'expected_version', '3': 4, '4': 1, '5': 5, '10': 'expectedVersion'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visibility', '3': 7, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'content_json', '3': 8, '4': 1, '5': 9, '10': 'contentJson'},
  ],
};

/// Descriptor for `TemplateUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateUpdateRequestDescriptor = $convert.base64Decode(
    'ChVUZW1wbGF0ZVVwZGF0ZVJlcXVlc3QSIQoMd29ya3NwYWNlX2lkGAEgASgJUgt3b3Jrc3BhY2'
    'VJZBIfCgt0ZW1wbGF0ZV9pZBgCIAEoCVIKdGVtcGxhdGVJZBIYCgdjaGFuZ2VkGAMgAygJUgdj'
    'aGFuZ2VkEikKEGV4cGVjdGVkX3ZlcnNpb24YBCABKAVSD2V4cGVjdGVkVmVyc2lvbhISCgRuYW'
    '1lGAUgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAYgASgJUgtkZXNjcmlwdGlvbhIeCgp2aXNp'
    'YmlsaXR5GAcgASgJUgp2aXNpYmlsaXR5EiEKDGNvbnRlbnRfanNvbhgIIAEoCVILY29udGVudE'
    'pzb24=');

@$core.Deprecated('Use variableDescriptor instead')
const Variable$json = {
  '1': 'Variable',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Variable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List variableDescriptor = $convert.base64Decode(
    'CghWYXJpYWJsZRISCgRuYW1lGAEgASgJUgRuYW1lEhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use warningDescriptor instead')
const Warning$json = {
  '1': 'Warning',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Warning`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List warningDescriptor = $convert.base64Decode(
    'CgdXYXJuaW5nEhIKBGNvZGUYASABKAlSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ'
    '==');
