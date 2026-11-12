import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/gen/infrastructure/customfields/grpc/customfields.pbgrpc.dart'
    as pb;

abstract interface class FieldsClient {
  /// The active fields in order; [includeArchived] adds the restorable ones
  /// (needs `project.update`).
  Future<List<CustomField>> list(
    String workspaceId,
    String projectId, {
    bool includeArchived = false,
  });

  Future<CustomField> create(
    String workspaceId,
    String projectId,
    FieldDraft draft,
  );

  /// Saves [draft] over [field]. [remap] says what the values of a removed
  /// option become (option id -> kept option id, or empty to clear them).
  Future<CustomField> update(
    String workspaceId,
    CustomField field,
    FieldDraft draft, {
    Map<String, String> remap = const {},
  });

  Future<List<CustomField>> reorder(
    String workspaceId,
    String projectId,
    List<String> ids,
  );

  Future<CustomField> archive(String workspaceId, CustomField field);
  Future<CustomField> restore(String workspaceId, CustomField field);
}

Map<String, int> _usage(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map) return const {};
    return {
      for (final e in decoded.entries) '${e.key}': (e.value as num).toInt(),
    };
  } on FormatException {
    return const {};
  }
}

List<String> _ids(String json) {
  try {
    final decoded = jsonDecode(json);
    return decoded is List ? [for (final e in decoded) '$e'] : const [];
  } on FormatException {
    return const [];
  }
}

FieldException mapFieldError(Object error) {
  if (error is FieldException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => FieldException(
        FieldFailure.denied,
        detail: denied.message,
      ),
      StatusCode.permissionDenied => const FieldException(
        FieldFailure.forbidden,
      ),
      StatusCode.alreadyExists when title == 'PROJECT_ARCHIVED' =>
        const FieldException(FieldFailure.archived),
      StatusCode.alreadyExists when title == 'FIELD_NAME_TAKEN' =>
        const FieldException(FieldFailure.nameTaken),
      StatusCode.failedPrecondition when title == 'OPTION_NEEDS_REMAP' =>
        FieldException(
          FieldFailure.needsRemap,
          usage: _usage(errorTrailer(error, 'x-error-options-bin')),
        ),
      StatusCode.invalidArgument when title == 'FIELD_LIMIT' =>
        const FieldException(FieldFailure.limit),
      StatusCode.invalidArgument when title == 'FIELD_REQUIRED' =>
        FieldException(
          FieldFailure.required,
          detail: stripErrorTitle(message),
          fieldIds: _ids(errorTrailer(error, 'x-error-fields-bin')),
        ),
      StatusCode.invalidArgument => FieldException(
        FieldFailure.invalid,
        detail: stripErrorTitle(message),
      ),
      StatusCode.notFound => const FieldException(FieldFailure.notFound),
      StatusCode.aborted => const FieldException(FieldFailure.conflict),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const FieldException(FieldFailure.network),
      _ => const FieldException(FieldFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const FieldException(FieldFailure.network);
  }
  return const FieldException(FieldFailure.other);
}

/// The domain field for a server message.
CustomField fieldFromPb(pb.Field f) => CustomField(
  id: f.id,
  projectId: f.projectId,
  name: f.name,
  type: FieldType.parse(f.type),
  options: [
    for (final o in f.options)
      FieldOption(id: o.id, label: o.label, color: o.color),
  ],
  required: f.required,
  defaultValue: f.default_7,
  hiddenViews: List.unmodifiable(f.hiddenViews),
  position: f.position,
  version: f.version,
  archivedAt: f.archivedAt,
);

class GrpcFieldsClient implements FieldsClient {
  GrpcFieldsClient(
    ClientChannelBase channel,
    this._session, {
    this.onRefusal,
    this.cache,
  }) : _stub = pb.FieldControllerClient(channel);

  final pb.FieldControllerClient _stub;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

  /// Keeps the last list for when the server cannot be reached.
  final ReadCache? cache;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapFieldError(e);
      if (!isRead &&
          (mapped.failure == FieldFailure.denied ||
              mapped.failure == FieldFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  List<pb.FieldOption> _optionsOf(FieldDraft d) => [
    for (final o in d.options)
      pb.FieldOption(id: o.id, label: o.label.trim(), color: o.color),
  ];

  @override
  Future<List<CustomField>> list(
    String workspaceId,
    String projectId, {
    bool includeArchived = false,
  }) async {
    final reply = await _run(
      () => readThrough(
        cache,
        workspaceId,
        'fields:$projectId:$includeArchived',
        () => _stub.list(
          pb.FieldListRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            includeArchived: includeArchived,
          ),
          options: _options,
        ),
        pb.FieldList.fromBuffer,
      ),
      isRead: true,
    );
    return [for (final f in reply.fields) fieldFromPb(f)];
  }

  @override
  Future<CustomField> create(
    String workspaceId,
    String projectId,
    FieldDraft draft,
  ) async => fieldFromPb(
    await _run(
      () => _stub.create(
        pb.FieldCreateRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          name: draft.name.trim(),
          type: draft.type.wire,
          options: _optionsOf(draft),
          required: draft.required,
          default_7: draft.defaultValue,
          hiddenViews: draft.hiddenViews,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<CustomField> update(
    String workspaceId,
    CustomField field,
    FieldDraft draft, {
    Map<String, String> remap = const {},
  }) async => fieldFromPb(
    await _run(
      () => _stub.update(
        pb.FieldUpdateRequest(
          workspaceId: workspaceId,
          projectId: field.projectId,
          id: field.id,
          expectedVersion: field.version,
          name: draft.name.trim(),
          type: draft.type.wire,
          required: draft.required,
          default_7: draft.defaultValue,
          setOptions: true,
          options: _optionsOf(draft),
          setHiddenViews: true,
          hiddenViews: draft.hiddenViews,
          remaps: [
            for (final e in remap.entries)
              pb.OptionRemap(fromOption: e.key, toOption: e.value),
          ],
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<CustomField>> reorder(
    String workspaceId,
    String projectId,
    List<String> ids,
  ) async {
    final reply = await _run(
      () => _stub.reorder(
        pb.FieldReorderRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          ids: ids,
        ),
        options: _options,
      ),
    );
    return [for (final f in reply.fields) fieldFromPb(f)];
  }

  @override
  Future<CustomField> archive(String workspaceId, CustomField field) async =>
      fieldFromPb(
        await _run(
          () => _stub.archive(
            pb.FieldArchiveRequest(
              workspaceId: workspaceId,
              projectId: field.projectId,
              id: field.id,
              expectedVersion: field.version,
            ),
            options: _options,
          ),
        ),
      );

  @override
  Future<CustomField> restore(String workspaceId, CustomField field) async =>
      fieldFromPb(
        await _run(
          () => _stub.restore(
            pb.FieldRestoreRequest(
              workspaceId: workspaceId,
              projectId: field.projectId,
              id: field.id,
              expectedVersion: field.version,
            ),
            options: _options,
          ),
        ),
      );
}
